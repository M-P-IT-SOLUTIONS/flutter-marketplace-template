import 'dart:async';
import 'dart:ui' as ui;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:randki/models/place.dart';
import 'package:randki/services/fetch_response.dart';
import 'package:randki/services/places_service.dart';
import 'package:randki/view_models/filter_view_model.dart';

/// ViewModel responsible for managing places on the map
/// Responsible for fetching places, setting markers, and handling user location
/// Used in the map screen and main app screen.
class PlacesModel extends ChangeNotifier {
  final IPlacesService _placesService;
  final FilterViewModel filter;

  PlacesModel(this._placesService, this.filter) {
    _setDefaultUserIcon();
    _setDefaultCircleResizeIcon();
  }

  Set<Marker> _markers = {};
  List<Place> _places = [];
  Marker? userMarker;

  /// Cache for marker icons to avoid fetching the same ones multiple times
  final _iconCache = <String, BitmapDescriptor>{};
  void Function(LatLng)? onUserLocationChanged;
  StreamSubscription<Position>? positionStream;
  BitmapDescriptor? _userIcon;
  BitmapDescriptor? circleResizeIcon;
  bool followUserLocation = true;
  bool _isLoading = false;
  final int _pageSize = 20; // number of places per page
  int _pageNumber = 1; // current page number
  bool _thereIsMore = true; // whether there are more places to fetch in the database
  bool abandonFetchingPlaces = false;

  /// Currently ongoing place fetch
  Future<void>? _currentFetch;
  bool _buildingMarkers = false;
  bool _hasErrors = false;
  String? _error;

  Set<Marker> get markers => _markers;
  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  bool get buildingMarkers => _buildingMarkers;
  bool get hasErrors => _hasErrors;
  int get pageSize => _pageSize;
  int get pageNumber => _pageNumber;
  bool get thereIsMore => _thereIsMore;
  String? get error => _error;

  /// Fetches filtered places from the database
  /// If called during an ongoing fetch, returns the previous future (only one request at a time)
  /// The [buildMarkers] flag determines whether to build markers based on the passed context
  Future<void> fetchFilteredPlaces({
    required bool buildMarkers,
    required BuildContext context,
    bool getAll = false
  }) async {
    if (_currentFetch != null) {
      return _currentFetch;
    }

    // no more places to fetch
    if (!_thereIsMore) {
      return; 
    }

    final completer = Completer<void>();
    _currentFetch = completer.future;

    if (_isLoading) {
      return _currentFetch;
    }

    _isLoading = true;
    _hasErrors = false;
    notifyListeners();

    if (filter.selectedMaxPrice != null &&
        filter.selectedMinPrice != null &&
        filter.selectedMaxPrice! < filter.selectedMinPrice!) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    Future<void> _fetchHelper() async {
      final response = await _placesService.fetchFilteredPlaces(filter: filter, context: context, pageSize: _pageSize, pageNumber: _pageNumber);

      if (response is FetchListSuccess<Place>) {
        if (response.items.length < _pageSize) {
          _thereIsMore = false;
        } else {
          increasePageNumber();
        }
        _places.addAll(response.items);
        debugPrint(_places.toString());
        _hasErrors = false;

        // building markers
        if (buildMarkers && !_buildingMarkers) {
          await makeMarkers(newPlaces: response.items, context: context);
        }
      } else if (response is FetchListFailure<Place>) {
        debugPrint('Error: ${response.message}');
        _hasErrors = true;
        _error = response.message;
      }
    }

    try {
      if (getAll) {
        // fetch everything in layers
        while (_thereIsMore && !abandonFetchingPlaces) {
          await _fetchHelper();
        }
        abandonFetchingPlaces = false;
      } else {
        // fetch one page
        await _fetchHelper();
      }
    } catch (e) {
      _hasErrors = true;
      _error = 'fetchFilteredPlaces fatal: $e';
      debugPrint('fetchFilteredPlaces fatal: $e');
    } finally {
      _isLoading = false;
      completer.complete();
      _currentFetch = null;
      notifyListeners();
    }
  }

  /// Creates markers for places
  Future<void> makeMarkers({List<Place>? newPlaces, required BuildContext context}) async {
    if (_buildingMarkers) {
      return; // already building markers
    }

    // safety check in case marker creation is called without places
    if (_places.isEmpty && (newPlaces == null || newPlaces.isEmpty)) {
      _markers = {};
      _buildingMarkers = false;
      notifyListeners();
      return;
    }

    _buildingMarkers = true;
    notifyListeners();

    // if no new places provided, build markers for all
    if (newPlaces == null) {
      _markers = {};
      newPlaces = _places;
    }

    try {
      // Fetch icons in parallel (fetch all at once)
      final futures =
          newPlaces.map((place) async {
            BitmapDescriptor icon;
            try {
              icon = await _bitmapDescriptorFromUrl(place.profilePicture);
            } catch (_) {
              icon = BitmapDescriptor.defaultMarker;
            }
            return place.toMarker(context, icon);
          }).toList();

      final result = await Future.wait(futures);
      _markers.addAll(result.toSet());
    } catch (e) {
      debugPrint('makeMarkers error: $e');
      _error = 'makeMarkers error: $e';
    } finally {
      _buildingMarkers = false;
      notifyListeners();
    }
  }

  /// Creates a [BitmapDescriptor] icon from a URL
  /// Saves newly created icons in cache
  /// Used to create marker icons on the map
  Future<BitmapDescriptor> _bitmapDescriptorFromUrl(
    String url, {
    int size = 120,
  }) async {
    // if icon was already fetched and is in cache, return it
    if (_iconCache.containsKey(url)) {
      return _iconCache[url]!;
    }
    final http.Response response = await http.get(Uri.parse(url));
    final Uint8List bytes = response.bodyBytes;
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: size,
      targetHeight: size,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    _iconCache[url] = icon; // add icon to cache
    return icon;
  }

  /// Creates user marker at current position
  Future<void> setUserMarker() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // No permission, don't set marker
        userMarker = null;
        notifyListeners();
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (_userIcon == null) {
      await _setDefaultUserIcon();
    }
    filter.setUserLocation(LatLng(position.latitude, position.longitude));
    userMarker = Marker(
      markerId: const MarkerId('user_marker'),
      position: LatLng(position.latitude, position.longitude),
      draggable: true,
      icon: _userIcon!,
      onDrag: (LatLng pos) {
        userMarker = userMarker!.copyWith(positionParam: pos);
        filter.setUserLocation(pos);
        notifyListeners();
      },
      onDragEnd: (LatLng newPosition) {
        // handle marker drag
        userMarker = userMarker!.copyWith(positionParam: newPosition);
        filter.setUserLocation(newPosition);
        notifyListeners();
      },
    );
    filter.setSearchNearbyUser(true);
    notifyListeners();
  }

  /// Sets user marker to current position
  /// Sets searchNearbyUser to true when successful
  Future<void> updateUserMarker() async {
    if (userMarker == null) {
      await setUserMarker();
    } else {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          // No permission, don't set marker
          userMarker = null;
          notifyListeners();
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      filter.setUserLocation(LatLng(position.latitude, position.longitude));
      userMarker = userMarker!.copyWith(
        positionParam: LatLng(position.latitude, position.longitude),
      );
    }
    filter.setSearchNearbyUser(true);
    notifyListeners();
  }

  /// Initializes stream listening for user location changes
  /// and updates their marker
  Future<void> startUserLocationStream() async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        userMarker = null;
        notifyListeners();
        return;
      }
    }
    if (filter.searchNearbyUser != false) {
      filter.setSearchNearbyUser(true);
    }

    if (_userIcon == null) {
      await _setDefaultUserIcon();
    }
    positionStream?.cancel(); // stop previous stream if any
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // minimum change in meters
      ),
    ).listen((Position position) {
      if (followUserLocation) {
        filter.setUserLocation(LatLng(position.latitude, position.longitude));
        if (userMarker == null) {
          userMarker = Marker(
            markerId: const MarkerId('user_marker'),
            position: LatLng(position.latitude, position.longitude),
            draggable: true,
            icon: _userIcon!,
            onDrag: (LatLng pos) {
              followUserLocation = false;
              userMarker = userMarker!.copyWith(positionParam: pos);
              filter.setUserLocation(pos);
              notifyListeners();
            },
            onDragEnd: (LatLng newPosition) {
              followUserLocation = false; // stop tracking location after drag
              filter.setUserLocation(newPosition);
              userMarker = userMarker!.copyWith(positionParam: newPosition);
              notifyListeners();
            },
          );
        } else {
          userMarker = userMarker!.copyWith(
            positionParam: LatLng(position.latitude, position.longitude),
          );
          filter.setUserLocation(LatLng(position.latitude, position.longitude));
        }
      }
      notifyListeners();
      if (onUserLocationChanged != null && followUserLocation) {
        onUserLocationChanged!(LatLng(position.latitude, position.longitude));
      }
    });
  }

  /// Sets default user icon
  Future<void> _setDefaultUserIcon() async {
    final BitmapDescriptor icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/map/my_location.png',
    );
    _userIcon = icon;
  }

  /// Sets default circle resize icon on map
  Future<void> _setDefaultCircleResizeIcon() async {
    final BitmapDescriptor icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(24, 24)),
      'assets/map/resizeeastwest_100180.png',
    );
    circleResizeIcon = icon;
  }

  /// Stops stream listening for user location changes
  void stopUserLocationStream() {
    positionStream?.cancel();
  }

  /// Safely clears markers
  void clearMarkers() {
    _markers = {};
    notifyListeners();
  }

  void clearPlaces() {
    _places = [];
    resetPageNumber();
    notifyListeners();
  }

  void resetPageNumber() {
    _pageNumber = 1;
    _thereIsMore = true;
    notifyListeners();
  }
  
  void increasePageNumber() {
    _pageNumber += 1;
    notifyListeners();
  }

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void stopFetchingPlaces() {
    abandonFetchingPlaces = true;
  }
}

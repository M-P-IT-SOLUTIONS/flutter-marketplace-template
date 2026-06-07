import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_marketplace_template/services/favorite_places_service.dart';
import 'package:flutter_marketplace_template/models/place.dart';

/// ViewModel managing the user's list of favorite places.
class FavoritePlacesViewModel extends ChangeNotifier {
  final IFavoritePlacesService _favoritePlacesService;

  Set<String> _favorites = <String>{};
  List<Place> _favoritePlaces = <Place>[];
  bool _loading = false;
  final int _pageSize = 5;
  int _pageNumber = 1;
  bool _thereIsMore = true;
  String? _error;
  final Set<String> _pending =
      <String>{}; // protection against multiple simultaneous clicks

  FavoritePlacesViewModel(this._favoritePlacesService) {
    // Listen for auth state changes – reload / clear.
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        // ignore: discarded_futures
        loadFavorites();
      } else {
        clear();
      }
    });

    if (Supabase.instance.client.auth.currentUser != null) {
      // Fire-and-forget initial fetch.
      // ignore: discarded_futures
      loadFavorites();
    }
  }

  bool get isLoading => _loading;
  String? get errorMessage => _error;
  int get favoritesCount => _favorites.length;
  List<Place> get favoritePlaces => _favoritePlaces;
  Set<String> get favorites => _favorites;

  bool isFavorite(String placeId) => _favorites.contains(placeId);

  Future<void> loadFavorites() async {
    if (!_thereIsMore) {
      return;
    }

    if (_loading) return;

    _loading = true;
    _error = null;
    notifyListeners();
    while (_thereIsMore) {
      final response = await _favoritePlacesService
          .fetchFavoritePlacesDetailedForCurrentUser(
            pageSize: _pageSize,
            pageNumber: _pageNumber,
          );
      if (response is FetchListSuccess<Place>) {
        if (response.items.length < _pageSize) {
          _thereIsMore = false;
        } else {
          increasePageNumber();
        }
        _favoritePlaces.addAll(response.items);
        _favorites = _favoritePlaces.map((p) => p.id).toSet();
        _error = null;
      } else if (response is FetchListFailure<Place>) {
        _error = response.message;
      }
    }
    _loading = false;
    notifyListeners();
  }

  /// Optimistic toggle of a favorite place.
  /// If a [place] object is provided, add it locally without full reload.
  /// On server error – rollback the change.
  Future<void> toggleFavorite(String placeId, {Place? place}) async {
    // Block multiple clicks during an ongoing operation for this id
    if (_pending.contains(placeId)) return;
    _pending.add(placeId);

    final wasFav = _favorites.contains(placeId);
    // Backups for potential rollback
    final previousFavorites = Set<String>.from(_favorites);
    final previousFavoritePlaces = List<Place>.from(_favoritePlaces);

    if (wasFav) {
      // Optimistic removal
      _favorites.remove(placeId);
      _favoritePlaces.removeWhere((p) => p.id == placeId);
      notifyListeners();
      final ok = await _favoritePlacesService.removeFavorite(placeId);
      if (!ok) {
        // rollback
        _favorites = previousFavorites;
        _favoritePlaces = previousFavoritePlaces;
        notifyListeners();
      }
    } else {
      // Optimistic addition
      _favorites.add(placeId);
      if (place != null && !_favoritePlaces.any((p) => p.id == placeId)) {
        _favoritePlaces.add(place);
      }
      notifyListeners();
      final ok = await _favoritePlacesService.addFavorite(placeId);
      if (!ok) {
        // rollback
        _favorites = previousFavorites;
        _favoritePlaces = previousFavoritePlaces;
        notifyListeners();
      } else {
        // if we don't have full place data (no place) we could optionally fetch details in background
        // (skipped for performance – to consider later)
      }
    }
    _pending.remove(placeId);
  }

  void increasePageNumber() {
    _pageNumber += 1;
    notifyListeners();
  }

  void clear() {
    _favorites = <String>{};
    _favoritePlaces = <Place>[];
    _pageNumber = 1;
    _thereIsMore = true;
    _error = null;
    notifyListeners();
  }
}

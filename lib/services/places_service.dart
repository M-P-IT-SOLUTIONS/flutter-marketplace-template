import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:randki/functions.dart';
import 'package:randki/main.dart';
import 'package:randki/models/category_tags_enums.dart';
import 'package:randki/models/place.dart';
import 'package:randki/services/fetch_response.dart';
import 'package:randki/services/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get _supabase => Supabase.instance.client;

/// Service for fetching places from the database based on various filters and criteria.
abstract class IPlacesService {
  Future<FetchResponse<Place>> fetchFilteredPlaces({
    required FilterViewModel filter,
    required BuildContext context,
    required int pageSize,
    required int pageNumber,
  });

  Future<FetchResponse<String?>> fetchPlaceName({required String placeId});
  Future<FetchResponse<Map<String, String?>>> fetchPlacesNames({required List<String> ids});
}

/// Service for fetching places from Supabase based on various filters and criteria.
class PlacesServiceSupabase implements IPlacesService {
  static const double earthRadiusMeters = 6371000;
  static const String places = 'places';

  static Future<dynamic> _fetchFilteredWithLocation({
    required FilterViewModel filter,
    required List<Map<String, dynamic>>? categoryTagsJson,
    required LatLng location,
    required int pageSize,
    required int pageNumber,
  }) async {
    return retry(
      () => _supabase.rpc(
        'get_places_with_details_v2',
        params: {
          '_categories':
              filter.selectedCategories.isNotEmpty
                  ? filter.selectedCategories.map((c) => c.name).toList()
                  : null,
          '_category_tags': categoryTagsJson,
          '_lon': location.longitude, // double
          '_lat': location.latitude, // double
          '_radius_m': filter.selectedMaxDistance, // double
          '_price_min': filter.selectedMinPrice, // int
          '_price_max': filter.selectedMaxPrice, // int
          '_order_by':
              filter.orderBy ??
              'overlap', // If sorting is not set, sort by the largest common part of the price (price_overlap)
          '_sort_asc': filter.orderBy != null ? filter.sortAsc : null, // bool
          '_limit': pageSize, // how many records on the page
          '_offset': (pageNumber - 1) * pageSize, // offset
        },
      ),
    );
  }

  static Future<dynamic> _fetchFilteredWithoutLocation({
    required FilterViewModel filter,
    required Map<Category, Set<String>> categoryTagsMap,
    required int pageSize,
    required int pageNumber,
  }) async {
    var querry = _supabase
        .from('places_tags_agg')
        .select('*, date_props(*, date_props_tags(tags(*))))');

    if (filter.selectedCategories.isNotEmpty && filter.selectedTags.isEmpty) {
      querry = querry.inFilter(
        'category',
        filter.selectedCategories.map((c) => c.name).toList(),
      );
    }

    if (filter.selectedCategories.isNotEmpty &&
        filter.selectedTags.isNotEmpty) {
      final List<String> orConditions = [];

      categoryTagsMap.forEach((category, tags) {
        if (tags.isEmpty) {
          // category without tags → any tags in this category
          orConditions.add('category.eq.${category.name}');
        } else {
          // category with tags → any tag from the list
          final tagList = tags.map((t) => '"$t"').join(',');
          orConditions.add(
            'and(category.eq.${category.name},tags.ov.{$tagList})',
          );
        }
      });

      querry = querry.or(orConditions.join(','));
    }

    if (filter.selectedMinPrice != null && filter.selectedMaxPrice != null) {
      querry = querry
          .lte('pricepp_first', filter.selectedMaxPrice!)
          .gte('pricepp_second', filter.selectedMinPrice!);
    }

    querry = querry.filter('deleted_at', 'is', null);

    var querry2 = querry.range(
      (pageNumber - 1) * pageSize,
      pageNumber * pageSize - 1,
    );

    if (filter.orderBy != null && filter.sortAsc != null) {
      if (filter.orderBy == 'price') {
        querry2 = querry2.order('pricepp_first', ascending: filter.sortAsc!);
      }
    }

    return await retry(() => querry2);
  }

  static List<Place> _jsonListToPlaces(
    List<dynamic> response, {
    required bool withDistance,
  }) {
    final parser = withDistance ? Place.fromJsonRPC : Place.fromJsonORM;

    final List<Place> places =
        (response)
            .map((raw) {
              try {
                return parser(raw);
              } catch (e) {
                Log.warning('Failure of JSON parsing: $e');
                return null;
              }
            })
            .whereType<Place>()
            .toList();
    return places;
  }

  /// Retrieves places from the database based on filters
  /// set in [FilterViewModel]
  ///
  /// Uses the 'get_places_with_details_v2' function call on the database side to enable sorting by distance
  /// and to make the entire query more efficient
  @override
  Future<FetchResponse<Place>> fetchFilteredPlaces({
    required FilterViewModel filter,
    required BuildContext context,
    required int pageSize,
    required int pageNumber,
  }) async {
    try {
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final response = await _fetchAllWithoutFiltersByName(
          filter: filter,
          pageSize: pageSize,
          pageNumber: pageNumber,
          name: filter.searchQuery!,
        );

        final places = _jsonListToPlaces(response, withDistance: false);
        return FetchListSuccess<Place>(places);
      }
      Map<Category, Set<String>> categoryTagsMap = {};
      List<Map<String, dynamic>>? categoryTagsJson;
      if (filter.selectedTags.isNotEmpty) {
        // grupujemy tagi po kategoriach
        for (var category in filter.selectedCategories) {
          final tagsForCategory =
              filter.selectedTags
                  .where((tag) => allowedTags[category]?.contains(tag) ?? false)
                  .toSet();
          categoryTagsMap[category] = tagsForCategory;
        }
        // convert map to list of maps for serialization to JSON
        categoryTagsJson =
            categoryTagsMap.entries
                .map(
                  (entry) => {
                    "category": entry.key.name,
                    "tags": entry.value.isEmpty ? null : entry.value.toList(),
                  },
                )
                .toList();
      }
      LatLng? location =
          filter.searchNearbyUser == true
              ? filter.userLocation
              : filter.selectedLocation;

      final bool withDistance = location != null;

      dynamic response;

      if (withDistance) {
        response = await _fetchFilteredWithLocation(
          filter: filter,
          location: location,
          categoryTagsJson: categoryTagsJson,
          pageSize: pageSize,
          pageNumber: pageNumber,
        );
      } else {
        response = await _fetchFilteredWithoutLocation(
          filter: filter,
          categoryTagsMap: categoryTagsMap,
          pageSize: pageSize,
          pageNumber: pageNumber,
        );
      }

      final places = _jsonListToPlaces(response, withDistance: withDistance);

      return FetchListSuccess(places);
    } catch (e) {
      print('Exception in fetchFilteredPlaces: $e');
      return FetchListFailure('Unable to retrieve places: ${e.toString()}');
    }
  }

  //Fetches all places without any filters but with name search
  static Future<dynamic> _fetchAllWithoutFiltersByName({
    required FilterViewModel filter,
    required int pageSize,
    required int pageNumber,
    required String name,
  }) async {
    var query = _supabase
        .from('places_tags_agg')
        .select('*, date_props(*, date_props_tags(tags(*))))')
        .ilike('name', '%$name%')
        .filter('deleted_at', 'is', null)
        .range((pageNumber - 1) * pageSize, pageNumber * pageSize - 1);

    if (filter.orderBy != null && filter.sortAsc != null) {
      if (filter.orderBy == 'price') {
        query = query.order('pricepp_first', ascending: filter.sortAsc!);
      }
    }

    return retry(() => query);
  }

  @override
  Future<FetchResponse<String?>> fetchPlaceName({required String placeId}) async {
    try {
      final response =
          await _supabase
              .from(places)
              .select('name')
              .eq('id', placeId)
              .filter('deleted_at', 'is', null)
              .maybeSingle();

      if (response == null || response.isEmpty) {
        return FetchOneSuccess(null);
      }
      final name = response['name'] as String?;
      return FetchOneSuccess(name);
    } catch (e) {
      print('Error fetching place name: $e');
      return FetchOneFailure('Error fetching place name: ${e.toString()}');
    }
  }

  @override
  Future<FetchResponse<Map<String, String?>>> fetchPlacesNames({
    required List<String> ids,
  }) async {
    try {
      final response = await _supabase
          .from(places)
          .select('id, name')
          .filter('deleted_at', 'is', null)
          .inFilter('id', ids);

      final Map<String, String?> items = Map.fromEntries(
        (response as List).map((json) {
          final placeId = json['id'] as String;
          final name = json['name'] as String?;
          return MapEntry(placeId, name);
        }),
      );

      return FetchOneSuccess(items);
    } catch (e) {
      print('Error fetching users names: $e');
      return FetchOneFailure('Error fetching users names: ${e.toString()}');
    }
  }
}

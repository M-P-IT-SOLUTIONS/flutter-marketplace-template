import 'package:flutter_marketplace_template/functions.dart';
import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_marketplace_template/services/logger_service.dart';
import 'package:flutter_marketplace_template/models/place.dart';

/// Service for handling the favorite_places table via Supabase.
abstract class IFavoritePlacesService {
  Future<FetchResponse<Place>> fetchFavoritePlacesDetailedForCurrentUser({
    required int pageSize,
    required int pageNumber,
  });

  Future<bool> addFavorite(String placeId);
  Future<bool> removeFavorite(String placeId);
  Future<bool> toggleFavorite(String placeId);
}

/// Service for handling the favorite_places table via Supabase.
class FavoritePlacesServiceSupabase implements IFavoritePlacesService {
  static const String table = 'favorite_places';

  /// Returns the ID of the current user or throws an exception.
  static User _requireAuthUser() {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No logged-in user found');
    return user;
  }

  /// Fetches detailed information about the current user's favorite places along with tags and date_props.
  @override
  Future<FetchResponse<Place>> fetchFavoritePlacesDetailedForCurrentUser({
    required int pageSize,
    required int pageNumber,
  }) async {
    final List<Place> result = [];
    try {
      final uid = _requireAuthUser().id;
      final rows = await retry(
        () => supabase
            .from('places_tags_agg')
            .select(
              '*, date_props(*, date_props_tags(tags(*))), favorite_places!inner(*)',
            )
            .filter('deleted_at', 'is', null)
            .eq('favorite_places.user_id', uid)
            .range((pageNumber - 1) * pageSize, pageNumber * pageSize - 1),
      );

      result.addAll(
        (rows).map((raw) => Place.fromJsonORM(raw)).whereType<Place>().toList(),
      );
      return FetchListSuccess(result);
    } catch (e) {
      Log.warning('Error fetching detailed favorite places: $e');
      return FetchListFailure(
        'Failed to fetch favorite places: ${e.toString()}',
      );
    }
  }

  /// Adds a place to the user's favorites (idempotent).
  @override
  Future<bool> addFavorite(String placeId) async {
    try {
      final uid = _requireAuthUser().id;
      await supabase.from(table).upsert({'user_id': uid, 'place_id': placeId});
      return true;
    } catch (e) {
      Log.warning('Error adding favorite place: $e');
      return false;
    }
  }

  /// Removes a place from the user's favorites.
  @override
  Future<bool> removeFavorite(String placeId) async {
    try {
      final uid = _requireAuthUser().id;
      await supabase
          .from(table)
          .delete()
          .eq('user_id', uid)
          .eq('place_id', placeId);
      return true;
    } catch (e) {
      Log.warning('Error removing favorite place: $e');
      return false;
    }
  }

  /// Toggles the favorite status of a place – if it was favorite, removes it, if not – adds it.
  /// Returns the new status: true if the place is favorite after the operation.
  @override
  Future<bool> toggleFavorite(String placeId) async {
    try {
      final uid = _requireAuthUser().id;
      final existing = await supabase
          .from(table)
          .select('place_id')
          .eq('user_id', uid)
          .eq('place_id', placeId)
          .limit(1);
      final isFav = existing.isNotEmpty;
      if (isFav) {
        await removeFavorite(placeId);
        return false;
      } else {
        await addFavorite(placeId);
        return true;
      }
    } catch (e) {
      Log.warning('Error toggling favorite place: $e');
      return false;
    }
  }
}

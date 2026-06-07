import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_marketplace_template/models/category_tags_enums.dart';

/// ViewModel responsible for storing and managing search filters for places
/// Allows setting parameters such as: category, tags, price range, distance from user, sorting type (by price or distance)
/// Used in the home screen to sort and filter listings.
class FilterViewModel extends ChangeNotifier {
  // Private filter fields
  List<Category> _selectedCategories = [];
  List<String> _selectedTags = [];
  int? _selectedMinPrice;
  int? _selectedMaxPrice;
  int? _selectedMaxDistance; // maximum distance in meters
  LatLng? _userLocation;
  LatLng? _selectedLocation;
  String? _selectedLocationName;
  bool?
  _searchNearbyUser; // determines whether to use userLocation or selectedLocation as the location for queries
  String? _orderBy;
  bool? _sortAsc;

  /// Whether the filter panel is expanded (to control the state of `ExpansionTile`)
  bool isExpanded = false;

  // field for searching by name
  String? _searchQuery;

  // Public getters for filters
  List<Category> get selectedCategories => _selectedCategories;
  List<String> get selectedTags => _selectedTags;
  int? get selectedMinPrice => _selectedMinPrice;
  int? get selectedMaxPrice => _selectedMaxPrice;
  int? get selectedMaxDistance => _selectedMaxDistance;
  LatLng? get userLocation => _userLocation;
  LatLng? get selectedLocation => _selectedLocation;
  String? get selectedLocationName => _selectedLocationName;
  bool? get searchNearbyUser => _searchNearbyUser;
  String? get orderBy => _orderBy;
  bool? get sortAsc => _sortAsc;
  String? get searchQuery => _searchQuery;

  /// Resets all filters to default values
  void resetFilters() {
    _selectedCategories = [];
    _selectedTags = [];
    _selectedMinPrice = null;
    _selectedMaxPrice = null;
    _selectedMaxDistance = null;
    _selectedLocation = null;
    _selectedLocationName = null;
    _searchNearbyUser = userLocation != null ? true : null;
    _orderBy = null;
    _sortAsc = null;
    _searchQuery = null;
    notifyListeners();
  }

  /// Adds or removes a category from the list of selected categories
  void toggleCategory(bool selected, Category category) {
    final updatedCategory = List<Category>.from(_selectedCategories);
    final updatedTags = List<String>.from(_selectedTags);

    if (selected) {
      if (!updatedCategory.contains(category)) {
        updatedCategory.add(category);
      }
    } else {
      updatedTags.removeWhere(
        (tag) => allowedTags[category]?.contains(tag) ?? false,
      ); // removes tags of the given category
      updatedCategory.remove(category);
    }

    _selectedCategories = updatedCategory;
    _selectedTags = updatedTags;
    notifyListeners();
  }

  /// Adds or removes a tag from the list of selected tags
  void toggleTag(bool selected, String tag) {
    final updated = List<String>.from(_selectedTags);
    if (selected) {
      updated.add(tag);
    } else {
      updated.remove(tag);
    }
    _selectedTags = updated;
    notifyListeners();
  }

  void setSelectedLocation(LatLng? value, {String? name}) {
    _selectedLocation = value;
    _selectedLocationName = name;
    _searchNearbyUser = false;
    notifyListeners();
  }

  void clearSelectedLocation() {
    _selectedLocation = null;
    _selectedLocationName = null;
    notifyListeners();
  }

  void clearSearchByNameQuery() {
    _searchQuery = null;
    notifyListeners();
  }

  void setUserLocation(LatLng? value) {
    _userLocation = value;
    notifyListeners();
  }

  // Setters for individual filters
  void setMinPrice(int? price) {
    _selectedMinPrice = price;
    notifyListeners();
  }

  void setMaxPrice(int? price) {
    _selectedMaxPrice = price;
    notifyListeners();
  }

  void setMaxDistance(int? distance) {
    _selectedMaxDistance = distance;
    notifyListeners();
  }

  void setOrderBy(String? byWhat, {bool notify = true}) {
    _orderBy = byWhat;
    if (notify) {
      notifyListeners();
    }
  }

  void setSortAsc(bool? asc, {bool notify = true}) {
    _sortAsc = asc;
    if (notify) {
      notifyListeners();
    }
  }

  /// Sets the expansion state of the filter panel
  void setExpanded(bool val) {
    isExpanded = val;
    notifyListeners();
  }

  void setSearchNearbyUser(bool? value) {
    _searchNearbyUser = value;
    notifyListeners();
  }

  void setSearchByNameQuery(String? value) {
    _searchQuery = value?.trim().isEmpty == true ? null : value;
    notifyListeners();
  }
}

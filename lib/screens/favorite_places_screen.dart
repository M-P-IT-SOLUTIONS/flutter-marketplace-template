import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/view_models/favorite_places_view_model.dart';
import 'package:flutter_marketplace_template/adapters/place_notice.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/models/place.dart';
import 'package:flutter_marketplace_template/screens/place_screen.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Screen displaying the user's favorite places.
/// The current implementation filters places already loaded in `PlacesModel`.
/// NOTE: If some favorites are not in the currently downloaded list of places
/// (e.g., due to filters or pagination), they will not appear here.
/// Possible future improvement: separate query by ID to Supabase.
/// But they all load sequentially from the moment the app is launched,
/// so we get the same effect.

class FavoritePlacesScreen extends StatefulWidget {
  const FavoritePlacesScreen({super.key});

  @override
  State<FavoritePlacesScreen> createState() => _FavoritePlacesScreenState();
}

class _FavoritePlacesScreenState extends State<FavoritePlacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Place> _filterFavorites(List<Place> allPlaces, Set<String> favoriteIds) {
    final favPlaces = allPlaces.where((p) => favoriteIds.contains(p.id));
    if (_query.isEmpty) return favPlaces.toList();
    return favPlaces
        .where((p) => p.name.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 400;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(showTitle: false, showMenu: true),
      body: Consumer<FavoritePlacesViewModel>(
        builder: (context, favVM, _) {
          final favIds = favVM.favorites;
          final isFetching = favVM.isLoading;

          // Lista placeholderów, gdy fetch trwa
          final filtered =
              isFetching
                  ? List.generate(5, (_) => PlaceExtension.placeholder())
                  : _filterFavorites(favVM.favoritePlaces, favIds);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(16, 20, 94, 0.1),
                      blurRadius: 3,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.favourite_places,
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 24 * textScale,
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      height: 5,
                      thickness: 0.5,
                      color: const Color.fromRGBO(195, 196, 215, 1),
                    ),
                    const SizedBox(height: 12),
                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                        hintText: AppLocalizations.of(context)!.search_by_name,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Skeletonizer(
                      enabled: isFetching,
                      child: Column(
                        children:
                            filtered
                                .map(
                                  (p) => GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => PlaceScreen(place: p),
                                        ),
                                      );
                                    },
                                    child: PlaceNotice(
                                      place: p,
                                      screenWidth: screenWidth,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

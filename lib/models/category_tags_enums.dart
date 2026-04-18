import 'package:randki/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Enum representing different categories of places
enum Category {
  restaurant,
  chill,
  culture,
  outdoors,
  cafe,
  creative,
  nightlife,
  hotel,
  activity,
  instagrammable
}

/// Map of allowed tags for each category
final Map<Category, Set<String>> allowedTags = {
  Category.restaurant: {
    'italian',
    'casual dining',
    'french',
    'spanish',
    'greek',
    'american',
    'mexican',
    'chinese',
    'japanese',
    'korean',
    'thai',
    'indian',
    'vietnamese',
    'mediterranean',
    'polish',
    'fine_dining',
    'casual_dining',
    'bistro',
    'bar_and_grill',
    'street_food',
    'vegan',
    'vegetarian',
    'steak_house',
    'sushi_bar',
    'fusion',
    'dining_in_the_dark',
    'other_cuisines',
  },
  Category.cafe: {
    'traditional_cafe',
    'tea_house',
    'ice_cream_parlor',
    'confectionery',
    'breakfast_spot',
    'literary_artistic',
    'board_games',
  },
  Category.nightlife: {
    'bar',
    'pub',
    'nightclub',
    'cocktail_bar',
    'wine_bar',
    'shot_bar',
    'whisky_bar',
    'beach_bar',
    'rooftop_bar',
    'jazz_club',
  },
  Category.hotel: {
    'romantic',
    'close_to_nature',
    'boutique',
    'spa_and_wellness',
    'all_inclusive',
    'kids_friendly',
    'agrotourism',
    'camping',
    'glamping',
    'party',
    'slow_life',
  },
  Category.activity: {
    'bowling',
    'escape_room',
    'laser_tag',
    'paintball',
    'mini_golf',
    'billiards_darts',
    'arcade_bar',
    'squash_tennis',
    'trampolines',
    'kayaks',
    'swimming_area',
    'aquapark_pool',
    'rope_park',
    'rage_room',
    'shooting_range',
    'axe_throwing',
  },
  Category.culture: {
    'theatre',
    'opera',
    'operetta',
    'musical',
    'ballet',
    'art_museum',
    'art_gallery',
    'temporary_exhibitions',
    'vernissages',
    'interactive_museum',
    'arthouse_cinema',
    'open_air_cinema',
    'poetry_evenings',
    'concerts',
    'author_meetings',
    'literary_evenings',
    'art_studios',
    'improv_theatre',
    'illusion_museum',
  },
  Category.outdoors: {
    'botanical_garden',
    'zoo',
    'beach',
    'japanese_garden',
    'themed_garden',
    'arboretum',
    'amusement_park',
    'park',
  },
  Category.creative: {
    'wine_painting',
    'ceramics_workshops',
    'cooking_workshops',
    'craft_workshops',
    'painting',
  },
  Category.chill: {
    'spa',
    'floating',
    'salt_cave',
    'massage',
    'bathhouse',
    'sauna',
    'hammam',
  },
  Category.instagrammable: {
    'UWR-II' // TODO: add something
  },
};

/// Gets the localized name of a category
String getCategoryName(BuildContext context, Category category) {
  final l10n = AppLocalizations.of(context)!;

  switch (category) {
    case Category.restaurant:
      return l10n.restaurant;
    case Category.cafe:
      return l10n.cafe;
    case Category.nightlife:
      return l10n.nightlife;
    case Category.hotel:
      return l10n.hotel;
    case Category.activity:
      return l10n.activity;
    case Category.culture:
      return l10n.culture;
    case Category.outdoors:
      return l10n.outdoors;
    case Category.creative:
      return l10n.creative;
    case Category.chill:
      return l10n.chill;
    case Category.instagrammable:
      return l10n.instagrammable;
  }
}

/// Map of icons for each category
final Map<Category, IconData> categoryIcons = {
  Category.restaurant: Symbols.restaurant,
  Category.cafe: Symbols.local_cafe,
  Category.nightlife: Symbols.nightlife,
  Category.hotel: Symbols.hotel,
  Category.activity: Symbols.directions_bike,
  Category.culture: Symbols.image,
  Category.outdoors: Symbols.nature,
  Category.creative: Symbols.palette,
  Category.chill: Symbols.relax,
  Category.instagrammable: Symbols.square_dot,
};

/// Gets the localized name of a tag within a category
String getLocalizedTag(BuildContext context, Category category, String tag) {
  final l10n = AppLocalizations.of(context)!;

  switch (category) {
    case Category.restaurant:
      switch (tag) {
        case 'italian': return l10n.restaurant_italian;
        case 'casual dining': return l10n.restaurant_casual_dining;
        case 'french': return l10n.restaurant_french;
        case 'spanish': return l10n.restaurant_spanish;
        case 'greek': return l10n.restaurant_greek;
        case 'american': return l10n.restaurant_american;
        case 'mexican': return l10n.restaurant_mexican;
        case 'chinese': return l10n.restaurant_chinese;
        case 'japanese': return l10n.restaurant_japanese;
        case 'korean': return l10n.restaurant_korean;
        case 'thai': return l10n.restaurant_thai;
        case 'indian': return l10n.restaurant_indian;
        case 'vietnamese': return l10n.restaurant_vietnamese;
        case 'mediterranean': return l10n.restaurant_mediterranean;
        case 'polish': return l10n.restaurant_polish;
        case 'fine_dining': return l10n.restaurant_fine_dining;
        case 'casual_dining': return l10n.restaurant_casual_dining;
        case 'bistro': return l10n.restaurant_bistro;
        case 'bar_and_grill': return l10n.restaurant_bar_and_grill;
        case 'street_food': return l10n.restaurant_street_food;
        case 'vegan': return l10n.restaurant_vegan;
        case 'vegetarian': return l10n.restaurant_vegetarian;
        case 'steak_house': return l10n.restaurant_steak_house;
        case 'sushi_bar': return l10n.restaurant_sushi_bar;
        case 'fusion': return l10n.restaurant_fusion;
        case 'dining_in_the_dark': return l10n.restaurant_dining_in_the_dark;
        case 'other_cuisines': return l10n.restaurant_other_cuisines;
      }
      break;

    case Category.cafe:
      switch (tag) {
        case 'traditional_cafe': return l10n.cafe_traditional_cafe;
        case 'tea_house': return l10n.cafe_tea_house;
        case 'ice_cream_parlor': return l10n.cafe_ice_cream_parlor;
        case 'confectionery': return l10n.cafe_confectionery;
        case 'breakfast_spot': return l10n.cafe_breakfast_spot;
        case 'literary_artistic': return l10n.cafe_literary_artistic;
        case 'board_games': return l10n.cafe_board_games;
      }
      break;

    case Category.nightlife:
      switch (tag) {
        case 'bar': return l10n.nightlife_bar;
        case 'pub': return l10n.nightlife_pub;
        case 'nightclub': return l10n.nightlife_nightclub;
        case 'cocktail_bar': return l10n.nightlife_cocktail_bar;
        case 'wine_bar': return l10n.nightlife_wine_bar;
        case 'shot_bar': return l10n.nightlife_shot_bar;
        case 'whisky_bar': return l10n.nightlife_whisky_bar;
        case 'beach_bar': return l10n.nightlife_beach_bar;
        case 'rooftop_bar': return l10n.nightlife_rooftop_bar;
        case 'jazz_club': return l10n.nightlife_jazz_club;
      }
      break;

    case Category.hotel:
      switch (tag) {
        case 'romantic': return l10n.hotel_romantic;
        case 'close_to_nature': return l10n.hotel_close_to_nature;
        case 'boutique': return l10n.hotel_boutique;
        case 'spa_and_wellness': return l10n.hotel_spa_and_wellness;
        case 'all_inclusive': return l10n.hotel_all_inclusive;
        case 'kids_friendly': return l10n.hotel_kids_friendly;
        case 'agrotourism': return l10n.hotel_agrotourism;
        case 'camping': return l10n.hotel_camping;
        case 'glamping': return l10n.hotel_glamping;
        case 'party': return l10n.hotel_party;
        case 'slow_life': return l10n.hotel_slow_life;
      }
      break;

    case Category.activity:
      switch (tag) {
        case 'bowling': return l10n.activity_bowling;
        case 'escape_room': return l10n.activity_escape_room;
        case 'laser_tag': return l10n.activity_laser_tag;
        case 'paintball': return l10n.activity_paintball;
        case 'mini_golf': return l10n.activity_mini_golf;
        case 'billiards_darts': return l10n.activity_billiards_darts;
        case 'arcade_bar': return l10n.activity_arcade_bar;
        case 'squash_tennis': return l10n.activity_squash_tennis;
        case 'trampolines': return l10n.activity_trampolines;
        case 'kayaks': return l10n.activity_kayaks;
        case 'swimming_area': return l10n.activity_swimming_area;
        case 'aquapark_pool': return l10n.activity_aquapark_pool;
        case 'rope_park': return l10n.activity_rope_park;
        case 'rage_room': return l10n.activity_rage_room;
        case 'shooting_range': return l10n.activity_shooting_range;
        case 'axe_throwing': return l10n.activity_axe_throwing;
      }
      break;

    case Category.culture:
      switch (tag) {
        case 'theatre': return l10n.culture_theatre;
        case 'opera': return l10n.culture_opera;
        case 'operetta': return l10n.culture_operetta;
        case 'musical': return l10n.culture_musical;
        case 'ballet': return l10n.culture_ballet;
        case 'art_museum': return l10n.culture_art_museum;
        case 'art_gallery': return l10n.culture_art_gallery;
        case 'temporary_exhibitions': return l10n.culture_temporary_exhibitions;
        case 'vernissages': return l10n.culture_vernissages;
        case 'interactive_museum': return l10n.culture_interactive_museum;
        case 'arthouse_cinema': return l10n.culture_arthouse_cinema;
        case 'open_air_cinema': return l10n.culture_open_air_cinema;
        case 'poetry_evenings': return l10n.culture_poetry_evenings;
        case 'concerts': return l10n.culture_concerts;
        case 'author_meetings': return l10n.culture_author_meetings;
        case 'literary_evenings': return l10n.culture_literary_evenings;
        case 'art_studios': return l10n.culture_art_studios;
        case 'improv_theatre': return l10n.culture_improv_theatre;
        case 'illusion_museum': return l10n.culture_illusion_museum;
      }
      break;

    case Category.outdoors:
      switch (tag) {
        case 'botanical_garden': return l10n.outdoors_botanical_garden;
        case 'zoo': return l10n.outdoors_zoo;
        case 'beach': return l10n.outdoors_beach;
        case 'japanese_garden': return l10n.outdoors_japanese_garden;
        case 'themed_garden': return l10n.outdoors_themed_garden;
        case 'arboretum': return l10n.outdoors_arboretum;
        case 'amusement_park': return l10n.outdoors_amusement_park;
        case 'park': return l10n.outdoors_park;
      }
      break;

    case Category.creative:
      switch (tag) {
        case 'wine_painting': return l10n.creative_wine_painting;
        case 'ceramics_workshops': return l10n.creative_ceramics_workshops;
        case 'cooking_workshops': return l10n.creative_cooking_workshops;
        case 'craft_workshops': return l10n.creative_craft_workshops;
        case 'painting': return l10n.creative_painting;
      }
      break;

    case Category.chill:
      switch (tag) {
        case 'spa': return l10n.chill_spa;
        case 'floating': return l10n.chill_floating;
        case 'salt_cave': return l10n.chill_salt_cave;
        case 'massage': return l10n.chill_massage;
        case 'bathhouse': return l10n.chill_bathhouse;
        case 'sauna': return l10n.chill_sauna;
        case 'hammam': return l10n.chill_hammam;
      }
      break;

    case Category.instagrammable:
      switch (tag) {
        case 'UWR-II': return l10n.instagrammable_UWR_II;
      }
      break;
  }

  // fallback, when no one found
  return tag;
}
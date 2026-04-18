import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcome_back;

  /// Error message shown when the map fails to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load map!'**
  String get failed_to_load_map;

  /// No description provided for @new_point.
  ///
  /// In en, this message translates to:
  /// **'New Point'**
  String get new_point;

  /// No description provided for @this_is_your_point.
  ///
  /// In en, this message translates to:
  /// **'This is your Point!'**
  String get this_is_your_point;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'sign in'**
  String get sign_in;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'sign up'**
  String get sign_up;

  /// No description provided for @dont_have_an_account_yet.
  ///
  /// In en, this message translates to:
  /// **'don\'t have an account yet? '**
  String get dont_have_an_account_yet;

  /// No description provided for @already_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'already have an account? '**
  String get already_have_an_account;

  /// No description provided for @go_to_login.
  ///
  /// In en, this message translates to:
  /// **'log in'**
  String get go_to_login;

  /// No description provided for @go_to_registration.
  ///
  /// In en, this message translates to:
  /// **'register'**
  String get go_to_registration;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @polish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get polish;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get language;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'register'**
  String get register;

  /// No description provided for @forgot_your_password.
  ///
  /// In en, this message translates to:
  /// **'forgot your password?'**
  String get forgot_your_password;

  /// No description provided for @reset_your_password.
  ///
  /// In en, this message translates to:
  /// **'reset your password'**
  String get reset_your_password;

  /// No description provided for @repeat_your_password.
  ///
  /// In en, this message translates to:
  /// **'repeat your password'**
  String get repeat_your_password;

  /// No description provided for @enter_the_code.
  ///
  /// In en, this message translates to:
  /// **'enter the 6-digit code we sent to your email address'**
  String get enter_the_code;

  /// No description provided for @enter_your_email.
  ///
  /// In en, this message translates to:
  /// **'enter the email address associated with your account'**
  String get enter_your_email;

  /// No description provided for @set_a_new_password.
  ///
  /// In en, this message translates to:
  /// **'create a new password for your account'**
  String get set_a_new_password;

  /// No description provided for @email_hint_text.
  ///
  /// In en, this message translates to:
  /// **'email@domain.com'**
  String get email_hint_text;

  /// No description provided for @miejsca.
  ///
  /// In en, this message translates to:
  /// **'MIEJSCA'**
  String get miejsca;

  /// No description provided for @find_a_place.
  ///
  /// In en, this message translates to:
  /// **'find a place'**
  String get find_a_place;

  /// No description provided for @filter_places.
  ///
  /// In en, this message translates to:
  /// **'filter places'**
  String get filter_places;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'filter'**
  String get filter;

  /// No description provided for @reset_filters.
  ///
  /// In en, this message translates to:
  /// **'reset filters'**
  String get reset_filters;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'sort'**
  String get sort;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'log out'**
  String get log_out;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'account'**
  String get account;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'map'**
  String get map;

  /// No description provided for @default_sort.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get default_sort;

  /// No description provided for @lowest_price.
  ///
  /// In en, this message translates to:
  /// **'lowest price'**
  String get lowest_price;

  /// No description provided for @highest_price.
  ///
  /// In en, this message translates to:
  /// **'highest price'**
  String get highest_price;

  /// No description provided for @lowest_distance.
  ///
  /// In en, this message translates to:
  /// **'lowest distance'**
  String get lowest_distance;

  /// No description provided for @highest_distance.
  ///
  /// In en, this message translates to:
  /// **'highest distance'**
  String get highest_distance;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'distance'**
  String get distance;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'categories'**
  String get categories;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'tags'**
  String get tags;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'price'**
  String get price;

  /// No description provided for @open_in_map.
  ///
  /// In en, this message translates to:
  /// **'open in map'**
  String get open_in_map;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'menu'**
  String get menu;

  /// No description provided for @no_menu.
  ///
  /// In en, this message translates to:
  /// **'no menu'**
  String get no_menu;

  /// No description provided for @date_ideas.
  ///
  /// In en, this message translates to:
  /// **'date ideas'**
  String get date_ideas;

  /// No description provided for @no_date_ideas.
  ///
  /// In en, this message translates to:
  /// **'no date ideas'**
  String get no_date_ideas;

  /// No description provided for @premium_user.
  ///
  /// In en, this message translates to:
  /// **'Premium User'**
  String get premium_user;

  /// No description provided for @favourite_places.
  ///
  /// In en, this message translates to:
  /// **'favourite places'**
  String get favourite_places;

  /// No description provided for @view_favourite_places.
  ///
  /// In en, this message translates to:
  /// **'view favourite places'**
  String get view_favourite_places;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'preferences'**
  String get preferences;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'level'**
  String get level;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'activity'**
  String get activity;

  /// No description provided for @active_days.
  ///
  /// In en, this message translates to:
  /// **'active days'**
  String get active_days;

  /// No description provided for @last_login.
  ///
  /// In en, this message translates to:
  /// **'last login'**
  String get last_login;

  /// No description provided for @completed_tasks.
  ///
  /// In en, this message translates to:
  /// **'completed tasks'**
  String get completed_tasks;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'theme'**
  String get theme;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'automatic'**
  String get automatic;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'dark'**
  String get dark;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'notifications'**
  String get notifications;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'edit profile'**
  String get edit_profile;

  /// No description provided for @profile_picture.
  ///
  /// In en, this message translates to:
  /// **'profile picture'**
  String get profile_picture;

  /// No description provided for @change_picture.
  ///
  /// In en, this message translates to:
  /// **'change picture'**
  String get change_picture;

  /// No description provided for @delete_picture.
  ///
  /// In en, this message translates to:
  /// **'delete picture'**
  String get delete_picture;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get username;

  /// No description provided for @set_nickname.
  ///
  /// In en, this message translates to:
  /// **'set nickname'**
  String get set_nickname;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'save changes'**
  String get save_changes;

  /// No description provided for @search_by_name.
  ///
  /// In en, this message translates to:
  /// **'search by name'**
  String get search_by_name;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'search'**
  String get search;

  /// No description provided for @use_my_location.
  ///
  /// In en, this message translates to:
  /// **'use my location'**
  String get use_my_location;

  /// No description provided for @choose_location.
  ///
  /// In en, this message translates to:
  /// **'choose location'**
  String get choose_location;

  /// No description provided for @no_location.
  ///
  /// In en, this message translates to:
  /// **'no location'**
  String get no_location;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'address'**
  String get address;

  /// No description provided for @place_name.
  ///
  /// In en, this message translates to:
  /// **'place name'**
  String get place_name;

  /// No description provided for @choose_language.
  ///
  /// In en, this message translates to:
  /// **'choose language'**
  String get choose_language;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'restaurants'**
  String get restaurant;

  /// No description provided for @cafe.
  ///
  /// In en, this message translates to:
  /// **'cafes'**
  String get cafe;

  /// No description provided for @nightlife.
  ///
  /// In en, this message translates to:
  /// **'nightlife'**
  String get nightlife;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'hotels'**
  String get hotel;

  /// No description provided for @culture.
  ///
  /// In en, this message translates to:
  /// **'culture'**
  String get culture;

  /// No description provided for @outdoors.
  ///
  /// In en, this message translates to:
  /// **'outdoors'**
  String get outdoors;

  /// No description provided for @creative.
  ///
  /// In en, this message translates to:
  /// **'creative'**
  String get creative;

  /// No description provided for @chill.
  ///
  /// In en, this message translates to:
  /// **'chill'**
  String get chill;

  /// No description provided for @instagrammable.
  ///
  /// In en, this message translates to:
  /// **'instagrammable'**
  String get instagrammable;

  /// No description provided for @restaurant_italian.
  ///
  /// In en, this message translates to:
  /// **'italian'**
  String get restaurant_italian;

  /// No description provided for @restaurant_casual_dining.
  ///
  /// In en, this message translates to:
  /// **'casual dining'**
  String get restaurant_casual_dining;

  /// No description provided for @restaurant_french.
  ///
  /// In en, this message translates to:
  /// **'french'**
  String get restaurant_french;

  /// No description provided for @restaurant_spanish.
  ///
  /// In en, this message translates to:
  /// **'spanish'**
  String get restaurant_spanish;

  /// No description provided for @restaurant_greek.
  ///
  /// In en, this message translates to:
  /// **'greek'**
  String get restaurant_greek;

  /// No description provided for @restaurant_american.
  ///
  /// In en, this message translates to:
  /// **'american'**
  String get restaurant_american;

  /// No description provided for @restaurant_mexican.
  ///
  /// In en, this message translates to:
  /// **'mexican'**
  String get restaurant_mexican;

  /// No description provided for @restaurant_chinese.
  ///
  /// In en, this message translates to:
  /// **'chinese'**
  String get restaurant_chinese;

  /// No description provided for @restaurant_japanese.
  ///
  /// In en, this message translates to:
  /// **'japanese'**
  String get restaurant_japanese;

  /// No description provided for @restaurant_korean.
  ///
  /// In en, this message translates to:
  /// **'korean'**
  String get restaurant_korean;

  /// No description provided for @restaurant_thai.
  ///
  /// In en, this message translates to:
  /// **'thai'**
  String get restaurant_thai;

  /// No description provided for @restaurant_indian.
  ///
  /// In en, this message translates to:
  /// **'indian'**
  String get restaurant_indian;

  /// No description provided for @restaurant_vietnamese.
  ///
  /// In en, this message translates to:
  /// **'vietnamese'**
  String get restaurant_vietnamese;

  /// No description provided for @restaurant_mediterranean.
  ///
  /// In en, this message translates to:
  /// **'mediterranean'**
  String get restaurant_mediterranean;

  /// No description provided for @restaurant_polish.
  ///
  /// In en, this message translates to:
  /// **'polish'**
  String get restaurant_polish;

  /// No description provided for @restaurant_fine_dining.
  ///
  /// In en, this message translates to:
  /// **'fine dining'**
  String get restaurant_fine_dining;

  /// No description provided for @restaurant_bistro.
  ///
  /// In en, this message translates to:
  /// **'bistro'**
  String get restaurant_bistro;

  /// No description provided for @restaurant_bar_and_grill.
  ///
  /// In en, this message translates to:
  /// **'bar and grill'**
  String get restaurant_bar_and_grill;

  /// No description provided for @restaurant_street_food.
  ///
  /// In en, this message translates to:
  /// **'street food'**
  String get restaurant_street_food;

  /// No description provided for @restaurant_vegan.
  ///
  /// In en, this message translates to:
  /// **'vegan'**
  String get restaurant_vegan;

  /// No description provided for @restaurant_vegetarian.
  ///
  /// In en, this message translates to:
  /// **'vegetarian'**
  String get restaurant_vegetarian;

  /// No description provided for @restaurant_steak_house.
  ///
  /// In en, this message translates to:
  /// **'steak house'**
  String get restaurant_steak_house;

  /// No description provided for @restaurant_sushi_bar.
  ///
  /// In en, this message translates to:
  /// **'sushi bar'**
  String get restaurant_sushi_bar;

  /// No description provided for @restaurant_fusion.
  ///
  /// In en, this message translates to:
  /// **'fusion'**
  String get restaurant_fusion;

  /// No description provided for @restaurant_dining_in_the_dark.
  ///
  /// In en, this message translates to:
  /// **'dining in the dark'**
  String get restaurant_dining_in_the_dark;

  /// No description provided for @restaurant_other_cuisines.
  ///
  /// In en, this message translates to:
  /// **'other cuisines'**
  String get restaurant_other_cuisines;

  /// No description provided for @cafe_traditional_cafe.
  ///
  /// In en, this message translates to:
  /// **'traditional cafe'**
  String get cafe_traditional_cafe;

  /// No description provided for @cafe_tea_house.
  ///
  /// In en, this message translates to:
  /// **'tea house'**
  String get cafe_tea_house;

  /// No description provided for @cafe_ice_cream_parlor.
  ///
  /// In en, this message translates to:
  /// **'ice cream parlor'**
  String get cafe_ice_cream_parlor;

  /// No description provided for @cafe_confectionery.
  ///
  /// In en, this message translates to:
  /// **'confectionery'**
  String get cafe_confectionery;

  /// No description provided for @cafe_breakfast_spot.
  ///
  /// In en, this message translates to:
  /// **'breakfast spot'**
  String get cafe_breakfast_spot;

  /// No description provided for @cafe_literary_artistic.
  ///
  /// In en, this message translates to:
  /// **'artistic'**
  String get cafe_literary_artistic;

  /// No description provided for @cafe_board_games.
  ///
  /// In en, this message translates to:
  /// **'board games'**
  String get cafe_board_games;

  /// No description provided for @nightlife_bar.
  ///
  /// In en, this message translates to:
  /// **'bar'**
  String get nightlife_bar;

  /// No description provided for @nightlife_pub.
  ///
  /// In en, this message translates to:
  /// **'pub'**
  String get nightlife_pub;

  /// No description provided for @nightlife_nightclub.
  ///
  /// In en, this message translates to:
  /// **'nightclub'**
  String get nightlife_nightclub;

  /// No description provided for @nightlife_cocktail_bar.
  ///
  /// In en, this message translates to:
  /// **'cocktail bar'**
  String get nightlife_cocktail_bar;

  /// No description provided for @nightlife_wine_bar.
  ///
  /// In en, this message translates to:
  /// **'wine bar'**
  String get nightlife_wine_bar;

  /// No description provided for @nightlife_shot_bar.
  ///
  /// In en, this message translates to:
  /// **'shot bar'**
  String get nightlife_shot_bar;

  /// No description provided for @nightlife_whisky_bar.
  ///
  /// In en, this message translates to:
  /// **'whisky bar'**
  String get nightlife_whisky_bar;

  /// No description provided for @nightlife_beach_bar.
  ///
  /// In en, this message translates to:
  /// **'beach bar'**
  String get nightlife_beach_bar;

  /// No description provided for @nightlife_rooftop_bar.
  ///
  /// In en, this message translates to:
  /// **'rooftop bar'**
  String get nightlife_rooftop_bar;

  /// No description provided for @nightlife_jazz_club.
  ///
  /// In en, this message translates to:
  /// **'jazz club'**
  String get nightlife_jazz_club;

  /// No description provided for @hotel_romantic.
  ///
  /// In en, this message translates to:
  /// **'romantic'**
  String get hotel_romantic;

  /// No description provided for @hotel_close_to_nature.
  ///
  /// In en, this message translates to:
  /// **'close to nature'**
  String get hotel_close_to_nature;

  /// No description provided for @hotel_boutique.
  ///
  /// In en, this message translates to:
  /// **'boutique'**
  String get hotel_boutique;

  /// No description provided for @hotel_spa_and_wellness.
  ///
  /// In en, this message translates to:
  /// **'spa and wellness'**
  String get hotel_spa_and_wellness;

  /// No description provided for @hotel_all_inclusive.
  ///
  /// In en, this message translates to:
  /// **'all inclusive'**
  String get hotel_all_inclusive;

  /// No description provided for @hotel_kids_friendly.
  ///
  /// In en, this message translates to:
  /// **'kids friendly'**
  String get hotel_kids_friendly;

  /// No description provided for @hotel_agrotourism.
  ///
  /// In en, this message translates to:
  /// **'agrotourism'**
  String get hotel_agrotourism;

  /// No description provided for @hotel_camping.
  ///
  /// In en, this message translates to:
  /// **'camping'**
  String get hotel_camping;

  /// No description provided for @hotel_glamping.
  ///
  /// In en, this message translates to:
  /// **'glamping'**
  String get hotel_glamping;

  /// No description provided for @hotel_party.
  ///
  /// In en, this message translates to:
  /// **'party'**
  String get hotel_party;

  /// No description provided for @hotel_slow_life.
  ///
  /// In en, this message translates to:
  /// **'slow life'**
  String get hotel_slow_life;

  /// No description provided for @activity_bowling.
  ///
  /// In en, this message translates to:
  /// **'bowling'**
  String get activity_bowling;

  /// No description provided for @activity_escape_room.
  ///
  /// In en, this message translates to:
  /// **'escape room'**
  String get activity_escape_room;

  /// No description provided for @activity_laser_tag.
  ///
  /// In en, this message translates to:
  /// **'laser tag'**
  String get activity_laser_tag;

  /// No description provided for @activity_paintball.
  ///
  /// In en, this message translates to:
  /// **'paintball'**
  String get activity_paintball;

  /// No description provided for @activity_mini_golf.
  ///
  /// In en, this message translates to:
  /// **'mini golf'**
  String get activity_mini_golf;

  /// No description provided for @activity_billiards_darts.
  ///
  /// In en, this message translates to:
  /// **'billiards and darts'**
  String get activity_billiards_darts;

  /// No description provided for @activity_arcade_bar.
  ///
  /// In en, this message translates to:
  /// **'arcade bar'**
  String get activity_arcade_bar;

  /// No description provided for @activity_squash_tennis.
  ///
  /// In en, this message translates to:
  /// **'squash/tennis'**
  String get activity_squash_tennis;

  /// No description provided for @activity_trampolines.
  ///
  /// In en, this message translates to:
  /// **'trampolines'**
  String get activity_trampolines;

  /// No description provided for @activity_kayaks.
  ///
  /// In en, this message translates to:
  /// **'kayaks'**
  String get activity_kayaks;

  /// No description provided for @activity_swimming_area.
  ///
  /// In en, this message translates to:
  /// **'swimming area'**
  String get activity_swimming_area;

  /// No description provided for @activity_aquapark_pool.
  ///
  /// In en, this message translates to:
  /// **'aquapark/pool'**
  String get activity_aquapark_pool;

  /// No description provided for @activity_rope_park.
  ///
  /// In en, this message translates to:
  /// **'rope park'**
  String get activity_rope_park;

  /// No description provided for @activity_rage_room.
  ///
  /// In en, this message translates to:
  /// **'rage room'**
  String get activity_rage_room;

  /// No description provided for @activity_shooting_range.
  ///
  /// In en, this message translates to:
  /// **'shooting range'**
  String get activity_shooting_range;

  /// No description provided for @activity_axe_throwing.
  ///
  /// In en, this message translates to:
  /// **'axe throwing'**
  String get activity_axe_throwing;

  /// No description provided for @culture_theatre.
  ///
  /// In en, this message translates to:
  /// **'theatre'**
  String get culture_theatre;

  /// No description provided for @culture_opera.
  ///
  /// In en, this message translates to:
  /// **'opera'**
  String get culture_opera;

  /// No description provided for @culture_operetta.
  ///
  /// In en, this message translates to:
  /// **'operetta'**
  String get culture_operetta;

  /// No description provided for @culture_musical.
  ///
  /// In en, this message translates to:
  /// **'musical'**
  String get culture_musical;

  /// No description provided for @culture_ballet.
  ///
  /// In en, this message translates to:
  /// **'ballet'**
  String get culture_ballet;

  /// No description provided for @culture_art_museum.
  ///
  /// In en, this message translates to:
  /// **'art museum'**
  String get culture_art_museum;

  /// No description provided for @culture_art_gallery.
  ///
  /// In en, this message translates to:
  /// **'art gallery'**
  String get culture_art_gallery;

  /// No description provided for @culture_temporary_exhibitions.
  ///
  /// In en, this message translates to:
  /// **'temporary exhibitions'**
  String get culture_temporary_exhibitions;

  /// No description provided for @culture_vernissages.
  ///
  /// In en, this message translates to:
  /// **'vernissages'**
  String get culture_vernissages;

  /// No description provided for @culture_interactive_museum.
  ///
  /// In en, this message translates to:
  /// **'interactive museum'**
  String get culture_interactive_museum;

  /// No description provided for @culture_arthouse_cinema.
  ///
  /// In en, this message translates to:
  /// **'arthouse cinema'**
  String get culture_arthouse_cinema;

  /// No description provided for @culture_open_air_cinema.
  ///
  /// In en, this message translates to:
  /// **'open-air cinema'**
  String get culture_open_air_cinema;

  /// No description provided for @culture_poetry_evenings.
  ///
  /// In en, this message translates to:
  /// **'poetry evenings'**
  String get culture_poetry_evenings;

  /// No description provided for @culture_concerts.
  ///
  /// In en, this message translates to:
  /// **'concerts'**
  String get culture_concerts;

  /// No description provided for @culture_author_meetings.
  ///
  /// In en, this message translates to:
  /// **'author meetings'**
  String get culture_author_meetings;

  /// No description provided for @culture_literary_evenings.
  ///
  /// In en, this message translates to:
  /// **'literary evenings'**
  String get culture_literary_evenings;

  /// No description provided for @culture_art_studios.
  ///
  /// In en, this message translates to:
  /// **'art studios'**
  String get culture_art_studios;

  /// No description provided for @culture_improv_theatre.
  ///
  /// In en, this message translates to:
  /// **'improv theatre'**
  String get culture_improv_theatre;

  /// No description provided for @culture_illusion_museum.
  ///
  /// In en, this message translates to:
  /// **'museum of illusions'**
  String get culture_illusion_museum;

  /// No description provided for @outdoors_botanical_garden.
  ///
  /// In en, this message translates to:
  /// **'botanical garden'**
  String get outdoors_botanical_garden;

  /// No description provided for @outdoors_zoo.
  ///
  /// In en, this message translates to:
  /// **'zoo'**
  String get outdoors_zoo;

  /// No description provided for @outdoors_beach.
  ///
  /// In en, this message translates to:
  /// **'beach'**
  String get outdoors_beach;

  /// No description provided for @outdoors_japanese_garden.
  ///
  /// In en, this message translates to:
  /// **'japanese garden'**
  String get outdoors_japanese_garden;

  /// No description provided for @outdoors_themed_garden.
  ///
  /// In en, this message translates to:
  /// **'themed garden'**
  String get outdoors_themed_garden;

  /// No description provided for @outdoors_arboretum.
  ///
  /// In en, this message translates to:
  /// **'arboretum'**
  String get outdoors_arboretum;

  /// No description provided for @outdoors_amusement_park.
  ///
  /// In en, this message translates to:
  /// **'amusement park'**
  String get outdoors_amusement_park;

  /// No description provided for @outdoors_park.
  ///
  /// In en, this message translates to:
  /// **'park'**
  String get outdoors_park;

  /// No description provided for @creative_wine_painting.
  ///
  /// In en, this message translates to:
  /// **'wine & painting'**
  String get creative_wine_painting;

  /// No description provided for @creative_ceramics_workshops.
  ///
  /// In en, this message translates to:
  /// **'ceramics'**
  String get creative_ceramics_workshops;

  /// No description provided for @creative_cooking_workshops.
  ///
  /// In en, this message translates to:
  /// **'cooking workshops'**
  String get creative_cooking_workshops;

  /// No description provided for @creative_craft_workshops.
  ///
  /// In en, this message translates to:
  /// **'craft workshops'**
  String get creative_craft_workshops;

  /// No description provided for @creative_painting.
  ///
  /// In en, this message translates to:
  /// **'painting'**
  String get creative_painting;

  /// No description provided for @chill_spa.
  ///
  /// In en, this message translates to:
  /// **'spa'**
  String get chill_spa;

  /// No description provided for @chill_floating.
  ///
  /// In en, this message translates to:
  /// **'floating'**
  String get chill_floating;

  /// No description provided for @chill_salt_cave.
  ///
  /// In en, this message translates to:
  /// **'salt cave'**
  String get chill_salt_cave;

  /// No description provided for @chill_massage.
  ///
  /// In en, this message translates to:
  /// **'massage'**
  String get chill_massage;

  /// No description provided for @chill_bathhouse.
  ///
  /// In en, this message translates to:
  /// **'bathhouse'**
  String get chill_bathhouse;

  /// No description provided for @chill_sauna.
  ///
  /// In en, this message translates to:
  /// **'sauna'**
  String get chill_sauna;

  /// No description provided for @chill_hammam.
  ///
  /// In en, this message translates to:
  /// **'hammam'**
  String get chill_hammam;

  /// No description provided for @instagrammable_UWR_II.
  ///
  /// In en, this message translates to:
  /// **'uwr-ii'**
  String get instagrammable_UWR_II;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'delete account'**
  String get delete_account;

  /// No description provided for @confirm_action.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm?'**
  String get confirm_action;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel;

  /// No description provided for @chat_load_failure.
  ///
  /// In en, this message translates to:
  /// **'Loading chat failure'**
  String get chat_load_failure;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @deletedChat.
  ///
  /// In en, this message translates to:
  /// **'Deleted chat'**
  String get deletedChat;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @private_chat.
  ///
  /// In en, this message translates to:
  /// **'private chat'**
  String get private_chat;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'chat'**
  String get chat;

  /// No description provided for @deleted_chat_description.
  ///
  /// In en, this message translates to:
  /// **'This chat has been deleted and cannot be messaged.'**
  String get deleted_chat_description;

  /// No description provided for @unable_to_get_location.
  ///
  /// In en, this message translates to:
  /// **'You must grant permission to access your location.'**
  String get unable_to_get_location;

  /// No description provided for @no_selected_location.
  ///
  /// In en, this message translates to:
  /// **'No selected location.'**
  String get no_selected_location;

  /// No description provided for @your_location.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get your_location;

  /// No description provided for @custom_location.
  ///
  /// In en, this message translates to:
  /// **'Custom location'**
  String get custom_location;

  /// No description provided for @custom_location_description.
  ///
  /// In en, this message translates to:
  /// **'That is your custom location'**
  String get custom_location_description;

  /// No description provided for @radius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get radius;

  /// No description provided for @allow_location_access_or_set_another.
  ///
  /// In en, this message translates to:
  /// **'Allow access to your location or set another in the selection field to be able to sort by distance.'**
  String get allow_location_access_or_set_another;

  /// No description provided for @reset_link_expired.
  ///
  /// In en, this message translates to:
  /// **'Link resetu wygasł lub jest niepoprawny.'**
  String get reset_link_expired;

  /// No description provided for @password_changed.
  ///
  /// In en, this message translates to:
  /// **'Hasło zostało zmienione'**
  String get password_changed;

  /// No description provided for @empty_password.
  ///
  /// In en, this message translates to:
  /// **'Hasło nie może być puste'**
  String get empty_password;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Zmień hasło'**
  String get change_password;

  /// No description provided for @password_reset_link_sent.
  ///
  /// In en, this message translates to:
  /// **'Link do resetu hasła został wysłany na podany email.'**
  String get password_reset_link_sent;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Wyślij'**
  String get send;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'dni'**
  String get days;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'dzień'**
  String get day;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

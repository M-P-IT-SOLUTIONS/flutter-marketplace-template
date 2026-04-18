import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:randki/app.dart';
import 'package:randki/services/auth_service.dart';
import 'package:randki/services/chat_service.dart';
import 'package:randki/services/delete_user_use_case_service.dart';
import 'package:randki/services/favorite_places_service.dart';
import 'package:randki/services/language_service.dart';
import 'package:randki/services/notifications_service.dart';
import 'package:randki/services/places_service.dart';
import 'package:randki/services/theme_service.dart';
import 'package:randki/services/user_service.dart';
import 'package:randki/view_models/language_view_model.dart';
import 'package:randki/view_models/theme_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "map_key.env");

  await Firebase.initializeApp();

  //TODO: Implement this
  await Supabase.initialize(
    url: ,
    anonKey:,
  );

  await Hive.initFlutter();
  await Hive.openBox('settings');

  await initNotifications();

  runApp(
    MultiProvider(
      // Services
      providers: [
        Provider<IPlacesService>(create: (_) => PlacesServiceSupabase()),
        Provider<INotificationsService>(
          create: (_) => NotificationsServiceSupabase(),
        ),
        Provider<IAuthService>(
          create:
              (context) =>
                  AuthServiceSupabase(context.read<INotificationsService>()),
        ),
        Provider<IUserService>(create: (_) => UserServiceSupabase()),
        Provider<IChatService>(
          create:
              (context) => ChatServiceSupabase(context.read<IUserService>()),
        ),
        Provider<IDeleteUserUseCaseService>(
          create:
              (context) => DeleteUserUseCaseServiceSupabase(
                context.read<IUserService>(),
                context.read<IChatService>(),
                context.read<IAuthService>(),
              ),
        ),
        Provider<IFavoritePlacesService>(
          create: (_) => FavoritePlacesServiceSupabase(),
        ),
        Provider<ILanguageService>(create: (_) => LanguageServiceHive()),
        Provider<IThemeService>(create: (_) => ThemeServiceHive()),
        ChangeNotifierProvider(
          create:
              (context) => LanguageViewModel(context.read<ILanguageService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeViewModel(context.read<IThemeService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Initialization of local notifications
Future<void> initNotifications() async {
  initializeTimeZones();
  setLocalLocation(getLocation('Europe/Warsaw'));

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(initSettings);

  // ANDROID 13+
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  // iOS
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}

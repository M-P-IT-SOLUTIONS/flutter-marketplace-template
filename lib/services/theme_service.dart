import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Service for managing the application's theme settings.
abstract class IThemeService {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
}

/// Service for managing the application's theme settings, using Hive for local storage.
class ThemeServiceHive implements IThemeService {
  static const String _settingsBoxName = 'settings';
  static const String _themeKey = 'app_theme_mode';

  @override
  Future<ThemeMode> getThemeMode() async {
    final box = await Hive.openBox(_settingsBoxName);
    final savedTheme = box.get(
      _themeKey,
      defaultValue: 'system', 
    );

    switch (savedTheme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final box = await Hive.openBox(_settingsBoxName);

    await box.put(
      _themeKey,
      mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system',
    );
  }
}

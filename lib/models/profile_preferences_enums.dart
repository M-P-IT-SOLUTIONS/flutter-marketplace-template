import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum AppLanguage { pl, en }

extension AppLanguageExtension on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.pl:
        return 'polski';
      case AppLanguage.en:
        return 'english';
    }
  }

  String get code {
    switch (this) {
      case AppLanguage.pl:
        return 'pl';
      case AppLanguage.en:
        return 'en';
    }
  }

  /// Function to get enum from code
  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.pl, // default
    );
  }
}

enum AppThemeMode { automatic, light, dark }

extension AppThemeModeLabel on AppThemeMode {
  String label(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    switch (this) {
      case AppThemeMode.automatic:
        return t.automatic;
      case AppThemeMode.light:
        return t.light;
      case AppThemeMode.dark:
        return t.dark;
    }
  }
}

extension AppThemeModeExt on AppThemeMode {
  ThemeMode toFlutter() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;

      case AppThemeMode.dark:
        return ThemeMode.dark;

      case AppThemeMode.automatic:
        return ThemeMode.system;
    }
  }

  static AppThemeMode fromFlutter(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppThemeMode.light;

      case ThemeMode.dark:
        return AppThemeMode.dark;

      case ThemeMode.system:
        return AppThemeMode.automatic;
    }
  }
}

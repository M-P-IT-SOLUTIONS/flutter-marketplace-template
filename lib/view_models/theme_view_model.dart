import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/services/theme_service.dart';
import 'package:flutter_marketplace_template/models/profile_preferences_enums.dart';

class ThemeViewModel extends ChangeNotifier {
  final IThemeService _themeService;

  AppThemeMode _mode = AppThemeMode.automatic;

  AppThemeMode get mode => _mode;

  ThemeViewModel(this._themeService) {
    _load();
  }

  Future<void> _load() async {
    final flutterMode = await _themeService.getThemeMode();
    _mode = AppThemeModeExt.fromFlutter(flutterMode);
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode m) async {
    _mode = m;
    await _themeService.setThemeMode(m.toFlutter());
    notifyListeners();
  }

  ThemeMode get flutterMode => _mode.toFlutter();
}

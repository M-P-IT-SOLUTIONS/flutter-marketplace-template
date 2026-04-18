import 'package:flutter/material.dart';
import 'package:randki/services/language_service.dart';

class LanguageViewModel extends ChangeNotifier {
  final ILanguageService _languageService;

  Locale _locale = const Locale('pl');

  Locale get locale => _locale;

  LanguageViewModel(this._languageService) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    _locale = await _languageService.getLocale();
    notifyListeners();
  }

  Future<void> changeLocale(String languageCode) async {
    _locale = Locale(languageCode);
    await _languageService.setLocale(languageCode);
    notifyListeners();
  }
}

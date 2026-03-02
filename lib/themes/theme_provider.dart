import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'selected_theme';
  static const _localeKey = 'selected_locale';
  static const _vibrationKey = 'vibration_enabled';

  AppThemeData _currentTheme = appThemes['tokyo_night']!;
  Locale _locale = const Locale('pt');
  bool _vibrationEnabled = true;

  AppThemeData get currentTheme => _currentTheme;
  Locale get locale => _locale;
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeId = prefs.getString(_themeKey) ?? 'tokyo_night';
    _currentTheme = appThemes[themeId] ?? appThemes['tokyo_night']!;

    final localeCode = prefs.getString(_localeKey) ?? 'pt';
    _locale = Locale(localeCode);

    _vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;

    notifyListeners();
  }

  Future<void> setTheme(String themeId) async {
    if (appThemes.containsKey(themeId)) {
      _currentTheme = appThemes[themeId]!;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeId);
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setVibration(bool enabled) async {
    _vibrationEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, enabled);
  }
}

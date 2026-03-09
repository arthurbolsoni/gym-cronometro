import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_timer/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider defaults', () {
    test('default theme is tokyo_night', () {
      final provider = ThemeProvider();
      expect(provider.currentTheme.id, 'tokyo_night');
    });

    test('default locale is pt', () {
      final provider = ThemeProvider();
      expect(provider.locale, const Locale('pt'));
    });

    test('default vibration is enabled', () {
      final provider = ThemeProvider();
      expect(provider.vibrationEnabled, isTrue);
    });
  });

  group('ThemeProvider.setTheme', () {
    test('changes theme to dark', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.setTheme('dark');

      expect(provider.currentTheme.id, 'dark');
    });

    test('ignores invalid theme id', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.setTheme('nonexistent');

      expect(provider.currentTheme.id, 'tokyo_night');
    });

    test('persists theme to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.setTheme('nord');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_theme'), 'nord');
    });

    test('notifies listeners on theme change', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setTheme('gruvbox');

      expect(notifyCount, 1);
    });

    test('does not notify listeners on invalid theme', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setTheme('fake');

      expect(notifyCount, 0);
    });
  });

  group('ThemeProvider.setLocale', () {
    test('changes locale to en', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.setLocale(const Locale('en'));

      expect(provider.locale, const Locale('en'));
    });

    test('persists locale to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.setLocale(const Locale('es'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_locale'), 'es');
    });

    test('notifies listeners on locale change', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setLocale(const Locale('en'));

      expect(notifyCount, 1);
    });
  });

  group('ThemeProvider.setVibration', () {
    test('disables vibration', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.setVibration(false);

      expect(provider.vibrationEnabled, isFalse);
    });

    test('persists vibration to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.setVibration(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('vibration_enabled'), isFalse);
    });

    test('notifies listeners on vibration change', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setVibration(false);

      expect(notifyCount, 1);
    });
  });

  group('ThemeProvider.load', () {
    test('loads saved theme from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'selected_theme': 'dark',
        'selected_locale': 'en',
        'vibration_enabled': false,
      });
      final provider = ThemeProvider();

      await provider.load();

      expect(provider.currentTheme.id, 'dark');
      expect(provider.locale, const Locale('en'));
      expect(provider.vibrationEnabled, isFalse);
    });

    test('falls back to defaults when no saved values', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.load();

      expect(provider.currentTheme.id, 'tokyo_night');
      expect(provider.locale, const Locale('pt'));
      expect(provider.vibrationEnabled, isTrue);
    });

    test('falls back to tokyo_night for invalid saved theme', () async {
      SharedPreferences.setMockInitialValues({
        'selected_theme': 'deleted_theme',
      });
      final provider = ThemeProvider();

      await provider.load();

      expect(provider.currentTheme.id, 'tokyo_night');
    });

    test('notifies listeners after load', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.load();

      expect(notifyCount, 1);
    });
  });
}

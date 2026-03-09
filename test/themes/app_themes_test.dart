import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_timer/themes/app_themes.dart';

void main() {
  group('appThemes map', () {
    test('contains 18 themes', () {
      expect(appThemes.length, 18);
    });

    test('each theme id matches its map key', () {
      for (final entry in appThemes.entries) {
        expect(entry.value.id, entry.key);
      }
    });

    test('contains all expected theme ids', () {
      final expectedIds = [
        'tokyo_night', 'dark', 'light', 'catppuccin', 'catppuccin_latte',
        'ethereal', 'everforest', 'flexoki_light', 'gruvbox', 'hackerman',
        'kanagawa', 'matte_black', 'nord', 'osaka_jade', 'ristretto',
        'rose_pine', 'solarized_dark', 'solarized_light',
      ];
      for (final id in expectedIds) {
        expect(appThemes.containsKey(id), isTrue, reason: 'Missing theme: $id');
      }
    });
  });

  group('AppThemeData.toThemeData', () {
    test('light themes return Brightness.light', () {
      final lightThemeIds = ['light', 'catppuccin_latte', 'flexoki_light', 'solarized_light'];
      for (final id in lightThemeIds) {
        final themeData = appThemes[id]!.toThemeData();
        expect(themeData.brightness, Brightness.light, reason: '$id should be light');
      }
    });

    test('dark themes return Brightness.dark', () {
      final darkThemeIds = [
        'tokyo_night', 'dark', 'catppuccin', 'ethereal', 'everforest',
        'gruvbox', 'hackerman', 'kanagawa', 'matte_black', 'nord',
        'osaka_jade', 'ristretto', 'rose_pine', 'solarized_dark',
      ];
      for (final id in darkThemeIds) {
        final themeData = appThemes[id]!.toThemeData();
        expect(themeData.brightness, Brightness.dark, reason: '$id should be dark');
      }
    });

    test('scaffoldBackgroundColor matches theme background', () {
      for (final entry in appThemes.entries) {
        final themeData = entry.value.toThemeData();
        expect(themeData.scaffoldBackgroundColor, entry.value.background);
      }
    });

    test('colorScheme.primary matches accent', () {
      for (final entry in appThemes.entries) {
        final themeData = entry.value.toThemeData();
        expect(themeData.colorScheme.primary, entry.value.accent);
      }
    });

    test('colorScheme.error matches resetColor', () {
      for (final entry in appThemes.entries) {
        final themeData = entry.value.toThemeData();
        expect(themeData.colorScheme.error, entry.value.resetColor);
      }
    });
  });

  group('themeLocalizedName', () {
    test('returns id for unknown theme', () {
      expect(themeLocalizedName('unknown_theme', _FakeL10n()), 'unknown_theme');
    });

    test('returns localized name for known theme', () {
      final l10n = _FakeL10n();
      expect(themeLocalizedName('dark', l10n), 'Dark');
      expect(themeLocalizedName('light', l10n), 'Light');
      expect(themeLocalizedName('tokyo_night', l10n), 'Tokyo Night');
    });
  });
}

class _FakeL10n {
  String get themeDark => 'Dark';
  String get themeLight => 'Light';
  String get themeCatppuccin => 'Catppuccin';
  String get themeCatppuccinLatte => 'Catppuccin Latte';
  String get themeEthereal => 'Ethereal';
  String get themeEverforest => 'Everforest';
  String get themeFlexokiLight => 'Flexoki Light';
  String get themeGruvbox => 'Gruvbox';
  String get themeHackerman => 'Hackerman';
  String get themeKanagawa => 'Kanagawa';
  String get themeMatteBlack => 'Matte Black';
  String get themeNord => 'Nord';
  String get themeOsakaJade => 'Osaka Jade';
  String get themeRistretto => 'Ristretto';
  String get themeRosePine => 'Rose Pine';
  String get themeSolarizedDark => 'Solarized Dark';
  String get themeSolarizedLight => 'Solarized Light';
  String get themeTokyoNight => 'Tokyo Night';
}

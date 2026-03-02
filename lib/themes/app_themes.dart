import 'package:flutter/material.dart';

class AppThemeData {
  final String id;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color buttonColor;
  final Color buttonText;
  final Color resetColor;
  final Color resetText;
  final Color accent;

  const AppThemeData({
    required this.id,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.buttonColor,
    required this.buttonText,
    required this.resetColor,
    required this.resetText,
    required this.accent,
  });

  ThemeData toThemeData() {
    return ThemeData(
      brightness: _isLight ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: _isLight ? Brightness.light : Brightness.dark,
        primary: accent,
        onPrimary: buttonText,
        secondary: buttonColor,
        onSecondary: buttonText,
        error: resetColor,
        onError: resetText,
        surface: surface,
        onSurface: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
      ),
      iconTheme: IconThemeData(color: text),
    );
  }

  bool get _isLight {
    final luminance = background.computeLuminance();
    return luminance > 0.4;
  }
}

String themeLocalizedName(String themeId, dynamic l10n) {
  switch (themeId) {
    case 'dark':
      return l10n.themeDark;
    case 'light':
      return l10n.themeLight;
    case 'catppuccin':
      return l10n.themeCatppuccin;
    case 'catppuccin_latte':
      return l10n.themeCatppuccinLatte;
    case 'ethereal':
      return l10n.themeEthereal;
    case 'everforest':
      return l10n.themeEverforest;
    case 'flexoki_light':
      return l10n.themeFlexokiLight;
    case 'gruvbox':
      return l10n.themeGruvbox;
    case 'hackerman':
      return l10n.themeHackerman;
    case 'kanagawa':
      return l10n.themeKanagawa;
    case 'matte_black':
      return l10n.themeMatteBlack;
    case 'nord':
      return l10n.themeNord;
    case 'osaka_jade':
      return l10n.themeOsakaJade;
    case 'ristretto':
      return l10n.themeRistretto;
    case 'rose_pine':
      return l10n.themeRosePine;
    case 'solarized_dark':
      return l10n.themeSolarizedDark;
    case 'solarized_light':
      return l10n.themeSolarizedLight;
    case 'tokyo_night':
      return l10n.themeTokyoNight;
    default:
      return themeId;
  }
}

final Map<String, AppThemeData> appThemes = {
  'tokyo_night': const AppThemeData(
    id: 'tokyo_night',
    background: Color(0xFF1A1B26),
    surface: Color(0xFF24283B),
    text: Color(0xFFC0CAF5),
    textSecondary: Color(0xFF565F89),
    buttonColor: Color(0xFF7AA2F7),
    buttonText: Color(0xFF1A1B26),
    resetColor: Color(0xFFF7768E),
    resetText: Color(0xFF1A1B26),
    accent: Color(0xFF7AA2F7),
  ),
  'dark': const AppThemeData(
    id: 'dark',
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    text: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8E8E93),
    buttonColor: Color(0xFF2196F3),
    buttonText: Color(0xFFFFFFFF),
    resetColor: Color(0xFFFF3B30),
    resetText: Color(0xFFFFFFFF),
    accent: Color(0xFF2196F3),
  ),
  'light': const AppThemeData(
    id: 'light',
    background: Color(0xFFF2F2F7),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF000000),
    textSecondary: Color(0xFF6C6C70),
    buttonColor: Color(0xFF007AFF),
    buttonText: Color(0xFFFFFFFF),
    resetColor: Color(0xFFFF3B30),
    resetText: Color(0xFFFFFFFF),
    accent: Color(0xFF007AFF),
  ),
  'catppuccin': const AppThemeData(
    id: 'catppuccin',
    background: Color(0xFF1E1E2E),
    surface: Color(0xFF313244),
    text: Color(0xFFCDD6F4),
    textSecondary: Color(0xFF6C7086),
    buttonColor: Color(0xFF89B4FA),
    buttonText: Color(0xFF1E1E2E),
    resetColor: Color(0xFFF38BA8),
    resetText: Color(0xFF1E1E2E),
    accent: Color(0xFFCBA6F7),
  ),
  'catppuccin_latte': const AppThemeData(
    id: 'catppuccin_latte',
    background: Color(0xFFEFF1F5),
    surface: Color(0xFFE6E9EF),
    text: Color(0xFF4C4F69),
    textSecondary: Color(0xFF8C8FA1),
    buttonColor: Color(0xFF1E66F5),
    buttonText: Color(0xFFEFF1F5),
    resetColor: Color(0xFFD20F39),
    resetText: Color(0xFFEFF1F5),
    accent: Color(0xFF8839EF),
  ),
  'ethereal': const AppThemeData(
    id: 'ethereal',
    background: Color(0xFF282C34),
    surface: Color(0xFF2C313A),
    text: Color(0xFFD7DAE0),
    textSecondary: Color(0xFF636D83),
    buttonColor: Color(0xFF61AFEF),
    buttonText: Color(0xFF282C34),
    resetColor: Color(0xFFE06C75),
    resetText: Color(0xFF282C34),
    accent: Color(0xFFC678DD),
  ),
  'everforest': const AppThemeData(
    id: 'everforest',
    background: Color(0xFF2D353B),
    surface: Color(0xFF343F44),
    text: Color(0xFFD3C6AA),
    textSecondary: Color(0xFF859289),
    buttonColor: Color(0xFFA7C080),
    buttonText: Color(0xFF2D353B),
    resetColor: Color(0xFFE67E80),
    resetText: Color(0xFF2D353B),
    accent: Color(0xFFA7C080),
  ),
  'flexoki_light': const AppThemeData(
    id: 'flexoki_light',
    background: Color(0xFFFFFCF0),
    surface: Color(0xFFF2F0E5),
    text: Color(0xFF100F0F),
    textSecondary: Color(0xFF6F6E69),
    buttonColor: Color(0xFF205EA6),
    buttonText: Color(0xFFFFFCF0),
    resetColor: Color(0xFFAF3029),
    resetText: Color(0xFFFFFCF0),
    accent: Color(0xFF205EA6),
  ),
  'gruvbox': const AppThemeData(
    id: 'gruvbox',
    background: Color(0xFF282828),
    surface: Color(0xFF3C3836),
    text: Color(0xFFEBDBB2),
    textSecondary: Color(0xFFA89984),
    buttonColor: Color(0xFF458588),
    buttonText: Color(0xFFEBDBB2),
    resetColor: Color(0xFFCC241D),
    resetText: Color(0xFFEBDBB2),
    accent: Color(0xFFD79921),
  ),
  'hackerman': const AppThemeData(
    id: 'hackerman',
    background: Color(0xFF0A0E14),
    surface: Color(0xFF111922),
    text: Color(0xFF00FF41),
    textSecondary: Color(0xFF0D7A2A),
    buttonColor: Color(0xFF00CC33),
    buttonText: Color(0xFF0A0E14),
    resetColor: Color(0xFFFF0040),
    resetText: Color(0xFF0A0E14),
    accent: Color(0xFF00FF41),
  ),
  'kanagawa': const AppThemeData(
    id: 'kanagawa',
    background: Color(0xFF1F1F28),
    surface: Color(0xFF2A2A37),
    text: Color(0xFFDCD7BA),
    textSecondary: Color(0xFF727169),
    buttonColor: Color(0xFF7E9CD8),
    buttonText: Color(0xFF1F1F28),
    resetColor: Color(0xFFC34043),
    resetText: Color(0xFFDCD7BA),
    accent: Color(0xFF957FB8),
  ),
  'matte_black': const AppThemeData(
    id: 'matte_black',
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF171717),
    text: Color(0xFFE0E0E0),
    textSecondary: Color(0xFF666666),
    buttonColor: Color(0xFF333333),
    buttonText: Color(0xFFE0E0E0),
    resetColor: Color(0xFF8B0000),
    resetText: Color(0xFFE0E0E0),
    accent: Color(0xFF4A4A4A),
  ),
  'nord': const AppThemeData(
    id: 'nord',
    background: Color(0xFF2E3440),
    surface: Color(0xFF3B4252),
    text: Color(0xFFECEFF4),
    textSecondary: Color(0xFF7B88A1),
    buttonColor: Color(0xFF5E81AC),
    buttonText: Color(0xFFECEFF4),
    resetColor: Color(0xFFBF616A),
    resetText: Color(0xFFECEFF4),
    accent: Color(0xFF88C0D0),
  ),
  'osaka_jade': const AppThemeData(
    id: 'osaka_jade',
    background: Color(0xFF0B1D0E),
    surface: Color(0xFF122716),
    text: Color(0xFFD0E8D0),
    textSecondary: Color(0xFF5C8A5C),
    buttonColor: Color(0xFF2E8B57),
    buttonText: Color(0xFFD0E8D0),
    resetColor: Color(0xFFC0392B),
    resetText: Color(0xFFD0E8D0),
    accent: Color(0xFF3CB371),
  ),
  'ristretto': const AppThemeData(
    id: 'ristretto',
    background: Color(0xFF1A1210),
    surface: Color(0xFF2B1F1A),
    text: Color(0xFFE8D5C4),
    textSecondary: Color(0xFF8A7060),
    buttonColor: Color(0xFF8B5E3C),
    buttonText: Color(0xFFE8D5C4),
    resetColor: Color(0xFFA0332C),
    resetText: Color(0xFFE8D5C4),
    accent: Color(0xFFD4915E),
  ),
  'rose_pine': const AppThemeData(
    id: 'rose_pine',
    background: Color(0xFF191724),
    surface: Color(0xFF1F1D2E),
    text: Color(0xFFE0DEF4),
    textSecondary: Color(0xFF6E6A86),
    buttonColor: Color(0xFFC4A7E7),
    buttonText: Color(0xFF191724),
    resetColor: Color(0xFFEB6F92),
    resetText: Color(0xFF191724),
    accent: Color(0xFFEBBCBA),
  ),
  'solarized_dark': const AppThemeData(
    id: 'solarized_dark',
    background: Color(0xFF002B36),
    surface: Color(0xFF073642),
    text: Color(0xFF839496),
    textSecondary: Color(0xFF586E75),
    buttonColor: Color(0xFF268BD2),
    buttonText: Color(0xFFFDF6E3),
    resetColor: Color(0xFFDC322F),
    resetText: Color(0xFFFDF6E3),
    accent: Color(0xFF2AA198),
  ),
  'solarized_light': const AppThemeData(
    id: 'solarized_light',
    background: Color(0xFFFDF6E3),
    surface: Color(0xFFEEE8D5),
    text: Color(0xFF657B83),
    textSecondary: Color(0xFF93A1A1),
    buttonColor: Color(0xFF268BD2),
    buttonText: Color(0xFFFDF6E3),
    resetColor: Color(0xFFDC322F),
    resetText: Color(0xFFFDF6E3),
    accent: Color(0xFF2AA198),
  ),
};

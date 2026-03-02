// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get sets => 'Series';

  @override
  String get reset => 'Reiniciar';

  @override
  String get settings => 'Configuración';

  @override
  String get vibration => 'Vibración';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Idioma';

  @override
  String get rest => 'Descanso';

  @override
  String get timeUp => '¡Se acabó el tiempo! Siguiente serie.';

  @override
  String get resetSets => 'Reiniciar series';

  @override
  String restTime(String time) {
    return 'Descanso: $time';
  }

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeCatppuccin => 'Catppuccin';

  @override
  String get themeCatppuccinLatte => 'Catppuccin Latte';

  @override
  String get themeEthereal => 'Ethereal';

  @override
  String get themeEverforest => 'Everforest';

  @override
  String get themeFlexokiLight => 'Flexoki Light';

  @override
  String get themeGruvbox => 'Gruvbox';

  @override
  String get themeHackerman => 'Hackerman';

  @override
  String get themeKanagawa => 'Kanagawa';

  @override
  String get themeMatteBlack => 'Matte Black';

  @override
  String get themeNord => 'Nord';

  @override
  String get themeOsakaJade => 'Osaka Jade';

  @override
  String get themeRistretto => 'Ristretto';

  @override
  String get themeRosePine => 'Rose Pine';

  @override
  String get themeSolarizedDark => 'Solarized Dark';

  @override
  String get themeSolarizedLight => 'Solarized Light';

  @override
  String get themeTokyoNight => 'Tokyo Night';

  @override
  String get about => 'Acerca de';
}

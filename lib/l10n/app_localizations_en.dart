// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sets => 'Sets';

  @override
  String get reset => 'Reset';

  @override
  String get settings => 'Settings';

  @override
  String get vibration => 'Vibration';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get rest => 'Rest';

  @override
  String get timeUp => 'Time is up! Next set.';

  @override
  String get resetSets => 'Reset sets';

  @override
  String restTime(String time) {
    return 'Rest: $time';
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
  String get about => 'About';
}

import 'package:flutter/material.dart';
import 'package:gym_timer/l10n/app_localizations.dart';
import 'package:gym_timer/screens/home_screen.dart';
import 'package:gym_timer/services/notification_service.dart';
import 'package:gym_timer/themes/theme_provider.dart';

ThemeProvider themeProvider = ThemeProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await themeProvider.load();
  runApp(const GymTimerApp());
}

class GymTimerApp extends StatelessWidget {
  const GymTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Gym Timer',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme.toThemeData(),
          locale: themeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_cronometro/l10n/app_localizations.dart';
import 'package:gym_cronometro/themes/app_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildTestApp({required Widget child, Locale locale = const Locale('en')}) {
  final theme = appThemes['tokyo_night']!;
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme.toThemeData(),
    home: Scaffold(body: child),
  );
}

void setupMockPrefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
}

void setupMockNotificationChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dexterous.com/flutter/local_notifications'),
    (MethodCall methodCall) async => null,
  );
}

void setupMockVibrationChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('vibration'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'hasVibrator') return true;
      return null;
    },
  );
}

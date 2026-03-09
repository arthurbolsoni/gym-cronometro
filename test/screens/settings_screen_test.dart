import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_timer/l10n/app_localizations.dart';
import 'package:gym_timer/main.dart' as app;
import 'package:gym_timer/screens/settings_screen.dart';
import 'package:gym_timer/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (MethodCall methodCall) async => null,
    );

    app.themeProvider = ThemeProvider();
  });

  Widget buildApp({VoidCallback? onResetSets}) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SettingsScreen(onResetSets: onResetSets ?? () {}),
    );
  }

  group('SettingsScreen layout', () {
    testWidgets('shows Settings title in app bar', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows vibration switch', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('shows vibration icon', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });

    testWidgets('shows all 3 language options', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Português'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
    });

    testWidgets('shows theme section with Tokyo Night', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Tokyo Night'), findsOneWidget);
    });

    testWidgets('shows theme section with Dark', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Dark'), findsOneWidget);
    });
  });

  group('SettingsScreen interactions', () {
    testWidgets('vibration switch toggles', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(app.themeProvider.vibrationEnabled, isTrue);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(app.themeProvider.vibrationEnabled, isFalse);
    });

    testWidgets('tapping language changes locale', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(app.themeProvider.locale.languageCode, 'pt');

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(app.themeProvider.locale.languageCode, 'en');
    });

    testWidgets('tapping a theme changes the active theme', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(app.themeProvider.currentTheme.id, 'tokyo_night');

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(app.themeProvider.currentTheme.id, 'dark');
    });

    testWidgets('reset sets button calls callback via navigation', (tester) async {
      bool resetCalled = false;

      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      onResetSets: () => resetCalled = true,
                    ),
                  ),
                );
              },
              child: const Text('Open Settings'),
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      final listFinder = find.byType(ListView);
      await tester.drag(listFinder, const Offset(0, -2000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset sets'));
      await tester.pumpAndSettle();

      expect(resetCalled, isTrue);
      expect(find.text('Open Settings'), findsOneWidget);
    });
  });
}

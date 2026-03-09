import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_timer/l10n/app_localizations.dart';
import 'package:gym_timer/main.dart' as app;
import 'package:gym_timer/screens/home_screen.dart';
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

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('vibration'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'hasVibrator') return true;
        return null;
      },
    );

    app.themeProvider = ThemeProvider();
  });

  Widget buildApp() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }

  group('HomeScreen initial state', () {
    testWidgets('shows Sets: 0 initially', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Sets: 0'), findsOneWidget);
    });

    testWidgets('shows 00:00 timer initially', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('shows settings icon', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('shows first row of preset buttons', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('00:30'), findsOneWidget);
      expect(find.text('00:45'), findsOneWidget);
    });

    testWidgets('shows second row of preset buttons', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('01:00'), findsOneWidget);
      expect(find.text('01:30'), findsOneWidget);
    });
  });

  group('HomeScreen timer interaction', () {
    testWidgets('clicking a time button increments sets to 1', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('00:30'));
      await tester.pump();

      expect(find.text('Sets: 1'), findsOneWidget);
    });

    testWidgets('clicking a time button twice increments sets to 2', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('00:30'));
      await tester.pump();
      await tester.tap(find.text('00:30').last);
      await tester.pump();

      expect(find.text('Sets: 2'), findsOneWidget);
    });

    testWidgets('tapping sets text resets sets to 0', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('00:30'));
      await tester.pump();
      expect(find.text('Sets: 1'), findsOneWidget);

      await tester.tap(find.text('Sets: 1'));
      await tester.pump();
      expect(find.text('Sets: 0'), findsOneWidget);
    });

    testWidgets('timer counts down after 1 second', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('00:30'));
      await tester.pump();

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:29'), findsOneWidget);
    });

    testWidgets('timer displays selected time in timer display', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('01:00'));
      await tester.pump();

      final timerTexts = find.text('01:00');
      expect(timerTexts, findsWidgets);
    });
  });
}

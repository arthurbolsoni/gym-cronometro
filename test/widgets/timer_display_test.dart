import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_timer/themes/app_themes.dart';
import 'package:gym_timer/widgets/timer_display.dart';
import '../helpers/test_helpers.dart';

final _theme = appThemes['tokyo_night']!;

void main() {
  group('TimerDisplay formatting', () {
    testWidgets('shows 00:00 for 0 seconds', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: TimerDisplay(remainingSeconds: 0, isRunning: false, theme: _theme),
      ));
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('shows 01:30 for 90 seconds', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: TimerDisplay(remainingSeconds: 90, isRunning: true, theme: _theme),
      ));
      expect(find.text('01:30'), findsOneWidget);
    });

    testWidgets('shows 03:00 for 180 seconds', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: TimerDisplay(remainingSeconds: 180, isRunning: true, theme: _theme),
      ));
      expect(find.text('03:00'), findsOneWidget);
    });

    testWidgets('shows 00:45 for 45 seconds', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: TimerDisplay(remainingSeconds: 45, isRunning: true, theme: _theme),
      ));
      expect(find.text('00:45'), findsOneWidget);
    });
  });

  group('TimerDisplay warning color', () {
    testWidgets('uses resetColor when running and <= 3 seconds', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: TimerDisplay(remainingSeconds: 3, isRunning: true, theme: _theme),
      ));

      final textWidget = tester.widget<Text>(find.text('00:03'));
      expect(textWidget.style?.color, _theme.resetColor);
    });

    testWidgets('uses text color when running and > 3 seconds', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: TimerDisplay(remainingSeconds: 5, isRunning: true, theme: _theme),
      ));

      final textWidget = tester.widget<Text>(find.text('00:05'));
      expect(textWidget.style?.color, _theme.text);
    });

    testWidgets('uses text color when not running even if <= 3', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: TimerDisplay(remainingSeconds: 2, isRunning: false, theme: _theme),
      ));

      final textWidget = tester.widget<Text>(find.text('00:02'));
      expect(textWidget.style?.color, _theme.text);
    });

    testWidgets('uses text color when remaining is 0', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: TimerDisplay(remainingSeconds: 0, isRunning: true, theme: _theme),
      ));

      final textWidget = tester.widget<Text>(find.text('00:00'));
      expect(textWidget.style?.color, _theme.text);
    });
  });
}

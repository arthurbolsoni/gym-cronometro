import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_cronometro/themes/app_themes.dart';
import 'package:gym_cronometro/widgets/time_button.dart';
import '../helpers/test_helpers.dart';

final _theme = appThemes['tokyo_night']!;

void main() {
  group('TimeButton label', () {
    testWidgets('shows 00:30 for 30 seconds', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: SizedBox(
          height: 80,
          child: TimeButton(seconds: 30, onPressed: () {}, theme: _theme),
        ),
      ));
      expect(find.text('00:30'), findsOneWidget);
    });

    testWidgets('shows 02:30 for 150 seconds', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: SizedBox(
          height: 80,
          child: TimeButton(seconds: 150, onPressed: () {}, theme: _theme),
        ),
      ));
      expect(find.text('02:30'), findsOneWidget);
    });

    testWidgets('shows 01:00 for 60 seconds', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: SizedBox(
          height: 80,
          child: TimeButton(seconds: 60, onPressed: () {}, theme: _theme),
        ),
      ));
      expect(find.text('01:00'), findsOneWidget);
    });
  });

  group('TimeButton callback', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(buildTestApp(
        child: SizedBox(
          height: 80,
          child: TimeButton(
            seconds: 30,
            onPressed: () => pressed = true,
            theme: _theme,
          ),
        ),
      ));

      await tester.tap(find.text('00:30'));
      expect(pressed, isTrue);
    });
  });
}

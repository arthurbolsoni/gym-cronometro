import 'package:flutter/material.dart';
import 'package:gym_timer/themes/app_themes.dart';

class TimeButton extends StatelessWidget {
  final int seconds;
  final VoidCallback onPressed;
  final AppThemeData theme;

  const TimeButton({
    super.key,
    required this.seconds,
    required this.onPressed,
    required this.theme,
  });

  String get _label {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.buttonColor,
          foregroundColor: theme.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          _label,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

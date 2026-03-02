import 'package:flutter/material.dart';
import 'package:gym_cronometro/themes/app_themes.dart';

class TimerDisplay extends StatelessWidget {
  final int remainingSeconds;
  final bool isRunning;
  final AppThemeData theme;

  const TimerDisplay({
    super.key,
    required this.remainingSeconds,
    required this.isRunning,
    required this.theme,
  });

  String get _formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = isRunning && remainingSeconds <= 3 && remainingSeconds > 0;

    return Text(
      _formattedTime,
      style: TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w700,
        color: isWarning ? theme.resetColor : theme.text,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

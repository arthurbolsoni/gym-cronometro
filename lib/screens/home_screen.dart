import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:gym_timer/l10n/app_localizations.dart';
import 'package:gym_timer/main.dart';
import 'package:gym_timer/screens/settings_screen.dart';
import 'package:gym_timer/services/notification_service.dart';
import 'package:gym_timer/widgets/time_button.dart';
import 'package:gym_timer/widgets/timer_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _sets = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  static const _presetSeconds = [30, 45, 60, 90, 120, 150, 180];

  @override
  void dispose() {
    _timer?.cancel();
    NotificationService.instance.cancel();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = seconds;
      _isRunning = true;
      _sets++;
    });

    _updateNotification();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
        _onTimerFinished();
      } else {
        _updateNotification();
      }
    });
  }

  void _updateNotification() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    final timeStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    NotificationService.instance.showOngoingTimer(
      l10n.restTime(timeStr),
      '${l10n.sets}: $_sets',
    );
  }

  Future<void> _onTimerFinished() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    await NotificationService.instance.showAlertNotification(
      l10n.timeUp,
      '${l10n.sets}: $_sets',
    );

    if (themeProvider.vibrationEnabled) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        Vibration.vibrate(pattern: [0, 500, 200, 500]);
      }
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    NotificationService.instance.cancel();
    setState(() {
      _remainingSeconds = 0;
      _isRunning = false;
    });
  }

  void _resetSets() {
    setState(() {
      _sets = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        final theme = themeProvider.currentTheme;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: _resetSets,
                        child: Text(
                          '${l10n.sets}: $_sets',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.accent,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: theme.textSecondary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(
                                onResetSets: _resetSets,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TimerDisplay(
                    remainingSeconds: _remainingSeconds,
                    isRunning: _isRunning,
                    theme: theme,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.8,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ..._presetSeconds.map((sec) => TimeButton(
                              seconds: sec,
                              onPressed: () => _startTimer(sec),
                              theme: theme,
                            )),
                        SizedBox(
                          height: double.infinity,
                          child: ElevatedButton(
                            onPressed: _resetTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.resetColor,
                              foregroundColor: theme.resetText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.reset,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:gym_timer/l10n/app_localizations.dart';
import 'package:gym_timer/main.dart';
import 'package:gym_timer/screens/settings_screen.dart';
import 'package:gym_timer/services/battery_service.dart';
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

  /// Wall-clock moment the rest ends. The countdown is always derived from
  /// it, so it stays right after Android suspends the app in the background.
  DateTime? _endTime;
  Duration _total = Duration.zero;
  bool _inBackground = false;
  late final AppLifecycleListener _lifecycleListener;

  static const _presetSeconds = [30, 45, 60, 90, 120, 150, 180];
  static const _endTimeKey = 'timer_end_ms';
  static const _setsKey = 'timer_sets';
  static const _totalKey = 'timer_total_s';

  /// Counted from the start of the last rest.
  static const _idleReminderAfter = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onHide: _onBackground,
      onShow: _onForeground,
    );
    NotificationService.instance.onNextSet = _nextSet;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _requestPermissions();
      await _restoreTimer();
      if (NotificationService.instance.launchedByNextSet) {
        NotificationService.instance.launchedByNextSet = false;
        _nextSet();
      }
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    NotificationService.instance.onNextSet = null;
    _timer?.cancel();
    NotificationService.instance.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await NotificationService.instance.requestPermission();
    await BatteryService.instance.requestExemptionOnce();
  }

  int _secondsLeft() {
    final end = _endTime;
    return end == null ? 0 : _secondsUntil(end);
  }

  int _secondsUntil(DateTime end) {
    final ms = end.difference(clock.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  void _startTimer(int seconds) {
    final end = clock.now().add(Duration(seconds: seconds));
    setState(() => _sets++);
    _total = Duration(seconds: seconds);
    _saveTimer(end);
    _runUntil(end);
    _showOngoingNotification();
    if (_inBackground) _scheduleBackgroundAlert();
    _scheduleIdleReminder();
  }

  /// Nudge for when the rest is long over and no new set was started.
  void _scheduleIdleReminder() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    NotificationService.instance.scheduleReminder(
      title: l10n.idleReminder,
      body: '${l10n.sets}: $_sets',
      actionLabel: l10n.nextSet,
      at: clock.now().add(_idleReminderAfter),
      vibrate: themeProvider.vibrationEnabled,
    );
  }

  /// "Next set" on the notification: another rest of the same length.
  void _nextSet() {
    if (!mounted || _total <= Duration.zero) return;
    _startTimer(_total.inSeconds);
  }

  void _runUntil(DateTime end) {
    _timer?.cancel();
    _endTime = end;

    setState(() {
      _remainingSeconds = _secondsLeft();
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!_isRunning) return;
    final left = _secondsLeft();

    if (left > 0) {
      if (left != _remainingSeconds) {
        setState(() => _remainingSeconds = left);
        _showOngoingNotification();
      }
      return;
    }

    _timer?.cancel();
    NotificationService.instance.cancelOngoing();
    _endTime = null;
    _clearSavedTimer();
    setState(() {
      _remainingSeconds = 0;
      _isRunning = false;
    });

    // In the background the alert scheduled in _onBackground does the job.
    if (!_inBackground) _onTimerFinished();
  }

  void _onBackground() {
    _inBackground = true;
    _scheduleBackgroundAlert();
  }

  /// Replaces whatever alert was pending with one for the current rest.
  void _scheduleBackgroundAlert() {
    final end = _endTime;
    final l10n = AppLocalizations.of(context);
    if (!_isRunning || end == null || l10n == null) return;

    NotificationService.instance.scheduleAlert(
      title: l10n.timeUp,
      body: '${l10n.sets}: $_sets',
      actionLabel: l10n.nextSet,
      at: end,
      vibrate: themeProvider.vibrationEnabled,
    );
  }

  void _onForeground() {
    _inBackground = false;
    // Drops the alert whether it is still pending or already fired.
    NotificationService.instance.cancelAlert();
    _tick();
  }

  void _showOngoingNotification() {
    final l10n = AppLocalizations.of(context);
    final end = _endTime;
    if (l10n == null || !_isRunning || end == null) return;

    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    final timeStr =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    NotificationService.instance.showOngoingTimer(
      title: l10n.restTime(timeStr),
      body: '${l10n.sets}: $_sets',
      label: l10n.rest,
      actionLabel: l10n.nextSet,
      endTime: end,
      total: _total,
    );
  }

  Future<void> _onTimerFinished() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    await NotificationService.instance.showAlertNotification(
      title: l10n.timeUp,
      body: '${l10n.sets}: $_sets',
      actionLabel: l10n.nextSet,
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
    _endTime = null;
    _clearSavedTimer();
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

  Future<void> _saveTimer(DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_endTimeKey, end.millisecondsSinceEpoch);
    await prefs.setInt(_setsKey, _sets);
    await prefs.setInt(_totalKey, _total.inSeconds);
  }

  Future<void> _clearSavedTimer() async {
    final prefs = await SharedPreferences.getInstance();
    // Sets and length stay: "next set" needs them if the process was killed.
    await prefs.remove(_endTimeKey);
  }

  /// Picks a running rest back up when Android killed the process meanwhile.
  Future<void> _restoreTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final endMs = prefs.getInt(_endTimeKey);
    if (NotificationService.instance.launchedByNextSet && !_isRunning) {
      final total = prefs.getInt(_totalKey);
      if (total != null && mounted) {
        _total = Duration(seconds: total);
        setState(() => _sets = prefs.getInt(_setsKey) ?? _sets);
      }
    }
    if (endMs == null) return;

    final end = DateTime.fromMillisecondsSinceEpoch(endMs);
    if (!mounted || _isRunning) return;
    if (!end.isAfter(clock.now())) {
      await _clearSavedTimer();
      return;
    }

    setState(() => _sets = prefs.getInt(_setsKey) ?? _sets);
    _total = Duration(seconds: prefs.getInt(_totalKey) ?? _secondsUntil(end));
    _runUntil(end);
    _showOngoingNotification();
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

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _serviceRunning = false;
  bool _systemDrawsCountdown = false;
  String? _lastPosted;

  static const _nativeTimer = MethodChannel('gym_timer/timer_notification');

  /// Called when "next set" is tapped on any of the timer notifications.
  void Function()? onNextSet;

  /// True when the app was cold-started by a "next set" tap; the home screen
  /// consumes it once.
  bool launchedByNextSet = false;

  // Default importance: HyperOS hides low-importance ("silent") notifications
  // on the lock screen. The channel has no sound or vibration of its own.
  static const _ongoingChannelId = 'timer_running';
  static const _legacyOngoingChannelId = 'timer_ongoing';
  static const _alertChannelId = 'timer_alert';
  static const _alertVibrateChannelId = 'timer_alert_vibrate';
  static const _ongoingId = 1;
  static const _alertId = 2;
  static const _reminderId = 3;
  static const _reminderChannelId = 'timer_idle_vibrate';
  static const _nextSetActionId = 'next_set';

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('ic_stat_timer');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == _nextSetActionId) onNextSet?.call();
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    launchedByNextSet = (launch?.didNotificationLaunchApp ?? false) &&
        launch?.notificationResponse?.actionId == _nextSetActionId;
    await _android?.deleteNotificationChannel(
      channelId: _legacyOngoingChannelId,
    );
    _nativeTimer.setMethodCallHandler((call) async {
      if (call.method == 'nextSet') onNextSet?.call();
    });
    _initialized = true;
  }

  /// Android 13+ only shows notifications after the user grants this.
  Future<void> requestPermission() async {
    if (!_initialized) return;
    await _android?.requestNotificationsPermission();
  }

  /// Ongoing notification with the remaining time in its title. The first
  /// call starts a foreground service, which keeps the process (and the Dart
  /// timer) running in the background; later calls only refresh the text.
  /// HyperOS freezes the system chronometer on the lock screen, hence the
  /// text refreshed from here every second.
  Future<void> showOngoingTimer({
    required String title,
    required String body,
    required String label,
    required String actionLabel,
    required DateTime endTime,
    required Duration total,
  }) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      _ongoingChannelId,
      'Timer',
      channelDescription: 'Shows rest timer countdown',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: false,
      category: AndroidNotificationCategory.stopwatch,
      visibility: NotificationVisibility.public,
      playSound: false,
      enableVibration: false,
    );

    // Same rest, countdown drawn by the system: nothing to refresh.
    final signature = '${endTime.millisecondsSinceEpoch}|$body';
    if (_serviceRunning && _systemDrawsCountdown && signature == _lastPosted) {
      return;
    }
    _lastPosted = signature;

    if (_serviceRunning) {
      await _postOngoing(
        title, body, label, actionLabel, endTime, total, androidDetails);
      return;
    }

    // Posted as a plain notification first: Android delays the notification
    // of a freshly started foreground service by up to 10 s unless it is
    // already on screen.
    await _plugin.show(
      id: _ongoingId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );

    _serviceRunning = true;
    try {
      await _android?.startForegroundService(
        id: _ongoingId,
        title: title,
        body: body,
        notificationDetails: androidDetails,
        startType: AndroidServiceStartType.startNotSticky,
        foregroundServiceTypes: {
          AndroidServiceForegroundType.foregroundServiceTypeSpecialUse,
        },
      );
    } catch (_) {
      _serviceRunning = false;
      rethrow;
    }
    await _postOngoing(
        title, body, label, actionLabel, endTime, total, androidDetails);
  }

  /// Posts through the activity, which adds what the plugin cannot: the
  /// HyperOS focus payload that makes the system draw the big countdown.
  Future<void> _postOngoing(
    String title,
    String body,
    String label,
    String actionLabel,
    DateTime endTime,
    Duration total,
    AndroidNotificationDetails fallbackDetails,
  ) async {
    try {
      final systemDrawn =
          await _nativeTimer.invokeMethod<bool>('show', <String, Object>{
        'id': _ongoingId,
        'channelId': _ongoingChannelId,
        'title': title,
        'body': body,
        'label': label,
        'actionLabel': actionLabel,
        'endMs': endTime.millisecondsSinceEpoch,
        'totalMs': total.inMilliseconds,
      });
      _systemDrawsCountdown = systemDrawn ?? false;
    } on MissingPluginException {
      await _plugin.show(
        id: _ongoingId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: fallbackDetails),
      );
    }
  }

  AndroidNotificationDetails _alertDetails({
    required bool vibrate,
    required String actionLabel,
    bool reminder = false,
  }) {
    // Opens the app and starts the next rest (see [onNextSet]).
    final actions = [
      AndroidNotificationAction(
        _nextSetActionId,
        actionLabel,
        showsUserInterface: true,
        cancelNotification: true,
      ),
    ];

    if (!vibrate) {
      return AndroidNotificationDetails(
        _alertChannelId,
        'Timer Alert',
        channelDescription: 'Alert when timer finishes',
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: true,
        playSound: false,
        enableVibration: false,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        actions: actions,
      );
    }
    return AndroidNotificationDetails(
      reminder ? _reminderChannelId : _alertVibrateChannelId,
      reminder ? 'Back to training reminder' : 'Timer Alert (vibration)',
      channelDescription: reminder
          ? 'Vibrates when too long passes without starting a set'
          : 'Alert with vibration when timer finishes',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      playSound: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(
        reminder ? [0, 800, 300, 800, 300, 800] : [0, 500, 200, 500],
      ),
      category: reminder
          ? AndroidNotificationCategory.reminder
          : AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      actions: actions,
    );
  }

  /// Shows the "time is up" notification right now, without vibration
  /// (the caller vibrates on its own while the app is in the foreground).
  Future<void> showAlertNotification({
    required String title,
    required String body,
    required String actionLabel,
  }) async {
    if (!_initialized) return;
    await _plugin.show(
      id: _alertId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: _alertDetails(vibrate: false, actionLabel: actionLabel),
      ),
    );
  }

  /// Hands the "time is up" notification to AlarmManager, so it fires at
  /// [at] even if the app is suspended or its process was killed.
  Future<void> scheduleAlert({
    required String title,
    required String body,
    required String actionLabel,
    required DateTime at,
    required bool vibrate,
  }) async {
    if (!_initialized) return;
    if (!at.isAfter(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: _alertId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.UTC),
      notificationDetails: NotificationDetails(
        android: _alertDetails(vibrate: vibrate, actionLabel: actionLabel),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Removes the alert, whether it is still scheduled or already on screen.
  Future<void> cancelAlert() async {
    if (!_initialized) return;
    await _plugin.cancel(id: _alertId);
  }

  /// (Re)arms the "back to training" reminder: fires at [at] unless another
  /// set is started (which calls this again) or the timer is reset.
  Future<void> scheduleReminder({
    required String title,
    required String body,
    required String actionLabel,
    required DateTime at,
    required bool vibrate,
  }) async {
    if (!_initialized) return;
    await _plugin.cancel(id: _reminderId);
    if (!at.isAfter(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: _reminderId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.UTC),
      notificationDetails: NotificationDetails(
        android: _alertDetails(
          vibrate: vibrate,
          actionLabel: actionLabel,
          reminder: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder() async {
    if (!_initialized) return;
    await _plugin.cancel(id: _reminderId);
  }

  Future<void> cancelOngoing() async {
    if (!_initialized) return;
    _serviceRunning = false;
    _lastPosted = null;
    await _android?.stopForegroundService();
    await _plugin.cancel(id: _ongoingId);
  }

  Future<void> cancel() async {
    await cancelOngoing();
    await cancelAlert();
    await cancelReminder();
  }
}

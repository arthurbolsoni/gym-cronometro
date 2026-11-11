import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _serviceRunning = false;

  // Default importance: HyperOS hides low-importance ("silent") notifications
  // on the lock screen. The channel has no sound or vibration of its own.
  static const _ongoingChannelId = 'timer_running';
  static const _legacyOngoingChannelId = 'timer_ongoing';
  static const _alertChannelId = 'timer_alert';
  static const _alertVibrateChannelId = 'timer_alert_vibrate';
  static const _ongoingId = 1;
  static const _alertId = 2;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('ic_stat_timer');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: settings);
    await _android?.deleteNotificationChannel(
      channelId: _legacyOngoingChannelId,
    );
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

    // Posted as a plain notification first: Android delays the notification
    // of a freshly started foreground service by up to 10 s unless it is
    // already on screen.
    await _plugin.show(
      id: _ongoingId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
    if (_serviceRunning) return;

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
  }

  AndroidNotificationDetails _alertDetails({required bool vibrate}) {
    if (vibrate) {
      return AndroidNotificationDetails(
        _alertVibrateChannelId,
        'Timer Alert (vibration)',
        channelDescription: 'Alert with vibration when timer finishes',
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: true,
        playSound: false,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
      );
    }
    return const AndroidNotificationDetails(
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
    );
  }

  /// Shows the "time is up" notification right now, without vibration
  /// (the caller vibrates on its own while the app is in the foreground).
  Future<void> showAlertNotification(String title, String body) async {
    if (!_initialized) return;
    await _plugin.show(
      id: _alertId,
      title: title,
      body: body,
      notificationDetails:
          NotificationDetails(android: _alertDetails(vibrate: false)),
    );
  }

  /// Hands the "time is up" notification to AlarmManager, so it fires at
  /// [at] even if the app is suspended or its process was killed.
  Future<void> scheduleAlert({
    required String title,
    required String body,
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
      notificationDetails:
          NotificationDetails(android: _alertDetails(vibrate: vibrate)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Removes the alert, whether it is still scheduled or already on screen.
  Future<void> cancelAlert() async {
    if (!_initialized) return;
    await _plugin.cancel(id: _alertId);
  }

  Future<void> cancelOngoing() async {
    if (!_initialized) return;
    _serviceRunning = false;
    await _android?.stopForegroundService();
    await _plugin.cancel(id: _ongoingId);
  }

  Future<void> cancel() async {
    await cancelOngoing();
    await cancelAlert();
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _ongoingChannelId = 'timer_ongoing';
  static const _alertChannelId = 'timer_alert';
  static const _notificationId = 1;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<void> showOngoingTimer(String title, String body) async {
    if (!_initialized) return;
    final androidDetails = AndroidNotificationDetails(
      _ongoingChannelId,
      'Timer',
      channelDescription: 'Shows rest timer countdown',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      silent: true,
    );

    await _plugin.show(
      id: _notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  Future<void> showAlertNotification(String title, String body) async {
    if (!_initialized) return;
    final androidDetails = AndroidNotificationDetails(
      _alertChannelId,
      'Timer Alert',
      channelDescription: 'Alert when timer finishes',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      playSound: false,
      enableVibration: false,
    );

    await _plugin.show(
      id: _notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  Future<void> cancel() async {
    if (!_initialized) return;
    await _plugin.cancel(id: _notificationId);
  }
}

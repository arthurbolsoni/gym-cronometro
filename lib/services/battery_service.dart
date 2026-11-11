import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Battery optimization exemption. HyperOS/MIUI freezes the app about 90 s
/// after it leaves the screen unless the user exempts it, which stalls the
/// countdown shown in the notification.
class BatteryService {
  BatteryService._();
  static final instance = BatteryService._();

  static const _channel = MethodChannel('gym_timer/battery');
  static const _askedKey = 'battery_exemption_asked';

  /// Opens the system dialog once; afterwards the choice is left to the user.
  Future<void> requestExemptionOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_askedKey) ?? false) return;

      final ignoring =
          await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      if (ignoring ?? true) return;

      await prefs.setBool(_askedKey, true);
      await _channel.invokeMethod<bool>('requestIgnoreBatteryOptimizations');
    } on MissingPluginException {
      // Platform without the channel (tests, non-Android).
    } on PlatformException {
      // Dialog unavailable on this device; the timer still works.
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Anonymous per-install device id — no login required.
abstract final class DeviceIdentity {
  static const _key = 'court_companion_device_id';

  static Future<String> ensureDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.length >= 8) {
      return existing;
    }
    final id = const Uuid().v4();
    await prefs.setString(_key, id);
    return id;
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

/// Web: prefer localStorage (reliable across Flutter web builds), with SharedPreferences backup.
Future<String?> readDeviceId(String key) async {
  try {
    final fromLs = web.window.localStorage.getItem(key);
    if (fromLs != null && fromLs.length >= 8) {
      return fromLs;
    }
  } catch (_) {}

  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  } catch (_) {
    return null;
  }
}

Future<void> writeDeviceId(String key, String value) async {
  try {
    web.window.localStorage.setItem(key, value);
  } catch (_) {}

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  } catch (_) {}
}

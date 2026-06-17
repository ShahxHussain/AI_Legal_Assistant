import 'package:uuid/uuid.dart';

import 'device_storage_platform.dart';

/// Anonymous per-install device id — no login required.
/// Cached in memory after first read so chat/voice always send `device_id` to the API.
abstract final class DeviceIdentity {
  static const _key = 'court_companion_device_id';

  static String? _cached;

  /// Last resolved id (may be null until [ensureDeviceId] completes).
  static String? get current => _cached;

  static Future<String> ensureDeviceId() async {
    if (_cached != null && _cached!.length >= 8) {
      return _cached!;
    }

    final existing = await readDeviceId(_key);
    if (existing != null && existing.length >= 8) {
      _cached = existing;
      return existing;
    }

    final id = const Uuid().v4();
    await writeDeviceId(_key, id);
    _cached = id;
    return id;
  }
}

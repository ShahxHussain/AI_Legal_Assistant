import 'package:flutter/foundation.dart'
    show kIsWeb, kReleaseMode, defaultTargetPlatform, TargetPlatform;

/// API configuration for Court Companion backend.
///
/// Auto-detects platform when `API_BASE_URL` is not set:
///   Android release APK      → Render production URL
///   Android debug / emulator → http://10.0.2.2:8000
///   Web / Windows / desktop  → http://localhost:8000
///
/// Override at run/build time:
///   flutter run -d chrome
///   flutter run -d android --dart-define=API_BASE_URL=http://192.168.1.10:8000
class ApiConfig {
  static const String _envUrl = String.fromEnvironment('API_BASE_URL');

  /// Deployed FastAPI backend on Render (used by release APK).
  static const String productionUrl =
      'https://ai-legal-assistant-fes8.onrender.com';

  static String get baseUrl {
    if (_envUrl.isNotEmpty) {
      return _envUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kReleaseMode ? productionUrl : 'http://10.0.2.2:8000';
    }
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    return 'http://localhost:8000';
  }

  static String get healthUrl => '$baseUrl/health';
  static String get askUrl => '$baseUrl/ask';
  static String get askStreamUrl => '$baseUrl/ask/stream';
  static String get analyzeDocumentUrl => '$baseUrl/analyze-document';
}

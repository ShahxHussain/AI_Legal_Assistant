import 'package:flutter/foundation.dart'
    show kReleaseMode, defaultTargetPlatform, TargetPlatform;

/// API configuration for Court Companion backend.
///
/// Auto-detects platform when `API_BASE_URL` is not set:
///   Release (APK or web)     → Render production URL
///   Android debug / emulator → http://10.0.2.2:8000
///   Web / desktop debug      → http://127.0.0.1:8000
///
/// Override at run/build time:
///   flutter run -d chrome
///   flutter run -d android --dart-define=API_BASE_URL=http://127.0.0.1:8000
class ApiConfig {
  static const String _envUrl = String.fromEnvironment('API_BASE_URL');

  /// Local dev API — use 127.0.0.1 (not localhost) to avoid Windows IPv6 issues.
  static const String localDevUrl = 'http://127.0.0.1:8000';

  /// Deployed FastAPI backend on Render (used by release APK).
  static const String productionUrl =
      'https://ai-legal-assistant-fes8.onrender.com';

  static String get baseUrl {
    if (_envUrl.isNotEmpty) {
      return _envUrl;
    }
    // Release APK and release web both talk to Render.
    if (kReleaseMode) {
      return productionUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return localDevUrl;
  }

  static String get healthUrl => '$baseUrl/health';
  static String get askUrl => '$baseUrl/ask';
  static String get askStreamUrl => '$baseUrl/ask/stream';
  static String get analyzeDocumentUrl => '$baseUrl/analyze-document';
  static String get feedbackUrl => '$baseUrl/feedback';
}

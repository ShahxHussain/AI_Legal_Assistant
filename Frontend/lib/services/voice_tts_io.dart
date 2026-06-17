import 'dart:collection';

import 'package:flutter_tts/flutter_tts.dart';

/// Native TTS via flutter_tts (Android, iOS, Windows, macOS).
class PlatformTts {
  final FlutterTts _tts = FlutterTts();
  final Queue<String> _queue = Queue<String>();
  bool _ready = false;
  bool _processing = false;
  String _language = 'en-US';

  String get language => _language;

  Future<bool> init({String language = 'en-US'}) async {
    try {
      _language = language;
      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(0.52);
      await _tts.setPitch(1.05);
      await _tts.awaitSpeakCompletion(true);
      _ready = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setLanguage(String language) async {
    _language = language;
    if (!_ready) return false;
    try {
      final result = await _tts.setLanguage(language);
      if (result is int) return result == 1;
      if (result is bool) return result;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLanguageAvailable(String language) async {
    try {
      final result = await _tts.isLanguageAvailable(language);
      if (result is int) return result == 1;
      if (result is bool) return result;
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLanguageInstalled(String language) async {
    try {
      final result = await _tts.isLanguageInstalled(language);
      if (result is int) return result == 1;
      if (result is bool) return result;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// True when a TTS engine reports an Urdu voice (installed or bundled).
  Future<bool> hasUrduVoice() async {
    if (!_ready) return false;
    try {
      if (await isLanguageInstalled('ur-PK')) return true;
      final voices = await _tts.getVoices;
      if (voices is! List) return false;
      for (final raw in voices) {
        if (raw is! Map) continue;
        final locale = (raw['locale'] ?? raw['name'] ?? '').toString().toLowerCase();
        if (locale.startsWith('ur')) return true;
      }
    } catch (_) {}
    return false;
  }

  void enqueue(String text) {
    if (!_ready || text.trim().isEmpty) return;
    _queue.add(text.trim());
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;
    while (_queue.isNotEmpty) {
      final chunk = _queue.removeFirst();
      try {
        await _tts.speak(chunk);
      } catch (_) {}
    }
    _processing = false;
  }

  Future<void> speak(String text) async {
    if (!_ready || text.isEmpty) return;
    stop();
    enqueue(text);
    await drain();
  }

  Future<void> drain() async {
    while (_processing || _queue.isNotEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> stop() async {
    _queue.clear();
    try {
      await _tts.stop();
    } catch (_) {}
    _processing = false;
  }
}

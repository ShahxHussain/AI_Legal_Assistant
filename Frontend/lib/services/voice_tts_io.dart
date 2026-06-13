import 'dart:collection';

import 'package:flutter_tts/flutter_tts.dart';

/// Native TTS via flutter_tts (Android, iOS, Windows, macOS).
class PlatformTts {
  final FlutterTts _tts = FlutterTts();
  final Queue<String> _queue = Queue<String>();
  bool _ready = false;
  bool _processing = false;

  Future<bool> init() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.52);
      await _tts.setPitch(1.05);
      await _tts.awaitSpeakCompletion(true);
      _ready = true;
      return true;
    } catch (_) {
      return false;
    }
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

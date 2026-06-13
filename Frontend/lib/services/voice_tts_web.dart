import 'dart:async';

import 'package:web/web.dart' as web;

/// Browser TTS — flutter_tts is not available on Flutter web.
class PlatformTts {
  bool _ready = false;

  Future<bool> init() async {
    _ready = true;
    return _ready;
  }

  /// Queue a phrase without cancelling earlier ones (for streaming speech).
  void enqueue(String text) {
    if (!_ready || text.trim().isEmpty) return;
    final utterance = web.SpeechSynthesisUtterance(text.trim());
    utterance.lang = 'en-US';
    utterance.rate = 0.92;
    web.window.speechSynthesis.speak(utterance);
  }

  Future<void> speak(String text) async {
    if (!_ready || text.isEmpty) return;
    await stop();
    enqueue(text);
    await drain();
  }

  Future<void> drain() async {
    while (_isActive) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
  }

  bool get _isActive =>
      web.window.speechSynthesis.speaking || web.window.speechSynthesis.pending;

  Future<void> stop() async {
    web.window.speechSynthesis.cancel();
  }
}

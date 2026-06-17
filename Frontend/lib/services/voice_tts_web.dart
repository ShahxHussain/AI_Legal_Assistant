import 'dart:async';

import 'package:web/web.dart' as web;

/// Browser TTS — flutter_tts is not available on Flutter web.
class PlatformTts {
  bool _ready = false;
  String _language = 'en-US';
  web.SpeechSynthesisVoice? _voice;

  String get language => _language;

  Future<bool> init({String language = 'en-US'}) async {
    _ready = true;
    return setLanguage(language);
  }

  Future<bool> setLanguage(String language) async {
    _language = language;
    _voice = await _pickVoice(language);
    return _voice != null || language.startsWith('en');
  }

  Future<bool> isLanguageAvailable(String language) async {
    final voice = await _pickVoice(language);
    return voice != null;
  }

  Future<bool> hasUrduVoice() async => isLanguageAvailable('ur-PK');

  Future<web.SpeechSynthesisVoice?> _pickVoice(String language) async {
    var voices = web.window.speechSynthesis.getVoices();
    if (voices.length == 0) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      voices = web.window.speechSynthesis.getVoices();
    }

    final prefix = language.split('-').first.toLowerCase();
    final target = language.toLowerCase();

    for (var i = 0; i < voices.length; i++) {
      final voice = voices[i];
      final lang = voice.lang.toLowerCase();
      if (lang == target || lang.startsWith('$prefix-')) {
        return voice;
      }
    }
    for (var i = 0; i < voices.length; i++) {
      final voice = voices[i];
      if (voice.lang.toLowerCase().startsWith(prefix)) {
        return voice;
      }
    }
    return null;
  }

  void enqueue(String text) {
    if (!_ready || text.trim().isEmpty) return;
    final utterance = web.SpeechSynthesisUtterance(text.trim());
    utterance.lang = _language;
    utterance.rate = 1.0;
    utterance.pitch = 1.02;
    if (_voice != null) {
      utterance.voice = _voice;
    }
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

import 'voice_tts_platform.dart';

/// Speaks streamed answer text chunk-by-chunk as sentences arrive.
class VoiceStreamSpeaker {
  VoiceStreamSpeaker(this._tts);

  final PlatformTts _tts;
  String _lastCleaned = '';
  String _buffer = '';
  bool _started = false;

  bool get hasStarted => _started;

  void reset() {
    _lastCleaned = '';
    _buffer = '';
    _started = false;
    _tts.stop();
  }

  /// Feed the latest full partial answer; queues speakable phrases.
  void feed(String fullPartial, String Function(String) strip) {
    final cleaned = strip(fullPartial);
    if (cleaned.length <= _lastCleaned.length) return;

    _buffer += cleaned.substring(_lastCleaned.length);
    _lastCleaned = cleaned;
    _flushPhrases(forcePartial: false);
  }

  void finish(String fullText, String Function(String) strip) {
    final cleaned = strip(fullText);
    if (cleaned.length > _lastCleaned.length) {
      _buffer += cleaned.substring(_lastCleaned.length);
      _lastCleaned = cleaned;
    }
    _flushPhrases(forcePartial: true);
    final tail = _buffer.trim();
    if (tail.isNotEmpty) {
      _speakChunk(tail);
      _buffer = '';
    }
  }

  Future<void> drain() => _tts.drain();

  void _flushPhrases({required bool forcePartial}) {
    while (true) {
      final punct = _buffer.indexOf(RegExp(r'[.!?۔]'));
      if (punct != -1) {
        var end = punct + 1;
        while (end < _buffer.length && _buffer[end] == ' ') {
          end++;
        }
        final phrase = _buffer.substring(0, end).trim();
        _buffer = _buffer.substring(end);
        if (phrase.length >= 6) {
          _speakChunk(phrase);
          continue;
        }
      }

      if (!_started && _buffer.length >= 40) {
        final space = _buffer.lastIndexOf(' ');
        if (space >= 20) {
          final phrase = _buffer.substring(0, space).trim();
          _buffer = _buffer.substring(space);
          if (phrase.isNotEmpty) {
            _speakChunk(phrase);
            continue;
          }
        }
      }

      if (forcePartial || _buffer.length >= 90) {
        final comma = _buffer.lastIndexOf(',');
        final semi = _buffer.lastIndexOf(';');
        final cut = comma > semi ? comma : semi;
        if (cut >= 35) {
          final phrase = _buffer.substring(0, cut + 1).trim();
          _buffer = _buffer.substring(cut + 1);
          if (phrase.length >= 20) {
            _speakChunk(phrase);
            continue;
          }
        }
      }
      break;
    }
  }

  void _speakChunk(String phrase) {
    _tts.enqueue(phrase);
    _started = true;
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'voice_stream_speaker.dart';
import 'voice_tts_platform.dart';

class VoiceInitResult {
  const VoiceInitResult({
    required this.sttReady,
    required this.ttsReady,
    this.hint,
  });

  final bool sttReady;
  final bool ttsReady;
  final String? hint;
}

/// On-device speech-to-text (listen) and text-to-speech (speak).
class VoiceService {
  final SpeechToText _stt = SpeechToText();
  final PlatformTts _tts = PlatformTts();
  late final VoiceStreamSpeaker _streamSpeaker = VoiceStreamSpeaker(_tts);
  bool _sttReady = false;
  bool _ttsReady = false;
  String? _lastHint;
  bool _keepListening = false;
  bool _resuming = false;
  String _dictationBuffer = '';
  void Function(String text, bool isFinal)? _wordsHandler;
  String _localeId = 'en_US';

  bool get isSttReady => _sttReady;
  bool get isTtsReady => _ttsReady;
  bool get isListening => _stt.isListening;
  bool get isStreamSpeaking => _streamSpeaker.hasStarted;
  String? get lastHint => _lastHint;

  Future<VoiceInitResult> init({bool requestPermission = false}) async {
    _lastHint = null;

    if (requestPermission && !kIsWeb) {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        _lastHint =
            'Microphone permission denied. Allow mic access in app settings, '
            'then tap Retry below.';
        return VoiceInitResult(
          sttReady: false,
          ttsReady: _ttsReady,
          hint: _lastHint,
        );
      }
    }

    try {
      _sttReady = await _stt.initialize(
        onError: (_) {},
        onStatus: _onSttStatus,
      );

      if (!_sttReady && requestPermission) {
        _sttReady = await _stt.initialize(
          onError: (_) {},
          onStatus: _onSttStatus,
        );
      }

      if (!_sttReady && requestPermission) {
        final permitted = await _stt.hasPermission;
        if (!permitted) {
          _lastHint =
              'Allow microphone access when prompted. USB headsets work — '
              'set your headset mic as the default recording device in '
              'Windows Sound settings if needed.';
        } else if (kIsWeb) {
          _lastHint =
              'Use Chrome or Edge, allow the microphone in the browser bar, '
              'then tap the mic again.';
        } else {
          _lastHint =
              'Speech recognition could not start. Enable the microphone in '
              'Windows Settings → Privacy → Microphone, then tap Retry.';
        }
      }
    } catch (e) {
      _lastHint = 'Could not start speech recognition: $e';
      _sttReady = false;
    }

    _ttsReady = await _tts.init();

    final sttReady = _sttReady || (kIsWeb && requestPermission);

    return VoiceInitResult(
      sttReady: sttReady,
      ttsReady: _ttsReady,
      hint: _lastHint,
    );
  }

  void _onSttStatus(String status) {
    if (!_keepListening || _wordsHandler == null) return;
    final s = status.toLowerCase();
    if (!s.contains('done') && !s.contains('notlistening')) return;
    _scheduleResume();
  }

  Future<void> _scheduleResume() async {
    if (!_keepListening || _resuming || _wordsHandler == null) return;
    _resuming = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!_keepListening || _stt.isListening || _wordsHandler == null) return;
      await _beginListen();
    } finally {
      _resuming = false;
    }
  }

  Future<void> startListening({
    required void Function(String text, bool isFinal) onWords,
    String localeId = 'en_US',
  }) async {
    await stopListening();

    if (!_sttReady) {
      final result = await init(requestPermission: true);
      if (!result.sttReady) return;
    }

    _wordsHandler = onWords;
    _localeId = localeId;
    _keepListening = true;
    _dictationBuffer = '';

    await _beginListen();
  }

  Future<void> _beginListen() async {
    if (!_keepListening || _wordsHandler == null) return;

    if (_stt.isListening) {
      await _stt.stop();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    final handler = _wordsHandler!;
    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        handler(_mergeTranscript(result), result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        listenMode: ListenMode.dictation,
        listenFor: const Duration(minutes: 3),
        pauseFor: const Duration(seconds: 15),
        partialResults: true,
        cancelOnError: false,
        onDevice: false,
      ),
    );
  }

  String _mergeTranscript(SpeechRecognitionResult result) {
    final segment = result.recognizedWords.trim();
    if (segment.isEmpty) return _dictationBuffer;

    if (_dictationBuffer.isEmpty) {
      if (result.finalResult) _dictationBuffer = segment;
      return segment;
    }

    if (segment.startsWith(_dictationBuffer)) {
      if (result.finalResult) _dictationBuffer = segment;
      return segment;
    }

    if (_dictationBuffer.startsWith(segment)) {
      return _dictationBuffer;
    }

    final merged = '$_dictationBuffer $segment';
    if (result.finalResult) {
      _dictationBuffer = merged;
    }
    return merged;
  }

  Future<void> stopListening() async {
    _keepListening = false;
    _wordsHandler = null;
    if (_stt.isListening) {
      await _stt.stop();
    }
  }

  void resetStreamSpeech() {
    if (_ttsReady) _streamSpeaker.reset();
  }

  /// Returns true the first time a spoken chunk is queued.
  bool feedStreamSpeech(String fullPartial) {
    if (!_ttsReady) return false;
    final wasStarted = _streamSpeaker.hasStarted;
    _streamSpeaker.feed(fullPartial, stripForSpeech);
    return !wasStarted && _streamSpeaker.hasStarted;
  }

  Future<void> finishStreamSpeech(String fullAnswer) async {
    if (!_ttsReady) return;
    _streamSpeaker.finish(fullAnswer, stripForSpeech);
    await _streamSpeaker.drain();
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _streamSpeaker.reset();
  }

  /// Plain-text cleanup for TTS — never use replaceAll(..., r'$1') (reads as "one dollar").
  static String stripForSpeech(String text) {
    var s = text;

    s = s.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (m) => m.group(1) ?? '',
    );
    s = s.replaceAllMapped(
      RegExp(r'\*([^*]+)\*'),
      (m) => m.group(1) ?? '',
    );
    s = s.replaceAll('**', '').replaceAll('*', '');

    s = s.replaceAll(
      RegExp(r'\[Source\s+\d+[^\]]*\]', caseSensitive: false),
      '',
    );
    s = s.replaceAll(RegExp(r'\[(\d+)\]'), '');
    s = s.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (m) => m.group(1) ?? '',
    );

    s = s.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    s = s.replaceAll(RegExp(r'(?<=\s|^)\d+\.\s+'), '');
    s = s.replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '');
    s = s.replaceAll(RegExp(r'^[-*•]\s+', multiLine: true), '');

    s = s.replaceAllMapped(
      RegExp(
        r'Section\s+(\d+)\s+(?:of\s+)?(?:the\s+)?(?:PPC|CrPC)',
        caseSensitive: false,
      ),
      (m) => 'section ${m.group(1)}',
    );
    s = s.replaceAllMapped(
      RegExp(r'§\s*(\d+)'),
      (m) => 'section ${m.group(1)}',
    );

    s = s.replaceAll(r'$', '');
    s = s.replaceAll('⚖️', '');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    s = s.replaceAll(RegExp(r'\n{2,}'), '. ');

    return s.trim();
  }
}

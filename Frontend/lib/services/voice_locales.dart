/// Voice-enabled backend language codes and locale mapping for STT/TTS.
const kVoiceDefaultLanguage = 'english';

const kVoiceEnabledLanguages = <String>{'english', 'urdu_script'};

/// BCP-47 tag for [flutter_tts] / browser speechSynthesis.
String ttsLocaleForVoiceLanguage(String code) {
  switch (code) {
    case 'urdu_script':
      return 'ur-PK';
    default:
      return 'en-US';
  }
}

/// Locale id for [speech_to_text] (underscore form).
String sttLocaleForVoiceLanguage(String code) {
  switch (code) {
    case 'urdu_script':
      return 'ur_PK';
    default:
      return 'en_US';
  }
}

bool isUrduVoiceLanguage(String code) => code == 'urdu_script';

import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';

bool get canInstallVoicePacksInApp => Platform.isAndroid;

/// Opens Google / system UI to download TTS voices (user taps Urdu → Install).
Future<bool> installTtsVoiceData() async {
  if (!Platform.isAndroid) return false;
  const intent = AndroidIntent(
    action: 'android.speech.tts.engine.INSTALL_TTS_DATA',
  );
  await intent.launch();
  return true;
}

/// Voice typing languages — user can enable Urdu (اردو) for the mic.
Future<bool> openVoiceInputSettings() async {
  if (!Platform.isAndroid) return false;
  const intent = AndroidIntent(
    action: 'android.settings.VOICE_INPUT_SETTINGS',
  );
  await intent.launch();
  return true;
}

/// Opens Google app settings (Assistant / voice languages on many phones).
Future<bool> openGoogleAppSettings() async {
  if (!Platform.isAndroid) return false;
  const intent = AndroidIntent(
    action: 'android.intent.action.APPLICATION_PREFERENCES',
    package: 'com.google.android.googlequicksearchbox',
  );
  await intent.launch();
  return true;
}

/// System text-to-speech output settings.
Future<bool> openTtsSettings() async {
  if (!Platform.isAndroid) return false;
  const intent = AndroidIntent(
    action: 'android.settings.TTS_SETTINGS',
  );
  await intent.launch();
  return true;
}

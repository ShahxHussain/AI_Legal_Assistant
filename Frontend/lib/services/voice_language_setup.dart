import 'voice_setup_platform.dart';

Future<bool> launchUrduTtsInstaller() => installTtsVoiceData();

Future<bool> launchUrduSttInstaller() => openVoiceInputSettings();

Future<bool> launchTtsSettings() => openTtsSettings();

Future<bool> launchGoogleAppSettings() => openGoogleAppSettings();

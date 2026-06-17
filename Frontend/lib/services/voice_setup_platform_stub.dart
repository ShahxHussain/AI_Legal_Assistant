/// Web / desktop — no in-app OS voice pack installer.
Future<bool> installTtsVoiceData() async => false;

Future<bool> openVoiceInputSettings() async => false;

Future<bool> openTtsSettings() async => false;

Future<bool> openGoogleAppSettings() async => false;

bool get canInstallVoicePacksInApp => false;

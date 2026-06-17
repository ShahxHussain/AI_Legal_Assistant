import 'package:court_companion/services/voice_locales.dart';
import 'package:court_companion/widgets/urdu_voice_help_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('voice_locales', () {
    test('maps English and Urdu to STT/TTS locales', () {
      expect(sttLocaleForVoiceLanguage('english'), 'en_US');
      expect(ttsLocaleForVoiceLanguage('english'), 'en-US');
      expect(sttLocaleForVoiceLanguage('urdu_script'), 'ur_PK');
      expect(ttsLocaleForVoiceLanguage('urdu_script'), 'ur-PK');
    });

    test('voice enabled languages include English and Urdu', () {
      expect(kVoiceEnabledLanguages, contains('english'));
      expect(kVoiceEnabledLanguages, contains('urdu_script'));
      expect(kVoiceEnabledLanguages.length, 2);
    });
  });

  group('UrduVoiceHelpSheet', () {
    testWidgets('shows informational help without setup checks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UrduVoiceHelpSheet(),
          ),
        ),
      );

      expect(find.text('Urdu voice help'), findsOneWidget);
      expect(find.textContaining('no setup needed'), findsOneWidget);
      expect(find.text('Spoken answers (optional)'), findsOneWidget);
      expect(find.text('Urdu microphone (optional)'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(find.text('Check again'), findsNothing);
      expect(find.text('Skip for now'), findsNothing);
    });
  });
}

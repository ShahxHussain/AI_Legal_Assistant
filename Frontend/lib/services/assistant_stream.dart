import '../models/legal_source.dart';
import 'api_service.dart';

class AssistantStreamResult {
  const AssistantStreamResult({
    required this.answer,
    this.sources = const [],
    this.disclaimer,
  });

  final String answer;
  final List<LegalSource> sources;
  final String? disclaimer;
}

/// Same streaming pipeline as chat — shared by ChatScreen and VoiceScreen.
Future<AssistantStreamResult> streamAssistantAnswer(
  ApiService api, {
  required String question,
  required String language,
  void Function(String partial)? onPartial,
  void Function(List<LegalSource> sources, String? disclaimer)? onMeta,
}) async {
  var answerText = '';
  var sources = <LegalSource>[];
  String? disclaimer;
  var receivedDelta = false;

  await for (final event in api.askStream(question, language: language)) {
    switch (event['type'] as String?) {
      case 'meta':
        final rawSources = event['sources'] as List<dynamic>? ?? [];
        sources = [
          for (var i = 0; i < rawSources.length; i++)
            LegalSource.fromJson(
              rawSources[i] as Map<String, dynamic>,
              index: i + 1,
            ),
        ];
        disclaimer = event['disclaimer'] as String?;
        onMeta?.call(sources, disclaimer);
      case 'delta':
        answerText += event['text'] as String? ?? '';
        receivedDelta = true;
        onPartial?.call(answerText);
      case 'done':
        final finalAnswer = event['answer'] as String?;
        if (finalAnswer != null && finalAnswer.isNotEmpty) {
          answerText = finalAnswer;
          onPartial?.call(answerText);
        }
      case 'error':
        throw ApiException(
          event['detail'] as String? ?? 'Streaming failed',
        );
    }
  }

  if (!receivedDelta) {
    throw ApiException('Connection lost before the answer arrived');
  }

  return AssistantStreamResult(
    answer: answerText,
    sources: sources,
    disclaimer: disclaimer,
  );
}

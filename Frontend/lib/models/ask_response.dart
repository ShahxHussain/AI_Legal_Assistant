import 'legal_source.dart';

class AskResponse {
  const AskResponse({
    required this.answer,
    required this.sources,
    required this.disclaimer,
    this.documentName,
    this.documentTruncated = false,
  });

  final String answer;
  final List<LegalSource> sources;
  final String disclaimer;
  final String? documentName;
  final bool documentTruncated;

  factory AskResponse.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'] as List<dynamic>? ?? [];
    return AskResponse(
      answer: json['answer'] as String? ?? '',
      sources: rawSources.asMap().entries.map((e) {
        return LegalSource.fromJson(
          e.value as Map<String, dynamic>,
          index: e.key + 1,
        );
      }).toList(),
      disclaimer: json['disclaimer'] as String? ?? '',
      documentName: json['document_name'] as String?,
      documentTruncated: json['document_truncated'] as bool? ?? false,
    );
  }
}

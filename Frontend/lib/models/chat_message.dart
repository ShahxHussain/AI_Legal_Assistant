import 'legal_source.dart';

enum MessageRole { user, assistant, error }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.sources = const [],
    this.disclaimer,
    this.isLoading = false,
    this.attachmentName,
    this.feedbackRating,
  });

  final String id;
  final MessageRole role;
  final String text;
  final List<LegalSource> sources;
  final String? disclaimer;
  final bool isLoading;
  final String? attachmentName;
  /// `up` or `down` after user rates this assistant reply.
  final String? feedbackRating;

  static final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  bool get canReceiveFeedback =>
      role == MessageRole.assistant &&
      !isLoading &&
      _uuidPattern.hasMatch(id);

  ChatMessage copyWith({
    String? id,
    String? text,
    List<LegalSource>? sources,
    String? disclaimer,
    bool? isLoading,
    MessageRole? role,
    String? attachmentName,
    String? feedbackRating,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      sources: sources ?? this.sources,
      disclaimer: disclaimer ?? this.disclaimer,
      isLoading: isLoading ?? this.isLoading,
      attachmentName: attachmentName ?? this.attachmentName,
      feedbackRating: feedbackRating ?? this.feedbackRating,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'text': text,
        'sources': sources.map((s) => s.toJson()).toList(),
        'disclaimer': disclaimer,
        'attachmentName': attachmentName,
        'feedbackRating': feedbackRating,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final roleName = json['role'] as String? ?? 'assistant';
    final rawSources = json['sources'] as List<dynamic>? ?? [];
    return ChatMessage(
      id: json['id'] as String? ?? '',
      role: MessageRole.values.firstWhere(
        (r) => r.name == roleName,
        orElse: () => MessageRole.assistant,
      ),
      text: json['content'] as String? ?? json['text'] as String? ?? '',
      sources: [
        for (var i = 0; i < rawSources.length; i++)
          LegalSource.fromJson(
            rawSources[i] as Map<String, dynamic>,
            index: i + 1,
          ),
      ],
      disclaimer: json['disclaimer'] as String?,
      attachmentName: json['attachmentName'] as String?,
      feedbackRating: json['feedbackRating'] as String?,
    );
  }
}

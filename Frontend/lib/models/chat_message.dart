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
  });

  final String id;
  final MessageRole role;
  final String text;
  final List<LegalSource> sources;
  final String? disclaimer;
  final bool isLoading;
  final String? attachmentName;

  ChatMessage copyWith({
    String? text,
    List<LegalSource>? sources,
    String? disclaimer,
    bool? isLoading,
    MessageRole? role,
    String? attachmentName,
  }) {
    return ChatMessage(
      id: id,
      role: role ?? this.role,
      text: text ?? this.text,
      sources: sources ?? this.sources,
      disclaimer: disclaimer ?? this.disclaimer,
      isLoading: isLoading ?? this.isLoading,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }
}

class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.title,
    this.updatedAt,
    this.isActive = false,
  });

  final String id;
  final String title;
  final DateTime? updatedAt;
  final bool isActive;

  ConversationSummary copyWith({
    String? title,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ConversationSummary(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  static ConversationSummary fromApi(
    Map<String, dynamic> json, {
    String? titleOverride,
    bool isActive = false,
  }) {
    final updatedRaw = json['updated_at'] as String?;
    DateTime? updatedAt;
    if (updatedRaw != null) {
      updatedAt = DateTime.tryParse(updatedRaw);
    }
    return ConversationSummary(
      id: json['id'] as String,
      title: titleOverride ?? _fallbackTitle(updatedAt),
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  static String _fallbackTitle(DateTime? updatedAt) {
    if (updatedAt == null) return 'Legal chat';
    final local = updatedAt.toLocal();
    final month = _months[local.month - 1];
    return 'Chat · $month ${local.day}';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

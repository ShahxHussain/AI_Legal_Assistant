class LegalSource {
  const LegalSource({
    required this.document,
    required this.section,
    required this.excerpt,
    required this.text,
    this.title = '',
    this.index = 0,
  });

  final String document;
  final String section;
  final String title;
  final String excerpt;
  final String text;
  final int index;

  String get fullText => text.isNotEmpty ? text : excerpt;

  factory LegalSource.fromJson(Map<String, dynamic> json, {int index = 0}) {
    final excerpt = json['excerpt'] as String? ?? '';
    final text = json['text'] as String? ?? excerpt;
    return LegalSource(
      document: json['document'] as String? ?? 'unknown',
      section: json['section'] as String? ?? '',
      title: json['title'] as String? ?? '',
      excerpt: excerpt,
      text: text,
      index: index,
    );
  }

  String get shortName {
    final doc = document
        .replaceAll('.pdf', '')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (section.isNotEmpty && title.isNotEmpty) {
      return '$doc · §$section $title';
    }
    if (section.isNotEmpty) {
      return '$doc · §$section';
    }
    return doc;
  }

  String get chipLabel {
    final n = index > 0 ? index : 1;
    if (section.isNotEmpty && title.isNotEmpty) {
      final shortTitle =
          title.length > 28 ? '${title.substring(0, 25)}...' : title;
      return '[$n] §$section $shortTitle';
    }
    if (section.isNotEmpty) {
      return '[$n] §$section';
    }
    return '[$n] ${document.split('.').first}';
  }
}

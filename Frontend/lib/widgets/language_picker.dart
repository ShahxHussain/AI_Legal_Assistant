import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Backend language codes + display labels. Default: Urdu.
const kDefaultLanguage = 'urdu_script';

const kSupportedLanguages = <(String, String)>[
  ('urdu_script', 'اردو (Urdu)'),
  ('english', 'English'),
  ('roman_urdu', 'Roman Urdu'),
  ('pashto', 'پښتو (Pashto)'),
  ('punjabi', 'پنجابی (Punjabi)'),
  ('sindhi', 'سنڌي (Sindhi)'),
  ('balochi', 'بلوچی (Balochi)'),
];

String languageLabel(String code) {
  return kSupportedLanguages
      .firstWhere((l) => l.$1 == code, orElse: () => kSupportedLanguages.first)
      .$2;
}

/// Short label for compact app-bar picker (avoids overflow on narrow screens).
String languageShortLabel(String code) {
  switch (code) {
    case 'english':
      return 'EN';
    case 'urdu_script':
      return 'اردو';
    case 'roman_urdu':
      return 'RU';
    case 'pashto':
      return 'پښتو';
    case 'punjabi':
      return 'پنج';
    case 'sindhi':
      return 'سن';
    case 'balochi':
      return 'بلو';
    default:
      return 'EN';
  }
}

/// Pill-style popup selector for the assistant's response language.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = languageLabel(value);
    final short = languageShortLabel(value);

    return PopupMenuButton<String>(
      tooltip: 'Response language',
      initialValue: value,
      onSelected: onChanged,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => kSupportedLanguages.map((l) {
        final selected = l.$1 == value;
        return PopupMenuItem<String>(
          value: l.$1,
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 18,
                color: selected ? AppColors.accent : AppColors.muted,
              ),
              const SizedBox(width: 10),
              Text(
                l.$2,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded,
                size: 15, color: AppColors.secondary),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ] else ...[
              const SizedBox(width: 4),
              Text(
                short,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
            Icon(
              Icons.expand_more_rounded,
              size: compact ? 14 : 16,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

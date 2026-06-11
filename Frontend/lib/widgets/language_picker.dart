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

/// Pill-style popup selector for the assistant's response language.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = languageLabel(value);

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const Icon(Icons.expand_more_rounded,
                size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

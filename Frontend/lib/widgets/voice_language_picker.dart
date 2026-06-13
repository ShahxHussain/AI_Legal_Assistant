import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'language_picker.dart';

/// Voice mode: English only today; other languages show Coming Soon.
const kVoiceDefaultLanguage = 'english';

const kVoiceEnabledLanguages = <String>{'english'};

class VoiceLanguagePicker extends StatelessWidget {
  const VoiceLanguagePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  void _onSelect(BuildContext context, String code) {
    if (!kVoiceEnabledLanguages.contains(code)) {
      _showComingSoon(context, languageLabel(code));
      return;
    }
    onChanged(code);
  }

  void _showComingSoon(BuildContext context, String label) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.mic_rounded, color: AppColors.secondary, size: 22),
            const SizedBox(width: 10),
            Text(
              'Coming Soon',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Voice assistant in $label is coming soon.\n\n'
          'For now, please use English voice or switch to Chat for '
          'text answers in all languages.',
          style: GoogleFonts.inter(height: 1.5, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = languageLabel(value);
    final isEnglish = kVoiceEnabledLanguages.contains(value);

    return PopupMenuButton<String>(
      tooltip: 'Voice language',
      initialValue: value,
      onSelected: (code) => _onSelect(context, code),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => kSupportedLanguages.map((l) {
        final selected = l.$1 == value;
        final enabled = kVoiceEnabledLanguages.contains(l.$1);
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
              Expanded(
                child: Text(
                  enabled ? l.$2 : '${l.$2} · Soon',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: enabled
                        ? AppColors.textDark
                        : AppColors.muted,
                  ),
                ),
              ),
              if (!enabled)
                Icon(Icons.lock_clock_rounded,
                    size: 16, color: AppColors.muted.withValues(alpha: 0.7)),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnglish
                ? AppColors.border
                : AppColors.secondary.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEnglish ? Icons.mic_rounded : Icons.mic_off_rounded,
              size: 15,
              color: AppColors.secondary,
            ),
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

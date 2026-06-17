import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/voice_locales.dart';
import '../theme/app_theme.dart';
import 'language_picker.dart';

export '../services/voice_locales.dart'
    show kVoiceDefaultLanguage, kVoiceEnabledLanguages;

class VoiceLanguagePicker extends StatelessWidget {
  const VoiceLanguagePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool compact;

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
          'English and Urdu voice are available now. For other languages, '
          'use Chat for text answers.',
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
    final short = languageShortLabel(value);
    final voiceEnabled = kVoiceEnabledLanguages.contains(value);

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
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: voiceEnabled
                ? AppColors.border
                : AppColors.secondary.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              voiceEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
              size: 15,
              color: AppColors.secondary,
            ),
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

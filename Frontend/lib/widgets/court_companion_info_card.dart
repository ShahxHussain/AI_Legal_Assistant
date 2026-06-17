import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Shared intro copy for Court Companion — used on the Info screen.
abstract final class CourtCompanionInfo {
  static const body =
      'Your AI legal assistant for Pakistani criminal law. Describe your situation — '
      'not just definitions — and get a structured walkthrough: which laws may apply (PPC/ATA), '
      'relevant procedure (CrPC), your rights, and practical next steps — grounded in statute text '
      'with source citations.';

  static const disclaimer =
      'General legal information only — not legal advice.';

  static const languages = <String>[
    'English',
    'اردو',
    'Roman Urdu',
    'پښتو',
    'پنجابی',
    'سنڌي',
    'بلوچی',
  ];
}

class LanguageChips extends StatelessWidget {
  const LanguageChips({super.key, this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      children: CourtCompanionInfo.languages.map((lang) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.accentSoft.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            lang,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CourtCompanionInfoCard extends StatelessWidget {
  const CourtCompanionInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.balance_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Court Companion',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'AI Legal Multilingual Assistant',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CourtCompanionInfo.body,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textDark.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Text(
                  CourtCompanionInfo.disclaimer,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'formatted_message.dart';

/// Shared intro copy for Court Companion — used on the Info screen.
abstract final class CourtCompanionInfo {
  static const body =
      'I am your **AI Legal Multilingual Assistant** for Pakistani citizens.\n\n'
      'Ask about **FIR**, **arrest rights**, **bail**, **PPC sections**, and **criminal procedure**. '
      'Answers are grounded in **PPC**, **CrPC**, and **ATA** — tap any source chip to read the statute excerpt.\n\n'
      'Ask in **English**, **Urdu** (script or Roman), **Pashto**, **Punjabi**, **Sindhi**, or **Balochi** — '
      'the assistant replies in your language.';

  static const disclaimer =
      'General legal information only — not legal advice.';

  /// Supported languages — shown as chips on Home and Info screens.
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

/// Small pill chips listing every language the assistant understands.
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            lang,
            style: GoogleFonts.inter(
              fontSize: 12.5,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assalam-o-Alaikum!',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Court Companion',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const FormattedMessage(
              text: CourtCompanionInfo.body,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentSoft.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      CourtCompanionInfo.disclaimer,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/voice_language_setup.dart';
import '../theme/app_theme.dart';

/// Optional help — most phones already support Urdu voice. No setup required.
class UrduVoiceHelpSheet extends StatelessWidget {
  const UrduVoiceHelpSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const UrduVoiceHelpSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, 22, 22, 16 + bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Urdu voice help',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'اردو آواز — معلومات',
                          style: GoogleFonts.notoNastaliqUrdu(
                            fontSize: 15,
                            color: AppColors.secondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Most phones (including Infinix, Xiaomi, Samsung, etc.) already '
                'support Urdu microphone input and spoken answers. You can use '
                'the mic right away — no setup needed in Court Companion.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If Urdu voice does not work on your device, try these optional '
                'steps in your phone Settings app (not the browser):',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 20),
              _HelpStep(
                step: 1,
                title: 'Spoken answers (optional)',
                titleUrdu: 'جواب سنیں',
                body:
                    'Settings → Text-to-speech / Speech output → select Urdu (Pakistan).',
                primaryLabel: 'Open speech settings',
                onPrimary: launchTtsSettings,
                secondaryLabel: 'Voice download screen',
                onSecondary: launchUrduTtsInstaller,
              ),
              const SizedBox(height: 12),
              _HelpStep(
                step: 2,
                title: 'Urdu microphone (optional)',
                titleUrdu: 'اردو میں بولیں',
                body:
                    'Settings → Google → Google Assistant → Languages → add Urdu (اردو). '
                    'On many phones it is already there with no download.',
                primaryLabel: 'Open Google settings',
                onPrimary: launchGoogleAppSettings,
                secondaryLabel: 'Voice input settings',
                onSecondary: launchUrduSttInstaller,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Got it',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  const _HelpStep({
    required this.step,
    required this.title,
    required this.titleUrdu,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final int step;
  final String title;
  final String titleUrdu;
  final String body;
  final String primaryLabel;
  final Future<bool> Function() onPrimary;
  final String? secondaryLabel;
  final Future<bool> Function()? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.accentSoft,
                child: Text(
                  '$step',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      titleUrdu,
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: 13,
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => onPrimary(),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                primaryLabel,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.35),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (secondaryLabel != null && onSecondary != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => onSecondary!(),
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: Text(
                  secondaryLabel!,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

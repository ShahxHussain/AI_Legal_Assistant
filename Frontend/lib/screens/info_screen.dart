import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/court_companion_info_card.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const _coverageTopics = [
    (
      'Offences against the state',
      'Treason, sedition, waging war',
      Icons.flag_outlined,
    ),
    (
      'Human body',
      'Murder (§302), assault, hurt, qatl',
      Icons.person_outline_rounded,
    ),
    (
      'Property offences',
      'Theft, robbery, cheating, breach of trust',
      Icons.home_work_outlined,
    ),
    (
      'Documents',
      'Forgery and document-related crimes',
      Icons.description_outlined,
    ),
    (
      'Public tranquility',
      'Rioting, unlawful assembly',
      Icons.groups_outlined,
    ),
    (
      'Religion',
      'Religion-related offences under PPC',
      Icons.volunteer_activism_outlined,
    ),
    (
      'Defamation',
      'Defamation and criminal intimidation',
      Icons.record_voice_over_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.primary,
        ),
        title: Text(
          'Info',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CourtCompanionInfoCard(),
            const SizedBox(height: 24),
            Text(
              'Legal sources',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _SourceTile(
              name: 'Pakistan Penal Code (PPC)',
              detail: 'Substantive criminal offences',
              icon: Icons.gavel_rounded,
            ),
            const SizedBox(height: 8),
            _SourceTile(
              name: 'Code of Criminal Procedure (CrPC)',
              detail: 'FIR, arrest, bail, investigation',
              icon: Icons.account_balance_rounded,
            ),
            const SizedBox(height: 8),
            _SourceTile(
              name: 'Anti-Terrorism Act (ATA)',
              detail: 'Terrorism offences & special procedure',
              icon: Icons.security_rounded,
            ),
            const SizedBox(height: 24),
            Text(
              'PPC coverage areas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ..._coverageTopics.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TopicTile(
                  title: t.$1,
                  subtitle: t.$2,
                  icon: t.$3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentSoft.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.translate_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ask in **English** or **Roman Urdu** — the assistant replies in the same language you use.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.primary,
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

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.name,
    required this.detail,
    required this.icon,
  });

  final String name;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  detail,
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
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  subtitle,
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
    );
  }
}

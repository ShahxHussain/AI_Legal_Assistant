import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Court Companion Pro — product info (beta). Full workspace ships in a later release.
class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  static const _features = [
    (
      Icons.psychology_alt_outlined,
      'Agentic follow-up questions',
      'When facts are missing, Pro asks targeted questions before citing the wrong PPC section.',
    ),
    (
      Icons.folder_open_rounded,
      'Full case workspace',
      'One case keeps every message, upload, and analysis — context never resets mid-matter.',
    ),
    (
      Icons.upload_file_rounded,
      'Case & document upload',
      'FIR copies, orders, pleadings, and scenario briefs — all searchable inside the case.',
    ),
    (
      Icons.balance_rounded,
      'Statute + case-law retrieval',
      'PPC, CrPC, ATA plus public judgments from Supreme, High, and Sessions courts.',
    ),
    (
      Icons.rule_folder_rounded,
      'Gaps & procedural flags',
      'Surfaces limitation, jurisdiction, bail category, and evidence gaps for counsel to verify.',
    ),
    (
      Icons.hub_outlined,
      'Structured legal analysis',
      'Facts, issues, applicable law, precedents, procedure, and next steps — in one stream.',
    ),
  ];

  static const _steps = [
    ('1', 'Open a Pro case', 'Name the matter and choose court level / case type.'),
    ('2', 'Upload & describe', 'Add documents and a short scenario brief.'),
    ('3', 'Answer clarifying questions', 'Pro gathers missing facts before citing law.'),
    ('4', 'Receive full analysis', 'Statutes, precedents, procedure, and risk flags.'),
    ('5', 'Continue in the same case', 'Follow-ups use the full case context — no re-uploading.'),
  ];

  static const _audience = [
    'Advocates & lawyers',
    'Legal researchers',
    'Law firms & legal aid NGOs',
    'Judicial clerks (research aid only)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        title: Text(
          'Court Companion Pro',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroCard(),
            const SizedBox(height: 24),
            const _SectionLabel('Who it is for'),
            const SizedBox(height: 12),
            _BulletCard(items: _audience),
            const SizedBox(height: 28),
            const _SectionLabel('How it works'),
            const SizedBox(height: 12),
            ..._steps.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _StepRow(number: s.$1, title: s.$2, body: s.$3),
              ),
            ),
            const SizedBox(height: 28),
            const _SectionLabel('What you get'),
            const SizedBox(height: 12),
            ..._features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FeatureRow(icon: f.$1, title: f.$2, body: f.$3),
              ),
            ),
            const SizedBox(height: 28),
            const _SectionLabel('Knowledge sources'),
            const SizedBox(height: 12),
            const _KnowledgeCard(),
            const SizedBox(height: 28),
            const _SectionLabel('Citizen chat vs Pro'),
            const SizedBox(height: 12),
            const _CompareCard(),
            const SizedBox(height: 28),
            _BetaPricingCard(),
            const SizedBox(height: 20),
            _ComingSoonButton(),
            const SizedBox(height: 16),
            _DisclaimerBox(),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'BETA · FREE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Professional case workspace',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'For lawyers and legal professionals. Upload a case, answer smart follow-up questions, '
            'and get deep analysis grounded in Pakistani statutes and public court judgments.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: AppColors.muted,
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          height: 1.4,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.inter(fontSize: 12.5, height: 1.45, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.inter(fontSize: 12.5, height: 1.45, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  const _KnowledgeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planned case-law corpus (public sources only)',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          ...[
            'Supreme Court of Pakistan — published judgments',
            'High Courts — Lahore, Sindh, Peshawar, Balochistan, Islamabad',
            'Sessions courts — where publicly available',
            'Plus PPC, CrPC & ATA statute index (existing)',
          ].map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.gavel_rounded, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textDark.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _CompareRow(
            label: 'Ask in chat',
            value: 'Quick legal info for citizens — free, always',
            highlight: false,
          ),
          const Divider(height: 24),
          _CompareRow(
            label: 'Court Companion Pro',
            value: 'Full case analysis for professionals — free in beta, paid at launch',
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.value,
    required this.highlight,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          highlight ? Icons.workspace_premium_rounded : Icons.chat_bubble_outline_rounded,
          size: 20,
          color: highlight ? AppColors.primary : AppColors.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: highlight ? AppColors.primary : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 12.5, height: 1.45, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BetaPricingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.celebration_outlined, color: AppColors.secondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beta access',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Court Companion Pro is free during beta for everyone. '
                  'After launch it will move to a professional subscription. '
                  'Citizen chat stays free.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textDark.withValues(alpha: 0.85),
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

class _ComingSoonButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.lock_clock_rounded, size: 20),
            label: Text(
              'Start a Pro case — Coming soon',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.9),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Workspace, uploads, and case-law search ship in the next release.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.muted, height: 1.4),
        ),
      ],
    );
  }
}

class _DisclaimerBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Court Companion Pro is a legal research aid for qualified professionals. '
        'It does not replace counsel judgment, client confidentiality duties, or court filings. '
        'Outputs are informational — verify all citations and strategy before relying on them.',
        style: GoogleFonts.inter(fontSize: 11.5, height: 1.45, color: AppColors.muted),
      ),
    );
  }
}

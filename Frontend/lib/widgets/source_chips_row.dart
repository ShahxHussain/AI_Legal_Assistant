import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/legal_source.dart';
import '../theme/app_theme.dart';
import 'source_detail_sheet.dart';

class SourceChipsRow extends StatelessWidget {
  const SourceChipsRow({super.key, required this.sources});

  final List<LegalSource> sources;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentSoft.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Legal sources',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${sources.length}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sources.map((source) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showSourceDetailSheet(context, source),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryContainer,
                        AppColors.accentSoft.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          source.chipLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 13,
                          color: AppColors.primary.withValues(alpha: 0.65),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap a source to view the full statute excerpt',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Renders assistant answers with markdown — headings, bold, lists, tables.
class FormattedMessage extends StatelessWidget {
  const FormattedMessage({
    super.key,
    required this.text,
    this.isError = false,
    this.onDark = false,
  });

  final String text;
  final bool isError;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor = onDark
        ? Colors.white.withValues(alpha: 0.92)
        : isError
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onSurface;
    final headingColor = onDark ? Colors.white : AppColors.primary;
    final subHeadingColor =
        onDark ? AppColors.accentLight : AppColors.secondary;
    final strongColor = onDark ? AppColors.accentLight : AppColors.secondary;

    return MarkdownBody(
      data: text,
      selectable: true,
      shrinkWrap: true,
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.inter(
          fontSize: 15.5,
          height: 1.6,
          color: bodyColor,
        ),
        h1: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.3,
          color: headingColor,
        ),
        h2: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.35,
          color: headingColor,
        ),
        h3: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.4,
          color: subHeadingColor,
        ),
        h4: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: subHeadingColor,
        ),
        strong: TextStyle(
          fontWeight: FontWeight.w700,
          color: strongColor,
        ),
        em: TextStyle(
          fontStyle: FontStyle.italic,
          color: bodyColor.withValues(alpha: 0.9),
        ),
        blockquote: GoogleFonts.inter(
          fontSize: 14.5,
          fontStyle: FontStyle.italic,
          color: AppColors.muted,
          height: 1.5,
        ),
        blockquoteDecoration: BoxDecoration(
          color: AppColors.accentSoft.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: AppColors.accent, width: 4),
          ),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
        listBullet: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
        orderedListAlign: WrapAlignment.start,
        unorderedListAlign: WrapAlignment.start,
        listIndent: 22,
        tableHead: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        tableBody: GoogleFonts.inter(
          fontSize: 13,
          height: 1.45,
          color: bodyColor,
        ),
        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        tableBorder: TableBorder.all(
          color: AppColors.border,
          width: 1,
          borderRadius: BorderRadius.circular(8),
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        code: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          backgroundColor: AppColors.background,
          color: AppColors.primary,
        ),
        codeblockDecoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        codeblockPadding: const EdgeInsets.all(12),
      ),
    );
  }
}

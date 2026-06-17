import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Soft like / unlike row under assistant answers — feeds admin helpfulness KPIs.
class AnswerFeedbackBar extends StatelessWidget {
  const AnswerFeedbackBar({
    super.key,
    required this.selectedRating,
    required this.onRate,
    this.disabled = false,
  });

  final String? selectedRating;
  final ValueChanged<String> onRate;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentSoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            'Was this helpful?',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const Spacer(),
          _FeedbackIconButton(
            icon: Icons.thumb_up_outlined,
            selectedIcon: Icons.thumb_up_rounded,
            selected: selectedRating == 'up',
            selectedColor: AppColors.secondary,
            selectedFill: AppColors.secondary.withValues(alpha: 0.1),
            onTap: disabled ? null : () => onRate('up'),
          ),
          const SizedBox(width: 6),
          _FeedbackIconButton(
            icon: Icons.thumb_down_outlined,
            selectedIcon: Icons.thumb_down_rounded,
            selected: selectedRating == 'down',
            selectedColor: AppColors.error,
            selectedFill: AppColors.error.withValues(alpha: 0.08),
            onTap: disabled ? null : () => onRate('down'),
          ),
        ],
      ),
    );
  }
}

class _FeedbackIconButton extends StatelessWidget {
  const _FeedbackIconButton({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.selectedColor,
    required this.selectedFill,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final Color selectedColor;
  final Color selectedFill;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? selectedColor
        : AppColors.muted.withValues(alpha: 0.7);

    return Material(
      color: selected ? selectedFill : AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? selectedColor.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          child: Icon(
            selected ? selectedIcon : icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }
}

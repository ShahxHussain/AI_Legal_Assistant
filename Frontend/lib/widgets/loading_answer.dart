import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Animated loading state while the assistant retrieves and drafts an answer.
class LoadingAnswer extends StatefulWidget {
  const LoadingAnswer({super.key});

  @override
  State<LoadingAnswer> createState() => _LoadingAnswerState();
}

class _LoadingAnswerState extends State<LoadingAnswer>
    with SingleTickerProviderStateMixin {
  static const _steps = [
  ('Searching PPC, CrPC & ATA', Icons.search_rounded),
  ('Reading statute sections', Icons.menu_book_rounded),
  ('Drafting your answer', Icons.edit_note_rounded),
];

  late final AnimationController _pulse;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _cycleSteps();
  }

  Future<void> _cycleSteps() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      if (mounted) setState(() => _step = (_step + 1) % _steps.length);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (label, icon) = _steps[_step];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _pulse.value * 2 * math.pi,
                  child: child,
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: AppColors.border,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _ShimmerLine(widthFactor: 1.0, animation: _pulse),
        const SizedBox(height: 10),
        _ShimmerLine(widthFactor: 0.92, animation: _pulse),
        const SizedBox(height: 10),
        _ShimmerLine(widthFactor: 0.75, animation: _pulse),
        const SizedBox(height: 10),
        _ShimmerLine(widthFactor: 0.55, animation: _pulse),
      ],
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({
    required this.widthFactor,
    required this.animation,
  });

  final double widthFactor;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = (math.sin(animation.value * 2 * math.pi) + 1) / 2;
        return FractionallySizedBox(
          widthFactor: widthFactor,
          child: Container(
            height: 11,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                colors: [
                  AppColors.border,
                  Color.lerp(AppColors.border, AppColors.accentSoft, t)!,
                  AppColors.border,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

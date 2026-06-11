import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 36),
              Text(
                'Kya karna chahte hain?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _HomeOptionCard(
                title: 'Asal Court Companion',
                subtitle:
                    'Legal sawal + PDF/TXT upload — FIR, bail, arrest, PPC sections',
                icon: Icons.chat_rounded,
                accent: AppColors.secondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ChatScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _HomeOptionCard(
                title: 'Info',
                subtitle:
                    'App ke baare mein maloomat — sources, languages aur disclaimer',
                icon: Icons.info_outline_rounded,
                accent: AppColors.accent,
                outlined: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const InfoScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'AI for Civic Innovation 2026 · Pakistan',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.muted.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.balance_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Court Companion',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'AI Legal Bilingual Assistant',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _HomeOptionCard extends StatelessWidget {
  const _HomeOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.outlined = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: outlined ? AppColors.surface : AppColors.primary,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: outlined ? AppColors.border : Colors.transparent,
              width: outlined ? 1.5 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: outlined ? 0.06 : 0.2),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: outlined
                        ? accent.withValues(alpha: 0.12)
                        : AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: outlined ? accent : AppColors.surface,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: outlined ? AppColors.primary : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.45,
                          color: outlined
                              ? AppColors.muted
                              : Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: outlined
                      ? AppColors.primary.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

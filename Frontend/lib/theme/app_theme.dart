import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Court Companion — Trust · Authority · Technology · Accessibility
abstract final class AppColors {
  // Brand palette
  static const primary = Color(0xFF0B2545); // Deep Legal Blue
  static const secondary = Color(0xFF1F6F5F); // Justice Green
  static const accent = Color(0xFF3BA776); // AI Mint
  static const background = Color(0xFFF5F7FA); // Soft Gray
  static const textDark = Color(0xFF1F2937); // Charcoal
  static const surface = Color(0xFFFFFFFF); // Pure White

  // Derived / UI helpers
  static const primaryLight = Color(0xFF1F6F5F); // gradient end — Justice Green
  static const accentSoft = Color(0xFFD4EDE4); // light mint tint
  static const accentLight = Color(0xFF7DD3A8); // highlight on dark backgrounds
  static const userBubble = Color(0xFF1F6F5F); // Justice Green
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const success = Color(0xFF3BA776);
  static const error = Color(0xFFDC2626);
  static const primaryContainer = Color(0xFFE8F2EE);
}

abstract final class AppTheme {
  static ThemeData light() {
    final baseText = GoogleFonts.interTextTheme();
    final display = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        secondary: AppColors.secondary,
        onSecondary: AppColors.surface,
        tertiary: AppColors.accent,
        onTertiary: AppColors.surface,
        surface: AppColors.surface,
        onSurface: AppColors.textDark,
        error: AppColors.error,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primary,
        secondaryContainer: AppColors.accentSoft,
        onSecondaryContainer: AppColors.secondary,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: display.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          fontSize: 17,
        ),
      ),
      textTheme: baseText.copyWith(
        bodyLarge: baseText.bodyLarge?.copyWith(
          fontSize: 15.5,
          height: 1.55,
          color: AppColors.textDark,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.5,
          color: AppColors.textDark.withValues(alpha: 0.85),
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        hintStyle: TextStyle(color: AppColors.muted.withValues(alpha: 0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.surface,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.muted,
        ),
      ),
    );
  }
}

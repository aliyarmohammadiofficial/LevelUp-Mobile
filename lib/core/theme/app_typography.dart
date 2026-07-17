// LevelUp — Typography
// The preview uses a rounded, friendly geometric sans for headings (bold,
// tight tracking, large size on "LevelUp" / "Welcome back!") and a clean
// grotesque for body/UI copy. We pair Baloo 2 (display — rounded terminals
// match the mascot's soft, playful line work) with Inter (body/UI — neutral,
// highly legible at small sizes for dense screens like Nutrition/Progress).
//
// If/when Persian (RTL) copy is added, swap the body family for
// Vazirmatn per project convention and keep Baloo 2 only for latin numerals
// and the wordmark.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color ink900, Color ink700, Color ink500) {
    final display = GoogleFonts.baloo2TextTheme();
    final body = GoogleFonts.interTextTheme();

    return TextTheme(
      // Wordmark / hero headings ("LevelUp", "Welcome back!")
      displayLarge: display.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: ink900,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: ink900,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      // Screen titles ("Workout", "Nutrition Plan")
      headlineLarge: display.headlineLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ink900,
        height: 1.3,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ink900,
        height: 1.3,
      ),
      // Card titles, list item titles ("Bench Press", "Push Day")
      titleLarge: body.titleLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: ink900,
        height: 1.35,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ink700,
        height: 1.4,
      ),
      titleSmall: body.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: ink700,
        height: 1.4,
      ),
      // Body copy
      bodyLarge: body.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: ink700,
        height: 1.5,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: ink700,
        height: 1.45,
      ),
      bodySmall: body.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: ink500,
        height: 1.4,
      ),
      // Labels, buttons, tags
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.surface,
        height: 1.2,
        letterSpacing: 0.1,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: ink500,
        height: 1.3,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: ink500,
        height: 1.3,
        letterSpacing: 0.2,
      ),
    );
  }
}

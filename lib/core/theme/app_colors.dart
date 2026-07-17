// LevelUp — Color Palette
// Extracted directly from the supplied Logo and App Preview assets.
// Do not introduce new brand colors without updating this file first —
// this is the single source of truth for color across the app.

import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------
  // Brand — primary blue family (sampled from logo ring + primary buttons)
  // ---------------------------------------------------------------------
  static const Color primary = Color(0xFF2F73E9); // main buttons, active states
  static const Color primaryDark = Color(0xFF1F63EF); // logo ring / pressed state
  static const Color primaryLight = Color(0xFF5C94F0); // hover / secondary emphasis
  static const Color primaryFaint = Color(0xFFC0DCFA); // logo's soft outer ring
  static const Color primarySurface = Color(0xFFEBF2FD); // screen background tint
  static const Color primarySurfaceAlt = Color(0xFFE3ECFC); // card backgrounds

  // ---------------------------------------------------------------------
  // Ink — text colors (sampled from headings and body copy)
  // ---------------------------------------------------------------------
  static const Color ink900 = Color(0xFF132776); // headings, "Welcome back!"
  static const Color ink700 = Color(0xFF3A4566); // primary body text
  static const Color ink500 = Color(0xFF6E7896); // secondary / muted text
  static const Color ink300 = Color(0xFFAEB6CC); // placeholders, disabled text
  static const Color ink100 = Color(0xFFE4E8F2); // dividers, hairlines

  // ---------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------
  static const Color background = Color(0xFFF7F9FE); // app background
  static const Color surface = Color(0xFFFFFFFF); // cards, sheets, inputs
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------
  static const Color success = Color(0xFF34C77B); // completed, streaks
  static const Color successSurface = Color(0xFFE3F9EE);
  static const Color warning = Color(0xFFF5A623); // reminders, near-limit
  static const Color warningSurface = Color(0xFFFDF1DD);
  static const Color error = Color(0xFFEF5350); // errors, delete actions
  static const Color errorSurface = Color(0xFFFCE8E7);
  static const Color info = primary;

  // ---------------------------------------------------------------------
  // Data viz — for charts (macros, calories, weight progress)
  // ---------------------------------------------------------------------
  static const Color chartProtein = Color(0xFF2F73E9);
  static const Color chartCarbs = Color(0xFFF5A623);
  static const Color chartFat = Color(0xFFEF5350);
  static const Color chartTrackWeak = Color(0xFFE4E8F2);

  // ---------------------------------------------------------------------
  // Dark mode
  // ---------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0F1420);
  static const Color darkSurface = Color(0xFF1A2133);
  static const Color darkSurfaceAlt = Color(0xFF232B40);
  static const Color darkInk900 = Color(0xFFF3F5FB);
  static const Color darkInk700 = Color(0xFFC7CEDE);
  static const Color darkInk500 = Color(0xFF8B93AC);
  static const Color darkDivider = Color(0xFF2C3550);

  // ---------------------------------------------------------------------
  // Gradients (used sparingly: hero cards, streak rings, mascot badge)
  // ---------------------------------------------------------------------
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  static const SweepGradient ringGradient = SweepGradient(
    startAngle: 0,
    endAngle: 6.28319,
    colors: [primaryFaint, primary, primaryDark, primaryFaint],
    stops: [0.0, 0.4, 0.75, 1.0],
  );
}

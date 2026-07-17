// LevelUp — Design Tokens
// Spacing, radius, elevation, and motion constants derived from the app
// preview: generous card padding, large 20–24px radii on cards and
// pill-shaped buttons, soft low-elevation shadows (no hard drop shadows
// visible anywhere in the reference screens).

import 'package:flutter/material.dart';

abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Standard screen horizontal padding used across every screen.
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
}

abstract class AppRadius {
  AppRadius._();

  static const double sm = 10;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 999;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}

abstract class AppElevation {
  AppElevation._();

  /// Soft ambient shadow used on cards — matches the barely-there card
  /// separation visible in the reference (no hard edges, no dark shadows).
  static List<BoxShadow> card(Color shadowColor) => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> button(Color shadowColor) => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> none = const [];
}

abstract class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration celebratory = Duration(milliseconds: 700);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve enterCurve = Curves.easeOutQuint;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve bounceCurve = Curves.easeOutBack;
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Row of tappable cup icons, matching the reference Water Tracker's cup
/// row under the ring — filled cups show progress at a glance, and
/// tapping any cup logs up to that count in one action.
class CupGrid extends StatelessWidget {
  const CupGrid({
    super.key,
    required this.cupsLogged,
    required this.cupGoal,
    required this.onCupTapped,
  });

  final int cupsLogged;
  final int cupGoal;
  final ValueChanged<int> onCupTapped;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      alignment: WrapAlignment.center,
      children: List.generate(cupGoal, (i) {
        final cupNumber = i + 1;
        final isFilled = cupNumber <= cupsLogged;
        return GestureDetector(
          onTap: () => onCupTapped(cupNumber == cupsLogged ? cupNumber - 1 : cupNumber),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isFilled ? AppColors.primarySurface : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isFilled ? AppColors.primary : AppColors.ink100,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.local_drink_rounded,
              color: isFilled ? AppColors.primary : AppColors.ink300,
              size: 20,
            ),
          ),
        );
      }),
    );
  }
}

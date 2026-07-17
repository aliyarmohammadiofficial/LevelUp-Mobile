import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.pillRadius,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: AppMotion.standard,
        curve: AppMotion.standardCurve,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: AppColors.ink100,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        ),
      ),
    );
  }
}

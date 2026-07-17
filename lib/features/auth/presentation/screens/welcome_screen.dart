import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/mascot.dart';

/// First screen of the app: wordmark, tagline, mascot, and the two primary
/// CTAs ("Get Started" / "I Already Have an Account") seen in the preview.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              Text(
                AppConstants.appName,
                style: theme.textTheme.displayLarge?.copyWith(color: AppColors.primary),
              ).animate().fadeIn(duration: AppMotion.slow).slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppConstants.tagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ink500),
              ).animate().fadeIn(delay: 120.ms, duration: AppMotion.slow),
              const SizedBox(height: AppSpacing.huge),
              Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Mascot(pose: MascotPose.wave, size: 190),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: AppMotion.celebratory)
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), curve: AppMotion.bounceCurve),
              const Spacer(),
              AppButton(
                label: 'Get Started',
                onPressed: () => context.push('/signup'),
              ).animate().fadeIn(delay: 320.ms, duration: AppMotion.standard),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'I Already Have an Account',
                variant: AppButtonVariant.outlined,
                onPressed: () => context.push('/login'),
              ).animate().fadeIn(delay: 380.ms, duration: AppMotion.standard),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

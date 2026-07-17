import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import 'onboarding_progress_bar.dart';

class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.progress,
    required this.title,
    required this.child,
    required this.onBack,
    required this.onContinue,
    this.subtitle,
    this.continueLabel = 'Continue',
    this.isContinueEnabled = true,
    this.isLoading = false,
  });

  final double progress;
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final String continueLabel;
  final bool isContinueEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primarySurface,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: OnboardingProgressBar(progress: progress)),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(title, style: theme.textTheme.displayMedium)
                  .animate(key: ValueKey('title-$title'))
                  .fadeIn(duration: AppMotion.standard)
                  .slideY(begin: 0.1, end: 0, curve: AppMotion.enterCurve),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ink500),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              Expanded(
                child: SingleChildScrollView(
                  child: child
                      .animate(key: ValueKey('content-$title'))
                      .fadeIn(delay: 80.ms, duration: AppMotion.standard),
                ),
              ),
              AppButton(
                label: continueLabel,
                onPressed: isContinueEnabled ? onContinue : null,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

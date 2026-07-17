import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/copyright_footer.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../onboarding/domain/entities/onboarding_answers.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../providers/profile_providers.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Real Personal Information screen — reads the signed-in [AppUser]
/// (name, email) and the [OnboardingAnswers] saved during onboarding
/// (sex, height, current weight) rather than showing placeholder rows.
class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).asData?.value;
    final profileAsync = ref.watch(profileSummaryProvider);
    final answersAsync = ref.watch(savedOnboardingAnswersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            final answers = answersAsync.asData?.value;
            final isLoadingAnswers = answersAsync.isLoading;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
                top: AppSpacing.xl,
                bottom: AppSpacing.xxxl,
              ),
              children: [
                _InfoCard(
                  title: 'Account',
                  rows: [
                    _Row('Full Name', authUser?.fullName ?? profile.displayName),
                    _Row('Email', authUser?.email ?? profile.email),
                    _Row(
                      'Member Since',
                      profile.memberSince != null
                          ? DateFormat.yMMMM().format(profile.memberSince!)
                          : 'Unknown',
                    ),
                  ],
                ).animate().fadeIn(duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.xl),
                if (isLoadingAnswers)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (answers == null)
                  _EmptyBodyStats(
                    onCompleteOnboarding: () => context.push('/onboarding'),
                  ).animate().fadeIn(delay: 80.ms, duration: AppMotion.standard)
                else
                  _InfoCard(
                    title: 'Body Details',
                    rows: [
                      _Row('Sex', answers.sex?.label ?? 'Not set'),
                      _Row(
                        'Height',
                        answers.heightCm != null ? '${answers.heightCm!.toStringAsFixed(0)} cm' : 'Not set',
                      ),
                      _Row(
                        'Current Weight',
                        answers.currentWeightKg != null
                            ? '${answers.currentWeightKg!.toStringAsFixed(1)} kg'
                            : 'Not set',
                      ),
                    ],
                  ).animate().fadeIn(delay: 80.ms, duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Editing name, email, and body details is coming soon — for now, '
                  'update your body details anytime by redoing onboarding.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.ink500),
                  textAlign: TextAlign.center,
                ),
                const CopyrightFooter(),
              ],
            );
          },
          loading: () => const AppLoadingIndicator(),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Mascot(pose: MascotPose.sad, size: 100),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Couldn't load your information.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String value;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(title, style: theme.textTheme.labelMedium?.copyWith(color: AppColors.ink500)),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.xlRadius,
            boxShadow: AppElevation.card(AppColors.ink900),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rows[i].label, style: theme.textTheme.bodyMedium),
                      Flexible(
                        child: Text(
                          rows[i].value,
                          style: theme.textTheme.titleSmall,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i != rows.length - 1)
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyBodyStats extends StatelessWidget {
  const _EmptyBodyStats({required this.onCompleteOnboarding});

  final VoidCallback onCompleteOnboarding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        children: [
          const Mascot(pose: MascotPose.sleepy, size: 80),
          const SizedBox(height: AppSpacing.md),
          Text(
            "You haven't set up your body details yet.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton(onPressed: onCompleteOnboarding, child: const Text('Complete setup')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/copyright_footer.dart';

/// Placeholder legal copy reached from Settings → Privacy Policy.
/// TODO: replace with the reviewed, final privacy policy text before
/// release — this is structural/sample copy only.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text('Your data, your control', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              'LevelUp stores your workout, nutrition, and fasting data on your '
              'device first, syncing to your account only so your progress is '
              'available across devices. We never sell personal data, and you '
              'can export or delete your data at any time from Settings.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('What we collect', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Account details (name, email), health inputs you choose to log '
              '(weight, meals, workouts, fasting windows), and basic usage '
              'analytics used only to improve the app.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Contact', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Questions about your data can be sent to ${AppConstants.supportEmail}.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const CopyrightFooter(),
          ],
        ),
      ),
    );
  }
}

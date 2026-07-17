import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/copyright_footer.dart';
import '../../../../core/widgets/mascot.dart';

/// "About LevelUp" screen reached from the Profile tab — app identity,
/// version, and developer credit. LevelUp is designed and built by
/// Ali Yarmohammadi (Forteen Club); this screen is the single place that
/// attribution/copyright notice is displayed in-app.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About LevelUp')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
            top: AppSpacing.xxl,
            bottom: AppSpacing.xxxl,
          ),
          children: [
            Center(
              child: Column(
                children: [
                  const AppLogo(size: 72),
                  const SizedBox(height: AppSpacing.lg),
                  Text(AppConstants.appName, style: theme.textTheme.displayMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Version ${AppConstants.appVersion} (${AppConstants.buildNumber})',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: AppMotion.standard),
            const SizedBox(height: AppSpacing.xxxl),
            Text(
              AppConstants.tagline.replaceAll('\n', ' '),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ).animate().fadeIn(delay: 80.ms, duration: AppMotion.standard),
            const SizedBox(height: AppSpacing.xxxl),
            _InfoCard(
              rows: [
                _InfoRow(label: 'Developed by', value: AppConstants.developerName),
                _InfoRow(label: 'Studio', value: AppConstants.developerSite),
                _InfoRow(label: 'Support', value: AppConstants.supportEmail),
              ],
            ).animate().fadeIn(delay: 140.ms, duration: AppMotion.standard),
            const SizedBox(height: AppSpacing.xxl),
            const Center(child: Mascot(pose: MascotPose.celebrate, size: 96)),
            const SizedBox(height: AppSpacing.xxl),
            const CopyrightFooter().animate().fadeIn(delay: 200.ms, duration: AppMotion.standard),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                  Text(rows[i].label, style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    rows[i].value,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
}

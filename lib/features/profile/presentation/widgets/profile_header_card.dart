import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../domain/entities/profile_summary.dart';

/// Header banner at the top of the Profile tab — mascot avatar, display
/// name, and a "Level N" badge, matching the "Meowster / Level 12" card
/// in the reference screens.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.summary});

  final ProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: summary.avatarUrl == null ? const EdgeInsets.all(6) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              image: summary.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(summary.avatarUrl!),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    )
                  : null,
            ),
            child: summary.avatarUrl == null
                ? const Mascot(pose: MascotPose.wink, size: 52, animate: false)
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.displayName, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  summary.email,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppRadius.pillRadius,
            ),
            child: Text(
              'Level ${summary.level}',
              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';

class DashboardTipCard extends StatelessWidget {
  const DashboardTipCard({super.key, required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.lgRadius,
      ),
      child: Row(
        children: [
          const Mascot(pose: MascotPose.wink, size: 52, animated: false),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tip', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.primary)),
                Text(tip, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

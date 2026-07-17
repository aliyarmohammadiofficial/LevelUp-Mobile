import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Grouped card of [SettingsTile]s under a section label — matches the
/// "Units / Theme / Notifications / ..." grouping on the reference
/// Settings screen.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.ink500),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.xlRadius,
            boxShadow: AppElevation.card(AppColors.ink900),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

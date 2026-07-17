import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class ProfileMenuItemData {
  const ProfileMenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

/// Card containing the Profile tab's navigation rows (Personal
/// Information, Goals, Reminders, Settings, Help & Support, About
/// LevelUp), each with a leading icon, label, and trailing chevron —
/// matching the reference "Profile" screen's menu list.
class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({super.key, required this.items});

  final List<ProfileMenuItemData> items;

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
          for (int i = 0; i < items.length; i++) ...[
            _ProfileMenuTile(item: items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, indent: AppSpacing.xl, endIndent: AppSpacing.xl),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({required this.item});

  final ProfileMenuItemData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = item.isDestructive ? AppColors.error : AppColors.ink700;

    return InkWell(
      onTap: item.onTap,
      borderRadius: AppRadius.xlRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.isDestructive ? AppColors.errorSurface : AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 18, color: item.isDestructive ? AppColors.error : AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                item.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: item.isDestructive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (!item.isDestructive)
              const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
          ],
        ),
      ),
    );
  }
}

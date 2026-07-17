import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// A single Settings row. Two shapes cover every row in the reference
/// screen: [SettingsTile.navigation] (label + current value + chevron,
/// tappable — Units/Theme/Language/Data Sync/Privacy Policy) and
/// [SettingsTile.toggle] (label + switch — Notifications/Sounds).
class SettingsTile extends StatelessWidget {
  const SettingsTile.navigation({
    super.key,
    required this.label,
    this.value,
    required VoidCallback this.onTap,
  })  : isToggle = false,
        toggleValue = null,
        onToggleChanged = null;

  const SettingsTile.toggle({
    super.key,
    required this.label,
    required bool this.toggleValue,
    required ValueChanged<bool> this.onToggleChanged,
  })  : isToggle = true,
        value = null,
        onTap = null;

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool isToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          if (isToggle)
            Switch(value: toggleValue!, onChanged: onToggleChanged)
          else ...[
            if (value != null)
              Text(
                value!,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink500),
              ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
          ],
        ],
      ),
    );

    if (isToggle) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xlRadius,
      child: content,
    );
  }
}

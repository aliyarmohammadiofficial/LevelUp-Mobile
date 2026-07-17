import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/reminder_item.dart';

/// One row on the Reminders screen — icon, label, and a subtitle
/// describing cadence (e.g. "Every day at 6:00 AM"), with a trailing
/// toggle. Tapping the label/subtitle while enabled opens a time picker,
/// matching the reference screen's reminder list.
class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggled,
    required this.onEditTime,
  });

  final ReminderItem reminder;
  final ValueChanged<bool> onToggled;
  final VoidCallback onEditTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: reminder.isEnabled ? onEditTime : null,
      borderRadius: AppRadius.xlRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: reminder.isEnabled ? AppColors.primarySurface : AppColors.primarySurfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                reminder.icon,
                size: 20,
                color: reminder.isEnabled ? AppColors.primary : AppColors.ink300,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.label, style: theme.textTheme.bodyLarge),
                  Text(
                    reminder.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink500),
                  ),
                ],
              ),
            ),
            Switch(value: reminder.isEnabled, onChanged: onToggled),
          ],
        ),
      ),
    );
  }
}

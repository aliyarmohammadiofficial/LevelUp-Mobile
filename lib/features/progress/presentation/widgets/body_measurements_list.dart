import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../domain/entities/progress_summary.dart';

/// "Today" / "Yesterday" / "Jul 12" — matches the phrasing used on the
/// capture screen so the two surfaces never say the same date two
/// different ways.
String _formatUpdatedAt(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat('MMM d').format(date);
}

/// The "Body" tab's list of measurement rows (whichever sites have been
/// logged at least once — see [BodyMeasurementFields]) with their current
/// value and change since the previous log, plus a header showing when
/// they were last updated and an empty state before any have been logged.
class BodyMeasurementsList extends StatelessWidget {
  const BodyMeasurementsList({
    super.key,
    required this.measurements,
    this.updatedAt,
    this.onUpdate,
  });

  final List<BodyMeasurement> measurements;
  final DateTime? updatedAt;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return _EmptyState(onUpdate: onUpdate);
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (updatedAt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md, left: AppSpacing.xs),
            child: Text(
              'Last updated ${_formatUpdatedAt(updatedAt!)}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgRadius,
            boxShadow: AppElevation.card(AppColors.ink900),
          ),
          child: Column(
            children: [
              for (int i = 0; i < measurements.length; i++) ...[
                _MeasurementRow(measurement: measurements[i]),
                if (i != measurements.length - 1)
                  const Divider(
                    height: 1,
                    color: AppColors.ink100,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
              ],
            ],
          ),
        ),
        if (onUpdate != null) ...[
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: onUpdate,
            icon: const Icon(Icons.straighten_rounded, size: 18),
            label: const Text('Update Measurements'),
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onUpdate});

  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Mascot(pose: MascotPose.wave, size: 96),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No measurements yet',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Log your chest, waist, hips, and more to start tracking '
            'change over time.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (onUpdate != null) ...[
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onUpdate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Log First Measurement'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  const _MeasurementRow({required this.measurement});
  final BodyMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDecrease = measurement.changeCm < 0;
    final noChange = measurement.changeCm == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(measurement.label, style: textTheme.titleMedium),
          ),
          Text('${measurement.valueCm.toStringAsFixed(0)} cm', style: textTheme.titleSmall),
          const SizedBox(width: AppSpacing.md),
          if (!noChange)
            Row(
              children: [
                Icon(
                  isDecrease ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  size: 14,
                  color: isDecrease ? AppColors.success : AppColors.warning,
                ),
                Text(
                  measurement.changeCm.abs().toStringAsFixed(1),
                  style: textTheme.labelMedium?.copyWith(
                    color: isDecrease ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            )
          else
            Text('—', style: textTheme.labelMedium),
        ],
      ),
    );
  }
}

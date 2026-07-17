import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// The "Goal: 65 kg" / "BMI: 22.1" two-column footer row shown under the
/// weight chart card in the reference image.
class ProgressStatRow extends StatelessWidget {
  const ProgressStatRow({super.key, required this.goalWeightKg, required this.bmi});

  final double goalWeightKg;
  final double bmi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              label: 'Goal',
              value: '${goalWeightKg.toStringAsFixed(0)} kg',
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.ink100),
          Expanded(
            child: _StatColumn(
              label: 'BMI',
              value: bmi.toStringAsFixed(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(label, style: textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: textTheme.titleLarge),
      ],
    );
  }
}

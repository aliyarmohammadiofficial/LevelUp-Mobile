import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// One macro's progress ("Protein 115 / 150g") — three of these stacked
/// horizontally reproduce the "Macro Targets" row on the reference
/// Nutrition Plan and Today screens.
class MacroBarRow extends StatelessWidget {
  const MacroBarRow({
    super.key,
    required this.label,
    required this.consumedG,
    required this.targetG,
    required this.color,
  });

  final String label;
  final double consumedG;
  final int targetG;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = targetG == 0 ? 0.0 : (consumedG / targetG).clamp(0, 1).toDouble();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppRadius.pillRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.chartTrackWeak,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${consumedG.round()} / $targetG g',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/progress_summary.dart';

/// The "72.5 kg / -4.5 kg from last month" hero card with a weight-trend
/// line chart below it, matching the Progress tab of the reference image.
class WeightChartCard extends StatelessWidget {
  const WeightChartCard({
    super.key,
    required this.currentWeightKg,
    required this.weightChangeKg,
    required this.periodLabel,
    required this.history,
  });

  final double currentWeightKg;
  final double weightChangeKg;
  final String periodLabel;
  final List<WeightPoint> history;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLoss = weightChangeKg <= 0;

    final minY = history.map((p) => p.weightKg).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = history.map((p) => p.weightKg).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentWeightKg.toStringAsFixed(1),
                style: textTheme.displayMedium,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('kg', style: textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                isLoss ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                size: 16,
                color: isLoss ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${weightChangeKg.abs().toStringAsFixed(1)} kg $periodLabel',
                style: textTheme.bodySmall?.copyWith(
                  color: isLoss ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= history.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            DateFormat.Md().format(history[index].date),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.ink900,
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} kg',
                        const TextStyle(color: AppColors.surface, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 3.5,
                        color: AppColors.surface,
                        strokeWidth: 2,
                        strokeColor: AppColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.18),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    spots: [
                      for (int i = 0; i < history.length; i++)
                        FlSpot(i.toDouble(), history[i].weightKg),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Large calorie ring + summary card matching the reference "Calories
/// 1,420/2,000 kcal — 71%" hero card on the Nutrition → Today tab.
class CalorieRingCard extends StatelessWidget {
  const CalorieRingCard({
    super.key,
    required this.consumed,
    required this.goal,
    required this.progress,
  });

  final int consumed;
  final int goal;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentLabel = '${(progress.clamp(0, 1) * 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppElevation.card(AppColors.primary),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: CustomPaint(
              painter: _RingPainter(progress: progress.clamp(0, 1)),
              child: Center(
                child: Text(
                  percentLabel,
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calories',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
                    children: [
                      TextSpan(text: '${consumed.toString()} '),
                      TextSpan(
                        text: '/ $goal kcal',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Large hydration ring showing "cupsLogged / cupGoal Cups", matching the
/// reference Water Tracker screen's hero ring.
class WaterRing extends StatelessWidget {
  const WaterRing({
    super.key,
    required this.cupsLogged,
    required this.cupGoal,
    this.size = 220,
  });

  final int cupsLogged;
  final int cupGoal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = cupGoal == 0 ? 0.0 : (cupsLogged / cupGoal).clamp(0, 1).toDouble();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _WaterRingPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.headlineLarge,
                  children: [
                    TextSpan(text: '$cupsLogged'),
                    TextSpan(
                      text: ' / $cupGoal',
                      style: theme.textTheme.titleLarge?.copyWith(color: AppColors.ink500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Cups', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterRingPainter extends CustomPainter {
  _WaterRingPainter({required this.progress});
  final double progress;

  static const _waterBlue = Color(0xFF3BA7F0);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    const strokeWidth = 16.0;

    final trackPaint = Paint()
      ..color = AppColors.chartTrackWeak
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [AppColors.primaryLight, _waterBlue, AppColors.primary],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaterRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

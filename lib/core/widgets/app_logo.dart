import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'mascot.dart';

/// The LevelUp mark: a circular progress ring that fades from light to dark
/// blue and terminates in an upward arrowhead, wrapped around the mascot.
/// Matches the supplied Logo.png composition (ring + up-arrow + cat).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.showBackground = true});

  final double size;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(size: Size.square(size), painter: _RingArrowPainter()),
        Mascot(size: size * 0.62, animate: false),
      ],
    );

    if (!showBackground) return content;

    return Container(
      width: size * 1.32,
      height: size * 1.32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: content,
    );
  }
}

class _RingArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.42;
    final strokeWidth = size.width * 0.09;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: const [
          AppColors.primaryFaint,
          AppColors.primary,
          AppColors.primaryDark,
        ],
        stops: const [0.0, 0.55, 0.92],
        transform: const GradientRotation(-math.pi / 2 - 0.6),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Ring spans ~80% of the circle, leaving a gap for the arrowhead.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 - 0.6,
      math.pi * 2 * 0.82,
      false,
      ringPaint,
    );

    // Arrowhead at the open end (top-right), pointing up.
    final arrowTip = center + Offset(radius * 0.72, -radius * 0.72);
    final arrowPaint = Paint()..color = AppColors.primary;
    final arrowPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy - strokeWidth * 1.1)
      ..lineTo(arrowTip.dx + strokeWidth * 0.9, arrowTip.dy + strokeWidth * 0.5)
      ..lineTo(arrowTip.dx - strokeWidth * 0.9, arrowTip.dy + strokeWidth * 0.5)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _RingArrowPainter oldDelegate) => false;
}

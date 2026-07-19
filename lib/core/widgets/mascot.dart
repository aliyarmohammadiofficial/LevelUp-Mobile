import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Poses for the LevelUp mascot (the headband-wearing cat from the logo).
enum MascotPose { wave, celebrate, sleepy, sad, wink }

/// The LevelUp mascot, drawn in code with [CustomPainter] so it always
/// matches the exact line weight and palette of the logo (navy outline,
/// primary-blue headband/bandana) at any size, with no raster asset to
/// keep in sync. This is the single source for the mascot across the app —
/// every empty state, achievement toast, and onboarding screen should use
/// this widget rather than a new drawing.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.pose = MascotPose.wave,
    this.size = 120,
    this.animated = true,
  });

  final MascotPose pose;
  final double size;
  // Note: intentionally not named `animate` — that would shadow the
  // flutter_animate extension's `.animate()` method on Widget and cause
  // `invocation_of_non_function_expression` wherever a Mascot instance is
  // chained with `.animate()...` for entrance animations.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final painter = _MascotPainter(pose: pose);
    final child = CustomPaint(size: Size.square(size), painter: painter);

    if (!animated) return child;

    return _MascotIdleAnimation(pose: pose, child: child);
  }
}

class _MascotIdleAnimation extends StatefulWidget {
  const _MascotIdleAnimation({required this.child, required this.pose});
  final Widget child;
  final MascotPose pose;

  @override
  State<_MascotIdleAnimation> createState() => _MascotIdleAnimationState();
}

class _MascotIdleAnimationState extends State<_MascotIdleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final bob = widget.pose == MascotPose.sleepy ? 0.0 : math.sin(t * math.pi) * 4;
        return Transform.translate(offset: Offset(0, -bob), child: child);
      },
      child: widget.child,
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter({required this.pose});
  final MascotPose pose;

  static const Color outline = AppColors.ink900;
  static const Color band = AppColors.primary;
  static const Color bandLight = AppColors.primaryLight;
  static const Color fur = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 + h * 0.04;

    final linePaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final furPaint = Paint()..color = fur;
    final bandPaint = Paint()..color = band;

    // --- Ears ---
    final earL = Path()
      ..moveTo(cx - w * 0.24, cy - h * 0.22)
      ..lineTo(cx - w * 0.32, cy - h * 0.42)
      ..lineTo(cx - w * 0.12, cy - h * 0.30)
      ..close();
    final earR = Path()
      ..moveTo(cx + w * 0.24, cy - h * 0.22)
      ..lineTo(cx + w * 0.32, cy - h * 0.42)
      ..lineTo(cx + w * 0.12, cy - h * 0.30)
      ..close();
    canvas.drawPath(earL, furPaint);
    canvas.drawPath(earR, furPaint);
    canvas.drawPath(earL, linePaint);
    canvas.drawPath(earR, linePaint);

    // --- Head ---
    final headRect = Rect.fromCenter(center: Offset(cx, cy), width: w * 0.56, height: h * 0.5);
    canvas.drawOval(headRect, furPaint);
    canvas.drawOval(headRect, linePaint);

    // --- Headband ---
    final bandRect = Rect.fromCenter(
      center: Offset(cx, cy - h * 0.12),
      width: w * 0.58,
      height: h * 0.11,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bandRect, Radius.circular(h * 0.05)),
      bandPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bandRect, Radius.circular(h * 0.05)),
      linePaint,
    );
    // band highlight stripe
    final stripePaint = Paint()
      ..color = bandLight
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - w * 0.2, cy - h * 0.14),
      Offset(cx + w * 0.16, cy - h * 0.145),
      stripePaint,
    );

    // --- Eyes ---
    final eyePaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;

    final isWink = pose == MascotPose.wink;
    final isSleepy = pose == MascotPose.sleepy;

    void drawEye(double dx, {required bool closed}) {
      final ex = cx + dx;
      final ey = cy - h * 0.01;
      if (closed || isSleepy) {
        canvas.drawArc(
          Rect.fromCenter(center: Offset(ex, ey), width: w * 0.09, height: h * 0.06),
          0.2,
          math.pi - 0.4,
          false,
          eyePaint,
        );
      } else {
        canvas.drawArc(
          Rect.fromCenter(center: Offset(ex, ey), width: w * 0.08, height: h * 0.08),
          math.pi + 0.3,
          math.pi - 0.6,
          false,
          eyePaint,
        );
      }
    }

    drawEye(-w * 0.13, closed: isWink);
    drawEye(w * 0.13, closed: false);

    // --- Nose + mouth ---
    final nosePos = Offset(cx, cy + h * 0.055);
    canvas.drawCircle(nosePos, w * 0.014, Paint()..color = outline);

    final mouthPath = Path()
      ..moveTo(nosePos.dx, nosePos.dy)
      ..quadraticBezierTo(cx - w * 0.03, cy + h * 0.09, cx - w * 0.06, cy + h * 0.075)
      ..moveTo(nosePos.dx, nosePos.dy)
      ..quadraticBezierTo(cx + w * 0.03, cy + h * 0.09, cx + w * 0.06, cy + h * 0.075);
    canvas.drawPath(mouthPath, eyePaint);

    // --- Whiskers ---
    final whiskerPaint = Paint()
      ..color = outline.withValues(alpha: 0.7)
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    for (final side in [-1, 1]) {
      for (final i in [-1, 0, 1]) {
        final startX = cx + side * w * 0.26;
        final startY = cy + h * 0.02 + i * h * 0.035;
        canvas.drawLine(
          Offset(startX, startY),
          Offset(startX + side * w * 0.1, startY + i * h * 0.01),
          whiskerPaint,
        );
      }
    }

    // --- Cheeks blush ---
    final blushPaint = Paint()..color = AppColors.primaryFaint.withValues(alpha: 0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.16, cy + h * 0.04), width: w * 0.05, height: h * 0.03),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.16, cy + h * 0.04), width: w * 0.05, height: h * 0.03),
      blushPaint,
    );

    // --- Pose accessories ---
    if (pose == MascotPose.celebrate) {
      final sparklePaint = Paint()..color = band;
      _drawSparkle(canvas, Offset(cx - w * 0.34, cy - h * 0.34), w * 0.05, sparklePaint);
      _drawSparkle(canvas, Offset(cx + w * 0.36, cy - h * 0.28), w * 0.035, sparklePaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 2) * i;
      final tip = center + Offset(math.cos(angle), math.sin(angle)) * r;
      final base1 = center + Offset(math.cos(angle + 0.5), math.sin(angle + 0.5)) * (r * 0.3);
      final base2 = center + Offset(math.cos(angle - 0.5), math.sin(angle - 0.5)) * (r * 0.3);
      if (i == 0) path.moveTo(tip.dx, tip.dy);
      path.lineTo(base1.dx, base1.dy);
      final nextAngle = (math.pi / 2) * (i + 1);
      final nextTip = center + Offset(math.cos(nextAngle), math.sin(nextAngle)) * r;
      path.lineTo(nextTip.dx, nextTip.dy);
      path.lineTo(base2.dx, base2.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) => oldDelegate.pose != pose;
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/workout_routine.dart';

/// Simplified front + back body silhouettes with the exercise's primary
/// muscle regions tinted, matching the "Muscles Worked" pair of figures on
/// the reference Exercise Detail screen. Deliberately schematic (rounded
/// rects, not anatomy) — legible at a glance rather than literal.
class MuscleDiagram extends StatelessWidget {
  const MuscleDiagram({super.key, required this.muscles, this.height = 150});

  final List<MuscleGroup> muscles;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _BodyFigure(muscles: muscles, front: true, height: height)),
        const SizedBox(width: 12),
        Expanded(child: _BodyFigure(muscles: muscles, front: false, height: height)),
      ],
    );
  }
}

class _BodyFigure extends StatelessWidget {
  const _BodyFigure({required this.muscles, required this.front, required this.height});

  final List<MuscleGroup> muscles;
  final bool front;
  final double height;

  bool _active(MuscleGroup group) =>
      muscles.contains(group) || muscles.contains(MuscleGroup.fullBody);

  Color _fill(MuscleGroup group) =>
      _active(group) ? AppColors.primary : AppColors.chartTrackWeak;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _BodyPainter(
          front: front,
          chest: _fill(MuscleGroup.chest),
          back: _fill(MuscleGroup.back),
          shoulders: _fill(MuscleGroup.shoulders),
          arms: _fill(MuscleGroup.arms),
          core: _fill(MuscleGroup.core),
          legs: _fill(MuscleGroup.legs),
        ),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.front,
    required this.chest,
    required this.back,
    required this.shoulders,
    required this.arms,
    required this.core,
    required this.legs,
  });

  final bool front;
  final Color chest;
  final Color back;
  final Color shoulders;
  final Color arms;
  final Color core;
  final Color legs;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final outline = Paint()
      ..color = AppColors.ink300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    void rrect(Rect rect, Color color, {double radius = 6}) {
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      canvas.drawRRect(rr, Paint()..color = color);
      canvas.drawRRect(rr, outline);
    }

    void oval(Rect rect, Color color) {
      canvas.drawOval(rect, Paint()..color = color);
      canvas.drawOval(rect, outline);
    }

    // Head
    oval(Rect.fromCenter(center: Offset(cx, h * 0.08), width: w * 0.22, height: h * 0.14),
        AppColors.chartTrackWeak);

    // Shoulders (trapezius/deltoid block)
    rrect(
      Rect.fromCenter(center: Offset(cx, h * 0.22), width: w * 0.62, height: h * 0.08),
      shoulders,
      radius: 10,
    );

    // Torso — chest (front) or back (back)
    rrect(
      Rect.fromCenter(center: Offset(cx, h * 0.38), width: w * 0.48, height: h * 0.24),
      front ? chest : back,
      radius: 8,
    );

    // Arms (two side bars)
    rrect(
      Rect.fromCenter(center: Offset(cx - w * 0.36, h * 0.4), width: w * 0.12, height: h * 0.34),
      arms,
      radius: 8,
    );
    rrect(
      Rect.fromCenter(center: Offset(cx + w * 0.36, h * 0.4), width: w * 0.12, height: h * 0.34),
      arms,
      radius: 8,
    );

    // Core / abdomen
    rrect(
      Rect.fromCenter(center: Offset(cx, h * 0.58), width: w * 0.34, height: h * 0.14),
      core,
      radius: 8,
    );

    // Legs (two bars)
    rrect(
      Rect.fromCenter(center: Offset(cx - w * 0.14, h * 0.84), width: w * 0.16, height: h * 0.32),
      legs,
      radius: 8,
    );
    rrect(
      Rect.fromCenter(center: Offset(cx + w * 0.14, h * 0.84), width: w * 0.16, height: h * 0.32),
      legs,
      radius: 8,
    );
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) => true;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:levelup/features/fasting/domain/entities/fasting_entities.dart';

void main() {
  const plan = FastingPlan(
    id: '16-8',
    label: '16:8',
    fastHours: 16,
    eatHours: 8,
    description: 'test plan',
  );

  FastingSession sessionStartedAt(DateTime startedAt) => FastingSession(
        plan: plan,
        state: FastingSessionState.fasting,
        startedAt: startedAt,
        fastEndsAt: startedAt.add(const Duration(hours: 16)),
        eatingWindowEndsAt: startedAt.add(const Duration(hours: 24)),
      );

  group('FastingSession.progressAt', () {
    test('is 0 at the moment the fast starts', () {
      final start = DateTime(2026, 1, 1, 8);
      final session = sessionStartedAt(start);
      expect(session.progressAt(start), 0);
    });

    test('is 0.5 halfway through the fast window', () {
      final start = DateTime(2026, 1, 1, 8);
      final session = sessionStartedAt(start);
      expect(session.progressAt(start.add(const Duration(hours: 8))), closeTo(0.5, 0.001));
    });

    test('clamps to 1 once the fast window has fully elapsed', () {
      final start = DateTime(2026, 1, 1, 8);
      final session = sessionStartedAt(start);
      expect(session.progressAt(start.add(const Duration(hours: 40))), 1);
    });
  });

  group('FastingSession.remainingIn', () {
    test('counts down toward fastEndsAt while fasting', () {
      final start = DateTime(2026, 1, 1, 8);
      final session = sessionStartedAt(start);
      final remaining = session.remainingIn(start.add(const Duration(hours: 10)));
      expect(remaining, const Duration(hours: 6));
    });

    test('counts down toward eatingWindowEndsAt once in the eating window', () {
      final start = DateTime(2026, 1, 1, 8);
      final session = sessionStartedAt(start).copyWith(state: FastingSessionState.eatingWindow);
      final remaining = session.remainingIn(start.add(const Duration(hours: 20)));
      expect(remaining, const Duration(hours: 4));
    });

    test('never goes negative once the target time has passed', () {
      final start = DateTime(2026, 1, 1, 8);
      final session = sessionStartedAt(start);
      final remaining = session.remainingIn(start.add(const Duration(hours: 100)));
      expect(remaining, Duration.zero);
    });
  });
}

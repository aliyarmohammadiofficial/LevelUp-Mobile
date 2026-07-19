import 'package:flutter_test/flutter_test.dart';
import 'package:levelup/core/utils/streak_milestones.dart';

void main() {
  group('matchedStreakMilestone', () {
    test('returns the streak length on an exact milestone day', () {
      for (final day in kStreakMilestoneDays) {
        expect(matchedStreakMilestone(day), day);
      }
    });

    test('returns null on a non-milestone day', () {
      expect(matchedStreakMilestone(1), isNull);
      expect(matchedStreakMilestone(4), isNull);
      expect(matchedStreakMilestone(15), isNull);
      expect(matchedStreakMilestone(0), isNull);
    });

    test('does not match past the last milestone without an exact hit', () {
      expect(matchedStreakMilestone(366), isNull);
      expect(matchedStreakMilestone(1000), isNull);
    });
  });
}

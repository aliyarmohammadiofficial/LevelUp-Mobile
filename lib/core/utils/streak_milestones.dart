/// Streak lengths (in days) that trigger a one-time "N-day streak!"
/// achievement notification. Shared between any feature that tracks a
/// day-based streak (currently Water and Fasting) so the milestone
/// ladder — and what counts as a moment worth celebrating — stays
/// consistent across the app rather than each feature picking its own.
const List<int> kStreakMilestoneDays = [3, 7, 14, 30, 50, 100, 200, 365];

/// Returns [streakDays] if it's exactly one of [kStreakMilestoneDays],
/// otherwise null. Callers should check this right after a streak-
/// affecting action (a goal met, a fast completed) so the notification
/// fires on the day the milestone is first reached, not retroactively.
int? matchedStreakMilestone(int streakDays) =>
    kStreakMilestoneDays.contains(streakDays) ? streakDays : null;

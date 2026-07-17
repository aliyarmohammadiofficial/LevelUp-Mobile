import '../../../fasting/data/datasources/fasting_local_datasource.dart';
import '../../../nutrition/data/datasources/nutrition_local_datasource.dart';
import '../../../nutrition/domain/entities/nutrition_entities.dart' as nutrition;
import '../../../workout/data/datasources/workout_local_datasource.dart';
import '../../domain/entities/dashboard_summary.dart';

const _tips = [
  'Consistency today, strength tomorrow!',
  'Staying hydrated during your fast helps curb hunger.',
  'Small daily wins add up to big results.',
  'Progress, not perfection.',
];

/// Assembles the Dashboard's read-model from the real Fasting, Workout,
/// and Nutrition datasources — no fabricated numbers. Each source is
/// queried independently so a missing/empty one (e.g. no fast started
/// yet) degrades to a sensible zero/idle state rather than failing the
/// whole dashboard.
class DashboardLocalDataSource {
  DashboardLocalDataSource(this._fasting, this._workout, this._nutrition);

  final FastingLocalDataSource _fasting;
  final WorkoutLocalDataSource _workout;
  final NutritionLocalDataSource _nutrition;

  Future<DashboardSummary> getSummary({required String userDisplayName}) async {
    final fastingStatus = await _buildFastingStatus();
    final workoutSummary = await _buildWorkoutSummary();
    final nutritionDay = await _nutrition.getToday();

    final tipIndex = DateTime.now().day % _tips.length;

    return DashboardSummary(
      userDisplayName: userDisplayName,
      fasting: fastingStatus,
      workout: workoutSummary,
      calories: CalorieSummary(
        consumed: nutritionDay.caloriesLogged,
        goal: nutritionDay.calorieGoal,
      ),
      todaysMeals: nutritionDay.meals
          .map((m) => MealSlot(
                type: _toDashboardMealType(m.type),
                label: m.type.label,
                calories: m.loggedCalories,
                isLogged: m.isLogged,
              ))
          .toList(),
      tip: _tips[tipIndex],
    );
  }

  Future<FastingStatus> _buildFastingStatus() async {
    final session = await _fasting.getCurrentSession();
    if (session == null) {
      return FastingStatus(
        isActive: false,
        planLabel: '—',
        remaining: Duration.zero,
        endsAt: DateTime.now(),
      );
    }
    final now = DateTime.now();
    final isEatingWindow = session.state.name == 'eatingWindow';
    final target = isEatingWindow ? session.eatingWindowEndsAt : session.fastEndsAt;
    final remaining = target.difference(now);
    return FastingStatus(
      isActive: session.state.name == 'fasting',
      planLabel: session.plan.label,
      remaining: remaining.isNegative ? Duration.zero : remaining,
      endsAt: target,
    );
  }

  Future<WorkoutSummary> _buildWorkoutSummary() async {
    final routines = await _workout.getRoutines();
    final today = routines.where((r) => r.isToday).toList();
    if (today.isEmpty) {
      return const WorkoutSummary(completedCount: 0, totalCount: 0);
    }
    final routine = today.first;
    return WorkoutSummary(
      completedCount: routine.completedCount,
      totalCount: routine.totalCount,
    );
  }

  MealType _toDashboardMealType(nutrition.MealType type) => switch (type) {
        nutrition.MealType.breakfast => MealType.breakfast,
        nutrition.MealType.lunch => MealType.lunch,
        nutrition.MealType.dinner => MealType.dinner,
        nutrition.MealType.snack => MealType.snack,
      };
}

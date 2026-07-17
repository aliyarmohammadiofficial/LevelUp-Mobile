import '../../../../core/utils/result.dart';
import '../entities/nutrition_entities.dart';

/// Contract for reading today's nutrition log, editing the plan, searching
/// the food database, and logging entries against a meal. Backed by
/// [NutritionRepositoryImpl] over an in-memory mock source for now — same
/// swap-later pattern as [WorkoutRepository]/[DashboardRepository].
abstract class NutritionRepository {
  Stream<NutritionDay> watchToday();

  Stream<NutritionInsights> watchInsights();

  Future<Result<List<FoodItem>>> searchFood(String query);

  /// Recently and commonly logged foods, shown before the user types a
  /// search query — matches the "Recent" section on the reference
  /// Add Food screen.
  Future<Result<List<FoodItem>>> getRecentFoods();

  Future<Result<NutritionDay>> logFood({
    required MealType meal,
    required FoodItem food,
    required double servings,
  });

  Future<Result<NutritionDay>> removeEntry({
    required MealType meal,
    required String entryId,
  });

  Future<Result<void>> updatePlan({
    required int calorieGoal,
    required MacroTargets macroTargets,
  });

  /// Adds a user-defined food to the catalog so it can be searched and
  /// logged just like the built-in foods — matches the "Create Custom
  /// Food" flow reachable from Add Food.
  Future<Result<FoodItem>> createCustomFood({
    required String name,
    required String servingLabel,
    required int caloriesPerServing,
    required double proteinG,
    required double carbsG,
    required double fatG,
  });

  Future<Result<void>> deleteCustomFood(String id);
}

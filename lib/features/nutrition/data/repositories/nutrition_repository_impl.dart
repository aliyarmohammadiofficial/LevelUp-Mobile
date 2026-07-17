import '../../../../core/utils/result.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_local_datasource.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  NutritionRepositoryImpl(this._local);

  final NutritionLocalDataSource _local;

  @override
  Stream<NutritionDay> watchToday() async* {
    yield await _local.getToday();
  }

  @override
  Stream<NutritionInsights> watchInsights() async* {
    yield await _local.getInsights();
  }

  @override
  Future<Result<List<FoodItem>>> searchFood(String query) async {
    return Result.success(await _local.searchCatalog(query));
  }

  @override
  Future<Result<List<FoodItem>>> getRecentFoods() async {
    return Result.success(await _local.recentCatalog());
  }

  @override
  Future<Result<NutritionDay>> logFood({
    required MealType meal,
    required FoodItem food,
    required double servings,
  }) async {
    final updated = await _local.logFood(meal: meal, food: food, servings: servings);
    return Result.success(updated);
  }

  @override
  Future<Result<NutritionDay>> removeEntry({
    required MealType meal,
    required String entryId,
  }) async {
    final updated = await _local.removeEntry(meal: meal, entryId: entryId);
    return Result.success(updated);
  }

  @override
  Future<Result<void>> updatePlan({
    required int calorieGoal,
    required MacroTargets macroTargets,
  }) async {
    await _local.updatePlan(calorieGoal: calorieGoal, macroTargets: macroTargets);
    return const Result.success(null);
  }

  @override
  Future<Result<FoodItem>> createCustomFood({
    required String name,
    required String servingLabel,
    required int caloriesPerServing,
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) async {
    final food = await _local.createCustomFood(
      name: name,
      servingLabel: servingLabel,
      caloriesPerServing: caloriesPerServing,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
    );
    return Result.success(food);
  }

  @override
  Future<Result<void>> deleteCustomFood(String id) async {
    await _local.deleteCustomFood(id);
    return const Result.success(null);
  }
}

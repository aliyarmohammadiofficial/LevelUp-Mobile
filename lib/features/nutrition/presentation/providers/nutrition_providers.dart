import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/nutrition_local_datasource.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../../domain/repositories/nutrition_repository.dart';

final nutritionLocalDataSourceProvider = Provider((ref) => NutritionLocalDataSource());

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepositoryImpl(ref.watch(nutritionLocalDataSourceProvider));
});

/// Drives every screen that needs "today's" nutrition state (Today tab,
/// Dashboard's calorie card, Nutrition Plan tab). Bumped by
/// [nutritionActionsProvider] after any write so all watchers refresh.
final _refreshTickProvider = StateProvider<int>((ref) => 0);

final nutritionTodayProvider = StreamProvider<NutritionDay>((ref) {
  ref.watch(_refreshTickProvider);
  return ref.watch(nutritionRepositoryProvider).watchToday();
});

final nutritionInsightsProvider = StreamProvider<NutritionInsights>((ref) {
  ref.watch(_refreshTickProvider);
  return ref.watch(nutritionRepositoryProvider).watchInsights();
});

/// Live food search results for the Add Food screen's search field.
final foodSearchQueryProvider = StateProvider<String>((ref) => '');

/// Bumped after a custom food is created/deleted so search results and the
/// recent list refresh to include it, without affecting the day/insights
/// refresh tick above.
final _catalogRefreshTickProvider = StateProvider<int>((ref) => 0);

final foodSearchResultsProvider = FutureProvider<List<FoodItem>>((ref) async {
  ref.watch(_catalogRefreshTickProvider);
  final query = ref.watch(foodSearchQueryProvider);
  if (query.trim().isEmpty) return [];
  final result = await ref.watch(nutritionRepositoryProvider).searchFood(query);
  return result.dataOrNull ?? [];
});

final recentFoodsProvider = FutureProvider<List<FoodItem>>((ref) async {
  ref.watch(_catalogRefreshTickProvider);
  final result = await ref.watch(nutritionRepositoryProvider).getRecentFoods();
  return result.dataOrNull ?? [];
});

/// Write-side actions, kept off the read providers above so screens can
/// `ref.read(nutritionActionsProvider).logFood(...)` without rebuilding on
/// every keystroke of unrelated state.
final nutritionActionsProvider = Provider((ref) => NutritionActions(ref));

class NutritionActions {
  NutritionActions(this._ref);
  final Ref _ref;

  Future<void> logFood({
    required MealType meal,
    required FoodItem food,
    required double servings,
  }) async {
    await _ref
        .read(nutritionRepositoryProvider)
        .logFood(meal: meal, food: food, servings: servings);
    _ref.read(_refreshTickProvider.notifier).state++;
  }

  Future<void> removeEntry({required MealType meal, required String entryId}) async {
    await _ref.read(nutritionRepositoryProvider).removeEntry(meal: meal, entryId: entryId);
    _ref.read(_refreshTickProvider.notifier).state++;
  }

  Future<void> updatePlan({
    required int calorieGoal,
    required MacroTargets macroTargets,
  }) async {
    await _ref
        .read(nutritionRepositoryProvider)
        .updatePlan(calorieGoal: calorieGoal, macroTargets: macroTargets);
    _ref.read(_refreshTickProvider.notifier).state++;
  }

  Future<FoodItem?> createCustomFood({
    required String name,
    required String servingLabel,
    required int caloriesPerServing,
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) async {
    final result = await _ref.read(nutritionRepositoryProvider).createCustomFood(
          name: name,
          servingLabel: servingLabel,
          caloriesPerServing: caloriesPerServing,
          proteinG: proteinG,
          carbsG: carbsG,
          fatG: fatG,
        );
    _ref.read(_catalogRefreshTickProvider.notifier).state++;
    return result.dataOrNull;
  }

  Future<void> deleteCustomFood(String id) async {
    await _ref.read(nutritionRepositoryProvider).deleteCustomFood(id);
    _ref.read(_catalogRefreshTickProvider.notifier).state++;
  }
}

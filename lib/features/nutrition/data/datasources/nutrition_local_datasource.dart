import 'package:hive_ce/hive_ce.dart';
import '../../domain/entities/nutrition_entities.dart';

/// Hive-backed persistence for Nutrition, following the same plain-map
/// pattern as [OnboardingLocalDataSource].
///
/// Box layout:
/// - `nutrition_plan_box` — calorie goal + macro targets (single record)
/// - `nutrition_days_box` — one entry per day, keyed by ISO date, holding
///   that day's logged meals
/// - `nutrition_custom_foods_box` — user-created [FoodItem]s, keyed by id,
///   merged with the static catalog below at read time so custom foods are
///   searchable/loggable just like built-in ones.
/// - Food catalog stays a static in-memory list (a real food database is
///   out of scope here) but logged entries, daily history, and any custom
///   foods the user creates are real.
class NutritionLocalDataSource {
  static const _planBoxName = 'nutrition_plan_box';
  static const _daysBoxName = 'nutrition_days_box';
  static const _customFoodsBoxName = 'nutrition_custom_foods_box';
  static const _calorieGoalKey = 'calorieGoal';
  static const _macroTargetsKey = 'macroTargets';

  static const defaultCalorieGoal = 2000;
  static const defaultMacroTargets = MacroTargets(proteinG: 150, carbsG: 220, fatG: 70);

  static const _emptyMealTypes = MealType.values;

  int _entryCounter = DateTime.now().millisecondsSinceEpoch;
  int _customFoodCounter = DateTime.now().millisecondsSinceEpoch;

  Future<Box> _planBox() => Hive.openBox(_planBoxName);
  Future<Box> _daysBox() => Hive.openBox(_daysBoxName);
  Future<Box> _customFoodsBox() => Hive.openBox(_customFoodsBoxName);

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<int> _calorieGoal() async {
    final box = await _planBox();
    return box.get(_calorieGoalKey, defaultValue: defaultCalorieGoal) as int;
  }

  Future<MacroTargets> _macroTargets() async {
    final box = await _planBox();
    final raw = box.get(_macroTargetsKey);
    if (raw == null) return defaultMacroTargets;
    final map = Map<String, dynamic>.from(raw as Map);
    return MacroTargets(
      proteinG: map['proteinG'] as int,
      carbsG: map['carbsG'] as int,
      fatG: map['fatG'] as int,
    );
  }

  Future<List<MealLog>> _mealsForDate(DateTime date) async {
    final box = await _daysBox();
    final raw = box.get(_dateKey(date));
    final targets = _mealTargets();

    if (raw == null) {
      return _emptyMealTypes
          .map((t) => MealLog(type: t, entries: const [], targetCalories: targets[t]!))
          .toList();
    }

    final map = Map<String, dynamic>.from(raw as Map);
    return _emptyMealTypes.map((type) {
      final entriesRaw = (map[type.name] as List?) ?? const [];
      final entries = entriesRaw.map((e) {
        final entryMap = Map<String, dynamic>.from(e as Map);
        return FoodEntry(
          id: entryMap['id'] as String,
          foodName: entryMap['foodName'] as String,
          quantityLabel: entryMap['quantityLabel'] as String,
          calories: entryMap['calories'] as int,
        );
      }).toList();
      return MealLog(type: type, entries: entries, targetCalories: targets[type]!);
    }).toList();
  }

  Map<MealType, int> _mealTargets() => const {
        MealType.breakfast: 400,
        MealType.lunch: 600,
        MealType.dinner: 600,
        MealType.snack: 200,
      };

  Future<void> _saveMeals(DateTime date, List<MealLog> meals) async {
    final box = await _daysBox();
    final map = {
      for (final meal in meals)
        meal.type.name: meal.entries
            .map((e) => {
                  'id': e.id,
                  'foodName': e.foodName,
                  'quantityLabel': e.quantityLabel,
                  'calories': e.calories,
                })
            .toList(),
    };
    await box.put(_dateKey(date), map);
  }

  Future<NutritionDay> getToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meals = await _mealsForDate(today);
    final calorieGoal = await _calorieGoal();
    final macroTargets = await _macroTargets();

    final loggedCalories = meals.fold<int>(0, (sum, m) => sum + m.loggedCalories);
    final macroProgress = MacroProgress(
      proteinG: (loggedCalories * 0.30) / 4,
      carbsG: (loggedCalories * 0.45) / 4,
      fatG: (loggedCalories * 0.25) / 9,
    );

    return NutritionDay(
      date: today,
      calorieGoal: calorieGoal,
      macroTargets: macroTargets,
      macroProgress: macroProgress,
      meals: meals,
    );
  }

  Future<NutritionDay> logFood({
    required MealType meal,
    required FoodItem food,
    required double servings,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meals = await _mealsForDate(today);

    _entryCounter++;
    final entry = FoodEntry(
      id: 'entry-$_entryCounter',
      foodName: food.name,
      quantityLabel: servings == 1
          ? food.servingLabel
          : '${servings.toStringAsFixed(servings.truncateToDouble() == servings ? 0 : 1)} × ${food.servingLabel}',
      calories: (food.caloriesPerServing * servings).round(),
    );

    final updated = meals.map((m) {
      if (m.type != meal) return m;
      return m.copyWith(entries: [...m.entries, entry]);
    }).toList();

    await _saveMeals(today, updated);
    return getToday();
  }

  Future<NutritionDay> removeEntry({required MealType meal, required String entryId}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meals = await _mealsForDate(today);

    final updated = meals.map((m) {
      if (m.type != meal) return m;
      return m.copyWith(entries: m.entries.where((e) => e.id != entryId).toList());
    }).toList();

    await _saveMeals(today, updated);
    return getToday();
  }

  Future<void> updatePlan({required int calorieGoal, required MacroTargets macroTargets}) async {
    final box = await _planBox();
    await box.put(_calorieGoalKey, calorieGoal);
    await box.put(_macroTargetsKey, {
      'proteinG': macroTargets.proteinG,
      'carbsG': macroTargets.carbsG,
      'fatG': macroTargets.fatG,
    });
  }

  Future<NutritionInsights> getInsights() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final calorieGoal = await _calorieGoal();

    final history = <NutritionHistoryPoint>[];
    for (var i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final meals = await _mealsForDate(date);
      final consumed = meals.fold<int>(0, (sum, m) => sum + m.loggedCalories);
      history.add(NutritionHistoryPoint(
        date: date,
        caloriesConsumed: consumed,
        calorieGoal: calorieGoal,
      ));
    }

    final loggedDays = history.where((h) => h.caloriesConsumed > 0).toList();
    final average = loggedDays.isEmpty
        ? 0
        : (loggedDays.fold<int>(0, (sum, h) => sum + h.caloriesConsumed) / loggedDays.length)
            .round();
    final best = history.isEmpty
        ? 0
        : history.map((h) => h.caloriesConsumed).reduce((a, b) => a > b ? a : b);

    int streak = 0;
    for (final point in history.reversed) {
      if (point.caloriesConsumed > 0) {
        streak++;
      } else {
        break;
      }
    }

    return NutritionInsights(
      history: history,
      averageCalories: average,
      bestDayCalories: best,
      loggingStreakDays: streak,
    );
  }

  // Food catalog: a static reference list merged with any foods the user
  // has created via "Create Custom Food". Swapping the static half for a
  // real food database (e.g. Open Food Facts / Supabase table) later
  // requires no change to the repository or providers above it.
  Future<List<FoodItem>> searchCatalog(String query) async {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    final all = [..._foodCatalog, ...await _customFoods()];
    return all.where((f) => f.name.toLowerCase().contains(lower)).toList();
  }

  Future<List<FoodItem>> recentCatalog() async {
    final custom = await _customFoods();
    return [
      ..._foodCatalog.where((f) => f.isRecent),
      // Custom foods are surfaced under Recent too, newest first, so a
      // food the user just created is immediately easy to log again.
      ...custom.reversed,
    ];
  }

  Future<List<FoodItem>> _customFoods() async {
    final box = await _customFoodsBox();
    return box.values.map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      return FoodItem(
        id: map['id'] as String,
        name: map['name'] as String,
        caloriesPerServing: map['caloriesPerServing'] as int,
        servingLabel: map['servingLabel'] as String,
        proteinG: (map['proteinG'] as num).toDouble(),
        carbsG: (map['carbsG'] as num).toDouble(),
        fatG: (map['fatG'] as num).toDouble(),
      );
    }).toList();
  }

  /// Creates a new custom [FoodItem], persisted so it survives app
  /// restarts and appears in search/recent alongside the built-in catalog.
  Future<FoodItem> createCustomFood({
    required String name,
    required String servingLabel,
    required int caloriesPerServing,
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) async {
    _customFoodCounter++;
    final food = FoodItem(
      id: 'custom-food-$_customFoodCounter',
      name: name,
      caloriesPerServing: caloriesPerServing,
      servingLabel: servingLabel,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
    );
    final box = await _customFoodsBox();
    await box.put(food.id, {
      'id': food.id,
      'name': food.name,
      'caloriesPerServing': food.caloriesPerServing,
      'servingLabel': food.servingLabel,
      'proteinG': food.proteinG,
      'carbsG': food.carbsG,
      'fatG': food.fatG,
    });
    return food;
  }

  Future<void> deleteCustomFood(String id) async {
    final box = await _customFoodsBox();
    await box.delete(id);
  }

  static const _foodCatalog = [
    FoodItem(
      id: 'food-oatmeal',
      name: 'Oatmeal',
      caloriesPerServing: 150,
      servingLabel: '100g',
      proteinG: 5,
      carbsG: 27,
      fatG: 3,
      isRecent: true,
    ),
    FoodItem(
      id: 'food-chicken-breast',
      name: 'Grilled Chicken Breast',
      caloriesPerServing: 165,
      servingLabel: '100g',
      proteinG: 31,
      carbsG: 0,
      fatG: 3.6,
      isRecent: true,
    ),
    FoodItem(
      id: 'food-banana',
      name: 'Banana',
      caloriesPerServing: 90,
      servingLabel: '1 medium',
      proteinG: 1.1,
      carbsG: 23,
      fatG: 0.3,
      isRecent: true,
    ),
    FoodItem(
      id: 'food-brown-rice',
      name: 'Brown Rice',
      caloriesPerServing: 112,
      servingLabel: '100g',
      proteinG: 2.6,
      carbsG: 24,
      fatG: 0.9,
    ),
    FoodItem(
      id: 'food-avocado',
      name: 'Avocado',
      caloriesPerServing: 160,
      servingLabel: '100g',
      proteinG: 2,
      carbsG: 8.5,
      fatG: 14.7,
    ),
    FoodItem(
      id: 'food-broccoli',
      name: 'Broccoli',
      caloriesPerServing: 55,
      servingLabel: '100g',
      proteinG: 3.7,
      carbsG: 11,
      fatG: 0.6,
    ),
    FoodItem(
      id: 'food-olive-oil',
      name: 'Olive Oil',
      caloriesPerServing: 119,
      servingLabel: '1 tbsp',
      proteinG: 0,
      carbsG: 0,
      fatG: 13.5,
    ),
    FoodItem(
      id: 'food-salmon',
      name: 'Salmon',
      caloriesPerServing: 208,
      servingLabel: '100g',
      proteinG: 20,
      carbsG: 0,
      fatG: 13,
    ),
    FoodItem(
      id: 'food-quinoa',
      name: 'Quinoa',
      caloriesPerServing: 120,
      servingLabel: '100g',
      proteinG: 4.4,
      carbsG: 21,
      fatG: 1.9,
    ),
    FoodItem(
      id: 'food-greek-yogurt',
      name: 'Greek Yogurt',
      caloriesPerServing: 100,
      servingLabel: '1 cup',
      proteinG: 17,
      carbsG: 6,
      fatG: 0.7,
    ),
    FoodItem(
      id: 'food-almonds',
      name: 'Almonds',
      caloriesPerServing: 164,
      servingLabel: '28g',
      proteinG: 6,
      carbsG: 6,
      fatG: 14,
    ),
    FoodItem(
      id: 'food-egg',
      name: 'Large Egg',
      caloriesPerServing: 72,
      servingLabel: '1 egg',
      proteinG: 6.3,
      carbsG: 0.4,
      fatG: 4.8,
    ),
    FoodItem(
      id: 'food-sweet-potato',
      name: 'Sweet Potato',
      caloriesPerServing: 86,
      servingLabel: '100g',
      proteinG: 1.6,
      carbsG: 20,
      fatG: 0.1,
    ),
    FoodItem(
      id: 'food-protein-shake',
      name: 'Whey Protein Shake',
      caloriesPerServing: 120,
      servingLabel: '1 scoop',
      proteinG: 24,
      carbsG: 3,
      fatG: 1.5,
    ),
    FoodItem(
      id: 'food-apple',
      name: 'Apple',
      caloriesPerServing: 95,
      servingLabel: '1 medium',
      proteinG: 0.5,
      carbsG: 25,
      fatG: 0.3,
    ),
  ];
}

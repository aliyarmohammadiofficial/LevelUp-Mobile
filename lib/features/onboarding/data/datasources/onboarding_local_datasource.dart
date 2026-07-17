import 'package:hive/hive.dart';
import '../../domain/entities/onboarding_answers.dart';

/// Stores onboarding answers as a plain string-keyed map in a dedicated
/// Hive box, rather than a generated Hive TypeAdapter — this data is
/// write-once/read-rarely (checked once at app start, written once at
/// flow completion), so the codegen overhead isn't worth it here. If this
/// grows into something read on every frame, switch to a TypeAdapter.
class OnboardingLocalDataSource {
  static const _boxName = 'onboarding_box';
  static const _answersKey = 'answers';
  static const _completedKey = 'completed';

  Future<Box> _openBox() => Hive.openBox(_boxName);

  Future<void> save(OnboardingAnswers answers) async {
    final box = await _openBox();
    await box.put(_answersKey, {
      'sex': answers.sex?.name,
      'goal': answers.goal?.name,
      'currentWeightKg': answers.currentWeightKg,
      'targetWeightKg': answers.targetWeightKg,
      'heightCm': answers.heightCm,
      'activityLevel': answers.activityLevel?.name,
      'workoutDaysPerWeek': answers.workoutDaysPerWeek,
      'dailyWaterCupsGoal': answers.dailyWaterCupsGoal,
    });
    await box.put(_completedKey, true);
  }

  Future<bool> isCompleted() async {
    final box = await _openBox();
    return box.get(_completedKey, defaultValue: false) as bool;
  }

  /// Reads back the persisted answers (used by the Profile tab's Personal
  /// Information / Goals screens). Returns null if onboarding was never
  /// completed on this device.
  Future<OnboardingAnswers?> load() async {
    final box = await _openBox();
    final raw = box.get(_answersKey);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(raw as Map);

    T? decodeEnum<T extends Enum>(String key, List<T> values) {
      final name = map[key] as String?;
      if (name == null) return null;
      for (final value in values) {
        if (value.name == name) return value;
      }
      return null;
    }

    return OnboardingAnswers(
      sex: decodeEnum('sex', BiologicalSex.values),
      goal: decodeEnum('goal', FitnessGoal.values),
      currentWeightKg: (map['currentWeightKg'] as num?)?.toDouble(),
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble(),
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      activityLevel: decodeEnum('activityLevel', ActivityLevel.values),
      workoutDaysPerWeek: (map['workoutDaysPerWeek'] as num?)?.toInt() ?? 3,
      dailyWaterCupsGoal: (map['dailyWaterCupsGoal'] as num?)?.toInt() ?? 8,
    );
  }
}

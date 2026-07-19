import 'package:hive_ce/hive_ce.dart';
import '../../domain/entities/workout_routine.dart';

/// Hive-backed persistence for Workout.
///
/// Routines/exercises themselves (name, target sets, instructions) are a
/// static seeded catalog, but the user can add their own exercises to any
/// routine via "Create Custom Exercise" — those are persisted separately
/// and merged in at read time. Every set's logged reps/weight and each
/// exercise's completed flag are real, persisted per calendar day so
/// today's workout state survives an app restart and a new day starts
/// fresh.
///
/// Box layout:
/// - `workout_progress_box` — key `<date>_<routineId>_<exerciseId>`, holds
///   the list of logged sets + completed flag for that exercise that day.
/// - `workout_custom_exercises_box` — key `<routineId>`, holds the list of
///   user-added [WorkoutExercise]s appended to that routine.
class WorkoutLocalDataSource {
  static const _boxName = 'workout_progress_box';
  static const _dailyLogBoxName = 'workout_daily_log_box';
  static const _customExercisesBoxName = 'workout_custom_exercises_box';

  Future<Box> _box() => Hive.openBox(_boxName);
  Future<Box> _dailyLogBox() => Hive.openBox(_dailyLogBoxName);
  Future<Box> _customExercisesBox() => Hive.openBox(_customExercisesBoxName);

  int _customExerciseCounter = DateTime.now().millisecondsSinceEpoch;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _progressKey(String routineId, String exerciseId) =>
      '${_todayKey()}_${routineId}_$exerciseId';

  Future<List<WorkoutRoutine>> getRoutines() async {
    final templates = _seedRoutines();
    final box = await _box();

    return Future.wait(templates.map((routine) async {
      final seededExercises = await Future.wait(routine.exercises.map((exercise) async {
        final raw = box.get(_progressKey(routine.id, exercise.id));
        if (raw == null) return exercise;

        final map = Map<String, dynamic>.from(raw as Map);
        final setsRaw = (map['sets'] as List?) ?? const [];
        final sets = setsRaw.map((s) {
          final sMap = Map<String, dynamic>.from(s as Map);
          return WorkoutSet(
            setNumber: sMap['setNumber'] as int,
            reps: sMap['reps'] as int,
            weightKg: (sMap['weightKg'] as num).toDouble(),
            isCompleted: sMap['isCompleted'] as bool,
          );
        }).toList();

        return exercise.copyWith(
          sets: sets.isEmpty ? exercise.sets : sets,
          isCompleted: map['isCompleted'] as bool? ?? exercise.isCompleted,
        );
      }));

      final customExercises = await _customExercisesFor(routine.id);
      final customWithProgress = await Future.wait(customExercises.map((exercise) async {
        final raw = box.get(_progressKey(routine.id, exercise.id));
        if (raw == null) return exercise;
        final map = Map<String, dynamic>.from(raw as Map);
        final setsRaw = (map['sets'] as List?) ?? const [];
        final sets = setsRaw.map((s) {
          final sMap = Map<String, dynamic>.from(s as Map);
          return WorkoutSet(
            setNumber: sMap['setNumber'] as int,
            reps: sMap['reps'] as int,
            weightKg: (sMap['weightKg'] as num).toDouble(),
            isCompleted: sMap['isCompleted'] as bool,
          );
        }).toList();
        return exercise.copyWith(
          sets: sets.isEmpty ? exercise.sets : sets,
          isCompleted: map['isCompleted'] as bool? ?? exercise.isCompleted,
        );
      }));

      return WorkoutRoutine(
        id: routine.id,
        name: routine.name,
        subtitle: routine.subtitle,
        isToday: routine.isToday,
        exercises: [...seededExercises, ...customWithProgress],
      );
    }));
  }

  Future<WorkoutRoutine?> getRoutine(String routineId) async {
    final routines = await getRoutines();
    for (final r in routines) {
      if (r.id == routineId) return r;
    }
    return null;
  }

  Future<WorkoutExercise?> getExercise(String routineId, String exerciseId) async {
    final routine = await getRoutine(routineId);
    if (routine == null) return null;
    for (final e in routine.exercises) {
      if (e.id == exerciseId) return e;
    }
    return null;
  }

  Future<WorkoutExercise?> logSet({
    required String routineId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    required double weightKg,
  }) async {
    final exercise = await getExercise(routineId, exerciseId);
    if (exercise == null) return null;

    final updatedSets = exercise.sets.map((s) {
      if (s.setNumber != setNumber) return s;
      return s.copyWith(reps: reps, weightKg: weightKg, isCompleted: true);
    }).toList();

    final allDone = updatedSets.every((s) => s.isCompleted);
    final updatedExercise = exercise.copyWith(sets: updatedSets, isCompleted: allDone);

    await _saveExerciseProgress(routineId, updatedExercise);
    await _recordDailyLog(routineId);
    return updatedExercise;
  }

  /// Records that the given routine had at least one set logged today, so
  /// Progress's "Workouts this week" reads real activity instead of a
  /// fixed mock schedule. Overwrites same-day/same-routine entries rather
  /// than duplicating.
  Future<void> _recordDailyLog(String routineId) async {
    final routines = _seedRoutines();
    final routine = routines.firstWhere((r) => r.id == routineId, orElse: () => routines.first);
    final box = await _dailyLogBox();
    final now = DateTime.now();
    final key = '${_todayKey()}_$routineId';
    await box.put(key, {
      'date': DateTime(now.year, now.month, now.day).toIso8601String(),
      'label': routine.name,
    });
  }

  /// Real workout-day history for the last [days] days, used by Progress.
  Future<List<({DateTime date, String label})>> getRecentWorkoutDays({int days = 7}) async {
    final box = await _dailyLogBox();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final entries = box.values
        .map((raw) {
          final map = Map<String, dynamic>.from(raw as Map);
          return (date: DateTime.parse(map['date'] as String), label: map['label'] as String);
        })
        .where((e) => e.date.isAfter(cutoff.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  Future<void> markExerciseCompleted({
    required String routineId,
    required String exerciseId,
  }) async {
    final exercise = await getExercise(routineId, exerciseId);
    if (exercise == null) return;
    await _saveExerciseProgress(routineId, exercise.copyWith(isCompleted: true));
  }

  Future<void> _saveExerciseProgress(String routineId, WorkoutExercise exercise) async {
    final box = await _box();
    await box.put(_progressKey(routineId, exercise.id), {
      'isCompleted': exercise.isCompleted,
      'sets': exercise.sets
          .map((s) => {
                'setNumber': s.setNumber,
                'reps': s.reps,
                'weightKg': s.weightKg,
                'isCompleted': s.isCompleted,
              })
          .toList(),
    });
  }

  Future<List<WorkoutExercise>> _customExercisesFor(String routineId) async {
    final box = await _customExercisesBox();
    final raw = box.get(routineId);
    if (raw == null) return [];
    final list = List<Map>.from(raw as List);
    return list.map((m) {
      final map = Map<String, dynamic>.from(m);
      return WorkoutExercise(
        id: map['id'] as String,
        name: map['name'] as String,
        targetSets: map['targetSets'] as int,
        repRangeLabel: map['repRangeLabel'] as String,
        primaryMuscles: (map['primaryMuscles'] as List)
            .map((g) => MuscleGroup.values.byName(g as String))
            .toList(),
        instructions: (map['instructions'] as List?)?.cast<String>() ?? const [],
        sets: _defaultSets(map['targetSets'] as int),
      );
    }).toList();
  }

  /// Adds a user-defined exercise to the given routine, persisted so it
  /// survives app restarts and shows up alongside the seeded exercises —
  /// matches the "Create Custom Exercise" flow reachable from Workout.
  Future<WorkoutExercise> createCustomExercise({
    required String routineId,
    required String name,
    required int targetSets,
    required String repRangeLabel,
    required List<MuscleGroup> primaryMuscles,
    List<String> instructions = const [],
  }) async {
    _customExerciseCounter++;
    final exercise = WorkoutExercise(
      id: 'custom-exercise-$_customExerciseCounter',
      name: name,
      targetSets: targetSets,
      repRangeLabel: repRangeLabel,
      primaryMuscles: primaryMuscles,
      instructions: instructions,
      sets: _defaultSets(targetSets),
    );

    final box = await _customExercisesBox();
    final raw = box.get(routineId);
    final list = raw == null ? <Map>[] : List<Map>.from(raw as List);
    list.add({
      'id': exercise.id,
      'name': exercise.name,
      'targetSets': exercise.targetSets,
      'repRangeLabel': exercise.repRangeLabel,
      'primaryMuscles': exercise.primaryMuscles.map((g) => g.name).toList(),
      'instructions': exercise.instructions,
    });
    await box.put(routineId, list);
    return exercise;
  }

  Future<void> deleteCustomExercise({
    required String routineId,
    required String exerciseId,
  }) async {
    final box = await _customExercisesBox();
    final raw = box.get(routineId);
    if (raw == null) return;
    final list = List<Map>.from(raw as List)
      ..removeWhere((m) => m['id'] == exerciseId);
    await box.put(routineId, list);
    await _box().then((b) => b.delete(_progressKey(routineId, exerciseId)));
  }

  static List<WorkoutSet> _defaultSets(int count, {int reps = 10, double weightKg = 20}) {
    return List.generate(
      count,
      (i) => WorkoutSet(setNumber: i + 1, reps: reps, weightKg: weightKg),
    );
  }

  static List<WorkoutRoutine> _seedRoutines() {
    return [
      WorkoutRoutine(
        id: 'push-day',
        name: 'Push Day',
        subtitle: 'Chest • Shoulders • Triceps',
        isToday: true,
        exercises: [
          WorkoutExercise(
            id: 'bench-press',
            name: 'Bench Press',
            targetSets: 4,
            repRangeLabel: '8-12 reps',
            primaryMuscles: const [MuscleGroup.chest, MuscleGroup.arms],
            instructions: const [
              'Lie on the bench, grip the bar slightly wider than shoulder width.',
              'Lower the bar to your chest with control, keeping elbows at ~45°.',
              'Press back up to full lockout without arching off the bench.',
            ],
            sets: _defaultSets(4, reps: 10, weightKg: 60),
          ),
          WorkoutExercise(
            id: 'incline-dumbbell-press',
            name: 'Incline Dumbbell Press',
            targetSets: 4,
            repRangeLabel: '8-12 reps',
            primaryMuscles: const [MuscleGroup.chest, MuscleGroup.shoulders],
            instructions: const [
              'Set the bench to a 30-45° incline.',
              'Press both dumbbells up until arms are extended, then lower slowly.',
            ],
            sets: _defaultSets(4, reps: 10, weightKg: 22),
          ),
          WorkoutExercise(
            id: 'shoulder-press',
            name: 'Shoulder Press',
            targetSets: 3,
            repRangeLabel: '8-12 reps',
            primaryMuscles: const [MuscleGroup.shoulders],
            instructions: const [
              'Sit tall, press the dumbbells overhead until arms are straight.',
              'Lower back to shoulder height with control.',
            ],
            sets: _defaultSets(3, reps: 10, weightKg: 16),
          ),
          WorkoutExercise(
            id: 'lateral-raises',
            name: 'Lateral Raises',
            targetSets: 3,
            repRangeLabel: '12-15 reps',
            primaryMuscles: const [MuscleGroup.shoulders],
            instructions: const [
              'Raise both dumbbells out to the sides until level with shoulders.',
              'Lower slowly, keeping a slight bend in the elbows.',
            ],
            sets: _defaultSets(3, reps: 12, weightKg: 8),
          ),
          WorkoutExercise(
            id: 'tricep-pushdown',
            name: 'Tricep Pushdown',
            targetSets: 3,
            repRangeLabel: '10-12 reps',
            primaryMuscles: const [MuscleGroup.arms],
            instructions: const [
              'Keep elbows tucked at your sides and push the bar down to full extension.',
              'Control the return without letting the weight stack slam.',
            ],
            sets: _defaultSets(3, reps: 10, weightKg: 25),
          ),
          WorkoutExercise(
            id: 'chest-fly',
            name: 'Chest Fly',
            targetSets: 3,
            repRangeLabel: '12-15 reps',
            primaryMuscles: const [MuscleGroup.chest],
            instructions: const [
              'With a slight bend in the elbows, bring the dumbbells together above your chest.',
              'Lower with control back out to chest height.',
            ],
            sets: _defaultSets(3, reps: 12, weightKg: 10),
          ),
        ],
      ),
      WorkoutRoutine(
        id: 'pull-day',
        name: 'Pull Day',
        subtitle: 'Back • Biceps',
        exercises: [
          WorkoutExercise(
            id: 'deadlift',
            name: 'Deadlift',
            targetSets: 4,
            repRangeLabel: '6-10 reps',
            primaryMuscles: const [MuscleGroup.back, MuscleGroup.legs],
            instructions: const [
              'Stand with feet hip-width apart, bar over mid-foot.',
              'Hinge at the hips, keep your back flat, and drive through the floor to stand.',
            ],
            sets: _defaultSets(4, reps: 8, weightKg: 80),
          ),
          WorkoutExercise(
            id: 'lat-pulldown',
            name: 'Lat Pulldown',
            targetSets: 4,
            repRangeLabel: '8-12 reps',
            primaryMuscles: const [MuscleGroup.back],
            instructions: const [
              'Pull the bar down to chest height, squeezing your shoulder blades together.',
              'Control the bar back up to full stretch.',
            ],
            sets: _defaultSets(4, reps: 10, weightKg: 45),
          ),
          WorkoutExercise(
            id: 'seated-row',
            name: 'Seated Cable Row',
            targetSets: 3,
            repRangeLabel: '8-12 reps',
            primaryMuscles: const [MuscleGroup.back],
            instructions: const ['Pull the handle to your torso, keeping your back straight.'],
            sets: _defaultSets(3, reps: 10, weightKg: 40),
          ),
          WorkoutExercise(
            id: 'bicep-curl',
            name: 'Bicep Curl',
            targetSets: 3,
            repRangeLabel: '10-12 reps',
            primaryMuscles: const [MuscleGroup.arms],
            instructions: const ['Curl the dumbbells up without swinging, then lower slowly.'],
            sets: _defaultSets(3, reps: 10, weightKg: 12),
          ),
          WorkoutExercise(
            id: 'face-pull',
            name: 'Face Pull',
            targetSets: 3,
            repRangeLabel: '12-15 reps',
            primaryMuscles: const [MuscleGroup.shoulders, MuscleGroup.back],
            instructions: const ['Pull the rope towards your face, flaring the elbows out wide.'],
            sets: _defaultSets(3, reps: 12, weightKg: 15),
          ),
        ],
      ),
      WorkoutRoutine(
        id: 'leg-day',
        name: 'Leg Day',
        subtitle: 'Glutes • Core',
        exercises: [
          WorkoutExercise(
            id: 'squat',
            name: 'Back Squat',
            targetSets: 4,
            repRangeLabel: '6-10 reps',
            primaryMuscles: const [MuscleGroup.legs],
            instructions: const [
              'Bar on your upper back, feet shoulder-width apart.',
              'Squat down until thighs are parallel to the floor, then drive back up.',
            ],
            sets: _defaultSets(4, reps: 8, weightKg: 70),
          ),
          WorkoutExercise(
            id: 'leg-press',
            name: 'Leg Press',
            targetSets: 4,
            repRangeLabel: '10-12 reps',
            primaryMuscles: const [MuscleGroup.legs],
            instructions: const ['Push the platform away without locking your knees out hard.'],
            sets: _defaultSets(4, reps: 10, weightKg: 90),
          ),
          WorkoutExercise(
            id: 'romanian-deadlift',
            name: 'Romanian Deadlift',
            targetSets: 3,
            repRangeLabel: '8-12 reps',
            primaryMuscles: const [MuscleGroup.legs, MuscleGroup.back],
            instructions: const ['Hinge at the hips, keeping a slight knee bend and flat back.'],
            sets: _defaultSets(3, reps: 10, weightKg: 50),
          ),
          WorkoutExercise(
            id: 'leg-curl',
            name: 'Leg Curl',
            targetSets: 3,
            repRangeLabel: '10-12 reps',
            primaryMuscles: const [MuscleGroup.legs],
            instructions: const ['Curl the pad towards your glutes, then lower with control.'],
            sets: _defaultSets(3, reps: 10, weightKg: 30),
          ),
          WorkoutExercise(
            id: 'plank',
            name: 'Plank',
            targetSets: 3,
            repRangeLabel: '30-45 sec',
            primaryMuscles: const [MuscleGroup.core],
            instructions: const ['Hold a straight line from head to heels, bracing your core.'],
            sets: _defaultSets(3, reps: 1, weightKg: 0),
          ),
          WorkoutExercise(
            id: 'calf-raise',
            name: 'Calf Raise',
            targetSets: 3,
            repRangeLabel: '15-20 reps',
            primaryMuscles: const [MuscleGroup.legs],
            instructions: const ['Rise onto your toes, pause, then lower fully with control.'],
            sets: _defaultSets(3, reps: 15, weightKg: 40),
          ),
        ],
      ),
      WorkoutRoutine(
        id: 'full-body',
        name: 'Full Body',
        subtitle: 'Strength • Endurance',
        exercises: [
          WorkoutExercise(
            id: 'goblet-squat',
            name: 'Goblet Squat',
            targetSets: 3,
            repRangeLabel: '10-12 reps',
            primaryMuscles: const [MuscleGroup.legs, MuscleGroup.core],
            instructions: const ['Hold a dumbbell at chest height and squat down between your knees.'],
            sets: _defaultSets(3, reps: 10, weightKg: 18),
          ),
          WorkoutExercise(
            id: 'push-up',
            name: 'Push-Up',
            targetSets: 3,
            repRangeLabel: '10-15 reps',
            primaryMuscles: const [MuscleGroup.chest, MuscleGroup.arms],
            instructions: const ['Keep your body in a straight line from head to heels.'],
            sets: _defaultSets(3, reps: 12, weightKg: 0),
          ),
          WorkoutExercise(
            id: 'bent-over-row',
            name: 'Bent-Over Row',
            targetSets: 3,
            repRangeLabel: '10-12 reps',
            primaryMuscles: const [MuscleGroup.back],
            instructions: const ['Hinge forward and row the bar to your lower ribs.'],
            sets: _defaultSets(3, reps: 10, weightKg: 35),
          ),
          WorkoutExercise(
            id: 'overhead-press',
            name: 'Overhead Press',
            targetSets: 3,
            repRangeLabel: '8-10 reps',
            primaryMuscles: const [MuscleGroup.shoulders],
            instructions: const ['Press the bar overhead in a straight line, bracing your core.'],
            sets: _defaultSets(3, reps: 8, weightKg: 30),
          ),
          WorkoutExercise(
            id: 'mountain-climbers',
            name: 'Mountain Climbers',
            targetSets: 3,
            repRangeLabel: '30 sec',
            primaryMuscles: const [MuscleGroup.core, MuscleGroup.fullBody],
            instructions: const ['Drive knees towards your chest quickly, keeping hips low.'],
            sets: _defaultSets(3, reps: 1, weightKg: 0),
          ),
          WorkoutExercise(
            id: 'burpees',
            name: 'Burpees',
            targetSets: 3,
            repRangeLabel: '10-12 reps',
            primaryMuscles: const [MuscleGroup.fullBody],
            instructions: const ['Drop to a push-up, then explode up into a jump.'],
            sets: _defaultSets(3, reps: 10, weightKg: 0),
          ),
          WorkoutExercise(
            id: 'plank-fb',
            name: 'Plank',
            targetSets: 3,
            repRangeLabel: '30-45 sec',
            primaryMuscles: const [MuscleGroup.core],
            instructions: const ['Hold a straight line from head to heels, bracing your core.'],
            sets: _defaultSets(3, reps: 1, weightKg: 0),
          ),
        ],
      ),
    ];
  }
}

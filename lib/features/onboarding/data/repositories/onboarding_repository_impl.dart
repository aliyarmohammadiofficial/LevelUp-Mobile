import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/onboarding_answers.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._local);

  final OnboardingLocalDataSource _local;

  @override
  Future<Result<void>> completeOnboarding(OnboardingAnswers answers) async {
    try {
      await _local.save(answers);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<bool> hasCompletedOnboarding() => _local.isCompleted();

  @override
  Future<OnboardingAnswers?> loadSavedAnswers() => _local.load();
}

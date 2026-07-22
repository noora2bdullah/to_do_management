import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

final class IsOnboardingCompleted extends UseCase<bool, NoParams> {
  const IsOnboardingCompleted(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<bool> call(NoParams params) => _repository.isCompleted();
}

final class CompleteOnboarding extends UseCase<void, NoParams> {
  const CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.complete();
}

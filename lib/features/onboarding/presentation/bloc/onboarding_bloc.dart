import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/onboarding_usecases.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

final class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._isOnboardingCompleted, this._completeOnboarding)
    : super(const OnboardingState()) {
    on<OnboardingStatusRequested>(_onStatusRequested);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingCompleted>(_onCompleted);
  }

  final IsOnboardingCompleted _isOnboardingCompleted;
  final CompleteOnboarding _completeOnboarding;

  Future<void> _onStatusRequested(
    OnboardingStatusRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      state.copyWith(status: OnboardingStatus.loading, clearErrorMessage: true),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1150));
      final isCompleted = await _isOnboardingCompleted(const NoParams());
      emit(
        state.copyWith(
          status: isCompleted
              ? OnboardingStatus.completed
              : OnboardingStatus.onboardingRequired,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: OnboardingStatus.onboardingRequired,
          errorMessage: exceptionMessage(error),
        ),
      );
    }
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(pageIndex: event.pageIndex));
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isCompleting: true, clearErrorMessage: true));

    try {
      await _completeOnboarding(const NoParams());
      emit(
        state.copyWith(status: OnboardingStatus.completed, isCompleting: false),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isCompleting: false,
          errorMessage: exceptionMessage(error),
        ),
      );
    }
  }
}

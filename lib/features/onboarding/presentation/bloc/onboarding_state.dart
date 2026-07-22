import 'package:equatable/equatable.dart';

enum OnboardingStatus { loading, onboardingRequired, completed }

final class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.loading,
    this.pageIndex = 0,
    this.isCompleting = false,
    this.errorMessage,
  });

  final OnboardingStatus status;
  final int pageIndex;
  final bool isCompleting;
  final String? errorMessage;

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? pageIndex,
    bool? isCompleting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      pageIndex: pageIndex ?? this.pageIndex,
      isCompleting: isCompleting ?? this.isCompleting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, pageIndex, isCompleting, errorMessage];
}

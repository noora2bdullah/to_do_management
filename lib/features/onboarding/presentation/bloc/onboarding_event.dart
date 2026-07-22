import 'package:equatable/equatable.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

final class OnboardingStatusRequested extends OnboardingEvent {
  const OnboardingStatusRequested();
}

final class OnboardingPageChanged extends OnboardingEvent {
  const OnboardingPageChanged(this.pageIndex);

  final int pageIndex;

  @override
  List<Object?> get props => [pageIndex];
}

final class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}

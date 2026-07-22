import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/pages/auth_gate.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import 'onboarding_page.dart';
import 'startup_page.dart';

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: switch (state.status) {
            OnboardingStatus.loading => const StartupPage(
              key: ValueKey('startup-page'),
            ),
            OnboardingStatus.onboardingRequired => const OnboardingPage(
              key: ValueKey('onboarding-page'),
            ),
            OnboardingStatus.completed => const AuthGate(
              key: ValueKey('auth-gate'),
            ),
          },
        );
      },
    );
  }
}

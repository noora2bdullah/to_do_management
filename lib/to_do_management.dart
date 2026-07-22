import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:to_do_man_management/core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_event.dart';
import 'features/onboarding/presentation/pages/startup_gate.dart';

class TodoManagement extends StatelessWidget {
  const TodoManagement({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(const AuthSubscriptionRequested()),
        ),
        BlocProvider(
          create: (_) =>
              sl<OnboardingBloc>()..add(const OnboardingStatusRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'To-Do',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const StartupGate(),
      ),
    );
  }
}

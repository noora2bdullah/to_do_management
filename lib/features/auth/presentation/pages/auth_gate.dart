import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../tasks/presentation/bloc/tasks_bloc.dart';
import '../../../tasks/presentation/bloc/tasks_event.dart';
import '../../../tasks/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'auth_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        return previous.status != current.status ||
            previous.user != current.user;
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: switch (state.status) {
            AuthStatus.unknown => const _SplashScreen(
              key: ValueKey('auth-splash'),
            ),
            AuthStatus.unauthenticated => const AuthPage(
              key: ValueKey('auth-page'),
            ),
            AuthStatus.authenticated => BlocProvider(
              key: ValueKey('home-${state.user?.id}'),
              create: (_) =>
                  sl<TasksBloc>()
                    ..add(TasksSubscriptionRequested(userId: state.user!.id)),
              child: HomePage(user: state.user!),
            ),
          },
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}

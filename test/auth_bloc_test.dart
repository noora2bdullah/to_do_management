import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_man_management/core/error/app_exception.dart';
import 'package:to_do_man_management/features/auth/domain/entities/app_user.dart';
import 'package:to_do_man_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:to_do_man_management/features/auth/domain/usecases/auth_usecases.dart';
import 'package:to_do_man_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do_man_management/features/auth/presentation/bloc/auth_event.dart';
import 'package:to_do_man_management/features/auth/presentation/bloc/auth_state.dart';

void main() {
  group('AuthBloc', () {
    test('switches to sign in and logs in when sign up email exists', () async {
      final repository = _FakeAuthRepository()
        ..signUpError = const AuthAppException(
          'An account already exists for this email.',
          code: 'email-already-in-use',
        )
        ..signInUser = const AppUser(id: 'user-1', email: 'exists@example.com');
      final bloc = _buildBloc(repository);
      addTearDown(bloc.close);
      addTearDown(repository.close);

      bloc.add(const AuthSubscriptionRequested());
      await pumpEventQueue();
      bloc.add(const AuthFormModeChanged(AuthFormMode.signUp));
      await pumpEventQueue();

      bloc.add(
        const AuthSignUpSubmitted(
          email: ' exists@example.com ',
          password: 'secret123',
        ),
      );
      await pumpEventQueue();

      expect(repository.signUpEmails, ['exists@example.com']);
      expect(repository.signInEmails, ['exists@example.com']);
      expect(repository.signInPasswords, ['secret123']);
      expect(bloc.state.formMode, AuthFormMode.signIn);
      expect(bloc.state.status, AuthStatus.authenticated);
      expect(bloc.state.user, repository.signInUser);
      expect(bloc.state.isSubmitting, isFalse);
    });

    test(
      'switches to sign in and shows login error when retry fails',
      () async {
        final repository = _FakeAuthRepository()
          ..signUpError = const AuthAppException(
            'An account already exists for this email.',
            code: 'email-already-in-use',
          )
          ..signInError = const AuthAppException(
            'The email or password is incorrect.',
            code: 'invalid-credential',
          );
        final bloc = _buildBloc(repository);
        addTearDown(bloc.close);
        addTearDown(repository.close);

        bloc.add(const AuthFormModeChanged(AuthFormMode.signUp));
        await pumpEventQueue();

        bloc.add(
          const AuthSignUpSubmitted(
            email: 'exists@example.com',
            password: 'wrong-password',
          ),
        );
        await pumpEventQueue();

        expect(repository.signInEmails, ['exists@example.com']);
        expect(bloc.state.formMode, AuthFormMode.signIn);
        expect(bloc.state.isSubmitting, isFalse);
        expect(bloc.state.errorMessage, 'The email or password is incorrect.');
      },
    );

    test('switches saved accounts without asking for a password', () async {
      const currentUser = AppUser(id: 'user-1', email: 'one@example.com');
      const otherUser = AppUser(id: 'user-2', email: 'two@example.com');
      final repository = _FakeAuthRepository()
        .._currentUser = currentUser
        .._savedAccounts = [currentUser, otherUser];
      final bloc = _buildBloc(repository);
      addTearDown(bloc.close);
      addTearDown(repository.close);

      bloc.add(const AuthSubscriptionRequested());
      await pumpEventQueue();

      bloc.add(const AuthSavedAccountSwitchRequested(otherUser));
      await pumpEventQueue();

      expect(repository.switchedAccounts, [otherUser]);
      expect(repository.signInEmails, isEmpty);
      expect(repository.signInPasswords, isEmpty);
      expect(bloc.state.user, otherUser);
      expect(bloc.state.status, AuthStatus.authenticated);
    });
  });
}

AuthBloc _buildBloc(_FakeAuthRepository repository) {
  return AuthBloc(
    WatchAuthState(repository),
    SignInWithEmail(repository),
    SignUpWithEmail(repository),
    GetSavedAccounts(repository),
    ForgetSavedAccount(repository),
    SwitchToSavedAccount(repository),
    SignOut(repository),
  );
}

final class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  final signUpEmails = <String>[];
  final signUpPasswords = <String>[];
  final signInEmails = <String>[];
  final signInPasswords = <String>[];
  final switchedAccounts = <AppUser>[];
  var _savedAccounts = <AppUser>[];
  AppUser? _currentUser;

  Object? signUpError;
  Object? signInError;
  Object? switchError;
  AppUser? signUpUser;
  AppUser? signInUser;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<List<AppUser>> savedAccounts() async => List.of(_savedAccounts);

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInEmails.add(email);
    signInPasswords.add(password);

    final error = signInError;
    if (error != null) {
      throw error;
    }

    final user = signInUser ?? AppUser(id: 'sign-in-$email', email: email);
    _currentUser = user;
    _savedAccounts = [user];
    _controller.add(user);

    return user;
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signUpEmails.add(email);
    signUpPasswords.add(password);

    final error = signUpError;
    if (error != null) {
      throw error;
    }

    final user = signUpUser ?? AppUser(id: 'sign-up-$email', email: email);
    _currentUser = user;
    _savedAccounts = [user];
    _controller.add(user);

    return user;
  }

  @override
  Future<AppUser> switchToAccount(AppUser account) async {
    switchedAccounts.add(account);

    final error = switchError;
    if (error != null) {
      throw error;
    }

    _currentUser = account;
    _savedAccounts = [
      account,
      for (final savedAccount in _savedAccounts)
        if (savedAccount.id != account.id) savedAccount,
    ];
    _controller.add(account);

    return account;
  }

  @override
  Future<void> forgetAccount(String userId) async {
    _savedAccounts = [
      for (final account in _savedAccounts)
        if (account.id != userId) account,
    ];
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  Future<void> close() => _controller.close();
}

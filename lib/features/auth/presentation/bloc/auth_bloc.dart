import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._watchAuthState,
    this._signInWithEmail,
    this._signUpWithEmail,
    this._signOut,
  ) : super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthStreamFailed>(_onStreamFailed);
    on<AuthFormModeChanged>(_onFormModeChanged);
    on<AuthPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<AuthSignInSubmitted>(_onSignInSubmitted);
    on<AuthSignUpSubmitted>(_onSignUpSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthMessageCleared>(_onMessageCleared);
  }

  final WatchAuthState _watchAuthState;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignOut _signOut;

  StreamSubscription<AppUser?>? _authSubscription;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authSubscription?.cancel();
    _authSubscription = _watchAuthState(const NoParams()).listen(
      (user) => add(AuthUserChanged(user)),
      onError: (Object error) => add(AuthStreamFailed(exceptionMessage(error))),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    emit(
      state.copyWith(
        status: user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: user,
        clearUser: user == null,
        isSubmitting: false,
        clearErrorMessage: true,
      ),
    );
  }

  void _onStreamFailed(AuthStreamFailed event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        isSubmitting: false,
        errorMessage: event.message,
      ),
    );
  }

  void _onFormModeChanged(AuthFormModeChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(formMode: event.mode, clearErrorMessage: true));
  }

  void _onPasswordVisibilityToggled(
    AuthPasswordVisibilityToggled event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _onSignInSubmitted(
    AuthSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _signInWithEmail(
        AuthCredentials(email: event.email.trim(), password: event.password),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: exceptionMessage(error),
        ),
      );
    }
  }

  Future<void> _onSignUpSubmitted(
    AuthSignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _signUpWithEmail(
        AuthCredentials(email: event.email.trim(), password: event.password),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: exceptionMessage(error),
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _signOut(const NoParams());
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: exceptionMessage(error),
        ),
      );
    }
  }

  void _onMessageCleared(AuthMessageCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearErrorMessage: true));
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}

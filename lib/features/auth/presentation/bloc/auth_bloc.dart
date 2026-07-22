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
    this._getSavedAccounts,
    this._forgetSavedAccount,
    this._switchToSavedAccount,
    this._signOutUseCase,
  ) : super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthStreamFailed>(_onStreamFailed);
    on<AuthFormModeChanged>(_onFormModeChanged);
    on<AuthPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<AuthSavedAccountsRequested>(_onSavedAccountsRequested);
    on<AuthSavedAccountSelected>(_onSavedAccountSelected);
    on<AuthSavedAccountForgotten>(_onSavedAccountForgotten);
    on<AuthSavedAccountSwitchRequested>(_onSavedAccountSwitchRequested);
    on<AuthAddAccountRequested>(_onAddAccountRequested);
    on<AuthSignInSubmitted>(_onSignInSubmitted);
    on<AuthSignUpSubmitted>(_onSignUpSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthMessageCleared>(_onMessageCleared);
  }

  final WatchAuthState _watchAuthState;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final GetSavedAccounts _getSavedAccounts;
  final ForgetSavedAccount _forgetSavedAccount;
  final SwitchToSavedAccount _switchToSavedAccount;
  final SignOut _signOutUseCase;

  StreamSubscription<AppUser?>? _authSubscription;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authSubscription?.cancel();
    await _loadSavedAccounts(emit);
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
        clearSelectedAccountEmail: user != null,
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
    emit(
      state.copyWith(
        formMode: event.mode,
        clearSelectedAccountEmail: event.mode == AuthFormMode.signUp,
        clearErrorMessage: true,
      ),
    );
  }

  void _onPasswordVisibilityToggled(
    AuthPasswordVisibilityToggled event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _onSavedAccountsRequested(
    AuthSavedAccountsRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _loadSavedAccounts(emit);
  }

  void _onSavedAccountSelected(
    AuthSavedAccountSelected event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        formMode: AuthFormMode.signIn,
        selectedAccountEmail: event.email,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onSavedAccountForgotten(
    AuthSavedAccountForgotten event,
    Emitter<AuthState> emit,
  ) async {
    final forgottenAccount = state.savedAccounts
        .where((account) => account.id == event.userId)
        .firstOrNull;

    try {
      await _forgetSavedAccount(event.userId);
      final accounts = await _getSavedAccounts(const NoParams());
      emit(
        state.copyWith(
          savedAccounts: accounts,
          clearSelectedAccountEmail:
              forgottenAccount?.email == state.selectedAccountEmail,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: exceptionMessage(error)));
    }
  }

  Future<void> _onAddAccountRequested(
    AuthAddAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        formMode: AuthFormMode.signIn,
        clearUser: true,
        isSubmitting: false,
        clearSelectedAccountEmail: true,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onSavedAccountSwitchRequested(
    AuthSavedAccountSwitchRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _switchToSavedAccount(event.account);
      await _loadSavedAccounts(emit);
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: exceptionMessage(error),
        ),
      );
    }
  }

  Future<void> _onSignInSubmitted(
    AuthSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final credentials = AuthCredentials(
      email: event.email.trim(),
      password: event.password,
    );

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    await _signIn(credentials, emit);
  }

  Future<void> _onSignUpSubmitted(
    AuthSignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final credentials = AuthCredentials(
      email: event.email.trim(),
      password: event.password,
    );

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _signUpWithEmail(credentials);
      await _loadSavedAccounts(emit);
    } catch (error) {
      if (_isEmailAlreadyInUse(error)) {
        emit(
          state.copyWith(
            formMode: AuthFormMode.signIn,
            clearErrorMessage: true,
          ),
        );
        await _signIn(credentials, emit);
        return;
      }

      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: exceptionMessage(error),
        ),
      );
    }
  }

  Future<void> _signIn(
    AuthCredentials credentials,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _signInWithEmail(credentials);
      await _loadSavedAccounts(emit);
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
    await _signOut(
      const NoParams(),
      emit: emit,
      clearSelectedAccountEmail: true,
    );
  }

  void _onMessageCleared(AuthMessageCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<void> _loadSavedAccounts(Emitter<AuthState> emit) async {
    try {
      final accounts = await _getSavedAccounts(const NoParams());
      emit(state.copyWith(savedAccounts: accounts));
    } catch (_) {
      emit(state.copyWith(savedAccounts: const []));
    }
  }

  Future<void> _signOut(
    NoParams params, {
    required Emitter<AuthState> emit,
    String? selectedAccountEmail,
    bool clearSelectedAccountEmail = false,
  }) async {
    emit(
      state.copyWith(
        formMode: AuthFormMode.signIn,
        isSubmitting: true,
        selectedAccountEmail: selectedAccountEmail,
        clearSelectedAccountEmail: clearSelectedAccountEmail,
        clearErrorMessage: true,
      ),
    );

    try {
      await _signOutUseCase(params);
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: exceptionMessage(error),
        ),
      );
    }
  }

  bool _isEmailAlreadyInUse(Object error) {
    return error is AuthAppException && error.code == 'email-already-in-use';
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

enum AuthFormMode { signIn, signUp }

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

final class AuthFormModeChanged extends AuthEvent {
  const AuthFormModeChanged(this.mode);

  final AuthFormMode mode;

  @override
  List<Object?> get props => [mode];
}

final class AuthPasswordVisibilityToggled extends AuthEvent {
  const AuthPasswordVisibilityToggled();
}

final class AuthSavedAccountsRequested extends AuthEvent {
  const AuthSavedAccountsRequested();
}

final class AuthSavedAccountSelected extends AuthEvent {
  const AuthSavedAccountSelected(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthSavedAccountForgotten extends AuthEvent {
  const AuthSavedAccountForgotten(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class AuthSavedAccountSwitchRequested extends AuthEvent {
  const AuthSavedAccountSwitchRequested(this.account);

  final AppUser account;

  @override
  List<Object?> get props => [account];
}

final class AuthAddAccountRequested extends AuthEvent {
  const AuthAddAccountRequested();
}

final class AuthSignInSubmitted extends AuthEvent {
  const AuthSignInSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignUpSubmitted extends AuthEvent {
  const AuthSignUpSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthMessageCleared extends AuthEvent {
  const AuthMessageCleared();
}

final class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final AppUser? user;

  @override
  List<Object?> get props => [user];
}

final class AuthStreamFailed extends AuthEvent {
  const AuthStreamFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

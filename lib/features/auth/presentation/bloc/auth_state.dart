import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';
import 'auth_event.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

final class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.formMode = AuthFormMode.signIn,
    this.isSubmitting = false,
    this.obscurePassword = true,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final AuthFormMode formMode;
  final bool isSubmitting;
  final bool obscurePassword;
  final String? errorMessage;

  bool get isSignIn => formMode == AuthFormMode.signIn;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    AuthFormMode? formMode,
    bool? isSubmitting,
    bool? obscurePassword,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      formMode: formMode ?? this.formMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    formMode,
    isSubmitting,
    obscurePassword,
    errorMessage,
  ];
}

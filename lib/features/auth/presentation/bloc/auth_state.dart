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
    this.savedAccounts = const [],
    this.selectedAccountEmail,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final AuthFormMode formMode;
  final bool isSubmitting;
  final bool obscurePassword;
  final List<AppUser> savedAccounts;
  final String? selectedAccountEmail;
  final String? errorMessage;

  bool get isSignIn => formMode == AuthFormMode.signIn;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    AuthFormMode? formMode,
    bool? isSubmitting,
    bool? obscurePassword,
    List<AppUser>? savedAccounts,
    String? selectedAccountEmail,
    bool clearSelectedAccountEmail = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      formMode: formMode ?? this.formMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      savedAccounts: savedAccounts ?? this.savedAccounts,
      selectedAccountEmail: clearSelectedAccountEmail
          ? null
          : selectedAccountEmail ?? this.selectedAccountEmail,
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
    savedAccounts,
    selectedAccountEmail,
    errorMessage,
  ];
}

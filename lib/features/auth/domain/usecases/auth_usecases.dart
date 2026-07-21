import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

final class AuthCredentials extends Equatable {
  const AuthCredentials({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class WatchAuthState extends StreamUseCase<AppUser?, NoParams> {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AppUser?> call(NoParams params) => _repository.authStateChanges();
}

final class SignInWithEmail extends UseCase<AppUser, AuthCredentials> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<AppUser> call(AuthCredentials params) {
    return _repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

final class SignUpWithEmail extends UseCase<AppUser, AuthCredentials> {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<AppUser> call(AuthCredentials params) {
    return _repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

final class SignOut extends UseCase<void, NoParams> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.signOut();
}

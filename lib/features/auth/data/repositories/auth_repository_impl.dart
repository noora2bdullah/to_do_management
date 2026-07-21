import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_remote_data_source.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<AppUser?> authStateChanges() => _remoteDataSource.authStateChanges();

  @override
  AppUser? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();
}

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_account_local_data_source.dart';
import '../datasources/auth_credential_local_data_source.dart';
import '../datasources/firebase_auth_remote_data_source.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._credentialLocalDataSource,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthAccountLocalDataSource _localDataSource;
  final AuthCredentialLocalDataSource _credentialLocalDataSource;

  @override
  Stream<AppUser?> authStateChanges() => _remoteDataSource.authStateChanges();

  @override
  AppUser? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<List<AppUser>> savedAccounts() => _localDataSource.savedAccounts();

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = await _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveAccountWithCredential(user: user, password: password);

    return user;
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = await _remoteDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveAccountWithCredential(user: user, password: password);

    return user;
  }

  @override
  Future<AppUser> switchToAccount(AppUser account) async {
    try {
      final user = await _remoteDataSource.switchToAccount(account);
      await _localDataSource.saveAccount(user);

      return user;
    } on AuthAppException catch (error) {
      if (error.code != 'missing-saved-session') {
        rethrow;
      }
    }

    final credential = await _credentialLocalDataSource.credentialForUser(
      account.id,
    );
    if (credential == null) {
      throw const AuthAppException(
        'Sign in to this account once before switching without a password.',
        code: 'missing-saved-credential',
      );
    }

    final user = await _remoteDataSource.signInWithEmailAndPassword(
      email: credential.email,
      password: credential.password,
    );
    await _localDataSource.saveAccount(user);

    return user;
  }

  @override
  Future<void> forgetAccount(String userId) async {
    await _localDataSource.forgetAccount(userId);
    await _credentialLocalDataSource.deleteCredential(userId);
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  Future<void> _saveAccountWithCredential({
    required AppUser user,
    required String password,
  }) async {
    await _localDataSource.saveAccount(user);
    await _credentialLocalDataSource.saveCredential(
      user: user,
      password: password,
    );
  }
}

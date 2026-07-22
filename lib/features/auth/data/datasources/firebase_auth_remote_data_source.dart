import '../../domain/entities/app_user.dart';
import 'firebase_account_session_manager.dart';

abstract interface class AuthRemoteDataSource {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> switchToAccount(AppUser account);

  Future<void> signOut();
}

final class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  const FirebaseAuthRemoteDataSource(this._sessionManager);

  final FirebaseAccountSessionManager _sessionManager;

  @override
  Stream<AppUser?> authStateChanges() {
    return _sessionManager.authStateChanges();
  }

  @override
  AppUser? get currentUser => _sessionManager.currentUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _sessionManager.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _sessionManager.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AppUser> switchToAccount(AppUser account) {
    return _sessionManager.switchToAccount(account);
  }

  @override
  Future<void> signOut() => _sessionManager.signOut();
}

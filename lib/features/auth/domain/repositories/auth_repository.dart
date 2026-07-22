import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<List<AppUser>> savedAccounts();

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> switchToAccount(AppUser account);

  Future<void> forgetAccount(String userId);

  Future<void> signOut();
}

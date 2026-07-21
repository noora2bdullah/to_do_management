import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/app_user.dart';

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

  Future<void> signOut();
}

final class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  const FirebaseAuthRemoteDataSource(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapUser);
  }

  @override
  AppUser? get currentUser => _mapUser(_firebaseAuth.currentUser);

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _mapUser(credential.user);

      if (user == null) {
        throw const AuthAppException('No Firebase user was returned.');
      }

      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthAppException(_authMessageForCode(error.code), code: error.code);
    }
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _mapUser(credential.user);

      if (user == null) {
        throw const AuthAppException('No Firebase user was returned.');
      }

      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthAppException(_authMessageForCode(error.code), code: error.code);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthAppException(_authMessageForCode(error.code), code: error.code);
    }
  }
}

AppUser? _mapUser(User? user) {
  if (user == null) {
    return null;
  }

  return AppUser(id: user.uid, email: user.email ?? 'unknown@email.local');
}

String _authMessageForCode(String code) {
  return switch (code) {
    'invalid-email' => 'Enter a valid email address.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' => 'No account exists for this email.',
    'wrong-password' ||
    'invalid-credential' => 'The email or password is incorrect.',
    'email-already-in-use' => 'An account already exists for this email.',
    'weak-password' => 'Use a password with at least 6 characters.',
    'network-request-failed' => 'Check your connection and try again.',
    _ => 'Authentication failed. Please try again.',
  };
}

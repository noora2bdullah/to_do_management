import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/app_user.dart';
import 'auth_account_local_data_source.dart';

final class FirebaseAccountSessionManager {
  FirebaseAccountSessionManager(this._localDataSource);

  final AuthAccountLocalDataSource _localDataSource;
  final _controller = StreamController<AppUser?>.broadcast();
  final _sessionsByUserId = <String, _FirebaseAccountSession>{};

  _FirebaseAccountSession? _activeSession;
  bool _restoredSavedSessions = false;

  AppUser? get currentUser => _activeSession?.user;

  Stream<AppUser?> authStateChanges() async* {
    await _restoreSavedSessions();
    yield currentUser;
    yield* _controller.stream;
  }

  FirebaseFirestore firestoreForUser(String userId) {
    final session = _activeSession;
    if (session == null || session.user.id != userId) {
      throw const DatabaseAppException(
        'Switch to this account before loading its tasks.',
        code: 'inactive-account',
      );
    }

    return session.firestore;
  }

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = await _authForEmail(email);

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _activateCredential(auth, credential);
    } on FirebaseAuthException catch (error) {
      throw AuthAppException(_authMessageForCode(error.code), code: error.code);
    }
  }

  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = await _authForEmail(email);

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _activateCredential(auth, credential);
    } on FirebaseAuthException catch (error) {
      throw AuthAppException(_authMessageForCode(error.code), code: error.code);
    }
  }

  Future<AppUser> switchToAccount(AppUser account) async {
    await _restoreSavedSessions();
    final existingSession = _sessionsByUserId[account.id];
    if (existingSession != null) {
      _activateSession(existingSession);
      return existingSession.user;
    }

    final restoredSession = await _sessionForSavedAccount(account);
    if (restoredSession != null) {
      _activateSession(restoredSession);
      return restoredSession.user;
    }

    throw AuthAppException(
      'Sign in to this account once before switching without a password.',
      code: 'missing-saved-session',
    );
  }

  Future<void> signOut() async {
    await _restoreSavedSessions();
    final session = _activeSession;
    if (session == null) {
      _controller.add(null);
      return;
    }

    try {
      await session.auth.signOut();
      _sessionsByUserId.remove(session.user.id);
      _activeSession = null;
      _controller.add(null);
    } on FirebaseAuthException catch (error) {
      throw AuthAppException(_authMessageForCode(error.code), code: error.code);
    }
  }

  Future<AppUser> _activateCredential(
    FirebaseAuth auth,
    UserCredential credential,
  ) async {
    final user = _mapUser(credential.user);
    if (user == null) {
      throw const AuthAppException('No Firebase user was returned.');
    }

    _activateSession(_FirebaseAccountSession(auth: auth, user: user));
    return user;
  }

  void _activateSession(_FirebaseAccountSession session) {
    _sessionsByUserId[session.user.id] = session;
    _activeSession = session;
    _controller.add(session.user);
  }

  Future<void> _restoreSavedSessions() async {
    if (_restoredSavedSessions) {
      return;
    }

    _restoredSavedSessions = true;
    final accounts = await _localDataSource.savedAccounts();

    for (final account in accounts) {
      final session = await _sessionForSavedAccount(account);
      if (session != null) {
        _sessionsByUserId[session.user.id] = session;
      }
    }

    final defaultUser = _mapUser(FirebaseAuth.instance.currentUser);
    if (defaultUser != null && !_sessionsByUserId.containsKey(defaultUser.id)) {
      final defaultSession = _FirebaseAccountSession(
        auth: FirebaseAuth.instance,
        user: defaultUser,
      );
      _sessionsByUserId[defaultUser.id] = defaultSession;
      await _localDataSource.saveAccount(defaultUser);
    }

    final firstSavedSession = accounts
        .map((account) => _sessionsByUserId[account.id])
        .whereType<_FirebaseAccountSession>()
        .firstOrNull;

    if (firstSavedSession != null) {
      _activeSession = firstSavedSession;
    } else if (defaultUser != null) {
      _activeSession = _sessionsByUserId[defaultUser.id];
    }
  }

  Future<_FirebaseAccountSession?> _sessionForSavedAccount(
    AppUser account,
  ) async {
    final auth = await _authForEmail(account.email);
    final user = _mapUser(auth.currentUser);
    if (user == null || user.id != account.id) {
      return null;
    }

    return _FirebaseAccountSession(auth: auth, user: user);
  }

  Future<FirebaseAuth> _authForEmail(String email) async {
    final app = await _appForEmail(email);
    return FirebaseAuth.instanceFor(app: app);
  }

  Future<FirebaseApp> _appForEmail(String email) async {
    final name = _appNameForEmail(email);

    try {
      return Firebase.app(name);
    } on FirebaseException {
      return Firebase.initializeApp(
        name: name,
        options: Firebase.app().options,
      );
    }
  }
}

final class _FirebaseAccountSession {
  _FirebaseAccountSession({required this.auth, required this.user})
    : firestore = FirebaseFirestore.instanceFor(app: auth.app);

  final FirebaseAuth auth;
  final AppUser user;
  final FirebaseFirestore firestore;
}

AppUser? _mapUser(User? user) {
  if (user == null) {
    return null;
  }

  return AppUser(id: user.uid, email: user.email ?? 'unknown@email.local');
}

String _appNameForEmail(String email) {
  final normalizedEmail = email.trim().toLowerCase();
  final encoded = base64Url
      .encode(utf8.encode(normalizedEmail))
      .replaceAll('=', '');
  return 'taskflow_account_$encoded';
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

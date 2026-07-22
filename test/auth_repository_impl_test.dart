import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_man_management/core/error/app_exception.dart';
import 'package:to_do_man_management/features/auth/data/datasources/auth_account_local_data_source.dart';
import 'package:to_do_man_management/features/auth/data/datasources/auth_credential_local_data_source.dart';
import 'package:to_do_man_management/features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import 'package:to_do_man_management/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:to_do_man_management/features/auth/domain/entities/app_user.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('stores credentials after sign in', () async {
      const user = AppUser(id: 'user-1', email: 'one@example.com');
      final remoteDataSource = _FakeAuthRemoteDataSource()..signInUser = user;
      final accountDataSource = _FakeAuthAccountLocalDataSource();
      final credentialDataSource = _FakeAuthCredentialLocalDataSource();
      final repository = AuthRepositoryImpl(
        remoteDataSource,
        accountDataSource,
        credentialDataSource,
      );

      await repository.signInWithEmailAndPassword(
        email: user.email,
        password: 'secret123',
      );

      expect(accountDataSource.accounts, [user]);
      final credential = credentialDataSource.credentials[user.id];
      expect(credential?.userId, user.id);
      expect(credential?.email, user.email);
      expect(credential?.password, 'secret123');
    });

    test('uses stored credentials when saved session is missing', () async {
      const user = AppUser(id: 'user-2', email: 'two@example.com');
      final remoteDataSource = _FakeAuthRemoteDataSource()
        ..switchError = const AuthAppException(
          'Missing session.',
          code: 'missing-saved-session',
        )
        ..signInUser = user;
      final accountDataSource = _FakeAuthAccountLocalDataSource()
        ..accounts = [user];
      final credentialDataSource = _FakeAuthCredentialLocalDataSource()
        ..credentials[user.id] = AuthStoredCredential(
          userId: user.id,
          email: user.email,
          password: 'stored-password',
        );
      final repository = AuthRepositoryImpl(
        remoteDataSource,
        accountDataSource,
        credentialDataSource,
      );

      final switchedUser = await repository.switchToAccount(user);

      expect(switchedUser, user);
      expect(remoteDataSource.signInEmails, [user.email]);
      expect(remoteDataSource.signInPasswords, ['stored-password']);
      expect(accountDataSource.accounts.first, user);
    });

    test('forgets saved account credentials', () async {
      const user = AppUser(id: 'user-3', email: 'three@example.com');
      final accountDataSource = _FakeAuthAccountLocalDataSource()
        ..accounts = [user];
      final credentialDataSource = _FakeAuthCredentialLocalDataSource()
        ..credentials[user.id] = AuthStoredCredential(
          userId: user.id,
          email: user.email,
          password: 'secret123',
        );
      final repository = AuthRepositoryImpl(
        _FakeAuthRemoteDataSource(),
        accountDataSource,
        credentialDataSource,
      );

      await repository.forgetAccount(user.id);

      expect(accountDataSource.accounts, isEmpty);
      expect(credentialDataSource.credentials, isEmpty);
    });
  });
}

final class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  final signInEmails = <String>[];
  final signInPasswords = <String>[];

  AppUser? current;
  AppUser? signInUser;
  AppUser? signUpUser;
  Object? switchError;

  @override
  Stream<AppUser?> authStateChanges() => Stream.value(current);

  @override
  AppUser? get currentUser => current;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInEmails.add(email);
    signInPasswords.add(password);
    current = signInUser ?? AppUser(id: 'sign-in-$email', email: email);
    return current!;
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    current = signUpUser ?? AppUser(id: 'sign-up-$email', email: email);
    return current!;
  }

  @override
  Future<AppUser> switchToAccount(AppUser account) async {
    final error = switchError;
    if (error != null) {
      throw error;
    }

    current = account;
    return account;
  }

  @override
  Future<void> signOut() async {
    current = null;
  }
}

final class _FakeAuthAccountLocalDataSource
    implements AuthAccountLocalDataSource {
  var accounts = <AppUser>[];

  @override
  Future<List<AppUser>> savedAccounts() async => List.of(accounts);

  @override
  Future<void> saveAccount(AppUser user) async {
    accounts = [
      user,
      for (final account in accounts)
        if (account.id != user.id) account,
    ];
  }

  @override
  Future<void> forgetAccount(String userId) async {
    accounts = [
      for (final account in accounts)
        if (account.id != userId) account,
    ];
  }
}

final class _FakeAuthCredentialLocalDataSource
    implements AuthCredentialLocalDataSource {
  final credentials = <String, AuthStoredCredential>{};

  @override
  Future<AuthStoredCredential?> credentialForUser(String userId) async {
    return credentials[userId];
  }

  @override
  Future<void> saveCredential({
    required AppUser user,
    required String password,
  }) async {
    credentials[user.id] = AuthStoredCredential(
      userId: user.id,
      email: user.email,
      password: password,
    );
  }

  @override
  Future<void> deleteCredential(String userId) async {
    credentials.remove(userId);
  }
}

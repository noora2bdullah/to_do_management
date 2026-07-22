import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/app_user.dart';

abstract interface class AuthCredentialLocalDataSource {
  Future<AuthStoredCredential?> credentialForUser(String userId);

  Future<void> saveCredential({
    required AppUser user,
    required String password,
  });

  Future<void> deleteCredential(String userId);
}

final class SecureStorageAuthCredentialLocalDataSource
    implements AuthCredentialLocalDataSource {
  const SecureStorageAuthCredentialLocalDataSource(this._storage);

  static const _credentialKeyPrefix = 'auth.credentials.';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthStoredCredential?> credentialForUser(String userId) async {
    final entry = await _storage.read(key: _credentialKey(userId));
    if (entry == null) {
      return null;
    }

    return _decodeCredential(entry);
  }

  @override
  Future<void> saveCredential({
    required AppUser user,
    required String password,
  }) {
    return _storage.write(
      key: _credentialKey(user.id),
      value: _encodeCredential(
        AuthStoredCredential(
          userId: user.id,
          email: user.email,
          password: password,
        ),
      ),
    );
  }

  @override
  Future<void> deleteCredential(String userId) {
    return _storage.delete(key: _credentialKey(userId));
  }

  String _credentialKey(String userId) => '$_credentialKeyPrefix$userId';
}

final class AuthStoredCredential {
  const AuthStoredCredential({
    required this.userId,
    required this.email,
    required this.password,
  });

  final String userId;
  final String email;
  final String password;
}

String _encodeCredential(AuthStoredCredential credential) {
  return jsonEncode({
    'userId': credential.userId,
    'email': credential.email,
    'password': credential.password,
  });
}

AuthStoredCredential? _decodeCredential(String entry) {
  try {
    final value = jsonDecode(entry);
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final userId = value['userId'];
    final email = value['email'];
    final password = value['password'];
    if (userId is! String ||
        userId.trim().isEmpty ||
        email is! String ||
        email.trim().isEmpty ||
        password is! String ||
        password.isEmpty) {
      return null;
    }

    return AuthStoredCredential(
      userId: userId,
      email: email,
      password: password,
    );
  } on FormatException {
    return null;
  }
}

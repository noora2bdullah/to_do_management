import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_user.dart';

abstract interface class AuthAccountLocalDataSource {
  Future<List<AppUser>> savedAccounts();

  Future<void> saveAccount(AppUser user);

  Future<void> forgetAccount(String userId);
}

final class SharedPreferencesAuthAccountLocalDataSource
    implements AuthAccountLocalDataSource {
  const SharedPreferencesAuthAccountLocalDataSource(this._preferences);

  static const _savedAccountsKey = 'auth.saved_accounts';

  final SharedPreferences _preferences;

  @override
  Future<List<AppUser>> savedAccounts() async {
    final entries = _preferences.getStringList(_savedAccountsKey) ?? const [];
    final accounts = <AppUser>[];
    final seenIds = <String>{};

    for (final entry in entries) {
      final account = _decodeAccount(entry);
      if (account == null || seenIds.contains(account.id)) {
        continue;
      }

      seenIds.add(account.id);
      accounts.add(account);
    }

    return accounts;
  }

  @override
  Future<void> saveAccount(AppUser user) async {
    final accounts = await savedAccounts();
    final normalizedEmail = user.email.toLowerCase();
    final updatedAccounts = [
      user,
      ...accounts.where(
        (account) =>
            account.id != user.id &&
            account.email.toLowerCase() != normalizedEmail,
      ),
    ];

    await _preferences.setStringList(
      _savedAccountsKey,
      updatedAccounts.map(_encodeAccount).toList(),
    );
  }

  @override
  Future<void> forgetAccount(String userId) async {
    final accounts = await savedAccounts();
    await _preferences.setStringList(
      _savedAccountsKey,
      accounts
          .where((account) => account.id != userId)
          .map(_encodeAccount)
          .toList(),
    );
  }
}

String _encodeAccount(AppUser user) {
  return jsonEncode({'id': user.id, 'email': user.email});
}

AppUser? _decodeAccount(String entry) {
  try {
    final value = jsonDecode(entry);
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final id = value['id'];
    final email = value['email'];
    if (id is! String ||
        id.trim().isEmpty ||
        email is! String ||
        email.trim().isEmpty) {
      return null;
    }

    return AppUser(id: id, email: email);
  } on FormatException {
    return null;
  }
}

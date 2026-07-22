import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_man_management/features/auth/data/datasources/auth_account_local_data_source.dart';
import 'package:to_do_man_management/features/auth/domain/entities/app_user.dart';

void main() {
  group('SharedPreferencesAuthAccountLocalDataSource', () {
    test('saves newest accounts first and de-duplicates by email', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final dataSource = SharedPreferencesAuthAccountLocalDataSource(
        preferences,
      );

      await dataSource.saveAccount(
        const AppUser(id: 'user-1', email: 'one@example.com'),
      );
      await dataSource.saveAccount(
        const AppUser(id: 'user-2', email: 'two@example.com'),
      );
      await dataSource.saveAccount(
        const AppUser(id: 'user-3', email: 'ONE@example.com'),
      );

      final accounts = await dataSource.savedAccounts();

      expect(accounts, [
        const AppUser(id: 'user-3', email: 'ONE@example.com'),
        const AppUser(id: 'user-2', email: 'two@example.com'),
      ]);
    });

    test('forgets an account by user id', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final dataSource = SharedPreferencesAuthAccountLocalDataSource(
        preferences,
      );

      await dataSource.saveAccount(
        const AppUser(id: 'user-1', email: 'one@example.com'),
      );
      await dataSource.saveAccount(
        const AppUser(id: 'user-2', email: 'two@example.com'),
      );

      await dataSource.forgetAccount('user-2');

      expect(await dataSource.savedAccounts(), [
        const AppUser(id: 'user-1', email: 'one@example.com'),
      ]);
    });
  });
}

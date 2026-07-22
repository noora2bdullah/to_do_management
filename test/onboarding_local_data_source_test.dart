import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_man_management/features/onboarding/data/datasources/onboarding_local_data_source.dart';

void main() {
  group('SharedPreferencesOnboardingLocalDataSource', () {
    test('is not completed by default', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final dataSource = SharedPreferencesOnboardingLocalDataSource(
        preferences,
      );

      expect(await dataSource.isCompleted(), isFalse);
    });

    test('persists completion', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final dataSource = SharedPreferencesOnboardingLocalDataSource(
        preferences,
      );

      await dataSource.complete();

      expect(await dataSource.isCompleted(), isTrue);
    });
  });
}

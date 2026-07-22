import 'package:shared_preferences/shared_preferences.dart';

abstract interface class OnboardingLocalDataSource {
  Future<bool> isCompleted();

  Future<void> complete();
}

final class SharedPreferencesOnboardingLocalDataSource
    implements OnboardingLocalDataSource {
  const SharedPreferencesOnboardingLocalDataSource(this._preferences);

  static const _isCompletedKey = 'is_onboarding_completed';

  final SharedPreferences _preferences;

  @override
  Future<bool> isCompleted() async {
    return _preferences.getBool(_isCompletedKey) ?? false;
  }

  @override
  Future<void> complete() async {
    await _preferences.setBool(_isCompletedKey, true);
  }
}

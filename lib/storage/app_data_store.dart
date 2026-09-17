import 'package:shared_preferences/shared_preferences.dart';

import 'app_profile.dart';

class AppDataStore {
  AppDataStore(this._preferences);

  static const _profileKey = 'app_profile';

  final SharedPreferences _preferences;

  Future<void> saveProfile(AppProfile profile) async {
    await _preferences.setString(_profileKey, profile.encode());
  }

  AppProfile? readProfile() {
    final storedValue = _preferences.getString(_profileKey);
    if (storedValue == null) {
      return null;
    }

    return AppProfile.decode(storedValue);
  }

  Future<AppProfile?> updateProfile({
    String? displayName,
    String? note,
    DateTime? updatedAt,
  }) async {
    final existing = readProfile();
    if (existing == null) {
      return null;
    }

    final updated = existing.copyWith(
      displayName: displayName,
      note: note,
      updatedAt: updatedAt ?? DateTime.now(),
    );
    await saveProfile(updated);
    return updated;
  }

  Future<void> deleteProfile() async {
    await _preferences.remove(_profileKey);
  }
}

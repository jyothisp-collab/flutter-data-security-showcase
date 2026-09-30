import 'package:shared_preferences/shared_preferences.dart';

import 'app_profile.dart';

class AppDataStore {
  static const _profileKey = 'app_profile';

  AppDataStore(this._preferences);

  final SharedPreferences _preferences;

  Future<void> saveProfile(AppProfile profile) async {
    await _preferences.setString(_profileKey, profile.encode());
  }

  AppProfile? loadProfile() {
    final raw = _preferences.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    return AppProfile.decode(raw);
  }

  Future<AppProfile?> updateProfile({
    String? displayName,
    String? note,
    DateTime? updatedAt,
  }) async {
    final existing = loadProfile();
    if (existing == null) return null;

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

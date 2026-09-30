import 'dart:async';

import '../../security/sensitive_value_store.dart';
import '../../storage/app_data_store.dart';
import '../../storage/app_profile.dart';
import '../../storage/profile_cache.dart';

class DataStorageController {
  DataStorageController({
    required AppDataStore dataStore,
    required SensitiveValueStore sensitiveValueStore,
  })  : _dataStore = dataStore,
        _sensitiveStore = sensitiveValueStore,
        _cache = ProfileCache(dataStore);

  final AppDataStore _dataStore;
  final SensitiveValueStore _sensitiveStore;
  final ProfileCache _cache;

  Future<AppProfile?> saveProfile(AppProfile profile) async {
    await _dataStore.saveProfile(profile);
    return _dataStore.loadProfile();
  }

  Future<AppProfile?> loadProfile() async {
    return _dataStore.loadProfile();
  }

  Future<AppProfile?> updateProfile({
    String? displayName,
    String? note,
    DateTime? updatedAt,
  }) async {
    return _dataStore.updateProfile(
      displayName: displayName,
      note: note,
      updatedAt: updatedAt,
    );
  }

  Future<void> saveToken(String key, String value) async {
    await _sensitiveStore.saveToken(key, value);
  }

  Future<bool> hasToken(String key) async {
    return _sensitiveStore.hasToken(key);
  }

  Future<String?> readToken(String key) async {
    return _sensitiveStore.getToken(key);
  }

  Future<void> clearAll() async {
    await _dataStore.deleteProfile();
    await _cache.clear();
    await _sensitiveStore.clearAll();
  }

  ProfileCache get cache => _cache;
}

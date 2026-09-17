import '../security/sensitive_value_store.dart';
import '../storage/app_data_store.dart';
import '../storage/app_profile.dart';
import '../storage/profile_cache.dart';

class StorageShowcaseSnapshot {
  const StorageShowcaseSnapshot({
    required this.profile,
    required this.hasSensitiveToken,
    required this.cacheMessage,
  });

  final AppProfile? profile;
  final bool hasSensitiveToken;
  final String cacheMessage;
}

class StorageShowcaseController {
  StorageShowcaseController({
    required this.dataStore,
    required this.secureStore,
  }) : _cache = ProfileCache(dataStore);

  final AppDataStore dataStore;
  final SensitiveValueStore secureStore;
  final ProfileCache _cache;

  Future<StorageShowcaseSnapshot> load() async {
    return StorageShowcaseSnapshot(
      profile: dataStore.readProfile(),
      hasSensitiveToken: await secureStore.hasToken(),
      cacheMessage: 'Idle',
    );
  }

  Future<StorageShowcaseSnapshot> saveOrdinaryData({
    required String displayName,
    required String note,
  }) async {
    final profile = AppProfile(
      id: 'local-profile',
      displayName: displayName.trim().isEmpty ? 'Local User' : displayName,
      note: note.trim().isEmpty ? 'Stored in shared preferences' : note,
      updatedAt: DateTime.now(),
    );
    await dataStore.saveProfile(profile);
    return load();
  }

  Future<StorageShowcaseSnapshot> updateOrdinaryData(String displayName) async {
    await dataStore.updateProfile(displayName: displayName);
    return load();
  }

  Future<StorageShowcaseSnapshot> saveSensitiveValue(String token) async {
    await secureStore.saveToken(token);
    return load();
  }

  Future<StorageShowcaseSnapshot> readThroughCache() async {
    final wasCached = _cache.readCached() != null;
    final profile = await _cache.readThrough(() async {
      return AppProfile(
        id: 'fetched-profile',
        displayName: 'Fetched User',
        note: 'Fetched once, then served from local cache',
        updatedAt: DateTime.now(),
      );
    });

    return StorageShowcaseSnapshot(
      profile: profile,
      hasSensitiveToken: await secureStore.hasToken(),
      cacheMessage: wasCached
          ? 'Served from local cache'
          : 'Fetched and cached',
    );
  }

  Future<StorageShowcaseSnapshot> clearAll() async {
    await dataStore.deleteProfile();
    await secureStore.clearToken();
    return load();
  }
}

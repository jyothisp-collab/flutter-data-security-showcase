import 'app_data_store.dart';
import 'app_profile.dart';

typedef ProfileFetcher = Future<AppProfile> Function();

class ProfileCache {
  ProfileCache(this._store);

  final AppDataStore _store;

  AppProfile? readCached() => _store.readProfile();

  Future<AppProfile> readThrough(ProfileFetcher fetchFresh) async {
    final cached = _store.readProfile();
    if (cached != null) {
      return cached;
    }

    final fresh = await fetchFresh();
    await _store.saveProfile(fresh);
    return fresh;
  }

  Future<void> clear() => _store.deleteProfile();
}

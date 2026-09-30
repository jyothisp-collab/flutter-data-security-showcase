import 'package:flutter_data_security_showcase/storage/app_data_store.dart';
import 'package:flutter_data_security_showcase/storage/app_profile.dart';
import 'package:flutter_data_security_showcase/storage/profile_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileCache', () {
    late AppDataStore store;
    late ProfileCache cache;

    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      store = AppDataStore(prefs);
      cache = ProfileCache(store);
    });

    test('readCached returns null when store is empty', () async {
      expect(cache.readCached(), isNull);
    });

    test('readCached returns profile after saveProfile', () async {
      final profile = AppProfile(
        id: 'cached',
        displayName: 'Cached',
        note: 'Note',
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      await store.saveProfile(profile);

      expect(cache.readCached(), isNotNull);
      expect(cache.readCached()!.id, 'cached');
    });

    test('readThrough returns cached profile without calling fetcher',
        () async {
      final cached = AppProfile(
        id: 'existing',
        displayName: 'Existing',
        note: 'Existing',
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      await store.saveProfile(cached);

      var fetchCalled = false;
      final result = await cache.readThrough(() async {
        fetchCalled = true;
        return AppProfile(
          id: 'fetched',
          displayName: 'Fetched',
          note: 'Fetched',
          updatedAt: DateTime.utc(2026, 6, 1),
        );
      });

      expect(fetchCalled, isFalse);
      expect(result.id, 'existing');
    });

    test('readThrough calls fetcher and persists when cache is empty',
        () async {
      var fetchCalled = false;
      final freshProfile = AppProfile(
        id: 'fresh',
        displayName: 'Fresh',
        note: 'Fresh',
        updatedAt: DateTime.utc(2026, 6, 1),
      );

      final result = await cache.readThrough(() async {
        fetchCalled = true;
        return freshProfile;
      });

      expect(fetchCalled, isTrue);
      expect(result.id, 'fresh');
      expect(result.displayName, 'Fresh');

      final cached = cache.readCached();
      expect(cached, isNotNull);
      expect(cached!.id, 'fresh');
    });

    test('readThrough calls fetcher only once across multiple calls',
        () async {
      int fetchCount = 0;
      final freshProfile = AppProfile(
        id: 'fresh',
        displayName: 'Fresh',
        note: 'Fresh',
        updatedAt: DateTime.utc(2026, 6, 1),
      );

      await cache.readThrough(() async {
        fetchCount++;
        return freshProfile;
      });

      await cache.readThrough(() async {
        fetchCount++;
        return freshProfile;
      });

      expect(fetchCount, 1);
    });
  });
}

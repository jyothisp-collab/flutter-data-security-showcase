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

  test('fetches once when cache is empty, then reads local cache', () async {
    final preferences = await SharedPreferences.getInstance();
    final cache = ProfileCache(AppDataStore(preferences));
    var fetchCount = 0;

    Future<AppProfile> fetchProfile() async {
      fetchCount += 1;
      return AppProfile(
        id: 'fetched',
        displayName: 'Fetched User',
        note: 'Cached after first read',
        updatedAt: DateTime.utc(2026, 1, 1),
      );
    }

    final first = await cache.readThrough(fetchProfile);
    final second = await cache.readThrough(fetchProfile);

    expect(first.displayName, 'Fetched User');
    expect(second.displayName, 'Fetched User');
    expect(fetchCount, 1);
  });
}

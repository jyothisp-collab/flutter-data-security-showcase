import 'package:flutter_data_security_showcase/storage/app_data_store.dart';
import 'package:flutter_data_security_showcase/storage/app_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves, reads, updates, and deletes ordinary local data', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = AppDataStore(preferences);
    final profile = AppProfile(
      id: 'profile-1',
      displayName: 'Ada',
      note: 'Non-sensitive preference',
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    await store.saveProfile(profile);

    expect(store.readProfile()?.displayName, 'Ada');

    final updated = await store.updateProfile(
      displayName: 'Ada Lovelace',
      updatedAt: DateTime.utc(2026, 1, 2),
    );

    expect(updated?.displayName, 'Ada Lovelace');
    expect(store.readProfile()?.updatedAt, DateTime.utc(2026, 1, 2));

    await store.deleteProfile();

    expect(store.readProfile(), isNull);
  });
}

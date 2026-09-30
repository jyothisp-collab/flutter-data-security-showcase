import 'package:flutter_data_security_showcase/storage/app_data_store.dart';
import 'package:flutter_data_security_showcase/storage/app_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppDataStore', () {
    late AppDataStore store;

    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      store = AppDataStore(prefs);
    });

    test('saveProfile persists and loadProfile returns it', () async {
      final profile = AppProfile(
        id: 'p-1',
        displayName: 'Ada',
        note: 'Note',
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      await store.saveProfile(profile);

      final loaded = store.loadProfile();
      expect(loaded, isNotNull);
      expect(loaded!.id, 'p-1');
      expect(loaded.displayName, 'Ada');
      expect(loaded.note, 'Note');
      expect(loaded.updatedAt, DateTime.utc(2026, 1, 1));
    });

    test('loadProfile returns null when no profile saved', () async {
      expect(store.loadProfile(), isNull);
    });

    test('deleteProfile removes stored profile', () async {
      final profile = AppProfile(
        id: 'p-1',
        displayName: 'Ada',
        note: 'Note',
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      await store.saveProfile(profile);
      expect(store.loadProfile(), isNotNull);

      await store.deleteProfile();
      expect(store.loadProfile(), isNull);
    });

    test('updateProfile returns null when no existing profile', () async {
      final result = await store.updateProfile(displayName: 'New Name');
      expect(result, isNull);
    });

    test('updateProfile modifies only specified fields', () async {
      final original = AppProfile(
        id: 'p-1',
        displayName: 'Ada',
        note: 'Original note',
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      await store.saveProfile(original);
      final updated = await store.updateProfile(displayName: 'Ada Lovelace');

      expect(updated, isNotNull);
      expect(updated!.displayName, 'Ada Lovelace');
      expect(updated.note, 'Original note');
      expect(updated.id, 'p-1');
    });

    test('updateProfile uses current time when updatedAt not provided',
        () async {
      final before = DateTime.utc(2026, 6, 1);
      final original = AppProfile(
        id: 'p-1',
        displayName: 'Ada',
        note: 'Note',
        updatedAt: before,
      );

      await store.saveProfile(original);
      final updated = await store.updateProfile(note: 'New note');

      expect(updated, isNotNull);
      expect(updated!.updatedAt.isAfter(before), isTrue);
      expect(updated.note, 'New note');
    });

    test('saving profile with different id replaces the old one', () async {
      await store.saveProfile(
        AppProfile(
          id: 'old',
          displayName: 'Old',
          note: 'Old note',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );

      await store.saveProfile(
        AppProfile(
          id: 'new',
          displayName: 'New',
          note: 'New note',
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      );

      final loaded = store.loadProfile();
      expect(loaded!.id, 'new');
      expect(loaded.displayName, 'New');
    });
  });
}

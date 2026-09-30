import 'package:flutter_data_security_showcase/features/data_storage_controller.dart';
import 'package:flutter_data_security_showcase/security/in_memory_token_store.dart';
import 'package:flutter_data_security_showcase/security/sensitive_value_store.dart';
import 'package:flutter_data_security_showcase/storage/app_data_store.dart';
import 'package:flutter_data_security_showcase/storage/app_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DataStorageController', () {
    late AppDataStore dataStore;
    late SensitiveValueStore sensitiveStore;
    late DataStorageController controller;

    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      dataStore = AppDataStore(prefs);
      sensitiveStore = InMemoryTokenStore();
      controller = DataStorageController(
        dataStore: dataStore,
        sensitiveValueStore: sensitiveStore,
      );
    });

    group('profile operations', () {
      test('saveProfile persists profile and returns it', () async {
        final profile = AppProfile(
          id: 'test',
          displayName: 'Test User',
          note: 'Test note',
          updatedAt: DateTime.utc(2026, 1, 1),
        );

        final result = await controller.saveProfile(profile);

        expect(result, isNotNull);
        expect(result!.id, 'test');
        expect(result.displayName, 'Test User');
      });

      test('loadProfile returns saved profile', () async {
        final profile = AppProfile(
          id: 'test',
          displayName: 'Test',
          note: 'Note',
          updatedAt: DateTime.utc(2026, 1, 1),
        );
        await dataStore.saveProfile(profile);

        final result = await controller.loadProfile();

        expect(result, isNotNull);
        expect(result!.id, 'test');
      });

      test('loadProfile returns null when nothing saved', () async {
        final result = await controller.loadProfile();
        expect(result, isNull);
      });

      test('updateProfile modifies displayName', () async {
        final original = AppProfile(
          id: 'test',
          displayName: 'Original',
          note: 'Note',
          updatedAt: DateTime.utc(2026, 1, 1),
        );
        await dataStore.saveProfile(original);

        final updated = await controller.updateProfile(
          displayName: 'Updated',
        );

        expect(updated, isNotNull);
        expect(updated!.displayName, 'Updated');
        expect(updated.note, 'Note');
      });
    });

    group('token operations', () {
      test('saveToken stores token in sensitive store', () async {
        await controller.saveToken('api-key', 'secret-value');

        final token = await controller.readToken('api-key');
        expect(token, 'secret-value');
      });

      test('hasToken returns true after save', () async {
        await controller.saveToken('api-key', 'secret-value');

        final has = await controller.hasToken('api-key');
        expect(has, isTrue);
      });

      test('hasToken returns false for missing key', () async {
        final has = await controller.hasToken('nonexistent');
        expect(has, isFalse);
      });
    });

    group('clearAll', () {
      test('removes profile, clears cache, and clears tokens', () async {
        final profile = AppProfile(
          id: 'test',
          displayName: 'Test',
          note: 'Note',
          updatedAt: DateTime.utc(2026, 1, 1),
        );
        await controller.saveProfile(profile);
        await controller.saveToken('api-key', 'secret');

        await controller.clearAll();

        expect(await controller.loadProfile(), isNull);
        expect(await controller.hasToken('api-key'), isFalse);
      });
    });
  });
}

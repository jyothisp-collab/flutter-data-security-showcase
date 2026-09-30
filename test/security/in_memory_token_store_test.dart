import 'package:flutter_data_security_showcase/security/in_memory_token_store.dart';
import 'package:flutter_data_security_showcase/security/sensitive_value_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryTokenStore', () {
    late InMemoryTokenStore store;

    setUp(() {
      store = InMemoryTokenStore();
    });

    test('saveToken and getToken round-trip', () async {
      await store.saveToken('k1', 'value1');
      await store.saveToken('k2', 'value2');

      expect(await store.getToken('k1'), 'value1');
      expect(await store.getToken('k2'), 'value2');
    });

    test('saveToken trims whitespace', () async {
      await store.saveToken('k1', '  trimmed  ');

      expect(await store.getToken('k1'), 'trimmed');
    });

    test('saveToken with empty string clears the key', () async {
      await store.saveToken('k1', 'value');
      await store.saveToken('k1', '');

      expect(await store.getToken('k1'), isNull);
      expect(await store.hasToken('k1'), isFalse);
    });

    test('clearAll removes all keys', () async {
      await store.saveToken('k1', 'value1');
      await store.saveToken('k2', 'value2');
      await store.clearAll();

      expect(await store.getToken('k1'), isNull);
      expect(await store.getToken('k2'), isNull);
      expect(await store.hasToken('k1'), isFalse);
    });

    test('multiple instances are isolated', () async {
      final other = InMemoryTokenStore();

      await store.saveToken('k1', 'store-a');
      await other.saveToken('k1', 'store-b');

      expect(await store.getToken('k1'), 'store-a');
      expect(await other.getToken('k1'), 'store-b');
    });
  });
}

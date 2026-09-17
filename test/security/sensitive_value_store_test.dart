import 'package:flutter_data_security_showcase/security/sensitive_value_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'secure store abstraction reports only whether a token exists',
    () async {
      final store = FakeSensitiveValueStore();

      expect(await store.hasToken(), isFalse);

      await store.saveToken('demo-token-value');

      expect(await store.hasToken(), isTrue);

      await store.clearToken();

      expect(await store.hasToken(), isFalse);
    },
  );

  test('blank sensitive values are cleared instead of stored', () async {
    final store = FakeSensitiveValueStore();

    await store.saveToken('demo-token-value');
    await store.saveToken('   ');

    expect(await store.hasToken(), isFalse);
  });
}

class FakeSensitiveValueStore implements SensitiveValueStore {
  String? _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<bool> hasToken() async {
    return _token != null && _token!.isNotEmpty;
  }

  @override
  Future<void> saveToken(String token) async {
    final trimmedToken = token.trim();
    _token = trimmedToken.isEmpty ? null : trimmedToken;
  }
}

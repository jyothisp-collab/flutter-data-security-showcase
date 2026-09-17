import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SensitiveValueStore {
  Future<void> saveToken(String token);

  Future<bool> hasToken();

  Future<void> clearToken();
}

class SecureTokenStore implements SensitiveValueStore {
  SecureTokenStore({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _tokenKey = 'session_token';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> saveToken(String token) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      await clearToken();
      return;
    }

    await _secureStorage.write(key: _tokenKey, value: trimmedToken);
  }

  @override
  Future<bool> hasToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearToken() {
    return _secureStorage.delete(key: _tokenKey);
  }
}

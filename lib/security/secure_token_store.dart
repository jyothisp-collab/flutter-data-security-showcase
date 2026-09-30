import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'sensitive_value_store.dart';

class SecureTokenStore implements SensitiveValueStore {
  SecureTokenStore({
    FlutterSecureStorage? secureStorage,
    AndroidOptions? androidOptions,
    IOSOptions? iosOptions,
    LinuxOptions? linuxOptions,
    WebOptions? webOptions,
    MacOsOptions? macOptions,
    WindowsOptions? windowsOptions,
  }) : _secureStorage = secureStorage ??
            FlutterSecureStorage(
              aOptions: androidOptions,
              iOptions: iosOptions,
              lOptions: linuxOptions,
              webOptions: webOptions,
              mOptions: macOptions,
              wOptions: windowsOptions,
            );

  static const _defaultKey = 'secure_session_token';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> saveToken(String key, String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await clearAll();
      return;
    }
    await _secureStorage.write(key: key, value: trimmed);
  }

  @override
  Future<String?> getToken(String key) async {
    return _secureStorage.read(key: key);
  }

  @override
  Future<bool> hasToken(String key) async {
    final value = await getToken(key);
    return value != null && value.isNotEmpty;
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.delete(key: _defaultKey);
  }
}

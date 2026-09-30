import 'dart:async';

abstract interface class SensitiveValueStore {
  Future<void> saveToken(String key, String value);

  Future<String?> getToken(String key);

  Future<void> clearAll();

  Future<bool> hasToken(String key);
}

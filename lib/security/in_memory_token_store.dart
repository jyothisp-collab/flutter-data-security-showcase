import 'dart:async';
import 'dart:collection';

import 'sensitive_value_store.dart';

class InMemoryTokenStore implements SensitiveValueStore {
  InMemoryTokenStore() : _map = HashMap<String, String>();

  final HashMap<String, String> _map;

  @override
  Future<void> saveToken(String key, String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _map.remove(key);
    } else {
      _map[key] = trimmed;
    }
  }

  @override
  Future<String?> getToken(String key) async {
    return _map[key];
  }

  @override
  Future<bool> hasToken(String key) async {
    final value = _map[key];
    return value != null && value.isNotEmpty;
  }

  @override
  Future<void> clearAll() async {
    _map.clear();
  }
}

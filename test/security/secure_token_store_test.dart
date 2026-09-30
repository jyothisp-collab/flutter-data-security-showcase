import 'package:flutter_data_security_showcase/security/secure_token_store.dart';
import 'package:flutter_data_security_showcase/security/sensitive_value_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockk/mockk.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureTokenStore store;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    store = SecureTokenStore(secureStorage: mockStorage);
  });

  group('SecureTokenStore', () {
    test('saveToken stores value via FlutterSecureStorage.write', () async {
      when(mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => null);

      await store.saveToken('my-key', 'my-value');

      verify(
        mockStorage.write(key: 'my-key', value: 'my-value'),
      ).called(1);
    });

    test('saveToken trims whitespace before storing', () async {
      when(mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => null);

      await store.saveToken('my-key', '  trimmed  ');

      verify(
        mockStorage.write(key: 'my-key', value: 'trimmed'),
      ).called(1);
    });

    test('saveToken clears when value is blank', () async {
      when(mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      await store.saveToken('my-key', '   ');

      verify(mockStorage.delete(key: 'my-key')).called(1);
      verifyNever(
        mockStorage.write(key: any(named: 'key'), value: any(named: 'value')),
      );
    });

    test('getToken returns stored value', () async {
      when(mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'stored-token');

      final result = await store.getToken('my-key');

      expect(result, 'stored-token');
      verify(mockStorage.read(key: 'my-key')).called(1);
    });

    test('getToken returns null when nothing stored', () async {
      when(mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final result = await store.getToken('my-key');

      expect(result, isNull);
    });

    test('hasToken returns true when token exists', () async {
      when(mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'token-value');

      final result = await store.hasToken('my-key');

      expect(result, isTrue);
    });

    test('hasToken returns false when token is null', () async {
      when(mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final result = await store.hasToken('my-key');

      expect(result, isFalse);
    });

    test('hasToken returns false when token is empty string', () async {
      when(mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => '');

      final result = await store.hasToken('my-key');

      expect(result, isFalse);
    });

    test('clearAll deletes token from secure storage', () async {
      when(mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      await store.clearAll();

      verify(mockStorage.delete(key: 'secure_session_token')).called(1);
    });

    test('overwriting a token replaces the old value', () async {
      when(mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => null);
      when(mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'new-value');

      await store.saveToken('my-key', 'first');
      await store.saveToken('my-key', 'second');

      final result = await store.getToken('my-key');

      expect(result, 'new-value');
      verify(mockStorage.write(key: 'my-key', value: 'first')).called(1);
      verify(mockStorage.write(key: 'my-key', value: 'second')).called(1);
    });
  });
}

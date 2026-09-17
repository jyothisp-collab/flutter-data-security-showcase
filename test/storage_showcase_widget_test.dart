import 'package:flutter/material.dart';
import 'package:flutter_data_security_showcase/features/storage_showcase_controller.dart';
import 'package:flutter_data_security_showcase/main.dart';
import 'package:flutter_data_security_showcase/security/sensitive_value_store.dart';
import 'package:flutter_data_security_showcase/storage/app_data_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('UI stores ordinary data and hides sensitive value', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final secureStore = FakeSensitiveValueStore();

    await tester.pumpWidget(
      StorageShowcaseApp(
        controller: StorageShowcaseController(
          dataStore: AppDataStore(preferences),
          secureStore: secureStore,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(2), 'secret-demo-token');
    await tester.tap(find.text('Save sensitive value'));
    await tester.pumpAndSettle();

    expect(find.text('Sensitive token stored: Yes'), findsOneWidget);
    expect(find.text('secret-demo-token'), findsNothing);
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

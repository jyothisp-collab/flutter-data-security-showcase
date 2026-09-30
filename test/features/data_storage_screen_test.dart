import 'package:flutter_data_security_showcase/features/data_storage_screen.dart';
import 'package:flutter_data_security_showcase/features/data_storage_controller.dart';
import 'package:flutter_data_security_showcase/security/app_config.dart';
import 'package:flutter_data_security_showcase/security/in_memory_token_store.dart';
import 'package:flutter_data_security_showcase/security/sensitive_value_store.dart';
import 'package:flutter_data_security_showcase/storage/app_data_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('save profile displays in state section', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStore = AppDataStore(prefs);
    final sensitiveStore = InMemoryTokenStore();
    final controller = DataStorageController(
      dataStore: dataStore,
      sensitiveValueStore: sensitiveStore,
    );
    final config = AppConfig.readFromEnvironment();

    await tester.pumpWidget(
      MaterialApp(
        home: DataStorageScreen(
          controller: controller,
          sensitiveStore: sensitiveStore,
          config: config,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextField, 'Display Name');
    await tester.enterText(nameField, 'Test User');
    await tester.enterText(find.widgetWithText(TextField, 'Note'), 'Test note');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Ordinary profile stored'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Test note'), findsOneWidget);
  });

  testWidgets('clear all removes displayed profile', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStore = AppDataStore(prefs);
    final sensitiveStore = InMemoryTokenStore();
    final controller = DataStorageController(
      dataStore: dataStore,
      sensitiveValueStore: sensitiveStore,
    );
    final config = AppConfig.readFromEnvironment();

    await tester.pumpWidget(
      MaterialApp(
        home: DataStorageScreen(
          controller: controller,
          sensitiveStore: sensitiveStore,
          config: config,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Display Name'),
      'To be cleared',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Note'),
      'Note to clear',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Yes'), findsOneWidget);

    await tester.tap(find.text('Clear All Stored Values'));
    await tester.pumpAndSettle();

    expect(find.text('No'), findsOneWidget);
    expect(find.text('To be cleared'), findsNothing);
    expect(find.text('Note to clear'), findsNothing);
  });

  testWidgets('sensitive token value never shown in UI', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStore = AppDataStore(prefs);
    final sensitiveStore = InMemoryTokenStore();
    final controller = DataStorageController(
      dataStore: dataStore,
      sensitiveValueStore: sensitiveStore,
    );
    final config = AppConfig.readFromEnvironment();

    await tester.pumpWidget(
      MaterialApp(
        home: DataStorageScreen(
          controller: controller,
          sensitiveStore: sensitiveStore,
          config: config,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Token Value'),
      'super-secret-token-123',
    );
    await tester.tap(find.text('Save Token'));
    await tester.pumpAndSettle();

    expect(find.text('super-secret-token-123'), findsNothing);
    expect(find.text('Sensitive token stored'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
  });

  testWidgets('configuration section renders environment values', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStore = AppDataStore(prefs);
    final sensitiveStore = InMemoryTokenStore();
    final controller = DataStorageController(
      dataStore: dataStore,
      sensitiveValueStore: sensitiveStore,
    );
    final config = AppConfig.readFromEnvironment();

    await tester.pumpWidget(
      MaterialApp(
        home: DataStorageScreen(
          controller: controller,
          sensitiveStore: sensitiveStore,
          config: config,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Configuration'), findsOneWidget);
    expect(find.text('Environment'), findsOneWidget);
    expect(find.text('API base URL'), findsOneWidget);
  });

  testWidgets('read through cache displays fetched profile', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStore = AppDataStore(prefs);
    final sensitiveStore = InMemoryTokenStore();
    final controller = DataStorageController(
      dataStore: dataStore,
      sensitiveValueStore: sensitiveStore,
    );
    final config = AppConfig.readFromEnvironment();

    await tester.pumpWidget(
      MaterialApp(
        home: DataStorageScreen(
          controller: controller,
          sensitiveStore: sensitiveStore,
          config: config,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Read Through Cache'));
    await tester.pumpAndSettle();

    expect(find.text('Fetched and cached'), findsOneWidget);
  });
}

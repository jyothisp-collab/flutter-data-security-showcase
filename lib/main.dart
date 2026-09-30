import 'package:flutter/material.dart';
import 'package:flutter_data_security_showcase/security/app_config.dart';
import 'package:flutter_data_security_showcase/features/data_storage_screen.dart';
import 'package:flutter_data_security_showcase/features/data_storage_controller.dart';
import 'package:flutter_data_security_showcase/security/in_memory_token_store.dart';
import 'package:flutter_data_security_showcase/security/secure_token_store.dart';
import 'package:flutter_data_security_showcase/storage/app_data_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final dataStore = AppDataStore(preferences);

  final config = AppConfig.readFromEnvironment();
  final sensitiveStore = config.isDemo
      ? InMemoryTokenStore()
      : SecureTokenStore();

  runApp(ShowcaseApp(
    controller: DataStorageController(
      dataStore: dataStore,
      sensitiveValueStore: sensitiveStore,
    ),
    sensitiveStore: sensitiveStore,
    config: config,
  ));
}

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({
    super.key,
    required this.controller,
    required this.sensitiveStore,
    required this.config,
  });

  final DataStorageController controller;
  final SensitiveValueStore sensitiveStore;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Security Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: DataStorageScreen(
        controller: controller,
        sensitiveStore: sensitiveStore,
        config: config,
      ),
    );
  }
}

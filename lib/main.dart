import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/storage_showcase_controller.dart';
import 'security/app_config.dart';
import 'security/sensitive_value_store.dart';
import 'storage/app_data_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  runApp(
    StorageShowcaseApp(
      controller: StorageShowcaseController(
        dataStore: AppDataStore(preferences),
        secureStore: SecureTokenStore(),
      ),
    ),
  );
}

class StorageShowcaseApp extends StatelessWidget {
  const StorageShowcaseApp({super.key, required this.controller});

  final StorageShowcaseController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Security Showcase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: StorageShowcasePage(controller: controller),
    );
  }
}

class StorageShowcasePage extends StatefulWidget {
  const StorageShowcasePage({super.key, required this.controller});

  final StorageShowcaseController controller;

  @override
  State<StorageShowcasePage> createState() => _StorageShowcasePageState();
}

class _StorageShowcasePageState extends State<StorageShowcasePage> {
  final _nameController = TextEditingController(text: 'Local User');
  final _noteController = TextEditingController(text: 'Safe local preference');
  final _tokenController = TextEditingController();

  late Future<StorageShowcaseSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = widget.controller.load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _run(Future<StorageShowcaseSnapshot> Function() action) {
    setState(() {
      _snapshotFuture = action();
    });
  }

  void _saveSensitiveValue() {
    final token = _tokenController.text;
    _tokenController.clear();
    _run(() => widget.controller.saveSensitiveValue(token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Security Showcase')),
      body: FutureBuilder<StorageShowcaseSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Ordinary local data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Safe note'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => _run(
                      () => widget.controller.saveOrdinaryData(
                        displayName: _nameController.text,
                        note: _noteController.text,
                      ),
                    ),
                    child: const Text('Save ordinary data'),
                  ),
                  OutlinedButton(
                    onPressed: () => _run(
                      () => widget.controller.updateOrdinaryData(
                        '${_nameController.text} (updated)',
                      ),
                    ),
                    child: const Text('Update'),
                  ),
                  OutlinedButton(
                    onPressed: () => _run(widget.controller.readThroughCache),
                    child: const Text('Read through cache'),
                  ),
                ],
              ),
              const Divider(height: 32),
              Text(
                'Sensitive value',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tokenController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Demo token value',
                  helperText: 'Stored with flutter_secure_storage',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _saveSensitiveValue,
                child: const Text('Save sensitive value'),
              ),
              const Divider(height: 32),
              _StatusPanel(snapshot: data),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _tokenController.clear();
                  _run(widget.controller.clearAll);
                },
                child: const Text('Clear stored values'),
              ),
              const SizedBox(height: 24),
              const _ConfigurationPanel(config: AppConfig.fromEnvironment),
            ],
          );
        },
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.snapshot});

  final StorageShowcaseSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final profile = snapshot?.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current safe state',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text('Profile stored: ${profile == null ? 'No' : 'Yes'}'),
        if (profile != null) ...[
          Text('Display name: ${profile.displayName}'),
          Text('Safe note: ${profile.note}'),
          Text('Last updated: ${profile.updatedAt.toLocal()}'),
        ],
        Text(
          'Sensitive token stored: ${snapshot?.hasSensitiveToken == true ? 'Yes' : 'No'}',
        ),
        Text('Cache status: ${snapshot?.cacheMessage ?? 'Loading'}'),
      ],
    );
  }
}

class _ConfigurationPanel extends StatelessWidget {
  const _ConfigurationPanel({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Configuration', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Environment: ${config.environmentName}'),
        Text('API base URL configured: ${config.hasApiBaseUrl ? 'Yes' : 'No'}'),
      ],
    );
  }
}

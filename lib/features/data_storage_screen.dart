import 'dart:async';

import 'package:flutter/material.dart';

import '../../security/app_config.dart';
import '../../security/sensitive_value_store.dart';
import '../../storage/app_data_store.dart';
import '../../storage/app_profile.dart';
import '../../storage/profile_cache.dart';
import 'data_storage_controller.dart';

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({
    super.key,
    required this.controller,
    required this.sensitiveStore,
    required this.config,
  });

  final DataStorageController controller;
  final SensitiveValueStore sensitiveStore;
  final AppConfig config;

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _tokenController = TextEditingController();

  AppProfile? _profile;
  bool _hasToken = false;
  String _cacheStatus = 'Idle';
  String? _statusMessage;

  static const _tokenKey = 'secure_session_token';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final profile = await widget.controller.loadProfile();
    final hasToken = await widget.controller.hasToken(_tokenKey);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _hasToken = hasToken;
      _cacheStatus = 'Idle';
    });
  }

  Future<void> _handleSaveProfile() async {
    final profile = AppProfile(
      id: 'local-profile',
      displayName: _nameController.text.trim().isEmpty
          ? 'Local User'
          : _nameController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? 'Stored in SharedPreferences'
          : _noteController.text.trim(),
      updatedAt: DateTime.now(),
    );
    await widget.controller.saveProfile(profile);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _statusMessage = 'Profile saved';
    });
  }

  Future<void> _handleUpdateProfile() async {
    final updated = await widget.controller.updateProfile(
      displayName: '${_nameController.text.trim()} (updated)',
    );
    if (!mounted) return;
    setState(() {
      _profile = updated ?? _profile;
      _statusMessage = updated != null ? 'Profile updated' : 'No profile to update';
    });
  }

  Future<void> _handleReadThroughCache() async {
    try {
      final profile = await widget.controller.cache.readThrough(
        () async => AppProfile(
          id: 'fetched-profile',
          displayName: widget.config.displayName,
          note: 'Fetched once, then served from local cache',
          updatedAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _cacheStatus = 'Fetched and cached';
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cacheStatus = 'Error: $e';
      });
    }
  }

  Future<void> _handleSaveToken() async {
    final token = _tokenController.text;
    await widget.controller.saveToken(_tokenKey, token);
    if (!mounted) return;
    final hasToken = await widget.controller.hasToken(_tokenKey);
    setState(() {
      _hasToken = hasToken;
      _tokenController.clear();
      _statusMessage = 'Sensitive token saved';
    });
  }

  Future<void> _handleClearAll() async {
    await widget.controller.clearAll();
    if (!mounted) return;
    setState(() {
      _profile = null;
      _hasToken = false;
      _cacheStatus = 'Idle';
      _statusMessage = 'All data cleared';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Security Showcase'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOrdinaryDataSection(),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 24),
            _buildSensitiveDataSection(),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 24),
            _buildConfigurationSection(),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 24),
            _buildCurrentStateSection(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _handleClearAll,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear All Stored Values'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              _StatusBanner(message: _statusMessage!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrdinaryDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ordinary Data (SharedPreferences)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Note',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: _handleSaveProfile,
              child: const Text('Save'),
            ),
            OutlinedButton(
              onPressed: _handleUpdateProfile,
              child: const Text('Update'),
            ),
            OutlinedButton(
              onPressed: _handleReadThroughCache,
              child: const Text('Read Through Cache'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSensitiveDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sensitive Data (Secure Storage)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tokenController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Token Value',
            helperText: 'Value is never shown in the UI',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _handleSaveToken,
          child: const Text('Save Token'),
        ),
      ],
    );
  }

  Widget _buildConfigurationSection() {
    final config = widget.config;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Configuration',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _ConfigRow(label: 'Environment', value: config.environmentName),
        _ConfigRow(
          label: 'Display Name',
          value: config.displayName,
        ),
        _ConfigRow(
          label: 'API Base URL',
          value: config.hasApiBaseUrl ? config.apiBaseUrl : 'Not configured',
        ),
        _ConfigRow(
          label: 'Mode',
          value: config.isDemo ? 'Demo' : 'Standard',
        ),
      ],
    );
  }

  Widget _buildCurrentStateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Current State',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _StatusRow(
          label: 'Ordinary profile stored',
          value: _profile == null ? 'No' : 'Yes',
        ),
        if (_profile != null) ...[
          _StatusRow(label: 'Display name', value: _profile!.displayName),
          _StatusRow(label: 'Note', value: _profile!.note),
          _StatusRow(
            label: 'Last updated',
            value: _profile!.updatedAt.toLocal().toString(),
          ),
        ],
        _StatusRow(
          label: 'Sensitive token stored',
          value: _hasToken ? 'Yes' : 'No',
        ),
        _StatusRow(label: 'Cache status', value: _cacheStatus),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: colorScheme.onPrimaryContainer),
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

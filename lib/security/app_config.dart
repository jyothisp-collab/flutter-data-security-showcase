import 'package:flutter/foundation.dart';

@immutable
class AppConfig {
  const AppConfig({
    required this.environmentName,
    required this.apiBaseUrl,
    required this.displayName,
  });

  factory AppConfig.readFromEnvironment() {
    return AppConfig(
      environmentName: const String.fromEnvironment(
        'APP_ENV',
        defaultValue: 'local',
      ),
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '',
      ),
      displayName: const String.fromEnvironment(
        'DISPLAY_NAME',
        defaultValue: 'Local User',
      ),
    );
  }

  final String environmentName;
  final String apiBaseUrl;
  final String displayName;

  bool get isDemo => environmentName == 'demo';

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;
}

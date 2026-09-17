class AppConfig {
  const AppConfig({required this.environmentName, required this.apiBaseUrl});

  static const fromEnvironment = AppConfig(
    environmentName: String.fromEnvironment('APP_ENV', defaultValue: 'local'),
    apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: ''),
  );

  final String environmentName;
  final String apiBaseUrl;

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;
}

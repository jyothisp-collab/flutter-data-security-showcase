# Flutter Data Security Showcase

Small Flutter reference implementation for local data storage and secure data handling.

This is not a complete application. It keeps the code intentionally compact so reviewers can inspect the storage boundaries and security decisions quickly.

## What It Demonstrates

- Storing ordinary application data locally with `shared_preferences`
- Basic create, read, update, and delete behavior for a simple profile object
- Storing sensitive token-like values separately with `flutter_secure_storage`
- A small read-through cache that returns local data first and fetches only when empty
- Safe UI display that shows whether a sensitive value exists without rendering the value
- Configuration through compile-time environment values instead of hardcoded secrets

## Normal Storage vs Secure Storage

Ordinary data is handled by `AppDataStore` in `lib/storage/app_data_store.dart`.

The stored profile contains safe fields such as:

- display name
- non-sensitive note
- last updated timestamp

Sensitive values are handled through `SensitiveValueStore` in `lib/security/sensitive_value_store.dart`. The production implementation uses `flutter_secure_storage` and stores token-like values under a separate key from ordinary app data.

The UI only displays `Sensitive token stored: Yes/No`. It never displays the sensitive value after saving.

## Cache Approach

`ProfileCache` in `lib/storage/profile_cache.dart` demonstrates a minimal read-through cache:

1. Try to read a profile from local storage.
2. If one exists, return it.
3. If not, call the provided fetcher function.
4. Save the fetched profile locally.

There is no networking code in this repository. The fetcher is deliberately passed in so the cache behavior is testable without adding an API client.

## Security Considerations

- No real credentials, tokens, API keys, or client data are included.
- Sensitive values are not logged or displayed.
- Sensitive and non-sensitive data use separate storage mechanisms.
- `AppConfig` reads values with `String.fromEnvironment`, so build-time configuration can be supplied with `--dart-define`.
- The example avoids custom encryption code. Platform secure storage is delegated to `flutter_secure_storage`.

Example configuration:

```sh
flutter run --dart-define=APP_ENV=demo --dart-define=API_BASE_URL=https://example.invalid
```

## Testing

The tests cover:

- CRUD behavior for ordinary local data
- Read-through cache behavior
- Sensitive-store abstraction behavior
- Widget behavior that confirms saved sensitive text is not displayed

Run:

```sh
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Out Of Scope

- Networking or API integration
- Authentication flows
- Firebase
- Notifications
- Payments
- Database synchronization
- Offline-first architecture
- Custom encryption implementation
- Dependency injection frameworks or service locators
- Code generation

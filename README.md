# Flutter Data Security Showcase

A focused Flutter reference implementation demonstrating how to separate ordinary and sensitive data storage. Built for client review to show secure-by-default local data handling patterns.

## What It Demonstrates

- **Ordinary data storage** with `shared_preferences` for non-sensitive profile fields (display name, note).
- **Sensitive data storage** with `flutter_secure_storage` (Keychain on iOS, Keystore on Android) for tokens and credentials.
- **Read-through cache pattern** — returns cached data first, fetches only on cache miss, making the cache behavior testable without an API client.
- **Immutable data models** with `copyWith`, JSON serialization (`toJson`/`fromJson`), and encode/decode helpers.
- **Compile-time configuration** via `String.fromEnvironment` and `--dart-define` instead of hardcoded secrets.
- **Safe UI display** — shows whether a sensitive value exists without ever rendering the value itself.
- **Interface-based abstractions** — `SensitiveValueStore` interface enables swapping implementations without touching the UI or tests.

## Architecture Overview

```
lib/
├── main.dart                              — Composition root, UI wiring
├── security/
│   ├── app_config.dart                    — Build-time environment config
│   └── sensitive_value_store.dart          — Interface + SecureTokenStore impl
└── storage/
    ├── app_data_store.dart                — SharedPreferences CRUD for profiles
    ├── app_profile.dart                   — Immutable profile model
    └── profile_cache.dart                 — Read-through cache with testable fetcher
```

### Storage Strategy

| Data Type | Mechanism | Encryption | Example Fields |
|---|---|---|---|
| Ordinary profile data | `SharedPreferences` (JSON) | None | display name, note, timestamp |
| Sensitive tokens | `flutter_secure_storage` | Platform keystore | access token, refresh token |
| Cached values | `SharedPreferences` | None | last-fetched profile |

## Data Flow

```
UI → StorageShowcaseController → AppDataStore (SharedPreferences)
                                      → SensitiveValueStore (Encrypted)
                                      → ProfileCache (read-through)
```

`StorageShowcaseController` composes all three storage layers and exposes async methods that return `StorageShowcaseSnapshot` for the UI to render.

## Read-Through Cache

`ProfileCache` implements a minimal cache-aside pattern:

1. Check local storage for cached data.
2. If found, return it immediately.
3. If not found, call the provided fetcher function.
4. Persist the fetched result locally.
5. Return the result.

The fetcher is passed as a callback so the cache behavior is testable without adding an API client.

## Security Considerations

- No real credentials, tokens, API keys, or client data are included.
- Sensitive values are never logged, printed, or displayed in the UI.
- Sensitive and non-sensitive data use separate storage mechanisms.
- `AppConfig` reads values with `String.fromEnvironment`, so build-time configuration is supplied with `--dart-define`:
  ```sh
  flutter run --dart-define=APP_ENV=demo --dart-define=API_BASE_URL=https://example.invalid
  ```
- Custom encryption is avoided. Platform secure storage is delegated to `flutter_secure_storage`.

## Testing

Tests cover:

- CRUD behavior for ordinary local data via `AppDataStore`.
- Read-through cache behavior with fetcher callbacks.
- `SensitiveValueStore` abstraction — save, retrieve, clear, overwrite.
- Widget tests confirming saved sensitive text is never displayed.

Run:

```bash
flutter pub get
flutter test
flutter analyze
```

## Out Of Scope

- Networking or API integration.
- Authentication flows (tokens are stored but not acquired).
- Firebase or push notifications.
- Biometric authentication for secure storage access.
- Database synchronization or offline-first architecture.
- Custom encryption implementation.
- Dependency injection frameworks.
- Code generation (json_serializable, freezed).

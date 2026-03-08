# Enapel Terminal

The user-facing client application for the Enapel ecosystem.

## Purpose

Enapel Terminal is a mobile and tablet application designed for front-line business operations. It provides an intuitive interface for staff to interact with the core business engine.

## Key Features

- **Real-time Operations**: Handles sales checkouts, inventory lookups, and room management.
- **Multi-platform**: Built with Flutter for seamless operation on various devices and screen sizes.
- **Dynamic Configuration**: Connects to any local `enapel-server` instance via simple server IP configuration.

## Tech Stack

- **Framework**: Flutter
- **State Management**: GetX
- **Communication**: REST API (http)

## Integration

- **Communication Hub**: Connects directly to the `enapel-server` API to perform operations.
- **Security**: Uses Bearer token authentication validated by the local server.

## Deployment Notes

- **Packaged Cloud URL**: Standalone terminal license validation uses a build-time cloud URL packaged into the app with `--dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com`.
- **Client Configuration**: End users only configure the local `enapel-server` IP when using server mode.

## Cloud URL Configuration

- **Standalone Mode**: When the terminal is used without a local `enapel-server`, it validates the entered license key directly against `enapel-cloud`.
- **Build-Time Setting**: The `enapel-cloud` base URL is packaged into the terminal app at build or run time with `ENAPEL_CLOUD_URL`.
- **Default Fallback**: If `ENAPEL_CLOUD_URL` is not provided, the terminal falls back to `https://cloud.enapel.com/api/v1`.

### `flutter run`

Use `--dart-define` when running the app locally:

```bash
flutter run --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
```

Examples:

```bash
flutter run -d windows --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
flutter run -d macos --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
flutter run -d linux --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
flutter run -d android --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
flutter run -d ios --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
```

### `flutter build`

Use the same `--dart-define` flag when packaging releases:

```bash
flutter build apk --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
flutter build windows --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
flutter build macos --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
flutter build linux --dart-define=ENAPEL_CLOUD_URL=https://your-cloud-domain.com
```

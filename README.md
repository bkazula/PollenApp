# PollenApp

A Flutter application that displays current pollen allergens and intensity for a selected location, using Google Pollen API.

## Features

- First launch opens a map screen for location selection.
- Location can be selected by:
  - tapping on the map,
  - using current device location,
  - typing a city name.
- Selected location is persisted on the device (`shared_preferences`).
- If no saved location exists, app starts with map screen again.
- Pollen list screen shows allergen name and intensity from Google Pollen API.
- On-demand location change from pollen list screen.
- App language switcher (English / Polish).

## Google Pollen API key

API key is injected at build/run time via environment variable passed as dart define:

```bash
flutter run --dart-define=GOOGLE_POLLEN_API_KEY=$GOOGLE_POLLEN_API_KEY
```

For release builds:

```bash
flutter build apk --release --dart-define=GOOGLE_POLLEN_API_KEY=$GOOGLE_POLLEN_API_KEY
flutter build web --release --dart-define=GOOGLE_POLLEN_API_KEY=$GOOGLE_POLLEN_API_KEY
```

## GitHub Actions

- `PR Checks` workflow runs `flutter analyze` and `dart analyze` on every PR to `main`.
- `Main Build & Release` workflow builds release artifacts (`APK`, `web`) on every push to `main` and creates a GitHub release.

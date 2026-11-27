# Shayek “ Smart Trip Packing Assistant

**SWE463 · Group 03**

Shayek is a Flutter app proposal for helping individuals and families prepare for trips with organized, reusable packing lists. The app is intended to generate a suggested checklist from trip details, let users manage and mark items as packed, and save lists as templates.

## Project status

The Phase 4 implementation includes the essential Shayek features with SQLite-backed trip, template, and packing-checklist persistence. Family-member and return-checklist screens remain optional placeholder areas unless their final implementation is explicitly completed.

## Implemented features

- Create a trip with its type, duration, departure date, and number of travelers.
- Generate and persist a suggested packing checklist based on trip details.
- Add, edit, delete, categorize, and check off packing items.
- Persist checklist items and packed state, including synchronized Home and checklist progress.
- Save and reuse packing templates.
- Family-member organization with persisted traveler records.
- Return checklist with custom items and persisted reminder settings.

## Run the starter app

Install the Flutter SDK, then from the repository root run:

```bash
flutter pub get
flutter run -d chrome
```

To run on another device, use `flutter devices` to see available targets, then run `flutter run -d <device-id>`.

## Project structure

```text
lib/
  main.dart       App entry point
  screens/        Main app screens
  widgets/        Reusable interface components
  models/         Data model classes
  providers/      Shared application state
  database/       SQLite repositories and database setup
```

## Technology and packages

- **Flutter and Dart** ” app framework and language.

- `sqflite` provides local SQLite storage.
- `provider` provides shared state with `ChangeNotifier`.

## Repository

[SWE-463 Project Group 03 on GitHub](https://github.com/Zahraaalmadeh/SWE-463-Project-Group03)

## Team

| Member | Student ID |
|---|---:|
| Naba Alali | 202268320 |
| Rayhanah Alobaid | 202243580 |
| Zahra Almadeh | 202254580 |
| Atheer Almomtan | 202246520 |

## Verification

From `shayek/`, run `flutter pub get`, `flutter analyze`, and `flutter test`. The checklist provider test suite verifies item and packed-state persistence across provider instances.

## References and assets

The Phase 1 proposal identifies Flutter, Dart, and possible packages listed above.

# Shayek - Smart Trip Packing Assistant

**SWE463, Group 03**

Shayek helps travelers plan trips, create packing checklists, and reuse packing lists.

## Features

- Create trips with type, duration, departure date, and traveler count.
- Generate and manage trip packing lists; search and filter items and track packing progress.
- Save, edit, and reuse packing templates.
- Organize persisted family members and shared packing items.
- Manage a return checklist and save departure reminder settings.

Family-member and return-checklist flows are optional Phase 4 features and are implemented. The reminder setting and time are persisted, but the app does not schedule or deliver platform notifications.

## Project structure

The Flutter app is in `shayek/`:

```text
shayek/
  lib/
    main.dart
    app_routes.dart
    models/
    providers/
    database/
    screens/
    theme/
    widgets/
  test/
```

Screens use Providers for state; Providers use repositories in `database/` for persistence.

## Setup and run

Install Flutter, then:

```bash
cd shayek
flutter pub get
flutter run -d chrome
```

Use `flutter devices` to select another target.

## Validation

From `shayek/`:

```bash
flutter analyze
flutter test
```

## Storage and limitations

Trips, templates, checklist items, family-member records, packed state, and reminder settings are stored locally. Web storage uses IndexedDB and is scoped to the app's origin and port. The app has no sign-in or cloud synchronization, and reminder notifications are not scheduled.

## Team

| Member | Student ID |
|---|---:|
| Naba Alali | 202268320 |
| Rayhanah Alobaid | 202243580 |
| Zahra Almadeh | 202254580 |
| Atheer Almomtan | 202246520 |

## Repository

[SWE-463 Project Group 03](https://github.com/Zahraaalmadeh/SWE-463-Project-Group03)

## AI-use disclosure

AI was used for setup guidance, debugging, and implementation suggestions. The team reviewed the resulting code.

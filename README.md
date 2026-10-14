# Shayek “ Smart Trip Packing Assistant

**SWE463 · Group 03**

Shayek is a Flutter app proposal for helping individuals and families prepare for trips with organized, reusable packing lists. The app is intended to generate a suggested checklist from trip details, let users manage and mark items as packed, and save lists as templates.

## Project status

This repository contains the Phase 2 Flutter starter project. The team is preparing the interface and technical design; features described below are planned and should not be treated as implemented until they are present in the app.

## Planned features

- Create a trip with its type, duration, departure date, and number of travelers.
- Generate a suggested packing checklist based on trip details.
- Add, edit, delete, categorize, and check off packing items.
- Save and reuse packing templates.
- Optional: organize items by family member and use a return checklist with reminders.

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
  services/       Data access and other app services
```

Folders may be added or removed later these are just the initials attempt.

## Technology and packages

- **Flutter and Dart** ” app framework and language.

- The Phase 1 proposal plans local storage with `sqflite`, state management with Provider or `ChangeNotifier`, and possibly `flutter_local_notifications` for reminders. These are plans, not confirmed installed dependencies. 

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

On the current setup, `flutter pub get` completed, `flutter analyze` reported no issues, and `flutter run -d chrome` launched the app. 

## References and assets

The Phase 1 proposal identifies Flutter, Dart, and possible packages listed above.

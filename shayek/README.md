# Shayek - Smart Trip Packing Assistant

**SWE463, Group 03**

Shayek is a Flutter application that helps travelers create, organize, and reuse packing lists. It is designed for individual travelers, families, students, and business travelers who want to prepare for trips more efficiently and avoid forgetting important items.

Team members:

- Naba Alali
- Rayhanah Alobaid
- Zahra Almadeh
- Atheer Almomtan

## Phase 3 scope

Phase 3 establishes the shared Flutter project skeleton and the navigation foundation for the core user journey:

`Home -> Create Trip -> Generate Packing Checklist -> Manage Checklist -> Save as Template -> Templates`

The priority features are Trip Creation, Generated Packing Checklist, Checklist Management, and Reusable Packing Templates. This skeleton deliberately provides the project structure, navigation, models, state-management shells, database schema, and basic validation required to start those features. It does **not** claim that the complete feature implementations are finished.

## Main project features

- Create trips with a name, type, duration, departure date, and traveler count.
- Generate suggested packing items based on trip details.
- Manage packing items by adding, editing, deleting, categorizing, and marking them packed.
- Save packing lists as reusable templates and use templates for future trips.
- Organize family-member and shared items.
- Use a return checklist and departure reminder.

## Implemented in this skeleton

- Material 3 application theme (see **UI design** below) and a clean Flutter project structure.
- Named routes for all six planned screens.
- Home/Lists navigation shell with a shared top bar and footer.
- Home page listing upcoming trips as boarding-pass cards, with empty, loading, and error states.
- Empty route placeholder files for Create Trip, Checklist, Templates, Family Members, and Return Checklist.
- Reachable placeholder screens for checklist, templates, family members, and return checklist.
- Null-safe base models for `Trip`, `PackingItem`, `PackingTemplate`, and `TemplateItem`.
- `TripProvider`, `ChecklistProvider`, and `TemplateProvider` registered through `MultiProvider`.
- Local SQLite database initialization and tables for `trips`, `travelers`, `packing_items`, `templates`, and `template_items`.

## Intentionally unfinished

- Trips, checklist items, templates, and travelers are not yet saved or loaded in the UI.
- Checklist generation, checklist CRUD, categorization, packed-state updates, and progress tracking are not implemented yet.
- Saving, editing, deleting, and applying templates are not implemented yet.
- Trip creation fields and validation are not implemented yet; the Create Trip page only links to the checklist route.
- Family Members and Return Checklist are basic navigable placeholders planned for **Phase 4**. Return reminders and notifications are also deferred; no notification package is included.

## UI design

The app uses one shared visual style, defined in `lib/theme/app_theme.dart`:

- **`AppColors`**: warm paper background, deep-blue actions, a tangerine accent, and ink/muted text colours.
- **`TripTypeColors`**: a soft tint and a readable text colour for each trip type (beach, business, family, camping, city, other), used on Home cards, the checklist header, and list cards.
- **`AppText`**: serif headings (Georgia) over a clean sans-serif body.
- **`AppTheme.build()`**: the `ThemeData` passed to `MaterialApp`; it styles buttons (pill-shaped), text fields, chips, checkboxes, dialogs, menus, snackbars, and progress bars, so screens pick up the look without repeating colours.

Screen highlights:

- **Home**: trips shown as boarding-pass cards with the departure date on a stub tinted by trip type.
- **Create Trip**: trip types as pill buttons, round +/− counters, and a full-width Generate button.
- **Checklist**: the trip name as a large heading, a slim progress bar, and items as rows on one sheet with round checkboxes.
- **Lists**: saved and public lists in a card grid showing the list name, trip type, sample items, and visibility.

New screens should use `AppColors`, `AppText`, and the theme's widget styles instead of hard-coded colours.

## Technology and packages

- Flutter and Dart
- Material 3
- `provider` with `ChangeNotifier` for shared state
- `sqflite` for local SQLite storage
- `sqflite_common_ffi_web` for SQLite-backed trip storage in browser IndexedDB
- `path` for portable database paths
- No authentication, backend, API, Firebase, or cloud storage

The web SQLite worker and WebAssembly runtime are included in `web/`. Browser
data is scoped to the app's origin and port.

## Folder structure

```text
lib/
  main.dart                 App entry point, theme, providers, and routes
  app_routes.dart           Named-route definitions
  models/                   Null-safe application data models
  providers/                Shared ChangeNotifier state shells
  screens/                  Feature screens and navigation shell
  widgets/                  Reusable, temporary UI components
  database/                 SQLite initialization and table schema
  repositories/             Reserved for persistence abstractions as CRUD is added
```

Screens interact with Providers; Providers will later call the database/repository layer. Screens should not access SQLite directly.

## Install dependencies

From the Flutter project directory:

```bash
cd shayek
flutter pub get
```

## Run the project

Use an available device or browser:

```bash
flutter devices
flutter run -d chrome
```

Replace `chrome` with a device ID from `flutter devices` when needed.

## Run static analysis

```bash
flutter analyze
```

## Current navigation flow

- `/` opens the Home tab.
- Home can open `/create-trip`.
- Home can open `/create-trip`.
- The remaining named routes are registered and ready for their feature owners to connect.
- Home and Templates are available through the bottom navigation bar.
- AppBar Back buttons and system Back return to the preceding route.

## Current limitations

The web database is stored in browser IndexedDB, so data is scoped to the app's origin and port. The Family Members and Return Checklist features remain planned for Phase 4.

## AI-use disclosure

AI was used for setup guidance, debugging, and small implementation suggestions. The team reviewed the resulting code and understands the project structure and implementation decisions.

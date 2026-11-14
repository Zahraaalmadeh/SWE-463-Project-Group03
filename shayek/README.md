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

The priority features are Trip Creation, Generated Packing Checklist, Checklist Management, and Reusable Packing Templates. All four now work end to end; the sections below list what is done and what is still planned.

## Main project features

- Create trips with a name, type, duration, departure date, and traveler count.
- Generate suggested packing items based on trip details.
- Manage packing items by adding, editing, deleting, categorizing, and marking them packed.
- Save packing lists as reusable templates and use templates for future trips.
- Organize family-member and shared items.
- Use a return checklist and departure reminder.

## What works now

- **Home**: lists saved trips as boarding-pass cards, with loading, empty, and error states. Tapping a trip opens its checklist.
- **Create Trip**: name (up to 60 characters), trip type, duration (1–90 days), travelers (1–20), and departure date, with inline validation (required name, no past dates). Saving stores the trip and opens its generated checklist.
- **Packing checklist**:
  - generates suggested items from the trip's type, length, and traveler count
  - add, edit, and delete items, each with a category, quantity, and optional "shared" flag
  - mark items packed, with a live progress bar and counts
  - search by name and filter by status (all / to pack / packed) and category
  - regenerate the checklist, remove all packed items, or save it as a reusable list
- **Lists (templates)**:
  - create a list from scratch, or save one from a checklist
  - rename, delete, and make a list public or private
  - "Use List" attaches a list to an existing trip and opens that trip's checklist
  - search public lists by name, trip type, or item
- **Storage**: trips and lists are saved in a local SQLite database (IndexedDB in the browser).
- **Shared design**: one theme for every screen (see **UI design** below).

## Not yet implemented

- Checklist items are kept in memory only, so they are regenerated after the app restarts.
- Family Members and Return Checklist are reachable placeholder screens planned for **Phase 4**.
- Departure reminders and notifications are deferred; no notification package is included.
- There is no sign-in; the Home greeting uses a placeholder name.

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
  main.dart                 App entry point, providers, theme, and routes
  app_routes.dart           Named-route definitions
  theme/                    Shared colours, text styles, and ThemeData
  models/                   Null-safe application data models
  providers/                Shared ChangeNotifier state (trips, checklist, lists)
  database/                 SQLite setup plus trip and template repositories
  screens/                  Feature screens and the Home/Lists navigation shell
  widgets/                  Reusable UI components (top bar, footer, trip card)
  repositories/             Reserved for future persistence abstractions
test/
  fakes/                    In-memory repositories used by the tests
  *_test.dart               Provider, screen, and flow tests
```

Screens talk to Providers, and Providers call the repositories in `database/`. Screens never access SQLite directly, which lets the tests swap in the in-memory fakes.

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

Replace `chrome` with a device ID from `flutter devices` when needed, for example `macos` for the desktop app:

```bash
flutter run -d macos
```

While it runs, press `r` to hot reload or `R` to hot restart after editing code.

## Run static analysis and tests

```bash
flutter analyze
flutter test
```

The tests cover the trip and checklist providers, the Create Trip screen, and the Home → Create Trip → Checklist flow.

## Screens and routes

On the web, routes appear after `#`, e.g. `http://localhost:<port>/#/create-trip`.

| Route | Screen |
|---|---|
| `/` | Home: your upcoming trips |
| `/templates` | Lists: your saved lists and public lists |
| `/create-trip` | Create Trip form |
| `/checklist` | Packing checklist for the selected trip (opened from Home, Create Trip, or Use List) |
| `/template-editor` | New list editor (normally opened as a dialog from Lists) |
| `/family` | Family Members (Phase 4 placeholder) |
| `/return-checklist` | Return Checklist (Phase 4 placeholder) |

- Home and Lists are switched from the top bar.
- Back buttons and the system Back gesture return to the previous screen.
- Unknown routes fall back to Home.

## Current limitations

- The web database is stored in browser IndexedDB, so data is scoped to the app's origin and port: running on a different port starts with an empty database.
- Headings use Georgia. Flutter web cannot load the computer's system fonts, so in the browser they fall back to a sans-serif font; desktop builds show the serif.
- Checklist items are not yet persisted (see **Not yet implemented**).

## AI-use disclosure

AI was used for setup guidance, debugging, and small implementation suggestions. The team reviewed the resulting code and understands the project structure and implementation decisions.

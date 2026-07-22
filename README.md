# To-Do Management

A Flutter task-management app built with Clean Architecture, Bloc state management, Firebase Authentication, and realtime Cloud Firestore task syncing.

The app supports onboarding, email/password accounts, saved-account switching, user-scoped task lists, manual task ordering, search, filters, sorting, validation, light/dark themes, and native splash assets.

## Features

- Firebase email/password sign in and sign up.
- Auth state subscription with automatic routing between auth and task screens.
- Saved account list using local storage.
- Secure credential storage for switching back to previously signed-in accounts.
- User-scoped realtime tasks stored at `users/{uid}/tasks/{taskId}`.
- Create, update, delete, reorder, and change task status.
- Task priority levels: `low`, `medium`, and `high`.
- Task status values: `pending`, `inProgress`, and `completed`.
- Search by title, filter by status or priority, and sort manually, by due date, or by created date.
- Pull-to-refresh, realtime sync timestamp, loading, empty, filtered-empty, and error states.
- Required-field validation, title length validation, and past due-date prevention.
- Responsive Material 3 UI with light/dark themes and reusable core widgets.
- Native splash screen configured for light and dark modes.

## Tech Stack

- Flutter and Dart.
- Firebase Core, Firebase Auth, and Cloud Firestore.
- Bloc for presentation state management.
- GetIt for dependency injection.
- SharedPreferences and Flutter Secure Storage for local persistence.
- Material 3 theming with custom font families.

## Requirements

- Flutter SDK compatible with Dart `^3.12.2`.
- Android Studio or Xcode for mobile builds.
- Firebase CLI if you need to deploy Firestore rules.
- A Firebase project with Email/Password Authentication enabled.

Check your local setup with:

```bash
flutter doctor
```

## Firebase Setup

Firebase platform configuration files are already included:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase.json`
- `firestore.rules`

The configured Firebase project in this repository is `to-do-management-recovery`.

Before running the app against Firebase:

1. Open Firebase Console.
2. Enable Email/Password in Authentication.
3. Make sure Cloud Firestore is created for the project.
4. Deploy the included Firestore rules when needed:

```bash
firebase deploy --only firestore:rules
```

The rules allow each signed-in user to read and write only their own document tree under:

```text
users/{uid}/tasks/{taskId}
```

Task documents are validated for owner, title, description, priority, status, timestamps, and optional `sortOrder`.

## Install

Fetch Flutter packages:

```bash
flutter pub get
```

If iOS pods need to be refreshed:

```bash
cd ios
pod install
cd ..
```

## Run

Run on the currently selected device:

```bash
flutter run
```

Run on a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

Common build commands:

```bash
flutter build apk --release
flutter build ios --release
```

## How To Use The App

1. Launch the app.
2. Complete onboarding on the first run.
3. Create an account or sign in with an existing email/password account.
4. Use the plus action on the Tasks screen to create a task.
5. Enter a title, description, priority, due date, and status.
6. Search tasks by title from the dashboard.
7. Filter tasks by status or priority.
8. Sort tasks manually, by due date, or by created date.
9. Drag tasks to reorder them when manual sorting is active.
10. Open a task to edit it, update status from the task card, or delete it.
11. Pull to refresh if you want to force a sync check.
12. Use the account menu to switch saved accounts, forget an account, or sign out.

## Package Usage

| Package | Used For |
| --- | --- |
| `flutter_bloc` | Bloc and Cubit-style presentation state for auth, onboarding, task lists, and task forms. |
| `get_it` | Service locator dependency injection in `lib/core/di/injection_container.dart`. |
| `equatable` | Value equality for entities, events, states, filters, and use-case params. |
| `firebase_core` | Firebase initialization in `lib/main.dart`. |
| `firebase_auth` | Email/password authentication and auth-state streams. |
| `cloud_firestore` | Realtime task storage and syncing under each user document. |
| `shared_preferences` | Local onboarding completion state and saved account metadata. |
| `flutter_secure_storage` | Local secure credential storage for saved-account switching. |
| `url_launcher` | Launching external contact/support links from the auth UI. |
| `package_info_plus` | Reading app version/build metadata. |
| `flutter_native_splash` | Generating native Android/iOS splash screens from `splash.yaml`. |
| `cupertino_icons` | iOS-style icon font support. |
| `skeletonizer` | Declared for skeleton/loading UI support; the current app also has custom loading states. |

Dev packages:

| Package | Used For |
| --- | --- |
| `flutter_test` | Widget and unit testing with Flutter's test framework. |
| `flutter_lints` | Recommended Dart and Flutter lint rules. |

## Project Structure

```text
lib/
  main.dart
  to_do_management.dart
  firebase_options.dart
  core/
    di/
    error/
    functions/
    theme/
    usecases/
    utils/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    onboarding/
      data/
      domain/
      presentation/
    tasks/
      data/
      domain/
      presentation/
```

The project follows Clean Architecture boundaries:

- `presentation` contains pages, widgets, Bloc events, Bloc states, and Blocs.
- `domain` contains entities, repository contracts, and use cases.
- `data` contains Firebase/local data sources, models, and repository implementations.
- `core` contains shared dependency injection, theming, utilities, errors, use-case base classes, and reusable widgets.

Dependency direction:

```text
UI -> Bloc -> Use Case -> Repository Contract -> Repository Implementation -> Data Source
```

## Tests And Quality Checks

Run formatting:

```bash
dart format lib test
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

The test suite covers auth repository behavior, auth Bloc behavior, saved account persistence, onboarding persistence, task Bloc refresh behavior, filters, validation, and shared widgets.

## Splash Screen

Splash configuration lives in `splash.yaml`.

After changing splash colors or images, regenerate native splash assets:

```bash
dart run flutter_native_splash:create --path=splash.yaml
```

## Assets And Fonts

Registered icon assets:

```text
assets/icons/
```

Registered font families:

- `Tajawal`
- `Gilroy`
- `OpenSans`

The app icon assets include light and dark variants used by the splash configuration:

- `assets/icons/app_ic_light.png`
- `assets/icons/app_ic_dark.png`

## Useful Commands

```bash
flutter clean
flutter pub get
flutter run
dart format lib test
flutter analyze
flutter test
dart run flutter_native_splash:create --path=splash.yaml
firebase deploy --only firestore:rules
```

# TaskFlow

A Flutter to-do management application built for the technical assessment using Clean Architecture, Bloc, Firebase Authentication, and realtime Firestore streams.

## Features

- Email/password authentication with Firebase Auth.
- User-scoped realtime tasks stored at `users/{uid}/tasks/{taskId}`.
- Create, update, delete, and change task status.
- Search by title, filter by status/priority, and sort by due date or created date.
- Pull-to-refresh, loading, empty, filtered-empty, and error states.
- Required-field validation, title length validation, and past due date prevention.
- Responsive Material 3 UI with light/dark themes, reusable widgets, Hero transitions, and AnimatedSwitcher feedback.
- Dependency injection via GetIt.

## Architecture

```text
lib/
  core/
    di/
    error/
    theme/
    usecases/
    utils/
  features/
    auth/
      data/
      domain/
      presentation/
    tasks/
      data/
      domain/
      presentation/
```

The presentation layer uses Bloc only. Blocs call domain use cases, use cases depend on repository contracts, and data repositories delegate to Firebase-backed data sources.

## Firebase

Firebase platform files are already present for Android and iOS:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Before running against a Firebase project, enable Email/Password sign-in in Firebase Authentication and deploy the included Firestore rules:

```bash
firebase deploy --only firestore:rules
```

## Run

```bash
flutter pub get
flutter run
```

## Verify

```bash
dart format lib test
flutter analyze
flutter test
```

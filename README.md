# RecipeBox — QE190009

Student: Hồ Lê Quốc Khánh (QE190009)

Repository: https://github.com/hlqkhanh/recipebox-qe190009

Android application ID: `com.hlqkhanh.recipebox_qe190009`

## Current state

Android Flutter application connected to Firebase project `recipebox-qe190009`.

- Public Home with feature cards; real Firebase Email/Password Register and Login.
- Auth gate, persistent sessions, account-isolated navigation, email header and Logout.
- Firestore-backed Add, Detail, Edit, Delete with confirmation, and persistent favorite stars.
- Combined category, difficulty, favorite and name/notes search filters; Clear resets all controls.
- Cook-time sorting with case-insensitive name ties, and summary calculated from the visible records.
- Shared Add/Edit validation with exact exam messages, delayed validation and inline backend errors.
- Cream, mint, forest-green and coral design system; bundled Plus Jakarta Sans and local category icons.

## Local environment

- Flutter 3.47.9 stable / Dart 3.13.7
- Flutter SDK: `C:\src\flutter`
- Android SDK: `C:\Users\Acer\AppData\Local\Android\Sdk`
- Flutter uses the installed Temurin Java 21 JDK.

Reopen your terminal or IDE after SDK installation to load the updated user PATH.

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter run
```

Connect an Android phone with USB debugging enabled or start an Android emulator before `flutter run`.

Build a debug APK:

```powershell
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`.

## Firebase configuration

The Android app uses `android/app/google-services.json` and `lib/firebase_options.dart`, prepared from the supplied Firebase client configuration. Dependencies include `firebase_core`, `firebase_auth`, and `cloud_firestore`. Firebase initializes before the app starts. Android requires API 24 or newer.

Email/Password Authentication, the grader account, and the Firestore database must be enabled in Firebase Console. Security Rules are stored in `firestore.rules` and deployed with:

```powershell
.\tools\node_modules\.bin\firebase.cmd deploy --only firestore:rules --project recipebox-qe190009
```

If switching Firebase projects, replace both client configuration files or regenerate them with FlutterFire CLI: https://firebase.google.com/docs/flutter/setup.

### Database design and uniqueness

All recipe records live in the single `recipes` collection, with the exam field names. Empty servings are omitted, notes default to an empty string, and favorites default to false. `createdAt` uses a server timestamp.

Document IDs are `<userId>__<uppercase UTF-8 hex of the trimmed lowercase recipe name>`. Rules independently recompute this ID and validate all required data. This prevents a client from creating a second document with the same user/name under an arbitrary ID, even with different letter case. Unicode and slashes in recipe names remain supported. No helper collection or admin key is used.

Adding is a transaction that refuses an existing name. Editing a name changes its canonical document ID: one transaction checks both documents, creates the renamed recipe, and deletes the old document. `createdAt`, ownership and favorite state are preserved. Ordinary updates cannot change ownership or `createdAt`. Renaming to another existing name is refused.

Queries always include `where('userId', isEqualTo: uid)`. Sorting, filtering and summaries are computed in the app; no composite Firestore index is needed.

## Verification

```powershell
flutter analyze
flutter test
cd tools
npm ci
npm run test:rules
```

Rules tests run on the local Firestore Emulator with a demo project. They cover validation, direct malicious writes, anonymous access, cross-user access, canonical IDs, Unicode names, optional fields, favorites and rename transactions.

The production-backed device test requires your own test-account credentials as command-line defines. It creates an extra QA auth account and manages only recipes whose names start with `QA • ` on the supplied test account.

```powershell
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5554 --dart-define=TEST_EMAIL=YOUR_TEST_EMAIL --dart-define=TEST_PASSWORD=YOUR_TEST_PASSWORD
```

On Windows, use `tools/run_device_test.ps1 -TestEmail YOUR_TEST_EMAIL -TestPassword YOUR_TEST_PASSWORD` to capture native Android screenshots at each test checkpoint under `artifacts/screenshots/`. This avoids the Flutter surface-conversion screenshot issue on some emulator GPUs. Never substitute test mockups for the required report screenshots.

## Release APK

```powershell
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`. The current exam build uses the Flutter template's debug signing configuration to produce an installable release APK; no private signing key is shipped in the source.

## Submission

Submit `QE190009.docx` and `QE190009.zip`. The source zip must have `pubspec.yaml` at its root and exclude `build/`, `.dart_tool/`, `.git/`, and admin/service-account keys. Only client Firebase configuration belongs in the app.

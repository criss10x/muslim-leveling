# Firebase Google Sign-In Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make native Google Sign-In through Firebase reliable on Android and remove the unsafe static Supabase export from the shipped app.

**Architecture:** `AuthService` owns one shared Firebase initialization future and the native Google credential exchange. `main.dart` only performs app startup orchestration; `CloudSync` continues using `user_data/{firebaseUid}`. Release signing validation is attached to release tasks instead of Gradle configuration so debug builds remain usable.

**Tech Stack:** Flutter/Dart, `firebase_core`, `firebase_auth`, `google_sign_in`, Firebase Firestore, Android Gradle Kotlin DSL, Flutter test.

## Global Constraints

- Use the Web OAuth client ID from `android/app/google-services.json`.
- Do not ship `assets/supabase_export.json` or run static Supabase migration code.
- Preserve local-first `SharedPreferences` state and UID-scoped Firestore rules.
- Native Android Google Sign-In still requires the correct SHA-1 in Firebase Console.
- Run `flutter analyze` after each source/config edit.

---

### Task 1: Add regression tests for config and unsafe export

**Files:**
- Create: `test/firebase_auth_config_test.dart`
- Create: `test/security_asset_test.dart`

**Interfaces:**
- Consumes: `AuthService.googleWebClientId` and repository asset layout.
- Produces: failing tests that prove the configured client ID matches Firebase config and the static export is absent.

- [ ] **Step 1: Write the failing tests**

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/auth_service.dart';

void main() {
  test('uses the Web OAuth client from google-services.json', () {
    final config = jsonDecode(
      File('android/app/google-services.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final clients = (config['client'] as List).single as Map;
    final oauthClients = clients['oauth_client'] as List;
    final webClient = (oauthClients.single as Map)['client_id'] as String;

    expect(AuthService.googleWebClientId, webClient);
  });
}
```

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('does not ship the static Supabase export', () {
    expect(File('assets/supabase_export.json').existsSync(), isFalse);
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail for the current code**

Run: `flutter test test/firebase_auth_config_test.dart test/security_asset_test.dart`

Expected: FAIL because `AuthService.googleWebClientId` does not exist and `assets/supabase_export.json` still exists.

### Task 2: Make Firebase initialization and native auth deterministic

**Files:**
- Modify: `lib/services/auth_service.dart`
- Modify: `lib/main.dart`
- Test: `test/firebase_auth_config_test.dart`

**Interfaces:**
- Consumes: `android/app/google-services.json` Web OAuth client ID.
- Produces: `AuthService.googleWebClientId`, `AuthService.ensureFirebaseReady()`, and a sign-in path that never calls Firebase Auth before initialization.

- [ ] **Step 1: Add the public testable client constant and shared initialization future**

```dart
@visibleForTesting
static const googleWebClientId =
    '691907686915-ljhu8cc4uvjuggd093fv5bl7dvk6joil.apps.googleusercontent.com';
static Future<bool>? _firebaseInit;

static Future<bool> ensureFirebaseReady() =>
    _firebaseInit ??= _initializeFirebase();
```

- [ ] **Step 2: Run the focused config test**

Run: `flutter test test/firebase_auth_config_test.dart`

Expected: PASS for the client ID after the constant is wired into `GoogleSignIn`.

- [ ] **Step 3: Implement readiness and use it from startup and sign-in**

`_initializeFirebase()` calls `Firebase.initializeApp()` only when no Firebase app exists, maps failures to `lastError`, and returns `false`. `init()` and `signInWithGoogle()` await `ensureFirebaseReady()` before using `FirebaseAuth`. Remove direct Firebase initialization and the removed migration call from `main.dart`.

- [ ] **Step 4: Run the focused auth test and analyze**

Run: `flutter test test/firebase_auth_config_test.dart`
Run: `flutter analyze`

Expected: the focused test passes; analyze reports only the four pre-existing test diagnostics and no new production errors.

### Task 3: Remove the unsafe static migration payload

**Files:**
- Delete: `assets/supabase_export.json`
- Delete: `lib/services/migration_service.dart`
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`
- Test: `test/security_asset_test.dart`

**Interfaces:**
- Consumes: local state and existing `CloudSync` behavior.
- Produces: no bundled user data and no startup write to an arbitrary Firebase UID.

- [ ] **Step 1: Remove the asset declaration, service import/call, service file, and export file**

Do not add a replacement migration path. Existing local state remains intact and authenticated backup continues through `CloudSync`.

- [ ] **Step 2: Run the security test and analyze**

Run: `flutter test test/security_asset_test.dart && flutter analyze`

Expected: PASS and no new analyzer errors.

### Task 4: Make release signing validation task-scoped

**Files:**
- Modify: `android/app/build.gradle.kts`

**Interfaces:**
- Consumes: existing `key.properties` detection.
- Produces: debug builds that do not require release credentials; `assembleRelease` and `bundleRelease` fail explicitly when credentials are absent.

- [ ] **Step 1: Move the missing-keystore exception out of `buildTypes.release`**

Only attach `signingConfig` when `useReleaseKeystore` is true. When false, attach a `doFirst` exception to `assembleRelease` and `bundleRelease`.

- [ ] **Step 2: Run analyze and a debug build**

Run: `flutter analyze && flutter build apk --debug`

Expected: analyze reports only the four pre-existing test diagnostics and the debug APK build exits 0 without `android/key.properties`.

### Task 5: Full verification and handoff

**Files:**
- Modify: `docs/superpowers/plans/2026-08-10-firebase-google-signin-hardening.md` only if task status needs recording.

- [ ] **Step 1: Run the complete test suite**

Run: `flutter test`

Expected: all non-golden tests pass; report any pre-existing golden mismatch separately.

- [ ] **Step 2: Check repository state**

Run: `git diff --check` and `git status --short --branch`.

Expected: no whitespace errors; only intentional changes remain.

- [ ] **Step 3: Commit the implementation**

```bash
git add lib pubspec.yaml android/app/build.gradle.kts test docs/superpowers/plans/2026-08-10-firebase-google-signin-hardening.md
git commit -m "fix: harden Firebase Google sign-in"
```

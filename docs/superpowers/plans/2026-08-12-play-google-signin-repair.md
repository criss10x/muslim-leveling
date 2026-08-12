# Play Google Sign-In Repair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Play-signed Android build use the correct Firebase OAuth configuration and allow Firebase sign-in with an ID token when Google does not provide an access token.

**Architecture:** Keep the existing native `GoogleSignIn` flow and Firebase initialization. Replace only the Android Firebase configuration, expose a test-only credential factory in `AuthService`, and make regression tests select OAuth records by their stable type rather than list position.

**Tech Stack:** Flutter/Dart, `firebase_auth`, `google_sign_in` 6.x, `flutter_test`, Android Google Services configuration.

## Global Constraints

- Preserve package ID `id.muslimleveling.muslim_leveling` and Web OAuth client `691907686915-ljhu8cc4uvjuggd093fv5bl7dvk6joil.apps.googleusercontent.com`.
- Use the supplied `E:\New folder\google-services.json` verbatim as the Firebase configuration source.
- Keep a non-empty Google ID token mandatory; treat the access token as optional.
- Do not merge `fix/google-signin-sentry-tracking` or modify Firebase Console state.
- Run `flutter analyze` after edits and commit only files in this repair scope.

---

### Task 1: Lock the Firebase configuration to the Play signing certificate

**Files:**
- Modify: `android/app/google-services.json`
- Modify: `test/firebase_auth_config_test.dart:8-17`

**Interfaces:**
- Consumes: Firebase configuration for package `id.muslimleveling.muslim_leveling`.
- Produces: A regression test that locates `client_type: 3` and requires Play SHA-1 `714387b55178b56364101ca4a1e15450e2cd17e8`.

- [x] **Step 1: Write the failing configuration assertion**

```dart
final oauthClients = client['oauth_client'] as List;
final webClient = oauthClients.cast<Map>().singleWhere(
  (oauth) => oauth['client_type'] == 3,
);
final androidSha1s = oauthClients
    .cast<Map>()
    .where((oauth) => oauth['client_type'] == 1)
    .map((oauth) => oauth['android_info']['certificate_hash'])
    .toSet();

expect(webClient['client_id'], AuthService.googleWebClientId);
expect(
  androidSha1s,
  contains('714387b55178b56364101ca4a1e15450e2cd17e8'),
);
```

- [x] **Step 2: Run the focused test and verify red**

Run: `flutter test test/firebase_auth_config_test.dart`

Expected: FAIL because the active configuration does not contain the exact Play App Signing SHA-1.

- [x] **Step 3: Replace the Firebase configuration**

Replace `android/app/google-services.json` with the complete supplied file. It must include Android OAuth entries for SHA-1 values `a4261bd1dfe4aaabae20c3d9705fa1221821ee2c`, `df2c7e725a29a71b6f66faa6fa0478775b46f723`, `714387b55178b56364101ca4a1e15450e2cd17e8`, `51b4b23fafb389be820bf9e937cfea02331a862e`, and `714387b55178b56364101ca41e15450e2cd17e8e`.

- [x] **Step 4: Run the focused test and verify green**

Run: `flutter test test/firebase_auth_config_test.dart`

Expected: PASS.

### Task 2: Accept an ID-token-only Firebase Google credential

**Files:**
- Modify: `lib/services/auth_service.dart:96-112`
- Create: `test/google_auth_credential_test.dart`

**Interfaces:**
- Produces: `AuthService.googleCredentialForTokens({required String idToken, String? accessToken})` returning `fb.AuthCredential`.
- Consumes: Google ID token and optional Google access token.

- [x] **Step 1: Write the failing credential regression test**

```dart
test('builds a Firebase credential from an ID token without an access token', () {
  final credential = AuthService.googleCredentialForTokens(
    idToken: 'test-id-token',
  );

  expect(credential, isNotNull);
});
```

- [x] **Step 2: Run the focused test and verify red**

Run: `flutter test test/google_auth_credential_test.dart`

Expected: FAIL because `googleCredentialForTokens` does not exist.

- [x] **Step 3: Implement the minimal credential change**

```dart
final credential = googleCredentialForTokens(
  idToken: idToken,
  accessToken: googleAuth.accessToken,
);

@visibleForTesting
static fb.AuthCredential googleCredentialForTokens({
  required String idToken,
  String? accessToken,
}) => fb.GoogleAuthProvider.credential(
  idToken: idToken,
  accessToken: accessToken,
);
```

Delete the existing early return that rejects a null or empty access token.

- [x] **Step 4: Run the focused test and verify green**

Run: `flutter test test/google_auth_credential_test.dart`

Expected: PASS.

### Task 3: Audit the remaining release/auth surface and verify the repair

**Files:**
- Review: `lib/main.dart`, `lib/screens/profil_tab.dart`, `lib/services/cloud_sync.dart`, `android/app/build.gradle.kts`, `.github/workflows/flutter.yml`
- Test: `test/firebase_auth_config_test.dart`, `test/google_auth_credential_test.dart`

**Interfaces:**
- Consumes: the repaired Firebase configuration and credential factory.
- Produces: a documented list of any newly found issue; no additional source edit unless a focused failing regression test proves it.

- [x] **Step 1: Inspect each auth/release boundary**

Use `rg` to trace `GoogleSignIn`, `FirebaseAuth`, `CloudSync`, `signingConfig`, and `bundleRelease`. Record whether a failure happens before account selection, during Firebase credential exchange, or after successful authentication during backup.

- [x] **Step 2: Run focused verification**

Run: `flutter test test/firebase_auth_config_test.dart test/google_auth_credential_test.dart`

Expected: PASS.

- [ ] **Step 3: Run project verification**

Run: `flutter analyze`, `flutter test`, and `flutter build appbundle --release`.

Expected: no auth/config regression and a release AAB produced from the repaired configuration; document unrelated existing failures rather than changing unrelated production behavior.

Audit result: `flutter analyze` completed with four unrelated test-only diagnostics, and `flutter test` completed with 158 passes plus two unrelated Windows golden mismatches. `flutter build appbundle --release` emitted no output for more than six minutes and its wrapper was stopped. An AAB appeared afterward, but the command never returned a successful exit status, so this step remains incomplete.

- [x] **Step 4: Review and commit the scoped repair**

Run: `git diff --check` and `git diff -- android/app/google-services.json lib/services/auth_service.dart test/firebase_auth_config_test.dart test/google_auth_credential_test.dart`.

Then commit the approved files and the design/plan documents:

```powershell
git add android/app/google-services.json lib/services/auth_service.dart test/firebase_auth_config_test.dart test/google_auth_credential_test.dart docs/superpowers/specs/2026-08-12-play-google-signin-repair-design.md docs/superpowers/plans/2026-08-12-play-google-signin-repair.md
git commit -m "fix: repair Play Google sign-in"
```

The production/config repair was already split across commits `04a34b4` and `7dfcb8c`; Task 3 therefore reviewed an empty scoped diff and committed only these design/plan documents.

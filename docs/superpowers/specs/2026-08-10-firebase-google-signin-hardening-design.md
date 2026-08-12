# Firebase Google Sign-In Hardening

## Goal

Make native Google Sign-In through Firebase reliable for the Android app while preventing the unsafe static Supabase export from shipping in the APK.

## Scope

- Use the Web OAuth client ID from `android/app/google-services.json` as the Dart default `serverClientId`.
- Gate Firebase Auth calls behind one shared initialization future and expose an actionable initialization error.
- Remove the bundled `assets/supabase_export.json` migration path and its startup call. Local `SharedPreferences` remains the source of truth; signed-in users back up to Firestore.
- Keep Firestore access constrained to the authenticated Firebase UID.
- Allow debug builds without a release keystore while failing release APK/AAB tasks when the release keystore is absent.
- Add focused tests for the auth configuration/readiness behavior where the native plugin can be tested without a device.

## Non-goals

- No automatic Supabase-to-Firebase data migration. A safe migration requires a server-side mapping from the old account identity to the Firebase UID.
- No browser OAuth fallback in this change; native Android sign-in remains the configured path and SHA-1 registration remains required.
- No unrelated UI, theme, or game-state refactor.

## Data flow

1. `main()` starts the app and begins Firebase initialization.
2. `AuthService` owns the shared initialization future, so both startup restore and a user-tapped login await the same result.
3. `GoogleSignIn` obtains Google tokens using the configured Web OAuth client.
4. `FirebaseAuth.signInWithCredential` creates/restores the Firebase user.
5. `CloudSync` reads/writes `user_data/{firebaseUid}`; Firestore rules enforce the same UID.

## Error handling

- Firebase initialization failures set `AuthService.lastError` and prevent sign-in attempts from reaching Google/Firebase with an uninitialized app.
- Existing Google error mapping remains intact for SHA-1, network, cancellation, and provider errors.
- Migration/export errors are removed by removing the unsafe migration path, not hidden behind a best-effort write.

## Verification

- Add/run focused regression tests before implementation and confirm they fail for the current code.
- Run `flutter analyze` after every edit.
- Run the focused tests and full `flutter test`.
- Run `flutter build apk --debug`; it must not require `android/key.properties`.
- Confirm `git diff --check` and a clean working tree except for intentional source changes.

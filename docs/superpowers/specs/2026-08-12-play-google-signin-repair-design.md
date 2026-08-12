# Play Google Sign-In Repair Design

## Goal

Ship a small, testable fix for Google Sign-In failures in Play Internal and Closed testing without merging the divergent Firebase/Sentry branch.

## Evidence

- Play App Signing's classical SHA-1 is `71:43:87:B5:51:78:B5:63:64:10:1C:A4:A1:E1:54:50:E2:CD:17:E8`.
- The prior working-tree config contained a similar but different fingerprint, so native Google Sign-In could not identify the Play-delivered APK.
- The supplied `E:\New folder\google-services.json` is for Firebase project `muslim-leveling`, package `id.muslimleveling.muslim_leveling`, and includes the exact Play SHA-1 plus the matching Web OAuth client.
- `AuthService` currently rejects an empty Google access token before Firebase sees a valid ID token. Firebase accepts an ID token without an access token.

## Scope

1. Replace `android/app/google-services.json` with the supplied Firebase configuration.
2. Keep the required non-empty ID-token check, but pass a nullable access token into `GoogleAuthProvider.credential`.
3. Make the Firebase config test select the Web OAuth entry by `client_type: 3`, and assert the exact Play SHA-1 is present.
4. Add a unit-level regression test proving the credential factory accepts an ID token with no access token.
5. Run a focused audit for additional auth/release defects, but only include defects with a small, proven regression test in this change.

## Non-goals

- No Firebase Console mutation; the supplied configuration is treated as the post-console snapshot.
- No browser OAuth fallback, package upgrade, unrelated UI redesign, or broad Sentry refactor.
- No merge or wholesale cherry-pick from `fix/google-signin-sentry-tracking`, because it diverges from the active branch.

## Data Flow

```text
Play App Signing SHA-1
  -> Firebase Android OAuth client in google-services.json
  -> GoogleSignIn returns idToken (+ optional accessToken)
  -> GoogleAuthProvider.credential
  -> FirebaseAuth.signInWithCredential
```

## Error Handling

- A missing ID token remains a failed Google sign-in.
- A missing access token does not block Firebase credential creation.
- The existing user-facing error mapping remains unchanged in this focused patch.

## Verification

- The new config test fails before the supplied JSON replaces the old file, then passes with the exact Play SHA-1 and Web OAuth client.
- The credential test fails before the nullable-token helper exists, then passes after the minimal AuthService change.
- Run focused tests, `flutter analyze`, the full test suite, and `flutter build appbundle --release` before commit. The release AAB verification remains inconclusive until that command returns a successful exit status.

# CloudSync Safe Login and Release Design

## Goal

Prevent a Firestore read error during Google login from being treated as an
empty backup, then ship the repair as Android version `1.0.0+16`.

## Root Cause

`CloudSync.load()` returns `null` for both a missing `user_data/{uid}`
document and every Firestore read error. `ProfilTab._completeGoogleLogin()`
then treats `null` as an empty backup, loads local services, merges local data,
and writes it to the same document. A temporary failed read can therefore
overwrite cloud values for `game`, `learning`, or `achievements`.

The read also occurs after `GameService.load()`. Its legacy streak backfill
can fire-and-forget a CloudSync save, so merely making `load()` strict is not
sufficient: the authoritative remote read must happen before any local service
can write.

## Scope

- Add an opt-in strict Firestore read to `CloudSync`.
- In the post-login flow, read remote data strictly before local services load.
- If the strict read fails, sign out, leave local state intact, perform no
  merge, and perform no cloud writes.
- Preserve fail-soft `CloudSync.load()` behavior for existing background
  loaders.
- Add regression coverage for strict reads and login safety boundaries.
- Release on `codex/release-v1.0.0-16` with `pubspec.yaml` set to
  `1.0.0+16`, tag `v1.0.0+16`, and a freshly built verified AAB.

## Non-Goals

- No Firestore schema, rules, or index migration.
- No Firebase Console mutation.
- No change to background sync behavior outside post-login recovery.
- No reuse of the prior AAB, because its build command did not return success.
- No modification to unrelated Windows golden tests or existing test lint.

## Firebase Gate

Before changing Firestore application code, identify the project database
edition. This Flutter app uses the Firebase Firestore SDK and UID-scoped rules.
The intended implementation assumes the existing database is Firestore
Standard. If Console shows Enterprise/native mode instead, read the matching
Firebase skill reference and revise the plan before code changes.

## Data Flow

```text
Google Sign-In succeeds
  -> CloudSync.initWithUser(uid)
  -> CloudSync.load(failOnError: true)
     -> existing document: merge remote + local
     -> absent document: first cloud backup from local
     -> read error: AuthService.signOut(), no local load/merge/write
  -> only successful read paths load services and save merged data
```

## API and Error Handling

`CloudSync.load({bool failOnError = false})` keeps the existing default:

- Existing document: return its data map.
- Confirmed absent document: return `null`.
- Read error with `failOnError: false`: return `null` for legacy callers.
- Read error with `failOnError: true`: rethrow the original error.

`ProfilTab._completeGoogleLogin()` calls strict mode immediately after setting
the user ID. Its catch signs out, shows a retry message, and returns before any
local service load or CloudSync write. This makes a failed read safe rather
than silently destructive.

## Testing

- Strict mode propagates a Firestore read exception.
- Default mode stays fail-soft on that exception.
- A confirmed absent document stays distinguishable from a read failure.
- The login orchestration proves its remote read precedes local loads and no
  save runs after a read failure.
- Existing CloudSync merge behavior is retained for a successful read.

## Release and Shutdown Gate

1. Use version `1.0.0+16` / Android `versionCode 16`.
2. Run focused CloudSync tests, `flutter analyze`, and `flutter test`.
3. Treat pre-existing golden/test diagnostics separately; do not claim a
   clean suite unless they are resolved or explicitly approved as baseline.
4. Build `flutter build appbundle --release` and require exit code `0`.
5. Hash and inspect the fresh AAB, commit, push the new branch, and publish
   GitHub Release `v1.0.0+16` with that exact AAB.
6. Verify the remote branch, release tag, and asset before invoking Windows
   shutdown. If any release gate is blocked, do not shut down.

# CloudSync Safe Login and Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent unsafe CloudSync writes after a failed Firestore read and publish a verified `v1.0.0+16` Android AAB.

**Architecture:** Preserve the current fail-soft CloudSync default for background loaders. Add an opt-in strict read used only during post-login recovery before any local service can write, then terminate the authenticated session if that read fails. Release the verified result from a fresh versioned branch.

**Tech Stack:** Flutter/Dart, `cloud_firestore`, Firebase Authentication, `flutter_test`, GitHub CLI, Android App Bundle.

## Global Constraints

- Firebase Console has been checked: Firestore is Standard edition in
  `asia-southeast2`.
- Preserve `CloudSync.load()` legacy default behavior.
- A strict login read failure must cause no local service load, merge, or cloud write.
- Use `AuthService.signOut()` on strict read failure to durably prevent later cloud writes.
- Do not change Firestore rules, schema, indexes, Firebase Console state, or
  golden baseline PNGs. The Windows profile-golden mismatches are documented
  font-rasterization differences; Ubuntu CI is authoritative. The only allowed
  lint cleanup is removing release-blocking lint violations from the two
  non-test simulation scripts under `test/`, with no app behavior change.
- Release version is exactly `1.0.0+16`; tag is exactly `v1.0.0+16`.
- Full release validation requires the Ubuntu GitHub Actions `analyze-build`
  workflow plus a fresh local AAB build with exit code `0`; never reuse the
  previously unverified AAB.
- Stage only scope files; preserve `.agents/` and `skills-lock.json`.

---

### Task 1: Verify Firestore contract and make strict reads testable

**Files:**
- Modify: `lib/services/cloud_sync.dart`
- Create: `test/cloud_sync_test.dart`

**Interfaces:**
- Produces: `CloudSync.load({bool failOnError = false})`.
- Produces: test-only injectable document reader to drive present, absent, and error cases without a Firebase emulator.

- [ ] **Step 1: Verify the Firestore edition**

Firebase Console has already confirmed a Standard Firestore database in
`asia-southeast2`; no Console mutation is required.

- [ ] **Step 2: Write failing strict-read tests**

```dart
test('strict load rethrows a Firestore read error', () async {
  CloudSync.initWithUser('uid');
  CloudSync.debugDocumentReader = (_) async => throw StateError('offline');

  await expectLater(
    CloudSync.load(failOnError: true),
    throwsA(isA<StateError>()),
  );
});

test('default load remains fail-soft after a read error', () async {
  CloudSync.initWithUser('uid');
  CloudSync.debugDocumentReader = (_) async => throw StateError('offline');

  expect(await CloudSync.load(), isNull);
});
```

- [ ] **Step 3: Run the focused test to verify red**

Run: `flutter test test/cloud_sync_test.dart`

Expected: FAIL because `failOnError` and the injected reader do not exist.

- [ ] **Step 4: Implement the minimal strict-read path**

```dart
static Future<Map<String, dynamic>?> load({bool failOnError = false}) async {
  if (!canSync) return null;
  try {
    return await _readDocument(_id);
  } catch (_) {
    if (failOnError) rethrow;
    return null;
  }
}
```

Keep the production reader backed by
`FirebaseFirestore.instance.collection('user_data').doc(id).get()` and only
expose its test replacement under `@visibleForTesting`.

- [ ] **Step 5: Run focused tests and commit**

Run: `flutter test test/cloud_sync_test.dart`

Expected: PASS.

Commit: `fix: distinguish CloudSync read failures`

### Task 2: Gate CloudSync writes until a strict remote read succeeds

**Files:**
- Modify: `lib/services/cloud_sync.dart`
- Modify: `lib/services/auth_service.dart`
- Modify: `lib/main.dart`
- Modify: `lib/screens/profil_tab.dart`
- Test: `test/cloud_sync_test.dart`

**Interfaces:**
- Consumes: `CloudSync.load(failOnError: true)`.
- Produces: `CloudSync.initWithUser(String userId)` as an awaited validation
  barrier that returns the remote document and enables writes only for the
  validated active user.
- Produces: post-login recovery that has no merge/write path after a strict
  read failure.

- [ ] **Step 1: Write failing validation-barrier tests**

Add tests that assert `CloudSync.initWithUser` does not enable writes until its
strict remote read succeeds, and that a read error leaves `saveGame` disabled.
The tests must also cover a UID change while a prior read is in flight so an
old completion cannot re-enable sync after logout or account switching.

- [ ] **Step 2: Run the focused test to verify red**

Run: `flutter test test/cloud_sync_test.dart`

Expected: FAIL because the awaited validation barrier and write gate do not
exist.

- [ ] **Step 3: Implement the smallest safe orchestration change**

Make `CloudSync.initWithUser(uid)` await a strict read and return that remote
document, enabling writes only if the completed read still belongs to the
active UID. Keep the auth-state listener from triggering an unawaited strict
read. In `main.dart`, await the validation barrier before local services load;
on failure sign out and keep the session local-only. In the interactive Profile
flow, await the same barrier immediately after login, use its returned remote
map for merging, and on error sign out, show a retry snackbar, and return
before any local service load, preferences write, or CloudSync save.

- [ ] **Step 4: Run focused tests and commit**

Run: `flutter test test/cloud_sync_test.dart`

Expected: PASS.

Commit: `fix: stop unsafe cloud sync after read failure`

### Task 3: Versioned release validation and publication

**Files:**
- Modify: `pubspec.yaml`
- Modify: `test/jumat_streak_test.dart`
- Modify: `test/wajib_lock_test.dart`
- Modify: `docs/superpowers/specs/2026-08-12-cloudsync-safe-release-design.md`
- Modify: `docs/superpowers/plans/2026-08-12-cloudsync-safe-release.md`
- Artifact: `build/app/outputs/bundle/release/app-release.aab`

**Interfaces:**
- Produces: Android `versionName 1.0.0`, `versionCode 16`, GitHub tag `v1.0.0+16`.

- [ ] **Step 1: Create the release branch and bump version**

Create branch `codex/release-v1.0.0-16` from the repaired current head. Change:

```yaml
version: 1.0.0+16
```

- [ ] **Step 2: Run code validation**

Run in order:

```powershell
flutter pub get
flutter analyze
flutter test
```

Record every exact result. Do not call validation clean if any command exits
nonzero; distinguish pre-existing failures only with evidence.

Before this gate, remove only the four diagnosed `flutter_lints` violations
from the two legacy simulation scripts: unused import, compile-time dead branch,
and two `avoid_print` calls. Do not refresh Windows golden images; their
font-rasterization mismatch is pre-existing and Ubuntu CI remains authoritative.

- [ ] **Step 3: Build a fresh release AAB**

Confirm `android/key.properties` and `android/release.jks` exist, then run:

```powershell
flutter build appbundle --release
Get-FileHash build/app/outputs/bundle/release/app-release.aab -Algorithm SHA256
```

Require the build command's exit code to be `0`. Record the AAB path, size,
and SHA-256.

- [ ] **Step 4: Commit and push the release branch**

Stage only code, tests, version, and design/plan files. Run `git diff --check`,
commit with `release: v1.0.0+16`, and push:

```powershell
git push -u origin codex/release-v1.0.0-16
```

- [ ] **Step 5: Publish and verify the GitHub Release**

Before creation, check that tag `v1.0.0+16` does not already exist. Create the
release from the pushed branch and upload the exact hashed AAB:

```powershell
gh release create v1.0.0+16 build/app/outputs/bundle/release/app-release.aab --target codex/release-v1.0.0-16 --title "Muslim Leveling v1.0.0+16" --notes "CloudSync safety repair and Play Google Sign-In configuration fixes."
gh release view v1.0.0+16 --json url,targetCommitish,assets
```

- [ ] **Step 6: Shut down only after remote verification**

Verify branch, release tag, and AAB asset are present remotely. Then schedule
the Windows shutdown command requested by the user.

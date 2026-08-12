# CloudSync Safe Login and Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent unsafe CloudSync writes after a failed Firestore read and publish a verified `v1.0.0+16` Android AAB.

**Architecture:** Preserve the current fail-soft CloudSync default for background loaders. Add an opt-in strict read used only during post-login recovery before any local service can write, then terminate the authenticated session if that read fails. Release the verified result from a fresh versioned branch.

**Tech Stack:** Flutter/Dart, `cloud_firestore`, Firebase Authentication, `flutter_test`, GitHub CLI, Android App Bundle.

## Global Constraints

- Verify Firestore database edition before modifying Firestore application code.
- Preserve `CloudSync.load()` legacy default behavior.
- A strict login read failure must cause no local service load, merge, or cloud write.
- Use `AuthService.signOut()` on strict read failure to durably prevent later cloud writes.
- Do not change Firestore rules, schema, indexes, Firebase Console state, unrelated goldens, or unrelated lint.
- Release version is exactly `1.0.0+16`; tag is exactly `v1.0.0+16`.
- Build a fresh AAB with exit code `0`; never reuse the previously unverified AAB.
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

Use Firebase Console or authenticated Firebase CLI to identify the existing
database edition. If it is Standard, read the Flutter Standard SDK reference;
if it is Enterprise/native, stop and revise this plan before code changes.

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

### Task 2: Stop login recovery before a failed cloud read can write

**Files:**
- Modify: `lib/screens/profil_tab.dart`
- Test: `test/cloud_sync_test.dart`

**Interfaces:**
- Consumes: `CloudSync.load(failOnError: true)`.
- Produces: post-login recovery that has no merge/write path after a strict read failure.

- [ ] **Step 1: Extract an injectable login recovery helper and write a failing test**

Move the non-widget recovery sequence into a package-visible helper with
injected callbacks for strict remote read, local loads, and saves. Its failure
test must assert that a thrown remote read causes no local load or save call.

```dart
test('login recovery does not load or save after a failed remote read', () async {
  var localLoads = 0;
  var saves = 0;

  await expectLater(
    recoverCloudLogin(
      readRemote: () async => throw StateError('offline'),
      loadLocal: () async => localLoads++,
      saveMerged: () async => saves++,
    ),
    throwsA(isA<StateError>()),
  );
  expect(localLoads, 0);
  expect(saves, 0);
});
```

- [ ] **Step 2: Run the focused test to verify red**

Run: `flutter test test/cloud_sync_test.dart`

Expected: FAIL because the recovery helper does not exist.

- [ ] **Step 3: Implement the smallest safe orchestration change**

Call strict `CloudSync.load()` immediately after `CloudSync.initWithUser(uid)`.
Only after that future resolves may `GameService.load`, `LearningService.load`,
or `AchievementService.load` run. On an error, call `AuthService.signOut()`,
show a retry snackbar, and return before writing preferences or calling a
CloudSync save method.

- [ ] **Step 4: Run focused tests and commit**

Run: `flutter test test/cloud_sync_test.dart`

Expected: PASS.

Commit: `fix: stop unsafe cloud sync after read failure`

### Task 3: Versioned release validation and publication

**Files:**
- Modify: `pubspec.yaml`
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

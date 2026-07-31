# Profile Order and Prayer GPS Area Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Put Streak per Sholat directly after the Profil hero and resolve GPS locations to kabupaten/kota instead of kecamatan before fetching prayer times.

**Architecture:** `ProfilTab` changes only the existing `ListView` child order. `PrayerService.prayerAreaFromAddress()` remains the one pure reverse-geocoder adapter and filters invalid lower-administrative candidates before the existing `searchCities()` and persistence flow runs.

**Tech Stack:** Flutter, flutter_test, existing `geolocator` and Nominatim reverse-geocoding flow.

## Global Constraints

- Preserve existing Indonesian labels, theme tokens, cosmetic behavior, prayer APIs, and manual city picker.
- Use the existing `AppSpacing` values; do not add dependencies or state-management layers.
- GPS must never select `Kecamatan ...`, `Kec. ...`, or a village as the prayer area.
- Run `flutter analyze` after code changes; do not build an APK.

---

## File Structure

- Modify `lib/screens/profil_tab.dart`: reorder existing profile sections only.
- Modify `test/profil_cosmetic_integration_test.dart`: enforce the approved section order.
- Modify `test/goldens/profil_tab_phone.png`: update the expected profile image after the intended reorder.
- Modify `lib/services/prayer_service.dart`: filter subdistrict and village reverse-geocoder values.
- Modify `test/prayer_service_test.dart`: cover the pure GPS area selection rules.

### Task 1: Reorder the Profile sections

**Files:**
- Modify: `test/profil_cosmetic_integration_test.dart:13-73`
- Modify: `lib/screens/profil_tab.dart:759-772`
- Modify: `test/goldens/profil_tab_phone.png`

**Interfaces:**
- Consumes: the existing `_hero`, `_prayerStreaks`, `_stats`, `_cosmeticLocker`, `_achievements`, and `_haidModeToggle` widgets.
- Produces: the visible order `Hero → Streak per Sholat → Statistik → Loker Skin → Achievements → Mode Haid`.

- [ ] **Step 1: Write the failing profile-order assertion**

  In `Profil keeps skin locker compact and opens it on demand`, add a local helper and assert the required sequence before the locker tap:

  ```dart
  double top(String label) => tester.getTopLeft(
    find.text(label, skipOffstage: false),
  ).dy;

  expect(top('STREAK PER SHOLAT'), greaterThan(tester.getBottomRight(hero).dy));
  expect(top('STATISTIK'), greaterThan(top('STREAK PER SHOLAT')));
  expect(tester.getTopLeft(locker).dy, greaterThan(top('STATISTIK')));
  expect(top('ACHIEVEMENTS'), greaterThan(tester.getTopLeft(locker).dy));
  expect(top('Mode Haid'), greaterThan(top('ACHIEVEMENTS')));
  ```

- [ ] **Step 2: Run the focused test to verify it fails**

  Run: `flutter test --no-pub test/profil_cosmetic_integration_test.dart`

  Expected: FAIL because the current page places Statistik and Loker Skin before Streak per Sholat, and Mode Haid before Achievements.

- [ ] **Step 3: Apply the minimal ListView reorder**

  Replace the profile section sequence with:

  ```dart
  _hero(context),
  const SizedBox(height: AppSpacing.md),
  _prayerStreaks(),
  const SizedBox(height: AppSpacing.md),
  _stats(),
  const SizedBox(height: AppSpacing.md),
  _cosmeticLocker(),
  const SizedBox(height: AppSpacing.md),
  _achievements(),
  const SizedBox(height: AppSpacing.md),
  _haidModeToggle(),
  ```

  Keep account backup and Settings after Mode Haid, unchanged.

- [ ] **Step 4: Run focused and golden verification**

  Run: `flutter test --no-pub test/profil_cosmetic_integration_test.dart test/profil_tab_golden_test.dart`

  Expected: the interaction test passes and the golden test fails only because the approved order changed.

  Update and verify the golden baseline:

  ```bash
  flutter test --no-pub test/profil_tab_golden_test.dart --update-goldens
  flutter test --no-pub test/profil_cosmetic_integration_test.dart test/profil_tab_golden_test.dart
  ```

- [ ] **Step 5: Commit the profile layout order**

  ```bash
  git add lib/screens/profil_tab.dart test/profil_cosmetic_integration_test.dart test/goldens/profil_tab_phone.png
  git commit -m "feat: reorder profile progress sections"
  ```

### Task 2: Reject kecamatan and village GPS areas

**Files:**
- Modify: `test/prayer_service_test.dart:5-27`
- Modify: `lib/services/prayer_service.dart:388-394`

**Interfaces:**
- Consumes: `prayerAreaFromAddress(Map<String, dynamic>? address)` and the existing `getCurrentLocation()` call to `searchCities(rawCity)`.
- Produces: `String?` containing only an accepted kabupaten/kota candidate or `null`.

- [ ] **Step 1: Write the failing unit tests**

  Replace the village fallback expectation and add this case:

  ```dart
  test('prayer area skips a kecamatan in favour of kabupaten kota', () {
    expect(
      PrayerService.prayerAreaFromAddress({
        'county': 'Kecamatan Kuta',
        'city': 'Kabupaten Badung',
      }),
      'Kabupaten Badung',
    );
  });

  test('prayer area rejects village-only reverse geocoding', () {
    expect(PrayerService.prayerAreaFromAddress({'village': 'Kuta'}), isNull);
  });
  ```

- [ ] **Step 2: Run the unit test to verify it fails**

  Run: `flutter test --no-pub test/prayer_service_test.dart`

  Expected: FAIL because the current helper returns `Kecamatan Kuta` first and accepts `Kuta` from `village`.

- [ ] **Step 3: Implement the filtered candidate list**

  Add a private helper:

  ```dart
  static bool _isKecamatan(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.startsWith('kecamatan ') || normalized.startsWith('kec. ');
  }
  ```

  Change `prayerAreaFromAddress()` to iterate only `county`, `city`,
  `municipality`, and `town`; return a non-empty candidate only when
  `_isKecamatan(value)` is false. Do not include `village` or `city_district`.

- [ ] **Step 4: Run the unit test to verify it passes**

  Run: `flutter test --no-pub test/prayer_service_test.dart`

  Expected: PASS. `Kabupaten Badung` wins after `Kecamatan Kuta` is filtered, and village-only data returns `null`.

- [ ] **Step 5: Run analyzer and commit the GPS fix**

  ```bash
  flutter analyze
  git add lib/services/prayer_service.dart test/prayer_service_test.dart
  git commit -m "fix: prefer kabupaten for GPS prayer area"
  ```

### Task 3: Verify the combined result

**Files:**
- Modify: none.

**Interfaces:**
- Consumes: the two commits from Tasks 1 and 2.
- Produces: a clean branch with the requested Profile order and GPS filtering intact.

- [ ] **Step 1: Run the focused regression suite**

  ```bash
  flutter test --no-pub test/profil_cosmetic_integration_test.dart test/profil_hero_card_test.dart test/profil_tab_golden_test.dart test/prayer_service_test.dart test/jadwal_tab_test.dart
  flutter analyze
  ```

  Expected: all focused tests pass and analyzer reports no issues.

- [ ] **Step 2: Inspect the final diff**

  ```bash
  git diff --check HEAD~2..HEAD
  git status --short
  ```

  Expected: no whitespace errors and no uncommitted source or generated test artifacts.

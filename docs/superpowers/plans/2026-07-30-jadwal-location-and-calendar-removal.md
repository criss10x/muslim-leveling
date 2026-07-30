# Jadwal Location and Calendar Removal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore current-location access on Android and simplify the Jadwal header by removing the calendar feature.

**Architecture:** `PrayerService` remains the single boundary for GPS, reverse geocoding, and city resolution. It returns the existing success location or a small typed failure enum so `JadwalTab` can display truthful feedback. The header composes the existing button styling into a 44dp icon action and one expanded city-search action.

**Tech Stack:** Flutter, Dart, `geolocator`, `flutter_test`, Android manifest.

## Global Constraints

- Add only `ACCESS_COARSE_LOCATION` and `ACCESS_FINE_LOCATION`; do not add packages.
- Keep the current 20-second position timeout and saved-city behavior.
- Keep the location action at least 44 by 44 dp in every theme.
- Remove the calendar button, its screen, and unused `hijri` dependency completely.
- Do not modify prayer calculations, schedule fetching, Qibla, or theme tokens.

---

### Task 1: Return actionable current-location failures

**Files:**
- Modify: `lib/services/prayer_service.dart:1-4,311-355`
- Modify: `lib/screens/jadwal_tab.dart:323-344`
- Modify: `android/app/src/main/AndroidManifest.xml:1-9`
- Test: `test/jadwal_tab_test.dart`

**Interfaces:**
- Consumes: `Geolocator.isLocationServiceEnabled`, `checkPermission`, `requestPermission`, and the existing reverse-geocode flow.
- Produces: `CurrentLocationFailure` and `getCurrentLocation(): Future<({String? id, String? name, CurrentLocationFailure? failure})>`.

- [x] **Step 1: Write the failing failure-copy test**

```dart
test('location failure messages identify the blocked step', () {
  expect(
    CurrentLocationFailure.permissionDenied.message,
    'Izinkan akses lokasi untuk menggunakan lokasi saat ini.',
  );
  expect(
    CurrentLocationFailure.serviceDisabled.message,
    'Aktifkan layanan lokasi perangkat, lalu coba lagi.',
  );
});
```

- [x] **Step 2: Run the test to verify it fails**

Run: `flutter test test/jadwal_tab_test.dart`

Expected: FAIL because `CurrentLocationFailure` does not exist.

- [x] **Step 3: Implement the smallest location-result boundary**

```dart
enum CurrentLocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  lookupFailed,
}

extension CurrentLocationFailureMessage on CurrentLocationFailure {
  String get message => switch (this) {
    CurrentLocationFailure.serviceDisabled =>
      'Aktifkan layanan lokasi perangkat, lalu coba lagi.',
    CurrentLocationFailure.permissionDenied =>
      'Izinkan akses lokasi untuk menggunakan lokasi saat ini.',
    CurrentLocationFailure.permissionDeniedForever =>
      'Izin lokasi diblokir. Buka Pengaturan untuk mengizinkannya.',
    CurrentLocationFailure.timeout =>
      'Lokasi terlalu lama ditemukan. Coba lagi di area terbuka.',
    CurrentLocationFailure.lookupFailed =>
      'Kota tidak dapat ditemukan. Periksa koneksi atau pilih kota manual.',
  };
}
```

In `getCurrentLocation`, check `isLocationServiceEnabled()` before permission; retain the permission returned from `requestPermission`; map timeout and all reverse-geocode failures to their matching enum. Update `_currentLocation` to show `result.failure!.message` or save `result.id!` and `result.name!`.

Add these Android declarations immediately below the existing network permission:

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

- [x] **Step 4: Run the test to verify it passes**

Run: `flutter test test/jadwal_tab_test.dart`

Expected: PASS.

### Task 2: Simplify the Jadwal header and remove calendar code

**Files:**
- Modify: `lib/screens/jadwal_tab.dart:1-8,235-266`
- Delete: `lib/screens/jadwal_kalender_screen.dart`
- Modify: `pubspec.yaml:30`
- Modify: `pubspec.lock` (via `flutter pub get`)
- Test: `test/jadwal_tab_test.dart`

**Interfaces:**
- Consumes: existing `_currentLocation`, `_changeLocation`, `PressableScale`, and semantic theme colors.
- Produces: an icon-only current-location action, an expanded city-search action, and no calendar route.

- [x] **Step 1: Write the failing Jadwal-header widget test**

```dart
expect(find.byIcon(Icons.my_location), findsOneWidget);
expect(find.text('Lokasi Saat Ini'), findsNothing);
expect(find.text('Cari Kota'), findsOneWidget);
expect(find.byIcon(Icons.calendar_month), findsNothing);
expect(find.text('Kalender'), findsNothing);
```

- [x] **Step 2: Run the test to verify it fails**

Run: `flutter test test/jadwal_tab_test.dart`

Expected: FAIL because the current header still renders location text and calendar.

- [x] **Step 3: Apply the minimal header and dependency removal**

```dart
Row(
  children: [
    _locationIconButton(onTap: _currentLocation),
    const SizedBox(width: AppSpacing.sm),
    Expanded(child: _locationButton(icon: Icons.search, label: 'Cari Kota', onTap: _changeLocation)),
  ],
)
```

Implement `_locationIconButton` with `SizedBox.square(dimension: 44)` and the existing surface, outline, primary icon, and `PressableScale` treatment. Remove the calendar import, button, `jadwal_kalender_screen.dart`, and `hijri` from `pubspec.yaml`, then run `flutter pub get`.

- [x] **Step 4: Run targeted tests to verify they pass**

Run: `flutter test test/jadwal_tab_test.dart`

Expected: PASS.

### Task 3: Validate and commit the final behavior

**Files:**
- Modify only formatter or lockfile output from Tasks 1-2.

**Interfaces:**
- Consumes: completed location result flow and compact header.
- Produces: a clean branch ready to update the existing draft PR.

- [x] **Step 1: Format and inspect the final diff**

Run: `dart format lib/services/prayer_service.dart lib/screens/jadwal_tab.dart test/jadwal_tab_test.dart`

Run: `git diff --check`

Expected: formatter succeeds and diff check has no output.

- [x] **Step 2: Run full validation**

Run: `flutter test`

Run: `flutter analyze`

Expected: all tests pass and analyzer reports `No issues found!`.

- [x] **Step 3: Commit implementation and plan**

```bash
git add android/app/src/main/AndroidManifest.xml lib/services/prayer_service.dart lib/screens/jadwal_tab.dart lib/screens/jadwal_kalender_screen.dart pubspec.yaml pubspec.lock test/jadwal_tab_test.dart
git commit -m "fix: restore current schedule location"
git add docs/superpowers/plans/2026-07-30-jadwal-location-and-calendar-removal.md
git commit -m "docs: add schedule location fix plan"
```

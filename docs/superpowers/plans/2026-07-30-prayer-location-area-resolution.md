# Prayer Location Area Resolution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure “Lokasi Saat Ini” resolves the kabupaten/kota supplied by reverse geocoding before a lower-level kecamatan or village.

**Architecture:** Add one small `PrayerService` helper that selects the first usable administrative area from Nominatim’s address map. `getCurrentLocation` uses that helper before its existing MyQuran lookup, cache, and failure paths.

**Tech Stack:** Flutter/Dart, `geolocator`, existing Nominatim and MyQuran HTTP calls, `flutter_test`.

## Global Constraints

- Change only `PrayerService` location-area selection and its focused regression test.
- Candidate order is `county`, `city`, `town`, then `village`.
- Keep existing APIs, UI, permissions, cache behavior, and error messages unchanged.
- Add no packages or abstractions.

---

### Task 1: Prefer kabupaten/kota for current-location schedules

**Files:**
- Create: `test/prayer_service_test.dart`
- Modify: `lib/services/prayer_service.dart:335-420`

**Interfaces:**
- Consumes: Nominatim `address` map (`Map<String, dynamic>?`).
- Produces: `PrayerService.prayerAreaFromAddress(Map<String, dynamic>? address) -> String?` for `getCurrentLocation` and tests.

- [ ] **Step 1: Write the failing regression tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/prayer_service.dart';

void main() {
  test('prayer area prefers county over a Bali kecamatan', () {
    expect(
      PrayerService.prayerAreaFromAddress({
        'county': 'Kabupaten Badung',
        'village': 'Kuta',
      }),
      'Kabupaten Badung',
    );
  });

  test('prayer area falls back through city, town, and village', () {
    expect(PrayerService.prayerAreaFromAddress({'city': 'Denpasar'}), 'Denpasar');
    expect(PrayerService.prayerAreaFromAddress({'town': 'Singaraja'}), 'Singaraja');
    expect(PrayerService.prayerAreaFromAddress({'village': 'Kuta'}), 'Kuta');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/prayer_service_test.dart`

Expected: FAIL because `PrayerService.prayerAreaFromAddress` does not exist yet.

- [ ] **Step 3: Add the minimal area selector and wire it into GPS resolution**

Add this static method above `getCurrentLocation`:

```dart
static String? prayerAreaFromAddress(Map<String, dynamic>? address) {
  for (final key in const ['county', 'city', 'town', 'village']) {
    final value = address?[key] as String?;
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}
```

Replace the inline address selection in `getCurrentLocation` with:

```dart
final rawCity = prayerAreaFromAddress(address);
```

Keep the existing null/empty failure return and all subsequent MyQuran lookup code unchanged.

- [ ] **Step 4: Run focused checks to verify the fix**

Run: `flutter test test/prayer_service_test.dart test/jadwal_tab_test.dart`

Expected: PASS; the new test proves `Kabupaten Badung` wins over `Kuta`.

Run: `flutter analyze`

Expected: `No issues found!`.

- [ ] **Step 5: Run the full suite and commit**

Run: `flutter test --no-pub`

Expected: all tests pass.

```bash
git add lib/services/prayer_service.dart test/prayer_service_test.dart
git commit -m "fix: prefer regency for current prayer location"
```

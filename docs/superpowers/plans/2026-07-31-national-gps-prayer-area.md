# National GPS Prayer Area Resolution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve every supported Indonesian GPS coordinate to an Equran kabupaten/kota name instead of saving a kecamatan such as Kuta Selatan.

**Architecture:** Keep reverse geocoding in `PrayerService`, but validate its administrative labels against `citiesForProvince()` before returning a location. A small pure matcher normalizes prefixes only for comparison and returns the exact Equran catalog value; the GPS flow caches the already-known province and fails safely when no catalog match exists.

**Tech Stack:** Dart, Flutter, `dart:io` `HttpClient`, Geolocator, SharedPreferences, Flutter Test.

## Global Constraints

- Apply this behavior to every Indonesian province supported by the app's existing Equran province catalog.
- Do not add dependencies or hardcoded kecamatan-to-kabupaten mappings.
- Do not change manual province/city selection or typed MyQuran search.
- Never persist an unmatched raw reverse-geocoder label.
- Keep async failure handling inside the existing `lookupFailed` path.
- Run `flutter analyze` after editing Dart code.

---

### Task 1: Validate GPS address labels against the Equran catalog

**Files:**
- Modify: `lib/services/prayer_service.dart:389-489`
- Test: `test/prayer_service_test.dart:1-49`

**Interfaces:**
- Consumes: `PrayerService.citiesForProvince(String province)` and the existing `_extractProvinsi(String city)` province aliases.
- Produces: `PrayerService.prayerAreaFromAddress(Map<String, dynamic>? address, List<String> validAreas) -> String?`, returning the exact entry from `validAreas`.
- Preserves: `PrayerService.getCurrentLocation() -> Future<({String? id, String? name, CurrentLocationFailure? failure})>`.

- [ ] **Step 1: Replace the old heuristic tests with failing catalog-validation tests**

Update `test/prayer_service_test.dart` so every call supplies the API catalog it expects the address to match:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/prayer_service.dart';

void main() {
  const baliAreas = [
    'Kab. Badung',
    'Kab. Bangli',
    'Kab. Buleleng',
    'Kota Denpasar',
  ];

  test('prayer area maps South Kuta address to the Badung API area', () {
    expect(
      PrayerService.prayerAreaFromAddress(
        {
          'town': 'Kuta Selatan',
          'region': 'Badung',
          'state': 'Bali',
        },
        baliAreas,
      ),
      'Kab. Badung',
    );
  });

  test('prayer area maps a city label to the exact API city name', () {
    expect(
      PrayerService.prayerAreaFromAddress(
        {'city': 'Denpasar'},
        baliAreas,
      ),
      'Kota Denpasar',
    );
  });

  test('prayer area normalizes case and kabupaten prefix', () {
    expect(
      PrayerService.prayerAreaFromAddress(
        {'county': 'KABUPATEN BADUNG'},
        baliAreas,
      ),
      'Kab. Badung',
    );
  });

  test('prayer area rejects unmatched lower administrative areas', () {
    expect(
      PrayerService.prayerAreaFromAddress(
        {'town': 'Kuta Selatan', 'village': 'Jimbaran'},
        baliAreas,
      ),
      isNull,
    );
  });

  test('province catalog includes Bali and all Equran provinces', () {
    expect(PrayerService.provinces, contains('Bali'));
    expect(PrayerService.provinces, hasLength(34));
  });
}
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```powershell
flutter test --no-pub test/prayer_service_test.dart -r compact
```

Expected: compilation fails because `prayerAreaFromAddress` does not yet accept `validAreas`, proving the new contract is not implemented.

- [ ] **Step 3: Implement the minimal pure catalog matcher**

In `lib/services/prayer_service.dart`, replace `_isKecamatan` and the current `prayerAreaFromAddress` with:

```dart
static String _normalizedAreaName(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceFirst(RegExp(r'^(kabupaten|kab\.?|kota)\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

static String? prayerAreaFromAddress(
  Map<String, dynamic>? address,
  List<String> validAreas,
) {
  for (final key in const [
    'county',
    'region',
    'state_district',
    'city',
    'municipality',
    'town',
  ]) {
    final value = address?[key] as String?;
    if (value == null || value.trim().isEmpty) continue;
    final candidate = _normalizedAreaName(value);
    for (final area in validAreas) {
      if (_normalizedAreaName(area) == candidate) return area.trim();
    }
  }
  return null;
}
```

This returns `Kab. Badung` for `region: Badung`, but never returns `Kuta Selatan` because it is absent from `validAreas`.

- [ ] **Step 4: Run the focused test and verify GREEN**

Run:

```powershell
flutter test --no-pub test/prayer_service_test.dart -r compact
```

Expected: all tests in `prayer_service_test.dart` pass.

- [ ] **Step 5: Integrate the matcher into the GPS flow**

In `getCurrentLocation()`, replace the raw-area/MyQuran lookup block beginning at `final rawCity = ...` with:

```dart
final state = address?['state'] as String? ?? '';
final province = _extractProvinsi(state);
if (province.isEmpty) {
  return (
    id: null,
    name: null,
    failure: CurrentLocationFailure.lookupFailed,
  );
}

final validAreas = await citiesForProvince(province);
final area = prayerAreaFromAddress(address, validAreas);
if (area == null) {
  return (
    id: null,
    name: null,
    failure: CurrentLocationFailure.lookupFailed,
  );
}

final areaKey = area.toLowerCase().trim();
_provCache[areaKey] = province;
final prefs = await SharedPreferences.getInstance();
await prefs.setString('prov_$areaKey', province);
return (id: area, name: area, failure: null);
```

Delete the GPS-only `searchCities(rawCity)` call and the unsafe `(id: rawCity, name: rawCity)` fallback. Keep `searchCities()` itself unchanged because manual typed search still uses it.

- [ ] **Step 6: Format and verify static analysis**

Run:

```powershell
dart format lib/services/prayer_service.dart test/prayer_service_test.dart
flutter analyze
```

Expected: formatting completes and analyzer exits with no errors.

- [ ] **Step 7: Run focused and full regression tests**

Run:

```powershell
flutter test --no-pub test/prayer_service_test.dart test/jadwal_tab_test.dart -r compact
flutter test --no-pub -r compact
```

Expected: the focused prayer/Jadwal tests pass, followed by the complete suite.

- [ ] **Step 8: Commit the implementation**

```powershell
git add -- lib/services/prayer_service.dart test/prayer_service_test.dart
git commit -m "fix: validate GPS prayer areas nationally"
```

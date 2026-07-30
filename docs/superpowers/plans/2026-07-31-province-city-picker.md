# Province-First City Picker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the ambiguous manual city search with a province-first, locally filterable kabupaten/kota picker.

**Architecture:** `PrayerService` exposes the existing province catalog and fetches a province’s Equran kabupaten/kota list. The existing shared `CityPicker` remains one dialog but switches from a locally filtered province stage to a locally filtered city stage, returning the same location record consumed by Jadwal, onboarding, and Profil.

**Tech Stack:** Flutter/Dart, existing `HttpClient`, Equran `kabkota` endpoint, `flutter_test`.

## Global Constraints

- Change only `PrayerService`, shared `CityPicker`, and focused service/widget tests.
- Province stage contains the existing 34 Equran province names and filters locally.
- City stage loads only the selected province’s Equran kabupaten/kota, filters locally, and has a back action.
- Keep GPS, permissions, theme tokens, dependencies, schedule calculations, and outside-picker labels unchanged.
- Return `{id, name}`; use a stable local ID based on selected province and city for cache scoping.

---

### Task 1: Add the province-first manual location flow

**Files:**
- Modify: `lib/services/prayer_service.dart:40-70,230-250`
- Modify: `lib/widgets/city_picker.dart:7-104`
- Modify: `test/prayer_service_test.dart`
- Create: `test/city_picker_test.dart`

**Interfaces:**
- Produces: `PrayerService.provinces` (`List<String>`) and `PrayerService.citiesForProvince(String)` (`Future<List<String>>`).
- Extends: `CityPicker.show(BuildContext, {Future<List<String>> Function(String province)? cityLoader})` while existing callers continue using `CityPicker.show(context)`.
- Returns: existing `({String id, String name})?` selection.

- [ ] **Step 1: Write the failing service and widget tests**

Add to `test/prayer_service_test.dart`:

```dart
test('province catalog includes Bali and all Equran provinces', () {
  expect(PrayerService.provinces, contains('Bali'));
  expect(PrayerService.provinces, hasLength(34));
});
```

Create `test/city_picker_test.dart` with a dialog host and this behavior test:

```dart
testWidgets('picker requires province before filtering kabupaten kota', (tester) async {
  late Future<({String id, String name})?> selection;
  await tester.pumpWidget(MaterialApp(
    home: Builder(builder: (context) => TextButton(
      onPressed: () {
        selection = CityPicker.show(
          context,
          cityLoader: (_) async => ['Kab. Badung', 'Kota Denpasar'],
        );
      },
      child: const Text('Buka'),
    )),
  ));

  await tester.tap(find.text('Buka'));
  await tester.pumpAndSettle();
  expect(find.text('Pilih Provinsi'), findsOneWidget);
  expect(find.text('Pilih Kabupaten/Kota'), findsNothing);

  await tester.enterText(find.byType(TextField), 'bali');
  await tester.pump();
  await tester.tap(find.text('Bali'));
  await tester.pumpAndSettle();
  expect(find.text('Pilih Kabupaten/Kota'), findsOneWidget);

  await tester.enterText(find.byType(TextField), 'badung');
  await tester.pump();
  await tester.tap(find.text('Kab. Badung'));
  expect(await selection, (id: 'Bali/Kab. Badung', name: 'Kab. Badung'));
});
```

- [ ] **Step 2: Run tests to verify RED**

Run: `flutter test test/prayer_service_test.dart test/city_picker_test.dart`

Expected: FAIL because `PrayerService.provinces` and the `cityLoader` argument do not exist, and the picker still opens on city search.

- [ ] **Step 3: Add minimal province/city service methods**

Expose the existing Equran province list without copying it:

```dart
static List<String> get provinces => _equranProvinsi;
```

Add the shared Equran loader and use it from `_cityInProvinsi` to avoid duplicate endpoint parsing:

```dart
static Future<List<String>> citiesForProvince(String province) async {
  if (province.trim().isEmpty) return const [];
  try {
    final req = await _discoveryClient.postUrl(Uri.parse('$_equranBase/kabkota'));
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode({'provinsi': province}));
    final res = await req.close();
    if (res.statusCode != 200) return const [];
    final json = jsonDecode(await res.transform(utf8.decoder).join()) as Map<String, dynamic>;
    return (json['data'] as List?)?.whereType<String>().toList() ?? const [];
  } catch (_) {
    return const [];
  }
}
```

- [ ] **Step 4: Replace the city dialog with two local-filter stages**

Keep `CityPicker.show` and its return type. Add the optional `cityLoader` callback, defaulting to `PrayerService.citiesForProvince`. Start with `selectedProvince == null`, title `Pilih Provinsi`, and `PrayerService.provinces` filtered case-insensitively by the typed query. On a province tap, clear the query, load cities through `cityLoader`, then show title `Pilih Kabupaten/Kota`, a back icon that resets to province stage, and the selected province label. Filter the loaded city list case-insensitively as the user types.

While city data loads, show the existing themed `CircularProgressIndicator`; on an empty response, show `Kabupaten/kota tidak ditemukan. Coba pilih provinsi lain.` and retain the back icon. On city tap, return:

```dart
(id: '$selectedProvince/$cityName', name: cityName)
```

Do not retain the old global MyQuran text search or add a new page route.

- [ ] **Step 5: Run GREEN verification and commit**

Run: `flutter test test/prayer_service_test.dart test/city_picker_test.dart test/jadwal_tab_test.dart`

Expected: PASS; the dialog opens on provinces, then filters selected-province cities and returns the stable value.

Run: `flutter analyze`

Expected: `No issues found!`.

Run: `flutter test --no-pub`

Expected: all tests pass.

```bash
git add lib/services/prayer_service.dart lib/widgets/city_picker.dart test/prayer_service_test.dart test/city_picker_test.dart
git commit -m "feat: add province-first city picker"
```

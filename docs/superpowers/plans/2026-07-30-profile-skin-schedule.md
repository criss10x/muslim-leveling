# Profile Skin and Prayer Schedule Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove selectable profile frames and its profile-location control, while making the next-prayer name legible in the light theme.

**Architecture:** `CosmeticCatalog` keeps only the circular fallback, `CosmeticLocker` exposes an explicit Aura/Title list, and `ProfilTab` passes the fallback directly. `JadwalTab` gives the next-prayer name `AppColors.onSurface`.

**Tech Stack:** Flutter, Dart, flutter_test, SharedPreferences test mocks.

## Global Constraints

- Do not add dependencies or a new theme system.
- Preserve saved location preferences and location editing in the schedule tab.
- Legacy saved frame ids must render as the circular fallback in the profile hero.
- Keep the existing dark-theme treatment readable.

---

### Task 1: Retire selectable frame cosmetics and the locker tab

**Files:**
- Modify: `lib/services/cosmetic_catalog.dart:73-102`
- Modify: `lib/widgets/cosmetic_locker.dart:8-28,105-117`
- Modify: `test/cosmetic_catalog_test.dart:35-39`
- Modify: `test/cosmetic_locker_test.dart:76-99`
- Modify: `test/cosmetic_service_test.dart:28-47`

**Interfaces:**
- Consumes: `CosmeticCatalog.bySlot(CosmeticSlot.frame)` and `CosmeticService.resolveSlot`.
- Produces: a catalog whose frame slot contains only `frame_default`, plus a locker with Aura and Title as its visible slots.

- [ ] **Step 1: Write failing catalog and locker tests**

```dart
test('frame slot keeps only the circular default', () {
  final frames = CosmeticCatalog.bySlot(CosmeticSlot.frame);
  expect(frames.map((c) => c.id), ['frame_default']);
  expect(frames.single.frameShape, FrameShape.circle);
  expect(CosmeticCatalog.byId('shield_classic'), isNull);
});

testWidgets('locker offers Aura and Title without a frame tab', (tester) async {
  await GameService.load();
  await EntitlementService.load();
  await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CosmeticLocker())));
  await tester.pumpAndSettle();

  expect(find.text('Aura'), findsOneWidget);
  expect(find.text('Title'), findsOneWidget);
  expect(find.text('Bingkai'), findsNothing);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/cosmetic_catalog_test.dart test/cosmetic_locker_test.dart`

Expected: FAIL because the catalog retains `shield_classic` and the locker renders `Bingkai`.

- [ ] **Step 3: Make the minimal catalog and locker change**

```dart
// cosmetic_locker.dart
const _visibleSlots = [CosmeticSlot.aura, CosmeticSlot.title];
CosmeticSlot _slot = CosmeticSlot.aura;
// Build the selector from _visibleSlots and compare trailing padding to _visibleSlots.last.
```

Delete the `frame_subuh` and `shield_classic` records while retaining the `frame_default` circular fallback.

- [ ] **Step 4: Test the legacy fallback and green suite**

```dart
test('retired saved frames resolve to the circular default', () {
  final state = GameState(equipped: const {'frame': 'shield_classic'});
  expect(
    CosmeticService.resolveSlot(state, CosmeticSlot.frame, isPro: true),
    'frame_default',
  );
});
```

Run: `flutter test test/cosmetic_catalog_test.dart test/cosmetic_locker_test.dart test/cosmetic_service_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/services/cosmetic_catalog.dart lib/widgets/cosmetic_locker.dart test/cosmetic_catalog_test.dart test/cosmetic_locker_test.dart test/cosmetic_service_test.dart
git commit -m "feat: retire selectable profile frames"
```

### Task 2: Simplify the profile hero

**Files:**
- Modify: `lib/screens/profil_tab.dart:1-145,804-884,1061-1110`
- Modify: `test/profil_hero_card_test.dart:1-105`
- Modify: `test/tier_avatar_frame_test.dart:87-157`

**Interfaces:**
- Consumes: `TierProfileAvatar.equippedFrameId` and `PrayerService` only for notification scheduling.
- Produces: a profile hero that always passes `'frame_default'` and has no location control or profile-owned location state.

- [ ] **Step 1: Write a failing hero test**

```dart
testWidgets('hero uses the circular fallback and omits location', (tester) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences.setMockInitialValues({
    'nickname': 'Pejuang',
    'onboarding_done': true,
    'game_state_v1': '{"xp":0,"level":1,"equipped":{"frame":"shield_classic"}}',
    'city_id': '1301',
    'city_name': 'Jakarta',
  });

  await tester.pumpWidget(MaterialApp(theme: AppTheme.dark(), home: const Scaffold(body: ProfilTab())));
  await tester.pump(const Duration(milliseconds: 300));

  expect(find.text('LOKASI'), findsNothing);
  expect(find.text('Jakarta'), findsNothing);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/profil_hero_card_test.dart`

Expected: FAIL because the hero displays its editable location row.

- [ ] **Step 3: Make the minimal profile change**

```dart
// Remove _cityName, _cityId, the CityPicker import, and _editLocation.
// Keep PrayerService because notification scheduling still reads it.
TierProfileAvatar(
  // existing profile, tier, size, and aura arguments
  equippedFrameId: 'frame_default',
)
```

Remove the location load and assignment from `_loadProfile`, and remove the divider and location `InkWell` from `_hero`.

- [ ] **Step 4: Verify the profile suite**

Run: `flutter test test/profil_hero_card_test.dart test/tier_avatar_frame_test.dart`

Expected: PASS after replacing retired-frame test inputs with circular-default assertions.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/profil_tab.dart test/profil_hero_card_test.dart test/tier_avatar_frame_test.dart
git commit -m "feat: simplify profile hero cosmetics"
```

### Task 3: Give the next-prayer name an explicit semantic foreground

**Files:**
- Modify: `lib/screens/jadwal_tab.dart:416-420`
- Create: `test/jadwal_tab_test.dart`

**Interfaces:**
- Consumes: `AppColors.onSurface` selected by the active theme preset.
- Produces: an explicitly styled next-prayer name in `_nextPrayerCard`.

- [ ] **Step 1: Write the failing light-theme widget test**

```dart
testWidgets('next-prayer name uses light-theme foreground', (tester) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  activeThemePreset = AppThemePreset.lightEmerald;
  SharedPreferences.setMockInitialValues({});

  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const JadwalTab()));
  await tester.pumpAndSettle();

  expect(tester.widget<Text>(find.text('—')).style?.color, AppColors.onSurface);
});
```

Reset `activeThemePreset` to `AppThemePreset.darkEmerald` in `tearDown`.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/jadwal_tab_test.dart`

Expected: FAIL because `Text(next.name, style: AppText.headlineLg())` has no colour.

- [ ] **Step 3: Add the semantic foreground**

```dart
Text(
  next.name,
  style: AppText.headlineLg().copyWith(color: AppColors.onSurface),
)
```

- [ ] **Step 4: Verify the schedule test**

Run: `flutter test test/jadwal_tab_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/jadwal_tab.dart test/jadwal_tab_test.dart
git commit -m "fix: keep next prayer readable in light theme"
```

### Task 4: Format and verify the complete branch

**Files:**
- Modify only files changed by Tasks 1-3 if formatter output requires it.

**Interfaces:**
- Consumes: all focused tests from Tasks 1-3.
- Produces: a formatted branch with no analyzer diagnostics.

- [ ] **Step 1: Format changed Dart files**

Run: `dart format lib/services/cosmetic_catalog.dart lib/widgets/cosmetic_locker.dart lib/screens/profil_tab.dart lib/screens/jadwal_tab.dart test/cosmetic_catalog_test.dart test/cosmetic_locker_test.dart test/cosmetic_service_test.dart test/profil_hero_card_test.dart test/tier_avatar_frame_test.dart test/jadwal_tab_test.dart`

Expected: formatter completes without errors.

- [ ] **Step 2: Run focused regression tests**

Run: `flutter test test/cosmetic_catalog_test.dart test/cosmetic_locker_test.dart test/cosmetic_service_test.dart test/profil_hero_card_test.dart test/tier_avatar_frame_test.dart test/jadwal_tab_test.dart`

Expected: PASS.

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze`

Expected: `No issues found!`.

- [ ] **Step 4: Commit formatting only if it changed files**

```bash
git add lib/services/cosmetic_catalog.dart lib/widgets/cosmetic_locker.dart lib/screens/profil_tab.dart lib/screens/jadwal_tab.dart test
git commit -m "style: format profile and schedule changes"
```


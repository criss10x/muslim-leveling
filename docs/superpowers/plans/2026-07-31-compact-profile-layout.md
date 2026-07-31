# Compact Profile Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Place Statistik directly below the profile hero and turn the wide Loker Skin section into a compact outlined action that opens the existing locker in a bottom sheet.

**Architecture:** Keep all cosmetic state inside `CosmeticLocker` and present that existing widget from a modal bottom sheet. `ProfilTab` only changes section order and its own composition; no services, theme tokens, or cosmetic catalog data change.

**Tech Stack:** Flutter, Material bottom sheet, flutter_test, existing app theme tokens.

## Global Constraints

- Change layout only: preserve existing Indonesian labels, statistics data, theme presets, colors, and cosmetic persistence.
- Use `AppColors`, `AppText`, `AppSpacing`, and `AppRadius`; do not add a dependency or a new state-management layer.
- Keep mobile touch targets at least 44 logical pixels high.
- Run `flutter analyze` after every implementation change; do not build an APK.

---

## File Structure

- Modify `lib/screens/profil_tab.dart`: reorder sections, expose a compact locker action, and present `CosmeticLocker` in a bottom sheet.
- Modify `test/profil_cosmetic_integration_test.dart`: assert the new placement and the compact action's modal interaction.
- Modify `test/goldens/profil_tab_phone.png`: accept the intentionally changed phone layout after the widget test passes.

### Task 1: Define the compact locker interaction

**Files:**
- Modify: `test/profil_cosmetic_integration_test.dart:15-53`
- Modify: `lib/screens/profil_tab.dart:751-765,1095-1106`

**Interfaces:**
- Consumes: `CosmeticLocker` from `lib/widgets/cosmetic_locker.dart`.
- Produces: a `Semantics` button labelled `Buka loker skin` in `ProfilTab`; tapping it presents one `CosmeticLocker` in a bottom sheet.

- [ ] **Step 1: Write the failing widget test**

  Replace the initial-render assertion that scrolls until `CosmeticLocker` is visible with this behavior test:

  ```dart
  testWidgets('Profil keeps skin locker compact and opens it on demand', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await GameService.load();
    await EntitlementService.load();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ProfilTab())));
    await tester.pumpAndSettle();

    final locker = find.bySemanticsLabel('Buka loker skin');
    expect(locker, findsOneWidget);
    expect(tester.getSize(locker).height, greaterThanOrEqualTo(44));
    final hero = find.bySemanticsLabel('Profile hero — Warrior');
    final stats = find.text('STATISTIK');
    expect(tester.getTopLeft(stats).dy, greaterThan(tester.getBottomRight(hero).dy));
    expect(tester.getTopLeft(locker).dy, greaterThan(tester.getBottomRight(stats).dy));
    expect(find.byType(CosmeticLocker), findsNothing);

    await tester.tap(locker);
    await tester.pumpAndSettle();
    expect(find.byType(CosmeticLocker), findsOneWidget);
  });
  ```

- [ ] **Step 2: Run the focused test to verify it fails**

  Run: `flutter test --no-pub test/profil_cosmetic_integration_test.dart`

  Expected: FAIL because no widget has the semantic label `Buka loker skin`,
  the locker is still embedded in the page, and Statistik is after it.

- [ ] **Step 3: Implement the minimal layout change**

  In the `ListView`, move `_stats()` before `_cosmeticLocker()`:

  ```dart
  _hero(context),
  const SizedBox(height: AppSpacing.md),
  _stats(),
  const SizedBox(height: AppSpacing.md),
  _cosmeticLocker(),
  ```

  Replace `_cosmeticLocker()` with a 44-pixel-minimum `Semantics` + `InkWell` outlined row using `Icons.inventory_2_outlined`, `AppColors.outlineVariant`, `AppColors.primary`, `AppSpacing.sm`, and `AppRadius.lg`. Its tap handler calls `showModalBottomSheet<void>` with `isScrollControlled: true`; the sheet contains a `SafeArea`, `SingleChildScrollView`, and the unchanged `const CosmeticLocker()`.

- [ ] **Step 4: Run the focused test to verify it passes**

  Run: `flutter test --no-pub test/profil_cosmetic_integration_test.dart`

  Expected: PASS. The locker is absent from the initial page, the compact action meets the touch-target rule, and tapping it shows the existing locker.

- [ ] **Step 5: Commit the tested interaction**

  ```bash
  git add lib/screens/profil_tab.dart test/profil_cosmetic_integration_test.dart
  git commit -m "feat: compact profile skin locker"
  ```

### Task 2: Refresh visual regression coverage

**Files:**
- Modify: `test/goldens/profil_tab_phone.png`

**Interfaces:**
- Consumes: the layout and behavior assertion in `test/profil_cosmetic_integration_test.dart` from Task 1.
- Produces: a golden baseline for the 412-by-915 dark profile page.

- [ ] **Step 1: Run the existing golden test after the layout change**

  Run: `flutter test --no-pub test/profil_tab_golden_test.dart`

  Expected: FAIL only because `test/goldens/profil_tab_phone.png` depicts the old embedded locker layout.

- [ ] **Step 2: Refresh and re-run the golden baseline**

  Run:

  ```bash
  flutter test --no-pub test/profil_tab_golden_test.dart --update-goldens
  flutter test --no-pub test/profil_tab_golden_test.dart
  ```

  Expected: PASS with the new compact layout baseline.

- [ ] **Step 3: Run final verification and commit the regression baseline**

  ```bash
  flutter analyze
  flutter test --no-pub test/profil_cosmetic_integration_test.dart test/profil_hero_card_test.dart test/profil_tab_golden_test.dart
  git add test/profil_cosmetic_integration_test.dart test/goldens/profil_tab_phone.png
  git commit -m "test: cover compact profile layout"
  ```

  Expected: analyzer reports no issues and all focused tests pass.

# Cosmetic Locker Visual Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Loker Skin a clear collection surface with equipped, Pro, and progression states, without changing cosmetic business rules.

**Architecture:** Keep all changes in `CosmeticLocker`. Derive UI state from `GameService.current`, `CosmeticCatalog`, and `CosmeticService`; reuse `GameService.unequipCosmetic` rather than changing storage, routes, or catalog data.

**Tech Stack:** Flutter/Dart, Material 3, `flutter_test`, and current app theme tokens.

## Global Constraints

- Do not change XP, quests, streaks, ownership, Pro rules, catalog, persistence, or routes.
- Retain the existing three-column non-scrollable grid and Profile integration.
- Preserve Pro-to-paywall and free-item equip behavior.
- Show the quest explanation only when the selected slot has no earned free item beyond its default.
- Use Indonesian copy, existing theme tokens, semantic 44dp targets, no new dependencies or assets.

---

### Task 1: Define the new behavior with failing widget tests

**Files:**
- Modify: `test/cosmetic_locker_test.dart`
- Read: `lib/widgets/cosmetic_locker.dart`

**Interfaces:**
- Consumes: `GameService`, `EntitlementService`, `CosmeticSlot`, and `CosmeticLocker`.
- Produces: Regression coverage for the progression hint and equipped-item toggle.

- [ ] **Step 1: Add the failing empty-slot test**

```dart
testWidgets('empty free slot explains how to unlock cosmetics', (tester) async {
  await GameService.load();
  await EntitlementService.load();
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: CosmeticLocker())),
  );
  await tester.pumpAndSettle();

  expect(
    find.text('Selesaikan quest harian untuk membuka skin dari Daily Chest.'),
    findsOneWidget,
  );
});
```

- [ ] **Step 2: Verify RED**

Run: `flutter test test/cosmetic_locker_test.dart --plain-name "empty free slot explains how to unlock cosmetics"`

Expected: failure because the progression panel does not exist.

- [ ] **Step 3: Add the failing equipped-item toggle test**

```dart
testWidgets('tapping an equipped free cosmetic unequips it', (tester) async {
  await GameService.load();
  await EntitlementService.load();
  await GameService.debugSeedOwned(['title_crescent']);
  await GameService.equipCosmetic(
    CosmeticSlot.title,
    'title_crescent',
    isPro: false,
  );

  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: CosmeticLocker())),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gelar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Bulan Sabit Menyala'));
  await tester.pumpAndSettle();

  expect(GameService.current.equipped.containsKey('title'), isFalse);
});
```

- [ ] **Step 4: Verify RED**

Run: `flutter test test/cosmetic_locker_test.dart --plain-name "tapping an equipped free cosmetic unequips it"`

Expected: failure because the current handler always equips.

### Task 2: Implement collection hierarchy and card states

**Files:**
- Modify: `lib/widgets/cosmetic_locker.dart:21-115`
- Test: `test/cosmetic_locker_test.dart`

**Interfaces:**
- Consumes: `CosmeticCatalog.bySlot`, `CosmeticCatalog.isDefault`, `CosmeticService.isAllowed`, `CosmeticService.resolveSlot`, and `GameService.unequipCosmetic`.
- Produces: The same public `CosmeticLocker` widget with compact collection metadata, semantic item states, and toggle-to-unequip.

- [ ] **Step 1: Derive active-slot collection state in `build`**

```dart
final unlockedFree = CosmeticCatalog.bySlot(_slot)
    .where((c) =>
        c.access == CosmeticAccess.free &&
        CosmeticService.isAllowed(state, c.id, isPro: isPro))
    .toList();
final hasEarnedFree = unlockedFree.any(
  (c) => !CosmeticCatalog.isDefault(c.id),
);
```

- [ ] **Step 2: Toggle an equipped allowed item**

After the existing non-Pro gate in `_onTap`, resolve the effective item and
unequip it when it is tapped again:

```dart
final equippedId = CosmeticService.resolveSlot(
  GameService.current,
  c.slot,
  isPro: isPro,
);
if (c.id == equippedId &&
    CosmeticService.isAllowed(GameService.current, c.id, isPro: isPro)) {
  await GameService.unequipCosmetic(c.slot);
  return;
}
```

- [ ] **Step 3: Replace `ChoiceChip` tabs with equal-width semantic segments**

Each `CosmeticSlot` uses `Expanded > Semantics > InkWell > Container`. The
container has `minHeight: 44`, `surfaceContainerHigh` when selected, and an
`outlineVariant` border when inactive:

```dart
Semantics(
  button: true,
  selected: sel,
  label: _slotLabels[s]!,
  child: InkWell(
    onTap: () => setState(() => _slot = s),
    borderRadius: BorderRadius.circular(AppRadius.md),
    child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: sel ? AppColors.surfaceContainerHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: sel ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
      child: Text(_slotLabels[s]!, style: AppText.labelCapsSm()),
    ),
  ),
)
```

- [ ] **Step 4: Add metadata, state labels, and semantics**

Below the segments add `KOLEKSI` and `${unlockedFree.length} TERBUKA` with
`AppText.labelCapsSm`. Each grid cell keeps its emoji/name but displays
`DIPAKAI` when selected or `PRO` when locked. Use a primary border for selected,
gold ink for locked, neutral colors otherwise, and wrap every item in:

```dart
Semantics(
  button: true,
  selected: selected,
  label: '${c.name}, ${selected ? 'dipakai' : locked ? 'Pro terkunci' : 'tersedia'}',
  child: InkWell(
    onTap: () => _onTap(c),
    borderRadius: BorderRadius.circular(AppRadius.lg),
    child: Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(AppSpacing.sm),
    ),
  ),
)
```

- [ ] **Step 5: Add the contextual progression panel**

After the grid, render this only when `!hasEarnedFree`:

```dart
if (!hasEarnedFree) ...[
  const SizedBox(height: AppSpacing.md),
  Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
    ),
    child: Row(
      children: [
        Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Selesaikan quest harian untuk membuka skin dari Daily Chest.',
            style: AppText.bodyMd().copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  ),
]
```

- [ ] **Step 6: Verify GREEN and commit**

Run: `flutter test test/cosmetic_locker_test.dart`

Expected: the original equip test and the new progression/toggle tests pass.

Run: `git add lib/widgets/cosmetic_locker.dart test/cosmetic_locker_test.dart; git commit -m "feat(cosmetics): polish locker collection states"`

### Task 3: Verify Profile integration and final scope

**Files:**
- Read: `test/profil_cosmetic_integration_test.dart`
- Read: `test/profil_tab_golden_test.dart`

**Interfaces:**
- Consumes: `CosmeticLocker` already mounted by `ProfilTab`.
- Produces: integration evidence and a scoped final diff.

- [ ] **Step 1: Run Profile checks**

Run: `flutter test test/profil_cosmetic_integration_test.dart test/profil_tab_golden_test.dart`

Expected: both pass. Update a golden only after visually checking the intended
layout change.

- [ ] **Step 2: Run all checks**

Run: `flutter test` and `flutter analyze`

Expected: no failures or new analyzer diagnostics.

- [ ] **Step 3: Inspect scope**

Run: `git diff --check; git status --short; git diff --stat; git diff -- lib/widgets/cosmetic_locker.dart test/cosmetic_locker_test.dart`

Expected: only the approved spec/plan, locker widget, and focused test change.

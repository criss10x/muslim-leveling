# Compact Profile Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce the profile page's skin-locker and statistics footprint on phone screens.

**Architecture:** Keep the existing `CosmeticLocker`, `FlatCard`, and statistics grid. Adjust only their established padding, aspect-ratio, and spacing values; no new widget or dependency is required.

**Tech Stack:** Flutter, Dart, flutter_test golden testing.

## Global Constraints

- Keep skin controls at least 44dp high.
- Do not change cosmetic behavior, statistics data, color roles, or typography outside compact card spacing.
- Update the profile golden to document the approved mobile layout.

---

### Task 1: Compact the locker and statistics layout

**Files:**
- Modify: `lib/screens/profil_tab.dart:761-765,1095-1103,1158-1165,1208-1230`
- Modify: `lib/widgets/cosmetic_locker.dart:179-186`
- Test: `test/profil_tab_golden_test.dart`

**Interfaces:**
- Consumes: `AppSpacing`, `FlatCard`, and `CosmeticLocker`.
- Produces: the same profile content with shorter collection tiles, bento cards, and section gaps.

- [x] **Step 1: Update the failing golden snapshot expectation**

Run: `flutter test test/profil_tab_golden_test.dart`

Expected: FAIL because the current reference image has the larger locker and statistics layout.

- [x] **Step 2: Apply the minimal layout values**

```dart
// profil_tab.dart list spacing
const SizedBox(height: AppSpacing.md), // hero → locker
const SizedBox(height: AppSpacing.md), // locker → statistics
const SizedBox(height: AppSpacing.xs), // statistics → next section

// locker shell and statistics grid
padding: const EdgeInsets.all(AppSpacing.sm),
childAspectRatio: 1.8,

// cosmetic_locker.dart collection grid
childAspectRatio: 0.8,
```

Set `_statCard` to `FlatCard(padding: const EdgeInsets.all(AppSpacing.sm), ...)` and change its label-to-value spacer from `AppSpacing.sm` to `AppSpacing.xs`.

- [x] **Step 3: Regenerate and verify the profile golden**

Run: `flutter test --update-goldens test/profil_tab_golden_test.dart`

Then run: `flutter test test/profil_tab_golden_test.dart test/profil_hero_card_test.dart test/cosmetic_locker_test.dart`

Expected: PASS.

- [x] **Step 4: Commit**

```bash
git add lib/screens/profil_tab.dart lib/widgets/cosmetic_locker.dart test/goldens/profil_tab_phone.png
git commit -m "style: compact profile locker and statistics"
```

### Task 2: Verify the complete branch

**Files:**
- Modify only formatter output from Task 1.

**Interfaces:**
- Consumes: the compact profile layout.
- Produces: a branch with no regression or analyzer diagnostic.

- [x] **Step 1: Format modified Dart files**

Run: `dart format lib/screens/profil_tab.dart lib/widgets/cosmetic_locker.dart`

Expected: formatter succeeds.

- [x] **Step 2: Run project verification**

Run: `flutter test`

Run: `flutter analyze`

Expected: all tests pass and analyzer reports `No issues found!`.

- [x] **Step 3: Commit formatter output if required**

```bash
git add lib/screens/profil_tab.dart lib/widgets/cosmetic_locker.dart
git commit -m "style: format compact profile layout"
```

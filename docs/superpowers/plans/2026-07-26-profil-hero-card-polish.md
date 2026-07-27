# Profil Hero Card Visual Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve the `ProfilTab` hero card's hierarchy, spacing, responsive behavior, and accessibility in both dark and light themes without changing profile behavior or data.

**Architecture:** Keep the existing `_hero` composition in `lib/screens/profil_tab.dart` and reuse the current avatar, theme, typography, radius, spacing, and card primitives. Add one focused widget test for the edit affordance's accessible touch target/tooltip; keep pixel-level validation in the existing golden test when Flutter is available.

**Tech Stack:** Flutter/Dart, Material 3, `flutter_test`, existing `AppColors`, `AppText`, `AppRadius`, and `AppSpacing` tokens.

## Global Constraints

- No new profile data, persistence, navigation, assets, or dependencies.
- Preserve existing tap behavior for edit profile and edit location.
- Support the existing 412×915 viewport and narrower phone widths.
- Nicknames, equipped titles, rank titles, city names, and stat values must not overflow horizontally.
- Use existing theme tokens for both dark and light themes.

---

### Task 1: Add a focused hero-card accessibility regression test

**Files:**
- Create: `test/profil_hero_card_test.dart`
- Read: `lib/screens/profil_tab.dart`

**Interfaces:**
- Consumes: `ProfilTab`, `AppTheme.dark()`, and the existing mock `SharedPreferences` setup pattern.
- Produces: A failing test proving the hero card exposes an accessible edit action with a mobile-sized target.

- [ ] **Step 1: Write the failing test**

Create a widget test that disables runtime font fetching, seeds the minimum profile preferences, pumps `ProfilTab`, waits for the async profile load, and asserts the edit control can be found by tooltip and has at least a 44×44 hit box:

```dart
testWidgets('hero edit action is accessible', (tester) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences.setMockInitialValues({
    'nickname': 'Pejuang',
    'onboarding_done': true,
    'avatar_path': '',
  });

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(body: ProfilTab()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  final edit = find.byTooltip('Edit profil');
  expect(edit, findsOneWidget);
  expect(tester.getSize(edit).width, greaterThanOrEqualTo(44));
  expect(tester.getSize(edit).height, greaterThanOrEqualTo(44));
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```powershell
flutter test test/profil_hero_card_test.dart
```

Expected: FAIL because the current hero card uses an unlabelled `GestureDetector` around a 20px edit icon.

### Task 2: Recompose the hero card with minimal theme-aware visual changes

**Files:**
- Modify: `lib/screens/profil_tab.dart:611-849`

**Interfaces:**
- Consumes: Existing profile state, cosmetic resolution, `TierProfileAvatar`, and app theme tokens.
- Produces: The same `_hero(BuildContext)` widget with stronger visual hierarchy and unchanged callbacks.

- [ ] **Step 1: Replace the inline edit gesture with an accessible control**

Use `IconButton` with `tooltip: 'Edit profil'`, `constraints: const BoxConstraints(minWidth: 44, minHeight: 44)`, and the existing `_showEditOptions` callback. Keep the same edit icon and primary color.

- [ ] **Step 2: Refine the identity header**

Keep the avatar at 72dp, use the nickname as the primary heading, and group rank/equipped-title/level badges with consistent spacing. Ensure the text column remains inside `Expanded` and does not push the edit control off-screen.

- [ ] **Step 3: Refine the XP and location layers**

Keep the existing progress calculation and gradient. Increase separation between the identity and XP sections with existing spacing tokens, keep the XP values aligned, and make the location row's city text use `maxLines: 1` and `TextOverflow.ellipsis`.

- [ ] **Step 4: Refine summary stats without changing data**

Preserve the four `_miniStat` values and labels, but give the row consistent padding and spacing so each stat reads as a compact unit on narrow screens. Ensure Rank text remains ellipsized inside its existing `Expanded` cell.

- [ ] **Step 5: Keep theme-specific decoration bounded**

Use `AppColors` values already present in the file. Keep the dark glow subtle and omit it in light mode; do not add new assets, gradients outside the existing XP bar, or hard-coded theme colors.

- [ ] **Step 6: Run the focused accessibility test**

Run:

```powershell
flutter test test/profil_hero_card_test.dart
```

Expected: PASS with one test and no overflow errors.

### Task 3: Verify profile visuals and repository scope

**Files:**
- Read: `test/profil_tab_golden_test.dart`
- Read: `test/goldens/profil_tab_phone.png`
- Read: `test/goldens/profil_tab.png`

**Interfaces:**
- Consumes: The updated hero card and existing golden fixtures.
- Produces: Fresh verification evidence and a clean, scoped diff ready to commit.

- [ ] **Step 1: Run the focused profile golden test**

Run:

```powershell
flutter test test/profil_tab_golden_test.dart
```

Expected: PASS if the Flutter SDK and platform tooling are available. If the environment lacks Flutter, record that limitation and use static diff checks instead.

- [ ] **Step 2: Run the broader test suite when tooling is available**

Run:

```powershell
flutter test
```

Expected: Existing tests pass with no new analyzer or overflow failures.

- [ ] **Step 3: Inspect the final diff**

Run:

```powershell
git diff --check
git status --short
git diff --stat
git diff -- lib/screens/profil_tab.dart test/profil_hero_card_test.dart
```

Expected: Only the design/plan docs, `lib/screens/profil_tab.dart`, and the focused test are changed; no PAT, generated files, or unrelated refactors appear.

### Task 4: Commit and push the feature branch

**Files:**
- Commit: All scoped files from Tasks 1–3.

**Interfaces:**
- Consumes: Verified working tree on `feat/profil-hero-card-polish`.
- Produces: A remote branch with the implementation and documentation commits.

- [ ] **Step 1: Commit the implementation**

Run:

```powershell
git add docs/superpowers/specs/2026-07-26-profil-hero-card-design.md docs/superpowers/plans/2026-07-26-profil-hero-card-polish.md lib/screens/profil_tab.dart test/profil_hero_card_test.dart
git commit -m "feat: polish profil hero card"
```

- [ ] **Step 2: Push the new branch**

Push `feat/profil-hero-card-polish` to `origin` using a temporary authorization header based on the PAT supplied by the user; do not write the PAT to this plan, the remote URL, shell history, or a commit.

- [ ] **Step 3: Verify the pushed branch**

Run:

```powershell
git status --short --branch
git log -2 --oneline
```

Expected: The branch tracks `origin/feat/profil-hero-card-polish`, the working tree is clean, and the latest commit is `feat: polish profil hero card`.

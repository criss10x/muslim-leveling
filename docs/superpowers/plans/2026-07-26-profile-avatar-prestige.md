# Profile Avatar Prestige Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every earned tier a distinct, calm avatar frame and make the profile hero a tier-tinted identity card with a restrained Pro signature finish.

**Architecture:** Keep `TierVisualConfig` as the single source of truth for tier palette and decorative treatment. `TierProfileAvatar` consumes that configuration for the full profile display, while `SmallTierAvatar` stays static and compact. `ProfilTab` resolves entitlement and cosmetics once, then supplies tier and Pro state to the avatar and derives the hero's low-alpha decoration from the same tier colours.

**Tech Stack:** Flutter, Dart, existing custom painters, `flutter_test`, existing golden-test setup, `SharedPreferences` test mocks.

**Branching:** Execute in an isolated worktree on
`feat/profile-avatar-prestige`, created from the current
`feat/cosmetic-locker-polish` head. This intentionally carries the approved
locker work as its base without changing the existing locker branch.

## Global Constraints

- Preserve the existing cosmetic catalog, entitlement rules, and Daily Chest unlock flow; do not add purchases or unlock paths.
- Keep the photo as the highest-priority visual element and use a circular default tier silhouette.
- Do not identify state by colour alone; a tier-specific crest/frame treatment must accompany every palette.
- Use antique gold and deep teal only for the Pro signature finish in tier
  frames and the profile hero; do not change existing cosmetic catalog data.
- Respect reduced motion; compact avatars run no decorative animation and no particles cover a user's photo.
- Preserve 44dp minimum tap targets for the profile edit action.
- Do not add dependencies.

---

## File Structure

- `lib/widgets/tier_avatar.dart` — tier palette/configuration, tier frame painters, initials fallback, and optional Pro signature layers for full avatars; static compact-avatar representation.
- `lib/screens/profil_tab.dart` — resolves `isPro`, passes display initials/Pro state to the avatar, and builds the tier-tinted hero card.
- `test/tier_avatar_frame_test.dart` — pure tier configuration and frame-rendering regression coverage.
- `test/profil_hero_card_test.dart` — hero accessibility plus tier/Pro profile rendering coverage.
- `test/profil_tab_golden_test.dart` and `test/goldens/profil_tab_phone.png` — approved dark-theme profile presentation regression.

## Tier Contract

Introduce an exported presentation enum and configuration fields in
`tier_avatar.dart` so rendering and tests share one contract:

```dart
enum TierFrameAccent {
  fullThinRing,
  doubleArc,
  diamond,
  facetedHex,
  rubySeal,
  crescent,
  constellation,
  orbitalArcs,
  sparkTrio,
  immortalCrest,
}

class TierVisualConfig {
  // Existing fields remain.
  final TierFrameAccent accent;
  final bool hasPartialOuterArcs;
  final bool hasFullOuterRing;
  final bool allowsHeroShimmer;
}
```

Use this approved mapping:

| Tier | Primary / secondary role | Accent | Outer treatment |
| --- | --- | --- | --- |
| Warrior | amethyst | `fullThinRing` | none |
| Elite | sky azure | `doubleArc` | partial arcs |
| Master | jade green | `diamond` | none |
| Grandmaster | royal sapphire | `facetedHex` | none |
| Epic | vermilion coral | `rubySeal` | none |
| Legend | lunar lavender | `crescent` | none |
| Mythic | electric cyan | `constellation` | none |
| Mythic Honor | ultraviolet | `orbitalArcs` | partial arcs |
| Mythic Glory | celestial magenta | `sparkTrio` | none |
| Mythic Immortal | obsidian opal | `immortalCrest` | full ring |

### Task 1: Lock the tier presentation contract with tests

**Files:**
- Modify: `test/tier_avatar_frame_test.dart`
- Modify: `lib/widgets/tier_avatar.dart:50-245`

**Interfaces:**
- Consumes: `getTierVisualConfig(String)` and `getTierName(int)`.
- Produces: `TierFrameAccent` and the configuration fields used by the avatar painters and hero.

- [ ] **Step 1: Write failing tier mapping tests**

  Add table-driven expectations for all thresholds, palette separation, accents,
  and arc rules:

  ```dart
  test('tier presentation keeps free palettes and accents distinct', () {
    final master = getTierVisualConfig('Master');
    final epic = getTierVisualConfig('Epic');
    final legend = getTierVisualConfig('Legend');
    final mythic = getTierVisualConfig('Mythic');
    final immortal = getTierVisualConfig('Mythic Immortal');

    expect(master.primaryColor, isNot(mythic.primaryColor));
    expect(epic.primaryColor, isNot(getTierVisualConfig('Mythic Glory').primaryColor));
    expect(legend.primaryColor, isNot(immortal.primaryColor));
    expect(getTierVisualConfig('Elite').hasPartialOuterArcs, isTrue);
    expect(getTierVisualConfig('Mythic Honor').hasPartialOuterArcs, isTrue);
    expect(getTierVisualConfig('Warrior').hasPartialOuterArcs, isFalse);
    expect(immortal.hasFullOuterRing, isTrue);
  });

  test('tier thresholds retain all ten existing ranks', () {
    expect(getTierName(1), 'Warrior');
    expect(getTierName(10), 'Elite');
    expect(getTierName(30), 'Grandmaster');
    expect(getTierName(60), 'Legend');
    expect(getTierName(80), 'Mythic');
    expect(getTierName(95), 'Mythic Immortal');
  });
  ```

- [ ] **Step 2: Run the focused test to verify it fails**

  Run: `flutter test test/tier_avatar_frame_test.dart`

  Expected: compile failure because `TierFrameAccent`,
  `hasPartialOuterArcs`, and `hasFullOuterRing` do not exist yet.

- [ ] **Step 3: Add the contract and approved palette mapping**

  In `tier_avatar.dart`, add `TierFrameAccent` and the three fields above to
  `TierVisualConfig`. Replace the current Grandmaster gold, Legend
  white-gold, Mythic red-gold, Mythic Honor gold-red, Mythic Glory white-red,
  and Mythic Immortal gold-white mappings with the approved sapphire,
  lavender, cyan, ultraviolet, magenta, and obsidian-opal mappings. Keep
  `getTierName` level thresholds unchanged.

- [ ] **Step 4: Run the focused test to verify it passes**

  Run: `flutter test test/tier_avatar_frame_test.dart`

  Expected: PASS, including the existing frame-path tests.

- [ ] **Step 5: Commit the contract**

  ```powershell
  git add lib/widgets/tier_avatar.dart test/tier_avatar_frame_test.dart
  git commit -m "feat: define distinct tier avatar presentation"
  ```

### Task 2: Render calm earned-tier frames and initials fallback

**Files:**
- Modify: `lib/widgets/tier_avatar.dart:250-880`
- Modify: `test/tier_avatar_frame_test.dart`

**Interfaces:**
- Consumes: `TierVisualConfig.accent`, `hasPartialOuterArcs`, and `hasFullOuterRing` from Task 1.
- Produces: `TierProfileAvatar(displayName:, isPro:)` and static `SmallTierAvatar(displayName:)` rendering without emoji fallback.

- [ ] **Step 1: Write failing widget tests**

  Add tests that exercise an earned frame and no-photo fallback:

  ```dart
  testWidgets('Epic avatar renders its earned frame with initials fallback',
      (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: TierProfileAvatar(
        tierName: 'Epic', displayName: 'Ahmad Fikri', sizeDp: 88,
      ),
    ));
    expect(find.text('AF'), findsOneWidget);
  });

  testWidgets('compact avatar stays static for Mythic Immortal', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: SmallTierAvatar(
        tierName: 'Mythic Immortal', displayName: 'Ahmad Fikri',
      ),
    ));
    expect(find.byType(SmallTierAvatar), findsOneWidget);
  });
  ```

- [ ] **Step 2: Run the focused test to verify it fails**

  Run: `flutter test test/tier_avatar_frame_test.dart`

  Expected: compile failure because `displayName` and the initials fallback do
  not exist.

- [ ] **Step 3: Implement one focused frame painter and fallback path**

  Add an internal `_TierAccentPainter` that draws from `TierFrameAccent`:
  short arcs only for Elite and Mythic Honor; diamond, hex, seal, crescent,
  constellation, spark trio, or immortal crest for their matching tiers.
  Replace `_defaultEmoji` rendering with a two-letter uppercase initials helper
  derived from `displayName` (use `?` when empty). Make the full avatar
  circular for default tier presentation, retain equipped cosmetic silhouettes,
  and remove continuous rotation/particle loops from earned-tier rendering.
  Keep `SmallTierAvatar` as a static border plus a minimal accent only.

- [ ] **Step 4: Run focused avatar tests**

  Run: `flutter test test/tier_avatar_frame_test.dart test/tier_avatar_aura_test.dart`

  Expected: PASS. Aura tests still render because equipped aura behaviour is
  unchanged.

- [ ] **Step 5: Commit the earned-frame rendering**

  ```powershell
  git add lib/widgets/tier_avatar.dart test/tier_avatar_frame_test.dart test/tier_avatar_aura_test.dart
  git commit -m "feat: refine earned tier avatar frames"
  ```

### Task 3: Add the Pro signature finish without obscuring tier achievement

**Files:**
- Modify: `lib/widgets/tier_avatar.dart:250-680`
- Modify: `lib/screens/profil_tab.dart:616-744`
- Modify: `test/tier_avatar_frame_test.dart`

**Interfaces:**
- Consumes: `TierProfileAvatar(isPro:)` from Task 2 and the current
  `EntitlementService.isPro` value already resolved in `_hero`.
- Produces: Pro outer arcs, teal membership crest, optional title composition,
  and tier-first layering for the profile hero.

- [ ] **Step 1: Write the failing Epic Pro rendering test**

  ```dart
  testWidgets('Epic Pro avatar keeps the Epic frame and renders Pro finish',
      (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: TierProfileAvatar(
        tierName: 'Epic', displayName: 'Ahmad Fikri', isPro: true, sizeDp: 88,
      ),
    ));
    expect(find.bySemanticsLabel('Epic achievement frame'), findsOneWidget);
    expect(find.bySemanticsLabel('Pro signature finish'), findsOneWidget);
  });
  ```

- [ ] **Step 2: Run the focused test to verify it fails**

  Run: `flutter test test/tier_avatar_frame_test.dart`

  Expected: FAIL because the semantic layers are not present.

- [ ] **Step 3: Implement the layered Pro finish**

  Add `bool isPro = false` to `TierProfileAvatar`. Wrap the earned tier frame
  in a semantic `Epic achievement frame` layer (using the current tier name in
  the label). When `isPro`, draw only two thin broken antique-gold outer arcs,
  a deep-teal crest, and a soft behind-photo halo. Give the finish semantic
  label `Pro signature finish`. Pass `isPro` and `_nickname` from
  `ProfilTab._hero`; do not alter cosmetic entitlement resolution or add a
  Pro finish to `SmallTierAvatar`.

- [ ] **Step 4: Run focused profile and avatar tests**

  Run: `flutter test test/tier_avatar_frame_test.dart test/profil_hero_card_test.dart`

  Expected: PASS, including the existing 44dp edit-control assertion.

- [ ] **Step 5: Commit the Pro presentation**

  ```powershell
  git add lib/widgets/tier_avatar.dart lib/screens/profil_tab.dart test/tier_avatar_frame_test.dart test/profil_hero_card_test.dart
  git commit -m "feat: layer Pro finish over tier achievement"
  ```

### Task 4: Build the tier-tinted profile hero

**Files:**
- Modify: `lib/screens/profil_tab.dart:610-785`
- Modify: `test/profil_hero_card_test.dart`
- Modify: `test/profil_tab_golden_test.dart`
- Modify: `test/goldens/profil_tab_phone.png`

**Interfaces:**
- Consumes: `TierVisualConfig.inkPrimary`, `inkSecondary`, avatar `isPro`,
  and resolved equipped title from Tasks 1--3.
- Produces: a low-alpha tier gradient hero, tier-coloured border and XP fill,
  and optional Pro inlay that retains the current tier tint.

- [ ] **Step 1: Write failing hero semantics tests**

  In `profil_hero_card_test.dart`, add a dedicated semantic label to the hero
  root and assert it remains present for the baseline state:

  ```dart
  testWidgets('hero exposes tier identity without reducing edit target',
      (tester) async {
    // Reuse the existing SharedPreferences mock and ProfilTab pump.
    expect(find.bySemanticsLabel('Profile hero — Warrior'), findsOneWidget);
    final edit = find.byTooltip('Edit profil');
    expect(tester.getSize(edit).shortestSide, greaterThanOrEqualTo(44));
  });
  ```

- [ ] **Step 2: Run the focused test to verify it fails**

  Run: `flutter test test/profil_hero_card_test.dart`

  Expected: FAIL because the tier-aware hero semantics do not exist.

- [ ] **Step 3: Apply the hero palette**

  In `_hero`, read `getTierVisualConfig(getTierName(_level))` once. Replace
  the fixed primary outer border/shadow and the fixed neutral inner treatment
  with a tier-primary/tier-secondary gradient at 8--14% opacity, a 30--40%
  tier border, and a tier gradient XP fill. Keep all body text and the photo
  surface neutral. Add an `ExcludeSemantics` decorative Pro gold inlay only
  when `isPro`; do not replace the tier palette. Increase the full avatar to
  88dp while retaining the edit button constraints.

- [ ] **Step 4: Update and run the dark-theme golden**

  Run: `flutter test --update-goldens test/profil_tab_golden_test.dart`

  Expected: PASS and updates `test/goldens/profil_tab_phone.png` with the
  tier-tinted Warrior hero.

  Then run: `flutter test test/profil_hero_card_test.dart test/profil_tab_golden_test.dart`

  Expected: PASS.

- [ ] **Step 5: Commit the hero presentation**

  ```powershell
  git add lib/screens/profil_tab.dart test/profil_hero_card_test.dart test/profil_tab_golden_test.dart test/goldens/profil_tab_phone.png
  git commit -m "feat: tint profile hero by earned tier"
  ```

### Task 5: Verify the full presentation and branch handoff

**Files:**
- Modify only if verification reveals an in-scope defect: files from Tasks 1--4.
- Verify: `test/tier_avatar_frame_test.dart`, `test/tier_avatar_aura_test.dart`, `test/profil_hero_card_test.dart`, `test/profil_tab_golden_test.dart`

**Interfaces:**
- Consumes: completed Tasks 1--4.
- Produces: verified `feat/profile-avatar-prestige` branch ready to push.

- [ ] **Step 1: Run formatter and analyzer**

  Run:

  ```powershell
  dart format lib/widgets/tier_avatar.dart lib/screens/profil_tab.dart test/tier_avatar_frame_test.dart test/tier_avatar_aura_test.dart test/profil_hero_card_test.dart test/profil_tab_golden_test.dart
  flutter analyze
  ```

  Expected: formatter makes no unexpected unrelated changes; analyzer reports
  no issues.

- [ ] **Step 2: Run the targeted suite**

  Run:

  ```powershell
  flutter test test/tier_avatar_frame_test.dart test/tier_avatar_aura_test.dart test/profil_hero_card_test.dart test/profil_tab_golden_test.dart
  ```

  Expected: PASS.

- [ ] **Step 3: Run the full test suite**

  Run: `flutter test`

  Expected: PASS.

- [ ] **Step 4: Inspect the final diff and commit any in-scope verification fix**

  Run:

  ```powershell
  git diff --check
  git status --short
  ```

  Expected: no whitespace errors and no unstaged/untracked implementation
  files. If a verification-only fix was needed, commit it with a focused
  `fix:` message before handoff.

- [ ] **Step 5: Push the requested branch after verification**

  Run:

  ```powershell
  git push -u origin feat/profile-avatar-prestige
  ```

  Expected: the remote branch is created or updated without changing the
  existing locker branch.

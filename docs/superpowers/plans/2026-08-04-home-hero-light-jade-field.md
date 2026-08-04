# Home Hero Light Jade Field Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the light Home rank hero's tier-heavy decoration with the approved semantic Jade Field treatment while leaving the dark hero unchanged.

**Architecture:** Keep the existing `_heroRank`, `_RankMedallion`, and `_IslamicHeroPatternPainter` boundaries in `home_tab.dart`. Select semantic light colors at the two existing light/dark branches; do not add state, helpers, components, or theme tokens.

**Tech Stack:** Flutter, Dart, Material `BoxDecoration`/gradients, existing `AppColors`, `flutter_test`.

## Global Constraints

- Change only the light-theme presentation of the existing Home rank hero.
- Preserve layout, copy, dimensions, XP behavior, animation, state, semantics, and dark-theme styling.
- Support both Light Emerald and Light Mushaf through semantic `AppColors` tokens.
- Add no assets, dependencies, state, or reusable abstractions.
- Keep Home/Jadwal/Belajar/Profil tab labels unchanged.
- Run `flutter analyze` after edits; accept only the four documented pre-existing info findings in `test/jumat_streak_test.dart` and `test/wajib_lock_test.dart`.
- The baseline full suite has two unrelated profile golden failures: `profil_tab_phone.png` and `profil_stats_populated.png`. Report them without changing or regenerating those goldens.

## File Map

- Modify `lib/screens/home_tab.dart`: select the Jade Field shell, lattice, and medallion colors for light presets while preserving dark branches.
- Modify `test/home_hero_hybrid_test.dart`: encode Light Emerald, Light Mushaf, and dark regression contracts.

---

### Task 1: Apply the semantic Jade Field treatment

**Files:**
- Modify: `test/home_hero_hybrid_test.dart:8-99`
- Modify: `lib/screens/home_tab.dart:310-366`
- Modify: `lib/screens/home_tab.dart:1839-1904`

**Interfaces:**
- Consumes: `activeThemePreset`, `AppThemePreset`, `AppColors`, `TierVisualConfig`, `getTierName(int)`, `getTierVisualConfig(String)`, and existing widget keys.
- Produces: the existing `_heroRank(LevelInfo)` and `_RankMedallion` widgets with new light-only semantic decoration; no new public API.

- [ ] **Step 1: Make the test harness select an exact preset**

In `test/home_hero_hybrid_test.dart`, import the tier config and make `pumpHero` accept an `AppThemePreset`. Reset the global preset in `setUp` so tests cannot leak theme state:

```dart
import 'package:muslim_leveling/widgets/tier_avatar.dart';

setUp(() {
  GoogleFonts.config.allowRuntimeFetching = false;
  activeThemePreset = AppThemePreset.darkEmerald;
  SharedPreferences.setMockInitialValues({
    'game_state_v1': '{"xp":0,"level":1}',
  });
});

Future<void> pumpHero(
  WidgetTester tester, {
  required AppThemePreset preset,
}) async {
  activeThemePreset = preset;
  await tester.pumpWidget(
    MaterialApp(
      theme: preset.isLight ? AppTheme.light() : AppTheme.dark(),
      home: const Scaffold(body: HomeTab()),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}
```

Replace existing `pumpHero(tester, light: true/false)` calls with `AppThemePreset.lightEmerald` and `AppThemePreset.darkEmerald` respectively.

- [ ] **Step 2: Write failing Light Emerald decoration assertions**

Extend the existing light widget test after reading `backgroundDecoration`, `pattern`, and `medallion`:

```dart
final backgroundGradient =
    backgroundDecoration.gradient! as RadialGradient;
final backgroundBorder = backgroundDecoration.border! as Border;
final patternPainter = pattern.painter as dynamic;
final medallionDecoration = medallion.decoration! as BoxDecoration;
final medallionInner = medallion.child! as Container;
final medallionInnerDecoration =
    medallionInner.decoration! as BoxDecoration;
final medallionStar = tester.widget<CustomPaint>(
  find.descendant(
    of: medallionFinder,
    matching: find.byType(CustomPaint),
  ),
);
final medallionStarPainter = medallionStar.painter as dynamic;

expect(
  backgroundGradient.colors,
  [
    AppColors.primaryContainer.withValues(alpha: 0.62),
    AppColors.surfaceContainerLow,
  ],
);
expect(
  backgroundBorder.top.color,
  AppColors.primary.withValues(alpha: 0.22),
);
expect(patternPainter.color, AppColors.primary);
expect(patternPainter.opacity, 0.05);
expect(medallionDecoration.color, AppColors.primary);
expect(medallionDecoration.gradient, isNull);
expect(medallionDecoration.boxShadow, isNull);
expect(medallionInnerDecoration.color, AppColors.primaryContainer);
expect(medallionStarPainter.color, AppColors.primary);
```

Keep the existing no-shadow, border radius, `IgnorePointer`, key, copy, and exception assertions.

- [ ] **Step 3: Add a failing Light Mushaf semantic-color test**

Add a focused test that proves the same decoration follows the active light preset instead of hard-coded Emerald colors:

```dart
testWidgets('Home hero Jade Field follows Light Mushaf semantic colors', (
  tester,
) async {
  await pumpHero(tester, preset: AppThemePreset.lightMushaf);

  final background = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byKey(const Key('home-hero-card')),
      matching: find.byWidgetPredicate((widget) {
        if (widget is! DecoratedBox || widget.decoration is! BoxDecoration) {
          return false;
        }
        final decoration = widget.decoration as BoxDecoration;
        return decoration.gradient is RadialGradient &&
            decoration.border != null;
      }),
    ),
  );
  final backgroundDecoration = background.decoration as BoxDecoration;
  final gradient = backgroundDecoration.gradient! as RadialGradient;
  final medallion = tester.widget<Container>(
    find.byKey(const Key('home-rank-medallion')),
  );
  final medallionDecoration = medallion.decoration! as BoxDecoration;

  expect(
    gradient.colors.first,
    AppColors.primaryContainer.withValues(alpha: 0.62),
  );
  expect(medallionDecoration.color, AppColors.primary);
  expect(tester.takeException(), isNull);
});
```

- [ ] **Step 4: Strengthen the dark regression test before implementation**

In the existing dark test, add assertions that pin the current tier treatment:

```dart
final tier = getTierVisualConfig(getTierName(1));
final patternPainter = pattern.painter as dynamic;
final medallion = tester.widget<Container>(
  find.byKey(const Key('home-rank-medallion')),
);
final medallionDecoration = medallion.decoration! as BoxDecoration;
final medallionInner = medallion.child! as Container;
final medallionInnerDecoration =
    medallionInner.decoration! as BoxDecoration;

expect(patternPainter.color, tier.inkPrimary);
expect(patternPainter.opacity, 0.09);
expect(medallionDecoration.color, isNull);
expect(
  (medallionDecoration.gradient! as LinearGradient).colors,
  [tier.inkPrimary, tier.inkSecondary],
);
expect(medallionDecoration.boxShadow, hasLength(1));
expect(medallionInnerDecoration.color, AppColors.surfaceContainer);
```

- [ ] **Step 5: Run the focused test and confirm the new light contract fails**

Run:

```powershell
flutter test test/home_hero_hybrid_test.dart --reporter compact
```

Expected: FAIL because the current light wash and lattice use `tier.inkPrimary`, and the current light medallion still uses a tier gradient with `AppColors.surfaceContainer` inside. The strengthened dark assertions should pass.

- [ ] **Step 6: Implement the minimal light-only shell and lattice color selection**

In `_heroRank`, select the light accent and wash once, then keep the current dark values exactly:

```dart
final heroAccent = light ? AppColors.primary : tier.inkPrimary;
final heroWash = light ? AppColors.primaryContainer : tier.inkPrimary;
```

Use those values in the existing background and painter:

```dart
gradient: RadialGradient(
  center: Alignment.topRight,
  radius: 1.4,
  colors: [
    heroWash.withValues(alpha: light ? 0.62 : 0.14),
    AppColors.surfaceContainerLow,
  ],
),
border: Border.all(
  color: AppColors.primary.withValues(
    alpha: light ? 0.22 : 0.45,
  ),
  width: light ? 1.0 : 1.5,
),
```

```dart
painter: _IslamicHeroPatternPainter(
  color: heroAccent,
  opacity: light ? 0.05 : 0.09,
),
```

Do not change the light no-shadow branch, dark glow, radius, pattern geometry, padding, typography, or XP widgets.

- [ ] **Step 7: Implement the minimal light-only medallion selection**

In `_RankMedallion`, replace only the outer decoration color selection, inner surface, and star color:

```dart
decoration: BoxDecoration(
  shape: BoxShape.circle,
  color: light ? AppColors.primary : null,
  gradient: light
      ? null
      : LinearGradient(
          colors: [tier.inkPrimary, tier.inkSecondary],
        ),
  boxShadow: light
      ? null
      : [
          BoxShadow(
            color: tier.inkPrimary.withValues(alpha: 0.28),
            blurRadius: 12,
          ),
        ],
),
```

```dart
color: light ? AppColors.primaryContainer : AppColors.surfaceContainer,
```

```dart
painter: _IslamicHeroPatternPainter(
  color: light ? AppColors.primary : tier.inkPrimary,
  opacity: 1,
  singleStar: true,
),
```

Keep the 68 dp size, 2 px ring, level label, `ExcludeSemantics`, and `IgnorePointer` unchanged.

- [ ] **Step 8: Format and run the focused test**

Run:

```powershell
dart format lib/screens/home_tab.dart test/home_hero_hybrid_test.dart
flutter test test/home_hero_hybrid_test.dart --reporter compact
```

Expected: all three hero tests PASS with no widget exception.

- [ ] **Step 9: Run static analysis and the full regression suite**

Run:

```powershell
flutter analyze
flutter test --reporter compact
```

Expected analysis: no new findings; only the four documented pre-existing info findings in `test/jumat_streak_test.dart` and `test/wajib_lock_test.dart` are tolerated.

Expected tests: all hero and non-profile tests pass. The two documented unrelated profile golden mismatches may remain; do not update `test/goldens/profil_tab_phone.png` or `test/goldens/profil_stats_populated.png` as part of this task.

- [ ] **Step 10: Review the diff and commit the implementation**

Run:

```powershell
git diff --check
git diff -- lib/screens/home_tab.dart test/home_hero_hybrid_test.dart
git status --short
```

Confirm the diff changes only the approved light color branches and their tests. Then commit:

```powershell
git add lib/screens/home_tab.dart test/home_hero_hybrid_test.dart
git commit -m "fix: connect light home hero palette"
```

- [ ] **Step 11: Push the completed branch**

Run:

```powershell
git push origin codex/home-hero-hybrid
```

Expected: `origin/codex/home-hero-hybrid` advances to the implementation commit. Do not create a pull request unless the user asks.

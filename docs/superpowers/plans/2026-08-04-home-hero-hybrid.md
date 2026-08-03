# Home Hero Hybrid Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the Home rank hero into a calm Islamic-premium card in light mode and a stronger game-rank card in dark mode.

**Architecture:** Keep all presentation inside `home_tab.dart`: the existing hero owns the stack, a private medallion widget draws the rank emblem, and one private custom painter draws the fading eight-point lattice. Add one focused widget test that exercises both theme treatments through stable keys.

**Tech Stack:** Flutter, Dart, Material widgets, `CustomPainter`, `flutter_test`.

## Global Constraints

- Preserve all Home labels, emoji, data flow, XP animation, and section ordering.
- Use existing `AppColors`, `AppText`, `AppSpacing`, `AppRadius`, and `TierVisualConfig` only.
- Light mode stays flat: white card, no shadow, restrained jade/tier wash, 4–6% lattice.
- Dark mode may use one restrained tier glow on the hero and an 8–10% lattice.
- No bitmap assets, dependencies, services, state, gestures, glass effects, mosque photos, swords, or shields.
- Keep the implementation in `lib/screens/home_tab.dart`; add only one focused test file.
- Do not fix the four unrelated baseline analyzer issues in `test/jumat_streak_test.dart` and `test/wajib_lock_test.dart`.

---

### Task 1: Hybrid rank hero visual treatment

**Files:**
- Modify: `lib/screens/home_tab.dart:308`
- Create: `test/home_hero_hybrid_test.dart`

**Interfaces:**
- Consumes: `LevelInfo`, `TierVisualConfig`, `getTierName(int)`, `getTierVisualConfig(String)`, `isLightTheme`, and existing app theme tokens.
- Produces: stable widget keys `home-hero-card`, `home-hero-pattern`, and `home-rank-medallion`; private `_RankMedallion`; private `_IslamicHeroPatternPainter`.

- [ ] **Step 1: Write the failing light/dark widget test**

Create `test/home_hero_hybrid_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'game_state_v1': '{"xp":0,"level":1}',
    });
  });

  Future<void> pumpHero(WidgetTester tester, {required bool light}) async {
    isLightTheme = light;
    await tester.pumpWidget(
      MaterialApp(
        theme: light ? AppTheme.light() : AppTheme.dark(),
        home: const Scaffold(body: HomeTab()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('Home hero renders Islamic pattern and rank medallion in light mode', (
    tester,
  ) async {
    await pumpHero(tester, light: true);

    final card = tester.widget<Container>(
      find.byKey(const Key('home-hero-card')),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.boxShadow, isNull);
    expect(find.byKey(const Key('home-hero-pattern')), findsOneWidget);
    expect(find.byKey(const Key('home-rank-medallion')), findsOneWidget);
    expect(find.text('CURRENT RANK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home hero adds one restrained rank glow in dark mode', (
    tester,
  ) async {
    await pumpHero(tester, light: false);

    final card = tester.widget<Container>(
      find.byKey(const Key('home-hero-card')),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.boxShadow, hasLength(1));
    expect(find.byKey(const Key('home-hero-pattern')), findsOneWidget);
    expect(find.byKey(const Key('home-rank-medallion')), findsOneWidget);
    expect(find.byKey(const Key('home-xp-progress-fill')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```powershell
flutter test test/home_hero_hybrid_test.dart
```

Expected: FAIL because `home-hero-card`, `home-hero-pattern`, and `home-rank-medallion` do not exist.

- [ ] **Step 3: Convert `_heroRank` to a clipped decorative stack**

In `_heroRank(LevelInfo info)`:

- Preserve the existing XP labels, animated counters, and `home-xp-progress-fill` subtree.
- Add `key: const Key('home-hero-card')` to the outer hero container.
- Keep the current light/no-shadow and dark/single-glow shell.
- Replace the inner padded container with `ClipRRect` → `Stack`.
- Add a full-size background `DecoratedBox` using the existing solid surface plus a restrained `RadialGradient` from `Alignment.topRight`; use lower alpha in light mode.
- Add `Positioned.fill` → `IgnorePointer` → `CustomPaint(key: const Key('home-hero-pattern'), painter: _IslamicHeroPatternPainter(...))`.
- Place the existing content column in `Padding(AppSpacing.lg)` above both decorative layers.
- Add `_RankMedallion(tier: tier, level: info.level, light: light)` as the trailing child of the top rank row with a fixed 68 dp footprint.

Use theme values directly; do not introduce configuration objects or new files.

- [ ] **Step 4: Add the minimal rank medallion**

At the end of `home_tab.dart`, replace the dangling pattern comment with `_RankMedallion`:

```dart
class _RankMedallion extends StatelessWidget {
  final TierVisualConfig tier;
  final int level;
  final bool light;

  const _RankMedallion({
    required this.tier,
    required this.level,
    required this.light,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        key: const Key('home-rank-medallion'),
        width: 68,
        height: 68,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
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
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceContainer,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: 30,
                child: CustomPaint(
                  painter: _IslamicHeroPatternPainter(
                    color: tier.inkPrimary,
                    opacity: 1,
                    singleStar: true,
                  ),
                ),
              ),
              Positioned(
                bottom: 7,
                child: Text(
                  'LV $level',
                  style: AppText.labelCapsSm().copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

The finished widget must use `BoxShape.circle`, `tier.inkPrimary`/`inkSecondary`, `AppColors.surfaceContainer`, and no light-mode shadow. Keep the level footer inside the circle without adding interaction or semantics.

- [ ] **Step 5: Add the minimal fading lattice painter**

Add `_IslamicHeroPatternPainter` below the medallion:

```dart
class _IslamicHeroPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final bool singleStar;

  const _IslamicHeroPatternPainter({
    required this.color,
    required this.opacity,
    this.singleStar = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path star(Offset center, double outerRadius) {
      final path = Path();
      for (var i = 0; i < 16; i++) {
        final radius = i.isEven ? outerRadius : outerRadius * 0.42;
        final angle = -math.pi / 2 + i * math.pi / 8;
        final point = Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path..close();
    }

    final paint = Paint()
      ..style = singleStar ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1;
    if (singleStar) {
      paint.color = color.withValues(alpha: opacity);
      canvas.drawPath(
        star(Offset(size.width / 2, size.height / 2 - 4), size.shortestSide / 2),
        paint,
      );
      return;
    }

    final startX = size.width * 0.42;
    const spacing = 40.0;
    for (var y = 0.0; y <= size.height + spacing; y += spacing) {
      for (var x = startX; x <= size.width + spacing; x += spacing) {
        final fade = ((x - startX) / (size.width - startX)).clamp(0.2, 1.0);
        paint.color = color.withValues(alpha: opacity * fade);
        canvas.drawPath(star(Offset(x, y), 13), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicHeroPatternPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.singleStar != singleStar;
}
```

Use `Path`, `Paint`, `math.cos`, and `math.sin` from the existing `dart:math` import if present; otherwise add `import 'dart:math' as math;`. Do not add a package.

- [ ] **Step 6: Run the focused test and verify GREEN**

Run:

```powershell
flutter test test/home_hero_hybrid_test.dart
```

Expected: both tests PASS with no layout or paint exception.

- [ ] **Step 7: Verify the existing XP animation regression**

Run:

```powershell
flutter test test/home_xp_progress_animation_test.dart test/home_hero_hybrid_test.dart
```

Expected: all tests PASS and `home-xp-progress-fill` remains under `TweenAnimationBuilder<double>`.

- [ ] **Step 8: Run full verification**

Run:

```powershell
flutter test
flutter analyze --no-pub
```

Expected: full test suite PASS. Analyzer may exit non-zero only for the same four accepted baseline issues: unused import, dead code, and two `avoid_print` findings in the two unrelated test files.

- [ ] **Step 9: Review the diff and commit**

Run:

```powershell
git diff --check
git diff -- lib/screens/home_tab.dart test/home_hero_hybrid_test.dart
git add lib/screens/home_tab.dart test/home_hero_hybrid_test.dart
git commit -m "feat: polish home rank hero"
```

Expected: only the hero presentation and its focused test are included in the feature commit.

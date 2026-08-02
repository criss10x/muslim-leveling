# Home XP Progress Animation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Animate the Home hero XP bar when its XP progress changes.

**Architecture:** Keep the existing Home hero structure and wrap only its bar
fill in `TweenAnimationBuilder<double>`. The builder supplies the animated
width factor to the existing `FractionallySizedBox`; game state and Profil are
unchanged.

**Tech Stack:** Flutter widget test, Material widgets, existing GameService.

## Global Constraints

- Keep the existing tier gradient, dark-mode glow, 10 px height, and pill radius.
- Animate from zero on first render and between values on XP updates.
- Use `Duration(milliseconds: 500)` and `Curves.easeOutCubic`.
- Add no dependency, controller, or state field.
- Run `flutter analyze` after the edit.

---

### Task 1: Animate the Home hero XP fill

**Files:**
- Create: `test/home_xp_progress_animation_test.dart`
- Modify: `lib/screens/home_tab.dart:431-460`

**Interfaces:**
- Consumes: `GameService.addXp(int xp)` and `GameService.stateVersion`.
- Produces: Home hero element keyed `home-xp-progress-fill`, whose width is
  driven by a `TweenAnimationBuilder<double>`.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('Home XP fill animates after XP changes', (tester) async {
  SharedPreferences.setMockInitialValues({
    'game_state_v1': '{"xp":0,"level":1}',
  });
  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.dark(), home: const Scaffold(body: HomeTab())),
  );
  await tester.pump(const Duration(milliseconds: 300));

  await GameService.addXp(20);
  await tester.pump(const Duration(milliseconds: 250));
  expect(find.byKey(const Key('home-xp-progress-fill')), findsOneWidget);
  expect(find.byWidgetPredicate((w) => w is TweenAnimationBuilder<double>),
      findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/home_xp_progress_animation_test.dart`

Expected: FAIL because the Home hero has no `TweenAnimationBuilder` and no
`home-xp-progress-fill` key.

- [ ] **Step 3: Write minimal implementation**

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: info.progress.clamp(0.0, 1.0)),
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeOutCubic,
  builder: (context, progress, child) => FractionallySizedBox(
    alignment: Alignment.centerLeft,
    widthFactor: progress,
    child: child,
  ),
  child: Container(
    key: const Key('home-xp-progress-fill'),
    decoration: existingFillDecoration,
  ),
)
```

Keep the existing `ClipRRect` and track container in place. Move only the
fill's `FractionallySizedBox` into the builder and preserve its decoration.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/home_xp_progress_animation_test.dart`

Expected: PASS; the Home bar contains the animation builder and named fill
after XP changes.

- [ ] **Step 5: Run static analysis**

Run: `flutter analyze`

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/screens/home_tab.dart test/home_xp_progress_animation_test.dart
git commit -m "feat: animate home XP progress"
```

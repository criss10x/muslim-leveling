# Minimal Splash Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Splash finish its calm entry sequence and begin navigation after a 900 ms minimum display time.

**Architecture:** Reuse Splash's existing three controllers. Replace the looping
pulse with one logo entry controller, use a short stagger for text, and finish
the existing progress controller before the 900 ms timer navigates. The current
theme tokens continue to provide distinct Light and Dark treatments.

**Tech Stack:** Flutter `AnimationController`, widget tests, existing AppTheme
and SharedPreferences.

## Global Constraints

- Keep the centered logo, existing copy, and current logo asset.
- Light stays flat with deep emerald; Dark retains only a restrained jade glow.
- No new asset, dependency, controller type, or game-state field.
- Splash exits at 900 ms minimum with a 200 ms fade.
- SharedPreferences errors route to onboarding.
- Run `flutter analyze` after the edit.

---

### Task 1: Stage and shorten the Splash entry

**Files:**
- Modify: `test/widget_test.dart:9-27`
- Modify: `lib/screens/splash_screen.dart:18-167`

**Interfaces:**
- Consumes: `SharedPreferences.getInstance()`, `onboarding_done`, and
  `nickname`.
- Produces: Splash keys `splash-logo-card` and `splash-progress-fill` for
  stable widget verification.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('Splash finishes progress within its 900 ms entry', (tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
  await tester.pump(const Duration(milliseconds: 900));

  final fill = tester.widget<FractionallySizedBox>(
    find.byKey(const Key('splash-progress-fill')),
  );
  expect(fill.widthFactor, 1);
  expect(find.byKey(const Key('splash-logo-card')), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test --no-pub test/widget_test.dart`

Expected: FAIL because Splash has no keys and its current 1000 ms progress bar
cannot be complete at 900 ms.

- [ ] **Step 3: Write minimal implementation**

```dart
_logoCtl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 180),
)..forward();
_barCtl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 550),
)..forward();
_navTimer = Timer(const Duration(milliseconds: 900), _navigate);
```

Wrap the logo in `FadeTransition` and `ScaleTransition`; wrap title/tagline in
one short delayed `FadeTransition` with a small `SlideTransition`. Keep the
existing Light/Dark decorations, add the two test keys, set the route fade to
200 ms, and use a `try/catch` in `_navigate` that defaults to onboarding.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test --no-pub test/widget_test.dart`

Expected: PASS; the progress fill is complete at 900 ms and the logo card is
present.

- [ ] **Step 5: Run static analysis**

Run: `flutter analyze --no-pub`

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/screens/splash_screen.dart test/widget_test.dart
git commit -m "feat: streamline splash entry"
```

# Mission Briefing Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the first welcome screen into a quick, gamified Mission Briefing.

**Architecture:** Keep the existing CharacterCreation route and theme tokens.
Use one entry controller to stagger the logo/header, three compact benefit rows,
and CTA without adding onboarding steps or dependencies.

**Tech Stack:** Flutter Material, existing AppTheme and HeroButton, widget tests.

## Global Constraints

- Use a neutral logo; do not show rank or prestige effects.
- Keep Light flat and Dark with only a soft jade brand halo.
- Benefit copy must stay one line on a phone.
- Preserve the CharacterCreationScreen destination.

---

### Task 1: Build the compact Mission Briefing

**Files:**
- Create: `test/onboarding_test.dart`
- Modify: `lib/screens/welcome_pejuang.dart`

**Interfaces:**
- Consumes: `HeroButton` and `CharacterCreationScreen`.
- Produces: CTA label `MULAI MISI PERTAMA` and three compact benefits.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('onboarding presents the first mission with concise benefits',
    (tester) async {
  await tester.pumpWidget(const MaterialApp(home: WelcomePejuangScreen()));
  expect(find.text('MULAI MISI PERTAMA'), findsOneWidget);
  expect(find.text('Sholat → XP → streak'), findsOneWidget);
  expect(find.text('Artikel & quiz Islam'), findsOneWidget);
  expect(find.text('Konsisten, raih badge'), findsOneWidget);
});
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `flutter test --no-pub test/onboarding_test.dart`

Expected: FAIL because the current screen has longer descriptions and the old
CTA label.

- [ ] **Step 3: Implement the minimum UI change**

```dart
HeroButton(
  label: 'MULAI MISI PERTAMA',
  trailingIcon: Icons.arrow_forward,
  onPressed: _openCharacterCreation,
)
```

Use a single `AnimationController` for a 280 ms header entry and 70 ms benefit
stagger. Compact each benefit row to its icon, title, and one-line copy.

- [ ] **Step 4: Run the test and verify it passes**

Run: `flutter test --no-pub test/onboarding_test.dart`

Expected: PASS.

- [ ] **Step 5: Run static analysis**

Run: `flutter analyze --no-pub`

Expected: `No issues found!`

- [ ] **Step 6: Commit and push**

```bash
git add lib/screens/welcome_pejuang.dart test/onboarding_test.dart
git commit -m "feat: streamline mission briefing onboarding"
git push
```

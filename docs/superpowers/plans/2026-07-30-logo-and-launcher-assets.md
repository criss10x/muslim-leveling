# Logo and Launcher Assets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install the supplied jade mosque-M as the Android launcher/native-startup asset and render the supplied black mosque-M in Flutter using each active theme's primary color.

**Architecture:** Android consumes fixed PNG resources before Flutter starts, so all `mipmap-*` launcher densities and the native `launch_background.xml` use the jade artwork. Flutter consumes one transparent mark asset and colors it at render time with `ColorFiltered`; no theme state is baked into the bitmap.

**Tech Stack:** Flutter, Dart, Android XML resources, built-in image editing, `flutter_test`.

## Global Constraints

- Do not add a runtime package.
- Native startup and launcher remain static jade-on-black.
- Flutter splash uses `AppColors.primary` with `BlendMode.srcIn`.
- Do not change splash timing, labels, navigation, or theme tokens.
- Do not build an APK; run analyzer and Flutter tests only.

---

### Task 1: Prepare the two approved image assets

**Files:**
- Create: `assets/images/logo_mark.png`
- Modify: `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- Modify: `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- Modify: `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- Modify: `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- Modify: `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- Create: `android/app/src/main/res/drawable/launch_logo.png`

**Interfaces:**
- Consumes: the user-supplied black-on-white mark for Flutter and jade-on-black mark for Android.
- Produces: a transparent `logo_mark.png` for tinting and static density-correct Android PNGs.

- [ ] **Step 1: Inspect both supplied images before processing**

Use `view_image` for both source paths. Confirm the Flutter source is the black mosque-M mark with white background, and the Android source is the jade mosque-M mark centered on black.

- [ ] **Step 2: Produce the transparent Flutter mark**

Use built-in image editing with the black-on-white source as the edit target:

```text
Preserve exactly the supplied mosque-M, crescent, and star geometry.
Remove the white background completely. Output only the black mark with clean antialiased transparent edges; no text, border, shadow, crop change, or added artwork.
```

Save the inspected result to `assets/images/logo_mark.png`. If the generated output uses a flat chroma-key background, remove it with the bundled chroma-key helper and validate that the mark is opaque while the surrounding canvas is transparent.

- [ ] **Step 3: Generate static Android launcher density resources**

From the jade-on-black source, preserve the square composition and emit PNG files at 48, 72, 96, 144, and 192 px to the five existing `mipmap-*` `ic_launcher.png` paths. Copy the 512 px jade-on-black source to `drawable/launch_logo.png` for the native launch layer.

- [ ] **Step 4: Inspect generated assets**

Open `assets/images/logo_mark.png`, `drawable/launch_logo.png`, and `mipmap-xxxhdpi/ic_launcher.png`. Confirm transparent Flutter background, centered jade launcher mark, black native background, and no visible white source background.

### Task 2: Tint the Flutter splash mark through theme primary

**Files:**
- Modify: `lib/screens/splash_screen.dart:79-113`
- Modify: `test/widget_test.dart:1-11`
- Modify: `pubspec.yaml:assets`

**Interfaces:**
- Consumes: `assets/images/logo_mark.png`, `AppColors.primary`, `SplashScreen`.
- Produces: a `ColorFiltered` splash logo that uses `BlendMode.srcIn` and leaves the bitmap color-neutral.

- [ ] **Step 1: Write the failing splash-logo test**

```dart
import 'package:muslim_leveling/screens/splash_screen.dart';
import 'package:muslim_leveling/theme/app_theme.dart';

testWidgets('splash tints the mosque mark with the active primary color', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

  final filter = tester.widget<ColorFiltered>(find.byType(ColorFiltered));
  expect(
    filter.colorFilter,
    ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
  );
  expect(find.byType(Image), findsOneWidget);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/widget_test.dart`

Expected: FAIL because the current splash image is not wrapped in `ColorFiltered`.

- [ ] **Step 3: Implement the smallest splash change**

```dart
child: ColorFiltered(
  colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
  child: Image.asset(
    'assets/images/logo_mark.png',
    width: 64,
    height: 64,
  ),
),
```

Keep the existing 120dp container, pulse, border, shadow, title, timing, and layout unchanged. Register `assets/images/logo_mark.png` in `pubspec.yaml` before the green run, run `flutter pub get`, and retain the old `assets/images/logo.png` declaration until Task 3 removes it.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/widget_test.dart`

Expected: PASS.

### Task 3: Add the jade mark to the native startup screen and validate

**Files:**
- Modify: `android/app/src/main/res/drawable/launch_background.xml`
- Modify: `android/app/src/main/res/drawable-v21/launch_background.xml`
- Modify: `pubspec.yaml:assets`
- Modify: `lib/screens/welcome_pejuang.dart:99-104`
- Modify: `lib/screens/character_creation.dart:137-142`
- Modify: `lib/screens/home_tab.dart:280`

**Interfaces:**
- Consumes: `@drawable/launch_logo` and Android's `layer-list` launch window.
- Produces: a black native startup screen with a centered static jade mark.

- [ ] **Step 1: Replace each native white launch canvas with the jade layer**

```xml
<item android:drawable="@android:color/black" />
<item>
    <bitmap
        android:gravity="center"
        android:src="@drawable/launch_logo" />
</item>
```

Apply the same layer-list to both API variants. Replace every remaining `assets/images/logo.png` image with the transparent `logo_mark.png` wrapped in `ColorFiltered(mode: AppColors.primary, BlendMode.srcIn)`, then remove the old `assets/images/logo.png` declaration from `pubspec.yaml`.

- [ ] **Step 2: Run native-resource and asset reference checks**

Run: `rg -n "launch_logo|@android:color/black" android/app/src/main/res/drawable android/app/src/main/res/drawable-v21`

Run: `rg -n "logo_mark.png|logo.png" lib pubspec.yaml`

Expected: both XML files reference `launch_logo`; Flutter and `pubspec.yaml` reference only `logo_mark.png`.

- [ ] **Step 3: Run final validation**

Run: `flutter analyze`

Run: `flutter test`

Expected: analyzer reports `No issues found!` and all tests pass.

- [ ] **Step 4: Commit and update the existing draft PR**

```bash
git add assets/images/logo_mark.png android/app/src/main/res/drawable/launch_logo.png android/app/src/main/res/mipmap-*/ic_launcher.png android/app/src/main/res/drawable/launch_background.xml android/app/src/main/res/drawable-v21/launch_background.xml lib/screens/splash_screen.dart pubspec.yaml test/widget_test.dart
git commit -m "feat: refresh launcher and splash logo"
git add docs/superpowers/plans/2026-07-30-logo-and-launcher-assets.md
git commit -m "docs: add logo asset plan"
git push
```

# Quran Polish & Four Theme Presets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add four persistent global color presets and polish the Quran list while retaining all existing reading and playback behavior.

**Architecture:** `AppThemePreset` is the single persisted theme identity. `ThemeNotifier` owns selection and brightness, publishes it to `AppColors`, and causes MaterialApp to rebuild. A reusable theme picker renders the four options in Profile; Quran consumes only the existing color-token API and receives its visual refresh through widget structure.

**Tech Stack:** Flutter, Material 3, `shared_preferences`, `flutter_test`, existing `AppColors`/`AppText` design system.

## Global Constraints

- Preserve legacy `theme_mode = light` as Light Emerald; all other legacy or invalid values resolve to Dark Emerald.
- Keep `isLightTheme` available for existing brightness-only layout branches.
- Add no dependencies, data files, images, audio behavior, bookmarks, or Quran-specific theme preference.
- All theme labels and Quran copy are Indonesian.
- Use existing `AppColors`, `AppText`, `AppSpacing`, and `AppRadius` instead of literal colors in production widgets.

---

### Task 1: Persisted preset state and palette selection

**Files:**
- Create: `test/theme_service_test.dart`
- Modify: `lib/theme/app_theme.dart:4-241`
- Modify: `lib/services/theme_service.dart:1-52`

**Interfaces:**
- Produces `enum AppThemePreset { darkEmerald, darkNightMosque, lightEmerald, lightMushaf }` in `app_theme.dart` with `storageValue`, `label`, `modeLabel`, and `isLight` getters.
- Produces `AppThemePreset get activeThemePreset` and `set activeThemePreset(AppThemePreset value)` for `AppColors` palette lookup.
- Produces `ThemeNotifier.preset`, `ThemeNotifier.mode`, `ThemeNotifier.load()`, and `Future<void> ThemeNotifier.setPreset(AppThemePreset preset)`.
- Consumes the existing `theme_mode` preference key and current `AppColors` getter names without changing callers.

- [ ] **Step 1: Write failing notifier tests**

```dart
test('migrates the legacy light value to Light Emerald', () async {
  SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
  final notifier = ThemeNotifier();
  await notifier.load();
  expect(notifier.preset, AppThemePreset.lightEmerald);
  expect(notifier.mode, ThemeMode.light);
});

test('persists Night Mosque and updates active palette', () async {
  SharedPreferences.setMockInitialValues({});
  final notifier = ThemeNotifier();
  await notifier.setPreset(AppThemePreset.darkNightMosque);
  expect(notifier.preset, AppThemePreset.darkNightMosque);
  expect(activeThemePreset, AppThemePreset.darkNightMosque);
  expect((await SharedPreferences.getInstance()).getString('theme_mode'), 'darkNightMosque');
});
```

- [ ] **Step 2: Run the new test to verify it fails**

Run: `flutter test test/theme_service_test.dart`  
Expected: FAIL because `AppThemePreset`, `preset`, and `setPreset` do not exist.

- [ ] **Step 3: Implement the minimal preset model and dynamic palettes**

```dart
enum AppThemePreset {
  darkEmerald('darkEmerald', 'Emerald', 'Gelap', false),
  darkNightMosque('darkNightMosque', 'Night Mosque', 'Gelap', false),
  lightEmerald('lightEmerald', 'Emerald', 'Terang', true),
  lightMushaf('lightMushaf', 'Mushaf', 'Terang', true);

  const AppThemePreset(this.storageValue, this.label, this.modeLabel, this.isLight);
  final String storageValue;
  final String label;
  final String modeLabel;
  final bool isLight;
}

Future<void> setPreset(AppThemePreset value) async {
  _preset = value;
  activeThemePreset = value;
  await (await SharedPreferences.getInstance()).setString(_prefKey, value.storageValue);
  _updateSystemUi();
  notifyListeners();
}
```

Define the Night Mosque and Mushaf palette token sets alongside the existing default dark/light palettes. Make every `AppColors` getter select the active preset first, then its corresponding token. Keep `AppTheme.dark()` and `AppTheme.light()` sourced from `AppColors` so Material controls follow the active preset.

- [ ] **Step 4: Run focused tests to verify they pass**

Run: `flutter test test/theme_service_test.dart`  
Expected: PASS, including legacy migration, invalid-value fallback, all four brightness values, persistence, and listener notification.

- [ ] **Step 5: Format and commit the isolated deliverable**

Run: `dart format lib/theme/app_theme.dart lib/services/theme_service.dart test/theme_service_test.dart`  
Run: `git add lib/theme/app_theme.dart lib/services/theme_service.dart test/theme_service_test.dart && git commit -m "feat: add four persistent theme presets"`

### Task 2: Profile theme picker

**Files:**
- Create: `lib/widgets/theme_preset_picker.dart`
- Create: `test/theme_preset_picker_test.dart`
- Modify: `lib/screens/profil_tab.dart:1740-1870`

**Interfaces:**
- Produces `Future<void> showThemePresetPicker(BuildContext context)`.
- Produces `ThemePresetPicker`, a widget that renders Dark and Light groups and calls `themeNotifier.setPreset` on selection.
- Consumes `AppThemePreset.values`, `themeNotifier.preset`, and the existing global tokens.

- [ ] **Step 1: Write the failing picker test**

```dart
testWidgets('shows four presets and selects Mushaf', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ThemePresetPicker())));
  expect(find.text('Gelap'), findsOneWidget);
  expect(find.text('Terang'), findsOneWidget);
  expect(find.text('Night Mosque'), findsOneWidget);
  expect(find.text('Mushaf'), findsOneWidget);

  await tester.tap(find.text('Mushaf'));
  await tester.pump();
  expect(themeNotifier.preset, AppThemePreset.lightMushaf);
});
```

- [ ] **Step 2: Run the new test to verify it fails**

Run: `flutter test test/theme_preset_picker_test.dart`  
Expected: FAIL because the picker widget and sheet function do not exist.

- [ ] **Step 3: Implement the picker and wire Profile to it**

```dart
Future<void> showThemePresetPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    builder: (_) => const ThemePresetPicker(),
  );
}

// In ProfilTab._settings:
_SettingRow(
  'Tema aplikasi',
  Icons.palette_outlined,
  onTap: () => showThemePresetPicker(context),
),
```

Render two labeled sections, `Gelap` and `Terang`, with two accessible tap targets each. Each target shows a small token-derived swatch, the preset label, and a selected check icon. After selecting, call `Navigator.pop(context)` only if the sheet is still mounted. Remove `_ThemeToggle` completely.

- [ ] **Step 4: Run focused tests to verify they pass**

Run: `flutter test test/theme_preset_picker_test.dart test/profil_hero_card_test.dart`  
Expected: PASS, and the Profile test still renders after the setting-row change.

- [ ] **Step 5: Format and commit the isolated deliverable**

Run: `dart format lib/widgets/theme_preset_picker.dart lib/screens/profil_tab.dart test/theme_preset_picker_test.dart`  
Run: `git add lib/widgets/theme_preset_picker.dart lib/screens/profil_tab.dart test/theme_preset_picker_test.dart && git commit -m "feat: add profile theme picker"`

### Task 3: Polish the Quran list without altering behavior

**Files:**
- Modify: `lib/screens/quran_tab.dart:45-143`
- Modify: `test/quran_tab_test.dart:1-42`

**Interfaces:**
- `QuranTab` continues to load with `quranData.surahs()`, filter with `quranData.search`, and push `QuranReader`.
- `_SurahRow` continues to accept exactly `QuranSurah surah` and adds no data dependency.

- [ ] **Step 1: Write failing Quran hierarchy and navigation tests**

```dart
testWidgets('shows Quran hierarchy and opens the selected reader', (tester) async {
  await tester.pumpWidget(wrap(QuranTab()));
  await tester.pumpAndSettle();
  expect(find.text('Al-Quran'), findsOneWidget);
  expect(find.text('114 surat'), findsOneWidget);
  expect(find.text('Pilih surat'), findsOneWidget);

  await tester.tap(find.text('Al-Fatihah'));
  await tester.pumpAndSettle();
  expect(find.byType(QuranReader), findsOneWidget);
});
```

- [ ] **Step 2: Run the new test to verify it fails**

Run: `flutter test test/quran_tab_test.dart`  
Expected: FAIL because the hierarchy labels do not exist.

- [ ] **Step 3: Implement the token-based hierarchy and cards**

```dart
Text('Al-Quran', style: AppText.headlineMd().copyWith(color: AppColors.onSurface));
Text('114 surat', style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant));
Text('Pilih surat', style: AppText.labelCaps().copyWith(color: AppColors.primary));
```

Place the existing search field below the header. Put the result count beside the section label. Replace `ListTile` with a semantic `InkWell` card using existing radius/spacing and token colors: number tile, Latin title + metadata, Arabic name, and `Icons.chevron_right`. Keep search, loading, error, empty state, and reader route exactly as before; use padding that keeps content clear of the bottom navigation.

- [ ] **Step 4: Run focused tests to verify they pass**

Run: `flutter test test/quran_tab_test.dart test/quran_ayah_card_test.dart`  
Expected: PASS, including the existing search and empty-result behavior.

- [ ] **Step 5: Format and commit the isolated deliverable**

Run: `dart format lib/screens/quran_tab.dart test/quran_tab_test.dart`  
Run: `git add lib/screens/quran_tab.dart test/quran_tab_test.dart && git commit -m "feat: polish quran tab"`

### Task 4: Full integration verification

**Files:**
- Modify only if Task 1-3 verification reveals a source or test failure.

**Interfaces:**
- Consumes the completed preset, picker, and Quran hierarchy work.
- Produces a clean analyzed and tested Flutter workspace.

- [ ] **Step 1: Run static analysis**

Run: `flutter analyze`  
Expected: exit code 0 with no analyzer errors.

- [ ] **Step 2: Run the complete test suite**

Run: `flutter test`  
Expected: exit code 0 with all unit, widget, and golden tests passing.

- [ ] **Step 3: Inspect the final diff and commit status**

Run: `git status --short && git log --oneline origin/main..HEAD`  
Expected: only the three feature commits after the previously committed design spec; no generated assets or untracked files.

## Self-review

**Spec coverage:** Task 1 supplies four persistent global themes, default migration, brightness, Material colors, and System UI. Task 2 exposes the four choices in Profile. Task 3 supplies the approved Quran visual hierarchy while preserving behavior. Task 4 verifies the whole application. No out-of-scope feature is planned.

**Placeholder scan:** No deferred implementation text or unnamed interfaces appear in task steps.

**Type consistency:** `AppThemePreset`, `ThemeNotifier.setPreset`, `ThemePresetPicker`, `showThemePresetPicker`, `QuranTab`, and `_SurahRow` use the same names in all tasks.

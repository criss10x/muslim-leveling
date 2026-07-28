import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/theme_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migrates the legacy light value to Light Emerald', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    final notifier = ThemeNotifier();

    await notifier.load();

    expect(notifier.preset, AppThemePreset.lightEmerald);
    expect(notifier.mode, ThemeMode.light);
  });

  test('falls back to Dark Emerald for legacy dark and invalid values', () async {
    for (final value in ['dark', 'unknown']) {
      SharedPreferences.setMockInitialValues({'theme_mode': value});
      final notifier = ThemeNotifier();

      await notifier.load();

      expect(notifier.preset, AppThemePreset.darkEmerald);
      expect(notifier.mode, ThemeMode.dark);
    }
  });

  test('loads every saved preset with its expected brightness', () async {
    for (final preset in AppThemePreset.values) {
      SharedPreferences.setMockInitialValues({'theme_mode': preset.storageValue});
      final notifier = ThemeNotifier();

      await notifier.load();

      expect(notifier.preset, preset);
      expect(notifier.mode, preset.isLight ? ThemeMode.light : ThemeMode.dark);
      expect(isLightTheme, preset.isLight);
    }
  });

  test('persists Night Mosque and updates active palette', () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = ThemeNotifier();

    await notifier.setPreset(AppThemePreset.darkNightMosque);

    expect(notifier.preset, AppThemePreset.darkNightMosque);
    expect(activeThemePreset, AppThemePreset.darkNightMosque);
    expect(
      (await SharedPreferences.getInstance()).getString('theme_mode'),
      'darkNightMosque',
    );
  });

  test('setting a preset notifies listeners', () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = ThemeNotifier();
    var calls = 0;
    notifier.addListener(() => calls++);

    await notifier.setPreset(AppThemePreset.lightMushaf);

    expect(calls, 1);
  });
}

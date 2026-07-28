import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Persists light/dark choice. Singleton so any widget can listen.
class ThemeNotifier extends ChangeNotifier {
  static const _prefKey = 'theme_mode';
  AppThemePreset _preset = AppThemePreset.darkEmerald;

  AppThemePreset get preset => _preset;
  ThemeMode get mode => _preset.isLight ? ThemeMode.light : ThemeMode.dark;
  bool get isLight => _preset.isLight;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    _preset = AppThemePreset.values.firstWhere(
      (preset) => preset.storageValue == saved,
      orElse: () => saved == 'light'
          ? AppThemePreset.lightEmerald
          : AppThemePreset.darkEmerald,
    );
    activeThemePreset = _preset;
    _updateSystemUi();
    notifyListeners();
  }

  Future<void> toggle() async {
    await setPreset(
      _preset.isLight
          ? AppThemePreset.darkEmerald
          : AppThemePreset.lightEmerald,
    );
  }

  Future<void> setPreset(AppThemePreset preset) async {
    _preset = preset;
    activeThemePreset = preset;
    await (await SharedPreferences.getInstance())
        .setString(_prefKey, preset.storageValue);
    _updateSystemUi();
    notifyListeners();
  }

  void _updateSystemUi() {
    try {
      final isLight = _preset.isLight;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: AppColors.surface,
          systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        ),
      );
    } catch (_) {}
  }
}

final ThemeNotifier themeNotifier = ThemeNotifier();

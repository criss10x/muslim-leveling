import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Menyimpan pilihan bahasa. Singleton supaya widget mana pun bisa listen —
/// pola sama dengan [ThemeNotifier] di services/theme_service.dart.
///
/// [_override] null = ikut bahasa HP. Itu default yang diinginkan: user
/// Indonesia langsung dapat ID, HP English langsung dapat EN, tanpa set apa pun.
class LocaleNotifier extends ChangeNotifier {
  static const _prefKey = 'app_locale';

  /// Urutan penting: Flutter memakai entri PERTAMA kalau bahasa HP tidak
  /// cocok dengan satu pun (basicLocaleListResolution). EN dulu → HP Jepang
  /// dapat English, bukan Indonesia.
  ///
  /// ponytail: satu daftar = satu sumber kebenaran. Menambah bahasa = tambah
  /// ARB (`app_<kode>.arb`) + `flutter gen-l10n` + entri di sini; picker,
  /// onboarding, dan supportedLocales ikut sendiri karena semuanya membaca
  /// daftar ini. Label dibaca dari ARB (key `locale<Negara>`) supaya nama bahasa
  /// tampil dalam bahasa yang sedang aktif — sama seperti app lain.
  static const supported = [
    Locale('en'),
    Locale('id'),
    Locale('tr'),
    Locale('ms'),
  ];

  Locale? _override;

  /// null → ikut device locale.
  Locale? get override => _override;

  /// Label bahasa untuk picker. Key ARB mengikuti pola `locale<Negara>`;
  /// kode tak dikenal → kode mentahnya, bukan crash (jaga-jaga kalau ada yang
  /// menambah locale tanpa menambah key).
  static String labelFor(AppL10n l10n, Locale locale) => switch (
        locale.languageCode
      ) {
        'id' => l10n.localeIndonesian,
        'en' => l10n.localeEnglish,
        'tr' => l10n.localeTurkish,
        'ms' => l10n.localeMalay,
        _ => locale.languageCode,
      };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _override = _parse(prefs.getString(_prefKey));
    notifyListeners();
  }

  /// null = kembali ikut bahasa HP.
  Future<void> setLocale(Locale? value) async {
    _override = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, value.languageCode);
    }
    notifyListeners();
  }

  /// Kode tak dikenal (prefs korup / downgrade) → ikut HP, bukan crash.
  static Locale? _parse(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final locale in supported) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }
}

final LocaleNotifier localeNotifier = LocaleNotifier();

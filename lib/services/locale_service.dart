import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show basicLocaleListResolution;
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Menyimpan pilihan bahasa. Singleton supaya widget mana pun bisa listen —
/// pola sama dengan [ThemeNotifier] di services/theme_service.dart.
///
/// [_override] null = ikut bahasa HP. Itu default yang diinginkan: user
/// Indonesia langsung dapat ID, HP English langsung dapat EN, tanpa set apa pun.
class LocaleNotifier extends ChangeNotifier {
  static const prefKey = 'app_locale';

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

  /// Bahasa yang benar-benar dipakai sekarang: pilihan user, atau hasil
  /// resolusi bahasa HP terhadap [supported] — algoritma yang sama dengan
  /// `MaterialApp` (HP Jepang → `en`, karena itu entri pertama).
  ///
  /// Dipakai kode tanpa `BuildContext` (service). Widget yang punya context
  /// sebaiknya pakai `Localizations.localeOf(context)`: itu yang benar-benar
  /// dirender, dan tidak bisa berbeda dari UI.
  Locale get effectiveLocale => basicLocaleListResolution(
        [_override ?? PlatformDispatcher.instance.locale],
        supported,
      );

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
    _override = _parse(prefs.getString(prefKey));
    notifyListeners();
  }

  /// null = kembali ikut bahasa HP.
  Future<void> setLocale(Locale? value) async {
    _override = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(prefKey);
    } else {
      await prefs.setString(prefKey, value.languageCode);
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/screens/dashboard_shell.dart';
import 'package:muslim_leveling/services/achievement_service.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/locale_service.dart';
import 'helpers/app_wrap.dart';

/// Guard: label bottom nav dibaca dari ARB, bukan hardcoded.
///
/// Dulu `_items` menyimpan literal 'HOME'/'JADWAL'/'QURAN'/'BELAJAR'/'PROFIL',
/// jadi nav tetap Indonesia di locale en/tr/ms walau seluruh app lain sudah
/// lewat ARB. Tes ini gagal kalau literal itu kembali.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
    AchievementService.resetForTest();
  });

  /// Label nav yang seharusnya tampil, diturunkan dari ARB untuk [locale].
  /// Dipakai sebagai pembanding — bukan daftar terjemahan kedua yang bisa
  /// basi, dan bukan tebakan aturan huruf besar (Dart `toUpperCase()` tidak
  /// locale-aware: 'Vakitler' → 'VAKITLER', bukan 'VAKİTLER').
  Set<String> expectedLabels(Locale locale) {
    final l10n = lookupAppL10n(locale);
    return [
      l10n.tabHome,
      l10n.tabJadwal,
      l10n.tabQuran,
      l10n.tabBelajar,
      l10n.tabProfil,
    ].map((s) => s.toUpperCase()).toSet();
  }

  /// Render shell di [locale] lalu kembalikan label nav yang benar-benar
  /// terlihat (uppercased oleh widget). Diambil dari render tree, bukan
  /// dari daftar kedua yang bisa basi.
  Future<Set<String>> renderedNavLabels(WidgetTester t, Locale locale) async {
    await t.pumpWidget(appWrap(DashboardShell(), locale: locale));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    final nav = find.byKey(const ValueKey('nav-bar'));
    return t
        .widgetList<Text>(find.descendant(of: nav, matching: find.byType(Text)))
        .map((w) => w.data ?? '')
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  // Tiap locale yang benar-benar dikirim app dibaca dari satu sumber
  // (LocaleNotifier.supported) — menambah bahasa otomatis ikut diuji.
  for (final locale in LocaleNotifier.supported) {
    testWidgets('nav ${locale.languageCode}: label = ARB, bukan hardcoded',
        (t) async {
      final rendered = await renderedNavLabels(t, locale);
      expect(
        rendered,
        expectedLabels(locale),
        reason: 'label nav di locale ${locale.languageCode} tidak sama dengan '
            'ARB — kalau isinya label Indonesia padahal locale-nya lain, '
            'berarti masih hardcoded di DashboardShell._items.',
      );
    });
  }

  test('ARB: 5 key tab ada di SEMUA locale dan tidak kosong', () {
    for (final locale in AppL10n.supportedLocales) {
      final l10n = lookupAppL10n(locale);
      final labels = [
        l10n.tabHome,
        l10n.tabJadwal,
        l10n.tabQuran,
        l10n.tabBelajar,
        l10n.tabProfil,
      ];
      for (final label in labels) {
        expect(label.trim(), isNotEmpty,
            reason: '${locale.languageCode}: key tab kosong');
      }
    }
  });
}

// Tile Ayat Rekomendasi di Akses Cepat (Home).
//
// Yang dijaga: tile-nya ADA, labelnya dari ARB (bukan hardcode), dan
// menekannya membuka halaman Ayat Rekomendasi. Selain itu, keberadaan tile
// ke-8 tidak boleh merusak kisi 3 kolom: Home sempat punya bug tile baris 2
// melar (115px vs 111px) + lubang 114px saat baris terakhir dirakit manual.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/screens/ayat_situasi_screen.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/widgets/common.dart';

import 'helpers/app_wrap.dart';

Future<void> _pump(WidgetTester tester, {Locale locale = const Locale('id')}) async {
  await tester.pumpWidget(appWrap(const HomeTab(), locale: locale));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tile "Rekomendasi" ada di Akses Cepat', (tester) async {
    await _pump(tester);
    final l10n = AppL10n.of(tester.element(find.byType(HomeTab)));
    expect(find.text(l10n.homeQuickRekomendasi), findsOneWidget);
  });

  testWidgets('tap tile membuka halaman Ayat Rekomendasi', (tester) async {
    await _pump(tester);
    final l10n = AppL10n.of(tester.element(find.byType(HomeTab)));
    // Home lebih tinggi dari viewport tes: Akses Cepat ada di bawah lipatan.
    // Tanpa ensureVisible, tap-nya kena widget yang tidak terlihat.
    await tester.ensureVisible(find.text(l10n.homeQuickRekomendasi));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.homeQuickRekomendasi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AyatSituasiScreen), findsOneWidget);
  });

  testWidgets('label tile ikut bahasa, bukan hardcode Indonesia',
      (tester) async {
    final seen = <String, String>{};
    for (final loc in [const Locale('id'), const Locale('tr')]) {
      await _pump(tester, locale: loc);
      final l10n = AppL10n.of(tester.element(find.byType(HomeTab)));
      seen[loc.languageCode] = l10n.homeQuickRekomendasi;
      expect(l10n.homeQuickRekomendasi, isNotEmpty);
    }
    expect(seen['id'], isNot(seen['tr']),
        reason: 'label tile sama di id dan tr → kunci ARB tidak terpakai');
  });

  testWidgets('semua tile dalam satu baris lebarnya sama', (tester) async {
    // 8 tile = 3 baris: 3 + 3 + 2. Baris terakhir yang tidak penuh harus tetap
    // 1/3 kolom (slot kosong), bukan melar mengisi sisa.
    await _pump(tester);
    final l10n = AppL10n.of(tester.element(find.byType(HomeTab)));
    final labels = [
      l10n.homeQuickHadis,
      l10n.homeQuickDoa,
      l10n.homeQuickAsma,
      l10n.homeQuickKiblat,
      l10n.homeQuickDzikir,
      l10n.homeQuickRenungan,
      l10n.homeQuickHariPenting,
      l10n.homeQuickRekomendasi,
    ];
    // Ukur lebar wadah tiap label (PressableScale di dalam Expanded).
    final widths = <String, double>{};
    for (final l in labels) {
      final f = find.ancestor(
        of: find.text(l),
        matching: find.byType(PressableScale),
      );
      expect(f, findsOneWidget, reason: '"$l" bukan tile?');
      widths[l] = tester.getSize(f).width;
    }
    final vals = widths.values.toList();
    final min = vals.reduce((a, b) => a < b ? a : b);
    final max = vals.reduce((a, b) => a > b ? a : b);
    expect(max - min, lessThan(0.5),
        reason: 'lebar tile tidak seragam: $widths');
  });
}

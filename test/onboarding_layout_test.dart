// Regresi layout onboarding: tidak boleh ada RenderFlex overflow, dan tiap
// halaman harus bisa di-scroll saat ruang tidak cukup (layar kecil / font besar).
//
// Ini penjaga untuk satu kelas bug, bukan satu halaman: `_PageBody` membungkus
// keenam halaman, dan `GhostButton` dipakai di banyak layar lain — dulu label
// panjangnya jebol horizontal karena tidak ada FittedBox.
//
// Angka rujukan (sebelum perbaikan): 320x568 @1.0 → p1 52px, p3 8px;
// @1.3 → p3 139px, p4 103px; @1.5 → p3 196px, p4 172px, p6 4px ke kanan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';

Widget _wrap(Widget child, double scale) => MaterialApp(
      locale: const Locale('id'),
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: AppL10n.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      builder: (ctx, kid) => MediaQuery(
        data:
            MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)),
        child: kid!,
      ),
      home: child,
    );

Future<void> _settle(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final (label, size, scale) in [
    ('360x800@1.0 (baseline)', const Size(360, 800), 1.0),
    ('320x568@1.0', const Size(320, 568), 1.0),
    ('320x568@1.3', const Size(320, 568), 1.3),
    ('320x568@1.5', const Size(320, 568), 1.5),
  ]) {
    testWidgets('tanpa overflow + bisa scroll: $label', (tester) async {
      SharedPreferences.setMockInitialValues({});
      // Bangun dari nol; jangan re-pump widget yang sama, karena PageView
      // menyimpan posisi antar pompa dan halaman yang diperiksa jadi salah.
      await tester.pumpWidget(const SizedBox());
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      await tester.pumpWidget(_wrap(const OnboardingScreen(), scale));
      await _settle(tester, 900);

      final pv = tester.widget<PageView>(find.byType(PageView));
      for (var p = 0; p < 6; p++) {
        pv.controller!.jumpToPage(p);
        await _settle(tester, 700);

        final overflow = <Object>[];
        while (true) {
          final e = tester.takeException();
          if (e == null) break;
          overflow.add(e);
        }
        // reason: dievaluasi eager — jangan panggil overflow.first saat kosong.
        expect(overflow, isEmpty,
            reason: overflow.isEmpty
                ? ''
                : '$label halaman ${p + 1} overflow: ${overflow.first}');

        // Halaman bisa di-scroll kalau kontennya lebih tinggi dari viewport
        // (SingleChildScrollView selalu hadir lewat _PageBody).
        expect(
          find
              .descendant(
                of: find.byType(PageView),
                matching: find.byType(Scrollable),
              )
              .evaluate()
              .length,
          greaterThanOrEqualTo(2),
          reason: '$label halaman ${p + 1} tidak punya scrollable',
        );
      }
    });
  }
}

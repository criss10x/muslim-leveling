// ponytail: penjaga "isi tab tidak ketutup nav bar". Ukur pakai GEOMETRI
// sebenarnya (tinggi nav bar dari render tree), bukan angka sihir — kalau bar
// naik jadi 80dp nanti, tes tetap benar.
//
// Konteks bug: `extendBody: true` menaruh body DI BELAKANG nav bar yang solid,
// jadi tiap tab ketutup 64dp + inset navigasi. Tes ini gagal kalau itu kembali.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/screens/dashboard_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences.setMockInitialValues({});


  testWidgets('setiap tab: konten scroll punya ruang di atas nav bar (#bug)',
      (tester) async {
    // Pixel-7-class device + inset navigasi. ponytail: lebar 412dp, bukan 360,
    // karena di 360 ada overflow horizontal yang SUDAH ADA sebelumnya
    // (home_tab.dart:830, belajar_tab.dart:132) — itu bug lain, jangan sampai
    // bikin tes ini merah dan mengubur sinyal inset bawah.
    tester.view.physicalSize = const Size(1236, 2745);
    tester.view.devicePixelRatio = 3;
    tester.view.viewPadding = const FakeViewPadding(bottom: 72, top: 90);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: DashboardShell()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final navTop = tester.getRect(find.byKey(const ValueKey('nav-bar'))).top;
    expect(navTop, lessThan(tester.view.physicalSize.height / 3));

    // Scroll tiap tab sampai mentok bawah, lalu pastikan item terakhir
    // benar-benar berhenti DI ATAS nav bar — bukan di belakangnya.
    for (final label in ['JADWAL', 'QURAN', 'BELAJAR', 'PROFIL']) {
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final scrollable = find.byType(Scrollable).first;
      if (scrollable.evaluate().isEmpty) continue;
      await tester.drag(scrollable, const Offset(0, -6000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final scrollBottom = tester.getRect(scrollable).bottom;
      final visibleBottom = navTop;
      expect(
        scrollBottom,
        lessThanOrEqualTo(visibleBottom + 1),
        reason: 'tab $label: area scroll (${scrollBottom.toStringAsFixed(1)}) '
            'menembus nav bar (${visibleBottom.toStringAsFixed(1)}) — konten '
            'terakhir bakal ketutup',
      );
    }
  });
}

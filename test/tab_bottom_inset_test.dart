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
import 'package:muslim_leveling/screens/home_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences.setMockInitialValues({});


  testWidgets('setiap tab: konten scroll punya ruang di atas nav bar (#bug)',
      (tester) async {
    // Pixel-7-class device + inset navigasi.
    tester.view.physicalSize = const Size(1236, 2745);
    tester.view.devicePixelRatio = 3;
    // ponytail: `padding` harus di-set juga — viewPadding saja tidak mengalir
    // ke MediaQuery.padding, dan SafeArea (di dalam nav bar) membacanya.
    const insets = FakeViewPadding(bottom: 72, top: 90);
    tester.view.viewPadding = insets;
    tester.view.padding = insets;
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

  // ⚠️ Dua pendekatan yang GAGAL dipakai di sini (jangan ulangi):
  // 1. "nol RenderFlex overflow di 360dp" — tidak deterministik. Dengan bug
  //    yang sama, satu run melaporkan "overflowed by 49 pixels", run berikutnya
  //    0 (ukuran teks font test jatuh persis di batas kolom).
  // 2. `find.ancestor(matching: find.byType(Expanded))` — selalu ketemu, karena
  //    seluruh Row-nya memang ada di dalam Expanded milik layout induk.
  //
  // Yang deterministik: lebar label harus DIBATASI (tight), bukan intrinsik.
  // `Expanded` memberi constraint minWidth == maxWidth; `Text` telanjang di Row
  // dapat maxWidth: Infinity. Tidak ada pengukuran teks di sini, jadi hasilnya
  // tidak bergantung ambient state.
  testWidgets('label _ringStat dibatasi lebarnya (bukan Text telanjang di Row)',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HomeTab())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    var checked = 0;
    for (final label in ['WAJIB', 'SUNNAH', 'SIDE QUEST']) {
      final finder = find.text(label);
      if (finder.evaluate().isEmpty) continue; // ring belum render
      checked++;
      final box = tester.renderObject<RenderBox>(finder);
      expect(
        box.constraints.minWidth,
        box.constraints.maxWidth,
        reason: 'label "$label" tidak dibatasi lebarnya — Text telanjang di Row '
            'pakai lebar intrinsik dan didorong keluar kolom oleh Spacer di '
            'layar sempit (RenderFlex overflow). Bungkus dengan Expanded.',
      );
    }
    expect(checked, greaterThan(0),
        reason: 'tidak ada label _ringStat yang ter-render — tes tidak menguji apa pun');
  });
}

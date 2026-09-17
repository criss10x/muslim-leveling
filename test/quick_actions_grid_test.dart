// ponytail: penjaga proporsi kisi "Akses Cepat".
//
// Kenapa ukuran RECT, bukan teks: rect dari render tree itu eksak dan
// deterministik. (Ukuran teks TIDAK — lihat catatan di tab_bottom_inset_test,
// di sana "nol overflow" berubah hasil antar-run.)
//
// Dulu baris ke-2 dirakit manual dengan Spacer(flex: 1) → tile-nya ikut melar
// (diukur dari PNG: 115px vs 111px) dan menyisakan lubang 114px di kanan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:muslim_leveling/widgets/common.dart';
import 'helpers/app_wrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tile Akses Cepat proporsional: seragam lebar & tinggi', (t) async {
    t.view.physicalSize = const Size(412, 915);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);

    await t.pumpWidget(
      appWrap(const Scaffold(body: HomeTab()), theme: AppTheme.dark()),
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    await t.scrollUntilVisible(find.text('AKSES CEPAT'), 200);
    await t.pump();

    // Tile = PressableScale yang memuat chip ikon + label. Ambil rect-nya.
    final boxes = find
        .descendant(
          of: find.byType(FlatCard),
          matching: find.byType(PressableScale),
        )
        .evaluate()
        .map((e) => (e.renderObject as RenderBox))
        .where((b) => b.hasSize)
        .map((b) => b.size)
        .toList();

    expect(boxes.length, 5, reason: 'harus 5 tile (4 pintasan + Renungan)');

    final widths = boxes.map((s) => s.width).toSet();
    final heights = boxes.map((s) => s.height).toSet();

    // Toleransi 0.5px untuk pembulatan subpiksel.
    expect(
      widths.length,
      1,
      reason: 'lebar tile harus SERAGAM, dapat: '
          '${boxes.map((s) => s.width.toStringAsFixed(1)).toList()}',
    );
    expect(
      heights.length,
      1,
      reason: 'tinggi tile harus SERAGAM, dapat: '
          '${boxes.map((s) => s.height.toStringAsFixed(1)).toList()}',
    );
    expect(widths.first, greaterThan(100));
    expect(heights.first, greaterThan(60));
  });
}

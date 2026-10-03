// Penjaga pemilih skin kiblat.
//
// Dua regresi yang pernah terjadi dan tidak tertangkap test mana pun:
//  1. Preview dial dirender sebagai TELUR, bukan lingkaran. `SizedBox(92x92)`
//     dibungkus `Expanded` di dalam Row, jadi lebarnya tertekan jadi ~47dp di
//     layar 320dp sementara tingginya tetap 92dp (rasio 1,95).
//  2. Nama skin dipotong `split(' ').first`, jadi justru kata yang menjelaskan
//     karakternya yang hilang: "Antique Brass" -> "Antique", "Midnight Gold" ->
//     "Midnight". Hanya "Shamseh" yang utuh (satu kata), jadi tampak tak konsisten.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/qibla_screen.dart';
import 'package:muslim_leveling/services/qibla_skin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('preview tiap skin bulat, bukan telur, di layar sempit',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(appWrap(const Scaffold(body: QiblaSkinPicker())));
    await tester.pumpAndSettle();

    final previews = find.descendant(
      of: find.byType(QiblaSkinPicker),
      matching: find.byType(CustomPaint),
    );
    final measured = <Size>[];
    for (final e in previews.evaluate()) {
      final size = tester.getSize(find.byWidget(e.widget));
      // buang CustomPaint non-preview (mis. dari decoration)
      if (size.width > 20 && size.width < 200) measured.add(size);
    }

    expect(measured.length, QiblaSkin.values.length,
        reason: 'satu preview per skin');
    for (final size in measured) {
      final ratio = size.height / size.width;
      expect(ratio, closeTo(1.0, 0.05),
          reason: 'preview harus lingkaran (rasio ~1.0), bukan telur. '
              'Terukur ${size.width}x${size.height} (rasio ${ratio.toStringAsFixed(2)})');
    }
  });

  testWidgets('nama skin tampil lengkap, bukan dipotong jadi kata pertama',
      (tester) async {
    await tester.pumpWidget(appWrap(const Scaffold(body: QiblaSkinPicker())));
    await tester.pumpAndSettle();

    for (final skin in QiblaSkin.values) {
      final finder = find.text(skin.label);
      expect(finder, findsOneWidget,
          reason: 'label utuh "${skin.label}" harus tampil');

      // Terpotong-ellipsis bukan sekadar "teks ada": periksa paragrafnya.
      // Nama terpanjang butuh 126px; dengan lebar opsi 72px dan maxLines 2,
      // tiap nama muat utuh. Kalau lebar opsi diperkecil lagi, ini yang gagal.
      final para = tester.renderObject<RenderParagraph>(finder);
      expect(para.didExceedMaxLines, isFalse,
          reason: 'nama "${skin.label}" terpotong; perlebar opsi atau kecilkan font');
    }
    // Potongan kata pertama tidak boleh jadi satu-satunya teks.
    expect(find.text('Brass'), findsNothing);
    expect(find.text('Gold'), findsNothing);
    expect(find.text('Minimal'), findsNothing);
  });

  testWidgets('pintu masuk ganti skin terbaca sebagai aksi dan membuka picker',
      (tester) async {
    await tester.pumpWidget(appWrap(
      Builder(builder: (context) {
        return Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const QiblaScreen(cityName: 'Jakarta'),
                ),
              ),
              child: const Text('buka'),
            ),
          ),
        );
      }),
    ));
    await tester.tap(find.text('buka'));
    // pumpAndSettle menggantung: ada firefly AmbientBackground + denyut yang
    // berulang tanpa henti. Jadi pump bertahap sampai header benar-benar ada.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Label aksi (bukan sekadar nama skin) harus ada di header.
    final entry = find.text('Ganti tampilan');
    expect(entry, findsOneWidget,
        reason: 'pintu masuk harus menyebut aksinya, bukan cuma nama skin');

    await tester.tap(entry);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byType(QiblaSkinPicker), findsOneWidget,
        reason: 'menekan pintu masuk membuka pemilih skin');
  });

  testWidgets('memilih skin menyimpan pilihan dan menutup picker',
      (tester) async {
    qiblaSkinNotifier.setSkin(QiblaSkin.nurDial);
    await tester.pumpWidget(appWrap(const Scaffold(body: QiblaSkinPicker())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Antique Brass'));
    await tester.pumpAndSettle();

    expect(qiblaSkinNotifier.skin, QiblaSkin.antique,
        reason: 'pilihan skin harus tersimpan');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('kibla_skin'), 'antique',
        reason: 'tersimpan permanen di SharedPreferences');
  });
}

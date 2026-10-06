import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/quran_tab.dart';

import 'helpers/app_wrap.dart';

/// Kartu panduan "Cara mencari" di bawah kotak cari tab Quran.
///
/// Ditaruh selama kotak cari kosong, lalu menghilang begitu user mengetik:
/// kalau menetap, ia merebut ruang hasil pencarian di layar kecil.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openTab(WidgetTester tester) async {
    await tester.pumpWidget(appWrap(const Scaffold(body: QuranTab())));
    await tester.pumpAndSettle();
  }

  testWidgets('panduan tampil saat kotak cari masih kosong', (tester) async {
    await openTab(tester);

    expect(find.text('Cara mencari'), findsOneWidget);
    // Ketiga jalan masuk, memakai contoh yang benar-benar bekerja.
    expect(find.text('Al-Baqarah 286'), findsOneWidget);
    expect(find.text('kesabaran'), findsOneWidget);
    expect(find.text('sapi'), findsOneWidget);
  });

  testWidgets('panduan hilang begitu user mengetik', (tester) async {
    await openTab(tester);
    expect(find.text('Cara mencari'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'baqarah');
    await tester.pumpAndSettle();

    expect(find.text('Cara mencari'), findsNothing,
        reason: 'panduan harus menyingkir supaya hasil dapat ruangnya');
  });

  testWidgets('tap contoh mengisi kotak cari dan menjalankan pencarian',
      (tester) async {
    await openTab(tester);

    // "sapi" -> arti surat; jalur ini tidak butuh index terjemahan.
    await tester.tap(find.text('sapi'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'sapi',
        reason: 'contoh yang ditap harus masuk ke kotak cari');
    // Panduan menyingkir karena kotak sudah terisi.
    expect(find.text('Cara mencari'), findsNothing);
    // Hasilnya surat yang benar, bukan daftar kosong.
    expect(find.text('Al-Baqarah'), findsWidgets);
  });

  testWidgets('tap contoh acuan ayat membuka kartu ayat', (tester) async {
    await openTab(tester);

    await tester.tap(find.text('Al-Baqarah 286'));
    await tester.pump(const Duration(milliseconds: 600)); // debounce
    await tester.pumpAndSettle();

    expect(find.text('Ayat 286 dari 286'), findsOneWidget,
        reason: 'contoh acuan harus langsung menghasilkan kartu ayat');
    expect(find.text('Cara mencari'), findsNothing);
  });

  testWidgets('tidak overflow di layar sempit 320dp', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await openTab(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Cara mencari'), findsOneWidget);
  });
}

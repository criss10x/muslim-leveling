import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/quran_tab.dart';

import 'helpers/app_wrap.dart';

/// Bantuan "Cara mencari" di tab Quran.
///
/// Bentuknya tombol ikon di dalam kotak cari + jendela penjelasan. Sebelumnya
/// kartu panduan setinggi ~198dp yang duduk di aliran daftar; di HP terasa
/// terlalu tinggi (keluhan user) dan menekan daftar surat ke bawah.
///
/// Yang dijaga di sini: daftar TIDAK lagi kehilangan tinggi karena panduan,
/// tombolnya ada dan bisa ditap, jendelanya memuat ketiga cara, dan memilih
/// contoh langsung mengisi kotak cari.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openTab(WidgetTester tester) async {
    await tester.pumpWidget(appWrap(const Scaffold(body: QuranTab())));
    await tester.pumpAndSettle();
  }

  /// Buka jendela bantuan lewat tombolnya (bukan memanggil method privat).
  Future<void> openHelp(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
  }

  testWidgets('panduan TIDAK lagi memakan tinggi daftar surat',
      (tester) async {
    await openTab(tester);

    // Kartu lama sudah tidak ada di aliran daftar.
    expect(find.text('Cara mencari'), findsNothing,
        reason: 'panduan tidak boleh lagi duduk di daftar');
    // Tapi pintu masuknya tetap ada.
    expect(find.byIcon(Icons.help_outline), findsOneWidget);

    // Surat pertama tetap terlihat tanpa perlu menggulir: dulu panduan
    // setinggi 198dp mendorongnya turun.
    expect(find.text('Al-Fatihah'), findsOneWidget);
  });

  testWidgets('tombol bantuan membuka jendela berisi tiga cara',
      (tester) async {
    await openTab(tester);
    await openHelp(tester);

    // Judul + ketiga cara, memakai contoh yang benar-benar bekerja.
    expect(find.text('Cara mencari'), findsOneWidget);
    expect(find.text('Al-Baqarah 286'), findsOneWidget);
    expect(find.text('kesabaran'), findsOneWidget);
    expect(find.text('sapi'), findsOneWidget);
  });

  testWidgets('pilih contoh mengisi kotak cari, menutup jendela, dan mencari',
      (tester) async {
    await openTab(tester);
    await openHelp(tester);

    // "sapi" -> arti surat; jalur ini tidak butuh index terjemahan.
    await tester.tap(find.text('sapi'));
    await tester.pumpAndSettle();

    // Jendelanya tertutup.
    expect(find.text('Cara mencari'), findsNothing);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'sapi',
        reason: 'contoh yang dipilih harus masuk ke kotak cari');
    expect(find.text('Al-Baqarah'), findsWidgets);
  });

  testWidgets('pilih contoh acuan ayat membuka kartu ayat', (tester) async {
    await openTab(tester);
    await openHelp(tester);

    await tester.tap(find.text('Al-Baqarah 286'));
    await tester.pump(const Duration(milliseconds: 600)); // debounce
    await tester.pumpAndSettle();

    expect(find.text('Ayat 286 dari 286'), findsOneWidget);
  });

  testWidgets('tombol bantuan punya label a11y', (tester) async {
    await openTab(tester);
    // Semantics label, bukan cuma ikon: TalkBack harus bisa menyebut fungsinya.
    expect(
      find.bySemanticsLabel('Cara mencari'),
      findsOneWidget,
      reason: 'tombol bantuan butuh label untuk pembaca layar',
    );
  });

  testWidgets('tidak overflow di layar sempit 320dp', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await openTab(tester);
    expect(tester.takeException(), isNull);

    await openHelp(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Cara mencari'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/widgets/quran_share_sheet.dart';
import 'package:muslim_leveling/widgets/share_card_kit.dart';

import 'helpers/app_wrap.dart';

/// Ruang preview kartu share + pembagian kontrol ke 3 tab.
///
/// Keluhan user: "banyaknya settingan bikin preview kecil". Terukur sebelum
/// perbaikan di 360x640: preview cuma 72x128dp (20% tinggi layar) sementara
/// kontrol menghabiskan 356dp, karena keenam kelompok kontrol tampil bertumpuk.
///
/// Sesudah panel tab: kontrol menetap 280dp, preview 133x236dp (37%). Angka itu
/// yang dikunci di sini, supaya penambahan setting berikutnya tidak diam-diam
/// memakan ruang preview lagi.
void main() {
  const surah = QuranSurah(
    number: 2,
    nameArabic: 'البقرة',
    nameLatin: 'Al-Baqarah',
    meaning: 'Sapi Betina',
    ayahCount: 286,
    revelation: 'Madaniyah',
  );
  const ayah = QuranAyah(
    ayah: 255,
    arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    translation: 'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup.',
  );

  Future<void> openSheet(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      appWrap(
        Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: TextButton(
                onPressed: () =>
                    showQuranShareSheet(ctx, surah: surah, ayah: ayah),
                child: const Text('buka'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  testWidgets('preview dapat >= 35% tinggi layar di 360x640', (tester) async {
    await openSheet(tester, const Size(360, 640));
    final sheetH = tester.getSize(find.byType(Scaffold)).height;
    final preview = tester.getSize(find.byType(FittedBox));
    // Regresi yang dijaga: 20% (sebelum tab) -> 37% (sesudah).
    expect(preview.height / sheetH, greaterThan(0.34),
        reason: 'preview menyusut lagi: '
            '${preview.height.toStringAsFixed(0)}dp dari '
            '${sheetH.toStringAsFixed(0)}dp');
    expect(tester.takeException(), isNull);
  });

  testWidgets('kontrol menetap tidak lebih dari 310dp', (tester) async {
    await openSheet(tester, const Size(360, 640));
    final controls = tester.getSize(find.byType(ShareCardControls));
    // 356dp sebelum tab. Batas 310 memberi ruang untuk penyesuaian kecil
    // tanpa membiarkan satu kelompok kontrol baru ditambahkan sembarangan.
    expect(controls.height, lessThan(310),
        reason: 'kontrol menetap ${controls.height.toStringAsFixed(0)}dp, '
            'terlalu tinggi untuk layar 640dp');
  });

  testWidgets('hanya tab aktif yang dirender', (tester) async {
    await openSheet(tester, const Size(360, 640));

    // Tab Latar: chip mode ada, chip konten & rasio tidak.
    expect(find.text('Solid'), findsOneWidget);
    expect(find.text('Arab'), findsNothing);
    expect(find.text('9:16'), findsNothing);

    await tester.tap(find.text('Isi'));
    await tester.pumpAndSettle();
    expect(find.text('Arab'), findsOneWidget);
    expect(find.text('Solid'), findsNothing,
        reason: 'tab Latar harus dilepas saat tab Isi dibuka');

    await tester.tap(find.text('Ukuran'));
    await tester.pumpAndSettle();
    expect(find.text('9:16'), findsOneWidget);
    expect(find.text('Arab'), findsNothing);
  });

  testWidgets('pindah tab tidak kehilangan pilihan', (tester) async {
    await openSheet(tester, const Size(360, 640));

    // Pilih rasio 1:1 di tab Ukuran.
    await tester.tap(find.text('Ukuran'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1:1'));
    await tester.pumpAndSettle();

    // Pergi ke tab lain lalu balik: pilihannya harus masih terpilih.
    await tester.tap(find.text('Latar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ukuran'));
    await tester.pumpAndSettle();

    // Kartu 1:1 berarti lebar == tinggi di area preview.
    final preview = tester.getSize(find.byType(FittedBox));
    expect(preview.width, isNot(equals(0)),
        reason: 'preview tidak boleh kolaps setelah pindah tab');
    expect(tester.takeException(), isNull);
  });

  testWidgets('tidak ada overflow di layar sempit 320x568', (tester) async {
    await openSheet(tester, const Size(320, 568));
    // Baris chip konten dulu melaporkan "RenderFlex overflowed" (3,5px di
    // 360dp, lebih parah di 320dp). Kini Wrap.
    for (final tab in ['Isi', 'Ukuran', 'Latar']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'overflow di tab $tab');
    }
  });
}

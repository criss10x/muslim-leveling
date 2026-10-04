import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/asma_screen.dart';
import 'package:muslim_leveling/services/asma_data.dart';
import 'package:muslim_leveling/services/asma_meanings.dart';
import 'package:muslim_leveling/widgets/share_card_kit.dart';

import 'helpers/app_wrap.dart';
import 'helpers/golden_fonts.dart';

/// Harness: buka layar share Asma lewat entry point publiknya, supaya tes ini
/// tidak perlu menyentuh kelas private _AsmaShareScreen.
class AsmaShareScreenHarness extends StatelessWidget {
  final AsmaItem item;
  const AsmaShareScreenHarness({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => showAsmaShareSheet(ctx, item: item),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }
}

void main() {
  // Font harus dimuat manual atau teks ter-render kotak .notdef (lihat
  // golden_fonts.dart — golden kartu share sempat begini sejak awal).
  setUpAll(loadGoldenFonts);

  const item = AsmaItem(
    number: 1,
    arab: 'الرَّحْمَنُ',
    translit: 'Ar Rahmaan',
    meaningEn: 'The Beneficent',
  );

  Widget card(double aspect) => appWrap(
        Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: AsmaSharePreviewCard(
                item: item,
                meaning: asmaMeaning('id', item.number),
                aspect: aspect,
              ),
            ),
          ),
        ),
      );

  for (final (name, aspect) in [('9x16', 9 / 16), ('3x4', 3 / 4), ('1x1', 1.0)]) {
    testWidgets('asma share card $name ter-render dan teks centered', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(card(aspect));
      await tester.pumpAndSettle();

      // Translit terlihat sekali (subtitle). Pill footer sekarang sitasi —
      // dulu pill mencetak translit yang sama dua kali dalam satu kartu.
      expect(find.text('Ar Rahmaan'), findsOneWidget);
      // Teks utama center-aligned (aturan UI kartu share).
      final centeredTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => t.textAlign == TextAlign.center)
          .length;
      expect(centeredTexts, greaterThanOrEqualTo(3),
          reason: 'arab, translit, dan arti harus centered');

      await expectLater(
        find.byType(AsmaSharePreviewCard),
        matchesGoldenFile('goldens/asma_share_$name.png'),
      );

    });
  }

  testWidgets('asma grid tampil 99 nama dengan arti per-locale', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(appWrap(const AsmaScreen()));
    await tester.pumpAndSettle();

    // Grid ter-render dan data 99 item lengkap.
    expect(find.byType(GridView), findsOneWidget);
    expect(asmaList.length, 99);
    expect(asmaList.first.number, 1);
    expect(asmaList.last.number, 99);

    // Arti per-locale tersedia untuk semua 99 nama di 4 locale.
    for (final locale in ['id', 'en', 'ms', 'tr']) {
      for (final it in asmaList) {
        expect(asmaMeaning(locale, it.number), isNotEmpty,
            reason: 'arti $locale #${it.number} kosong');
      }
    }
  });

  testWidgets('kartu Asma memakai kit bersama: 17 preset + mode + rasio',
      (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(appWrap(AsmaShareScreenHarness(item: item)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // 17 preset harus tersedia — jumlah sama dengan kartu ayat Quran.
    // Kalau kit dilepas dari layar ini, angka ini yang menangkapnya.
    expect(shareBgPresets.length, 17);

    // Chip mode background ada (Solid/Gradasi/Estetik + Foto Saya).
    expect(find.text('Solid'), findsOneWidget);
    expect(find.text('Gradasi'), findsOneWidget);
    expect(find.text('Estetik'), findsOneWidget);
    // Mode keempat: background dari foto user.
    expect(find.text('Foto Saya'), findsOneWidget);

    // Chip mode WAJIB muat: sejak 4 chip, barisnya pernah overflow 51px di
    // layar 420dp (lebih parah di HP 360dp). Kalau seseorang mengembalikannya
    // jadi Row, tes ini yang menangkapnya.
    expect(tester.takeException(), isNull,
        reason: 'chip mode tidak boleh overflow di layar 420dp');

    // Ganti ke Estetik → 9 swatch foto muncul.
    await tester.tap(find.text('Estetik'));
    await tester.pumpAndSettle();
    expect(
      shareBgPresets.where((p) => p.kind == ShareBgKind.esthetic).length,
      9,
    );

    // Toggle konten ada: Arab + Arti.
    expect(find.text('Arab'), findsOneWidget);
    expect(find.text('Arti'), findsOneWidget);

    // Rasio 3 pilihan.
    expect(find.text('9:16'), findsOneWidget);
    expect(find.text('3:4'), findsOneWidget);
    expect(find.text('1:1'), findsOneWidget);

    // Badge Google Play ikut (footer kit) — kartu Asma dulu tidak punya.
    expect(find.text('Google Play'), findsOneWidget);
  });
}

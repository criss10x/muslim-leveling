import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/asma_screen.dart';
import 'package:muslim_leveling/services/asma_data.dart';
import 'package:muslim_leveling/services/asma_meanings.dart';

import 'helpers/app_wrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const item = AsmaItem(
    number: 1,
    arab: 'الرَّحْمَنُ',
    translit: 'Ar Rahmaan',
    meaningEn: 'The Beneficent',
  );

  Widget card(double aspect) => appWrap(
        Scaffold(
          body: Center(
            child: AsmaSharePreviewCard(
              item: item,
              meaning: asmaMeaning('id', item.number),
              aspect: aspect,
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

      // Translit terlihat (subtitle + pill footer).
      expect(find.text('Ar Rahmaan'), findsNWidgets(2));
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
}

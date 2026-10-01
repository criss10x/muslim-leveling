import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/widgets/quran_share_sheet.dart';
import 'helpers/app_wrap.dart';
import 'helpers/golden_fonts.dart';

void main() {
  setUpAll(loadGoldenFonts);

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
    translation:
        'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup, Yang terus-menerus mengurus makhluk-Nya.',
  );

  Widget card(double aspect) => appWrap(
        Scaffold(
          body: Center(
            child: QSharePreviewCard(surah: surah, ayah: ayah, aspect: aspect),
          ),
        ),
      );

  for (final (name, aspect) in [('9x16', 9 / 16), ('3x4', 3 / 4), ('1x1', 1.0)]) {
    testWidgets('share card $name ter-render dan teks centered', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(card(aspect));
      await tester.pumpAndSettle();

      // Teks utama ada di layar.
      expect(find.textContaining('Allah'), findsWidgets);
      expect(find.textContaining('Muslim Leveling'), findsWidgets);

      // Teks konten (arab, terjemahan) memakai TextAlign.center.
      final centeredTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => t.textAlign == TextAlign.center)
          .length;
      expect(centeredTexts, greaterThanOrEqualTo(3),
          reason: 'arab, terjemahan, dan header harus centered');

      await expectLater(
        find.byType(QSharePreviewCard),
        matchesGoldenFile('goldens/quran_share_$name.png'),
      );
      expect(
        File('test/goldens/quran_share_$name.png').existsSync(),
        isTrue,
        reason: 'golden $name harus tersimpan',
      );

    });
  }
}

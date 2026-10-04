import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/widgets/quran_share_sheet.dart';
import 'package:muslim_leveling/widgets/share_card_kit.dart';
import 'helpers/app_wrap.dart';
import 'helpers/golden_fonts.dart';
import 'helpers/share_assets.dart';

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

      // Badge Google Play harus BENAR-BENAR termuat sebelum dipotret. Tanpa
      // ini golden-nya lulus dengan badge kosong (terbukti: tidak ada satu pun
      // piksel hitam di area footer pada golden hasil CI).
      await precacheShareBadge(tester, only: 'id');
      await tester.pump(const Duration(milliseconds: 200));

      // Badge harus sudah punya ukuran saat dipotret. Sebelum ini golden
      // sempat lulus dengan badge KOSONG: `Image.asset` belum selesai memuat,
      // ukurannya 0x0, dan tidak ada satu pun piksel hitam di area footer.
      expect(tester.getSize(find.byType(GooglePlayBadge)).width,
          greaterThan(20), reason: 'badge belum termuat saat dipotret');

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

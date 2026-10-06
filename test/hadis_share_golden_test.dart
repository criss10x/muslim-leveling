import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/hadis_api.dart';
import 'package:muslim_leveling/widgets/hadis_share_sheet.dart';
import 'package:muslim_leveling/widgets/share_card_kit.dart';

import 'helpers/app_wrap.dart';
import 'helpers/golden_fonts.dart';
import 'helpers/share_assets.dart';

/// Golden kartu share hadis, tiga rasio (pola kartu share ayat & Asma).
void main() {
  setUpAll(loadGoldenFonts);

  const item = HadisItem(
    id: 1234,
    ar: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
    idn: 'Sesungguhnya setiap amalan tergantung pada niatnya.',
    grade: 'Sahih Hadis',
    takhrij: 'HR. Bukhari no. 1',
    hikmah: 'Niat menentukan nilai amal.',
  );

  Widget card(double aspect) => appWrap(
        Scaffold(
          body: Center(
            child: HadisSharePreviewCard(item: item, aspect: aspect),
          ),
        ),
      );

  for (final (name, aspect) in [('9x16', 9 / 16), ('3x4', 3 / 4), ('1x1', 1.0)]) {
    testWidgets('kartu share hadis $name ter-render', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(card(aspect));
      await tester.pumpAndSettle();

      // Badge wajib benar-benar termuat sebelum dipotret: tanpa ini golden
      // "lulus" dengan badge kosong (pola yang sudah terbukti di kartu ayat).
      await precacheShareBadge(tester, only: 'id');
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.getSize(find.byType(GooglePlayBadge)).width,
          greaterThan(20), reason: 'badge belum termuat saat dipotret');
      expect(find.textContaining('Muslim Leveling'), findsWidgets);
      expect(tester.takeException(), isNull);

      await expectLater(
        find.byType(HadisSharePreviewCard),
        matchesGoldenFile('goldens/hadis_share_$name.png'),
      );
      expect(
        File('test/goldens/hadis_share_$name.png').existsSync(),
        isTrue,
        reason: 'golden $name harus tersimpan',
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/widgets/share_card_kit.dart';

/// Memuat aset badge Google Play supaya benar-benar tergambar di golden test.
///
/// Tanpa ini golden test menangkap badge kosong: `Image.asset` baru memuat
/// gambarnya setelah provider-nya selesai resolve, dan zona async palsu milik
/// widget test tidak memompanya. Akibatnya golden "lulus" padahal badge-nya
/// tidak ada di gambar, dan itu terbukti: golden hasil CI tidak punya satu pun
/// piksel hitam di area footer, padahal badge resmi adalah kotak hitam pekat.
///
/// `runAsync` WAJIB: precache menunggu kerja nyata dari engine.
Future<void> precacheShareBadge(WidgetTester tester, {String? only}) async {
  await tester.runAsync(() async {
    for (final code in only == null ? ['id', 'en', 'tr'] : [only]) {
      await precacheImage(
        AssetImage(GooglePlayBadge.assetFor(code)),
        tester.element(find.byType(ShareCardFooter)),
      );
    }
  });
}

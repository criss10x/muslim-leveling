import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:muslim_leveling/widgets/prayer_heatmap.dart';

import 'helpers/app_wrap.dart';

/// Guard nama bulan/hari heatmap: dulu dua daftar `const` Indonesia, jadi user
/// English tetap membaca "Januari" / "Sen".
///
/// Ekspektasi diturunkan dari `intl` itu sendiri, bukan ditulis tangan — kalau
/// ditulis tangan, tesnya cuma menguji tebakan penulisnya.
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpHeatmap(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(appWrap(
      // Viewport tes 600px; heatmap butuh lebih, sama seperti tes yang sudah ada.
      Scaffold(body: SingleChildScrollView(child: PrayerHeatmap())),
      locale: locale,
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('locale en: header bulan + hari dari intl English', (tester) async {
    await pumpHeatmap(tester, const Locale('en'));
    expect(tester.takeException(), isNull);

    final bulan = toBeginningOfSentenceCase(
      DateFormat.yMMMM('en').format(DateTime.now()),
    );
    expect(find.text('$bulan'), findsOneWidget,
        reason: 'header heatmap bukan nama bulan English dari intl');

    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
    // Sisa daftar const Indonesia yang lama.
    expect(find.text('Sen'), findsNothing);
    expect(find.text('Min'), findsNothing);
  });

  testWidgets('locale id: header bulan + hari tetap Indonesia', (tester) async {
    await pumpHeatmap(tester, const Locale('id'));
    expect(tester.takeException(), isNull);

    final bulan = toBeginningOfSentenceCase(
      DateFormat.yMMMM('id').format(DateTime.now()),
    );
    expect(find.text('$bulan'), findsOneWidget);
    expect(find.text('Sen'), findsOneWidget,
        reason: 'nama hari Indonesia hilang setelah pindah ke DateFormat');
    expect(find.text('Min'), findsOneWidget);
  });

  testWidgets('locale tr: hari tidak lagi jatuh ke daftar Indonesia',
      (tester) async {
    await pumpHeatmap(tester, const Locale('tr'));
    expect(tester.takeException(), isNull);
    expect(find.text('Pzt'), findsOneWidget);
    expect(find.text('Sen'), findsNothing);
  });
}

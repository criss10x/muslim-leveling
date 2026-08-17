import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/widgets/quran_share_sheet.dart';

void main() {
  const surah = QuranSurah(
    number: 1,
    nameArabic: 'الفاتحة',
    nameLatin: 'Al-Fatihah',
    meaning: 'Pembukaan',
    revelation: 'Makkiyah',
    ayahCount: 7,
  );
  const ayah = QuranAyah(
    ayah: 1,
    arabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
    translation: 'Dengan nama Allah yang Maha Pengasih lagi Maha Penyayang.',
  );

  // Swatch eksplisit dengan Semantics berlabel "Mode N" (solid 1..4, ll).
  List<Semantics> swatchOf(WidgetTester t, String label) =>
      t.widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.label == label)
          .toList();

  bool isSelected(Semantics s) => s.properties.selected ?? false;

  Finder findSwatch(WidgetTester t, String label, int idx) =>
      find.byWidget(swatchOf(t, label)[idx]);

  testWidgets('ganti mode tidak mereset pilihan swatch', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () =>
                  showQuranShareSheet(context, surah: surah, ayah: ayah),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // → mode Solid
    await tester.tap(find.text('Solid'));
    await tester.pumpAndSettle();

    // pilih swatch solid ke-2 (label "Solid 2")
    await tester.tap(findSwatch(tester, 'Solid 2', 0));
    await tester.pumpAndSettle();
    expect(isSelected(swatchOf(tester, 'Solid 2').first), isTrue);

    // → mode Gradasi, lalu balik Solid
    await tester.tap(find.text('Gradasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solid'));
    await tester.pumpAndSettle();

    // pilihan solid ke-2 tetap terpilih, bukan reset ke pertama
    final solid = swatchOf(tester, 'Solid 2');
    expect(solid, hasLength(1));
    expect(isSelected(solid.first), isTrue);
    expect(isSelected(swatchOf(tester, 'Solid 1').first), isFalse);
  });
}
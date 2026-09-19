import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/widgets/quran_share_sheet.dart';
import 'helpers/app_wrap.dart';

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
  List<Semantics> swatchOf(WidgetTester t, String label) => t
      .widgetList<Semantics>(find.byType(Semantics))
      .where((s) => s.properties.label == label)
      .toList();

  bool isSelected(Semantics s) => s.properties.selected ?? false;

  Finder findSwatch(WidgetTester t, String label, int idx) =>
      find.byWidget(swatchOf(t, label)[idx]);

  testWidgets('ganti mode tidak mereset pilihan swatch', (tester) async {
    await tester.pumpWidget(
      appWrap(
        Builder(
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
      ),
    );

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

  // Sebelum ini seluruh sheet hardcode Indonesia — di app berbahasa Inggris
  // judul, mode, dan tombolnya tetap "Bagikan Ayat"/"Gradasi". Tes ini yang
  // menahan regresinya.
  testWidgets('locale en: sheet memakai teks English, bukan hardcode', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWrap(
        Builder(
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
        locale: const Locale('en'),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Share Verse'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Arabic'), findsOneWidget);
    expect(find.text('Translation'), findsOneWidget);
    expect(find.text('Gradient'), findsOneWidget);
    expect(find.text('Esthetic'), findsOneWidget);

    // Sisa hardcode Indonesia harus nol.
    for (final s in [
      'Bagikan Ayat',
      'Bagikan',
      'Gradasi',
      'Estetik',
      'Terjemahan',
    ]) {
      expect(find.text(s), findsNothing, reason: 'masih hardcode: $s');
    }
  });

  // Label mode dulu disimpan 17x di tabel preset (satu per swatch) padahal
  // nilainya cuma 3. Sekarang diturunkan dari `kind` → satu tempat l10n.
  testWidgets('mode Estetik tersedia di kedua locale', (tester) async {
    for (final (locale, label) in [
      (const Locale('id'), 'Estetik'),
      (const Locale('en'), 'Esthetic'),
    ]) {
      await tester.pumpWidget(
        appWrap(
          Builder(
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
          locale: locale,
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(
        find.text(label),
        findsOneWidget,
        reason: locale.languageCode,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }
  });
}

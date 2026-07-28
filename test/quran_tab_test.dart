import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/quran_tab.dart';
import 'package:muslim_leveling/screens/quran_reader.dart';
import 'package:muslim_leveling/widgets/rub_el_hizb_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('shows Quran hierarchy and opens the selected reader', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    expect(find.text('Al-Quran'), findsOneWidget);
    expect(find.text('114 surat'), findsOneWidget);
    expect(find.text('Pilih surat'), findsOneWidget);

    await tester.tap(find.text('Al-Fatihah'));
    await tester.pumpAndSettle();

    expect(find.byType(QuranReader), findsOneWidget);
  });

  testWidgets('menampilkan daftar surat', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah'), findsOneWidget);
    // Arti digabung dengan tempat turun dan jumlah ayat dalam satu subtitle.
    expect(find.textContaining('Pembukaan'), findsOneWidget);
  });

  testWidgets('menampilkan chip tempat turun, bukan subtitle gabungan', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    // Al-Fatihah Makkiyah, Al-Baqarah Madaniyah — keduanya di layar pertama.
    expect(find.text('Makkiyah'), findsWidgets);
    expect(find.text('Madaniyah'), findsWidgets);
    expect(find.text('7 ayat'), findsOneWidget);
    // Subtitle gabungan lama tidak boleh ada lagi.
    expect(find.textContaining('Pembukaan · '), findsNothing);
  });

  testWidgets('baris surat tidak lagi memakai chevron', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('setiap baris surat memakai badge Rub el Hizb', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    expect(find.byType(RubElHizbBadge), findsWidgets);
  });

  testWidgets('pencarian memfilter daftar', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'baqarah');
    await tester.pumpAndSettle();

    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsNothing);
  });

  testWidgets('pencarian tanpa hasil menampilkan pesan kosong', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pumpAndSettle();

    expect(find.text('Surat tidak ditemukan'), findsOneWidget);
  });
}

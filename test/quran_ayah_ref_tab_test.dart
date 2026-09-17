import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/quran_tab.dart';
import 'package:muslim_leveling/screens/quran_reader.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'helpers/app_wrap.dart';

// ponytail: runnable check untuk pencarian nomor ayat di tab Quran.
// Kasus user: ketik "Al-Baqarah 286" → bukan cuma daftar surat, tapi kartu
// yang menyebut ayat 286 dan membuka reader tepat di ayat itu.
//
// Tes ini juga menahan short-circuit: acuan ayat diperiksa SEBELUM cabang
// pencarian terjemahan. Kalau urutannya dibalik, "Al-Baqarah 286" akan
// memicu pembangunan indeks 114 berkas surat dan tes ini menggantung.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) => appWrap(Scaffold(body: child));

  testWidgets('"Al-Baqarah 286" menampilkan kartu ayat, bukan daftar surat',
      (tester) async {
    // Panaskan cache ayat dulu: fallback aset surat 2 (~2MB) butuh I/O asli
    // yang tidak selesai dalam waktu fake test.
    await tester.runAsync(() => quranData.ayahs(2));

    await tester.pumpWidget(wrap(const QuranTab()));
    await tester.pumpAndSettle();

    // Sebelum mencari: daftar surat normal.
    expect(find.text('Al-Fatihah'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Al-Baqarah 286');
    await tester.pump(const Duration(milliseconds: 600)); // debounce
    await tester.pumpAndSettle();

    // Kartu ayatnya yang tampil — daftar surat tidak lagi mendominasi.
    expect(find.text('Ayat 286 dari 286'), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsNothing);

    // Tap kartu → reader terbuka dan mendarat di ayat 286, bukan ayat 1.
    await tester.tap(find.text('Ayat 286 dari 286'));
    await tester.pumpAndSettle();

    expect(find.byType(QuranReader), findsOneWidget);
    expect(find.text('Ayat 286'), findsWidgets);
  });

  testWidgets('acuan lewat nomor surat juga jalan', (tester) async {
    await tester.runAsync(() => quranData.ayahs(2));

    await tester.pumpWidget(wrap(const QuranTab()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '2:286');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Ayat 286 dari 286'), findsOneWidget);
  });

  testWidgets('pencarian kata biasa tidak terpengaruh jalur acuan ayat',
      (tester) async {
    await tester.pumpWidget(wrap(const QuranTab()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'baqarah');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Nama surat tetap muncul sebagai baris surat (bukan kartu ayat), dan
    // tidak ada kartu acuan ayat yang salah klaim. Format kartu acuan dikunci
    // ketat ("Ayat N dari M") — kartu "Lanjutkan membaca" juga memuat kata
    // "Ayat", jadi `textContaining('Ayat ')` akan salah tangkap.
    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'^Ayat \d+ dari \d+$')),
      findsNothing,
      reason: '"baqarah" bukan acuan ayat — jangan tampilkan kartu ayat',
    );
  });
}

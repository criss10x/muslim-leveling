import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/hadis_screen.dart';
import 'package:muslim_leveling/services/hadis_api.dart';
import 'package:muslim_leveling/widgets/hadis_share_sheet.dart';
import 'package:muslim_leveling/widgets/share_card_kit.dart';

import 'helpers/app_wrap.dart';
import 'helpers/golden_fonts.dart';
import 'helpers/share_assets.dart';

/// Share hadis.
///
/// Permintaan user: tombol share di hadis dengan settingan SAMA PERSIS seperti
/// share ayat Quran. Karena itu kit yang dipakai adalah kit yang sama, dan tes
/// ini menjaga kesamaan itu secara eksplisit: 3 tab (Latar/Isi/Ukuran), 17
/// preset, badge Google Play resmi. Kalau salah satu sisi berubah sendirian,
/// tes ini gagal.
void main() {
  setUpAll(loadGoldenFonts);
  TestWidgetsFlutterBinding.ensureInitialized();

  const item = HadisItem(
    id: 1234,
    ar: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
    idn: 'Sesungguhnya setiap amalan tergantung pada niatnya.',
    grade: 'Sahih Hadis',
    takhrij: 'HR. Bukhari no. 1',
    hikmah: 'Niat menentukan nilai amal.',
  );

  const tanpaHikmah = HadisItem(
    id: 55,
    ar: 'الدِّينُ النَّصِيحَةُ',
    idn: 'Agama itu nasihat.',
    grade: '',
    takhrij: '',
  );

  Widget kartu(HadisItem it) => appWrap(
        Scaffold(body: Center(child: HadisSharePreviewCard(item: it))),
      );

  group('kartu share hadis', () {
    testWidgets('memakai kit yang sama: badge resmi ikut ter-render',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(kartu(item));
      await tester.pumpAndSettle();
      await precacheShareBadge(tester, only: 'id');
      await tester.pump(const Duration(milliseconds: 200));

      // Badge harus benar-benar termuat (pelajaran dari share ayat: tanpa
      // precache, golden "lulus" dengan badge kosong).
      expect(tester.getSize(find.byType(GooglePlayBadge)).width,
          greaterThan(20));
      // Isi kartu hadis: nomor, derajat, takhrij, Arab, terjemahan.
      expect(find.textContaining('1234'), findsWidgets);
      expect(find.textContaining('Sahih Hadis'), findsWidgets);
      expect(find.textContaining('HR. Bukhari'), findsWidgets);
      // Substring diambil dari SUMBERNYA, bukan diketik ulang: harakat Arab
      // gampang salah ketik (kasrah vs dammah, shadda hilang) dan itu membuat
      // tes gagal karena salah tes, bukan salah produk.
      expect(find.textContaining(item.ar.split(' ').first), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('derajat & takhrij disembunyikan bila sumber tidak kirim',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(kartu(tanpaHikmah));
      await tester.pumpAndSettle();

      // Hasil pencarian tidak mengirim grade/takhrij: keduanya harus hilang,
      // bukan tampil sebagai teks kosong atau strip.
      expect(find.textContaining('Sahih'), findsNothing);
      expect(find.textContaining('HR.'), findsNothing);
      // Tapi isi utamanya tetap ada.
      expect(find.textContaining(tanpaHikmah.ar.split(' ').first), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tanpa overflow di rasio 1:1 (kartu terpendek)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        appWrap(
          const Scaffold(
            body: Center(
              child: HadisSharePreviewCard(item: item, aspect: 1.0),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('sheet share hadis = settingan share ayat', () {
    Future<void> bukaSheet(WidgetTester tester, HadisItem it) async {
      await tester.pumpWidget(
        appWrap(
          Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: TextButton(
                  onPressed: () => showHadisShareSheet(ctx, item: it),
                  child: const Text('buka'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('buka'));
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
    }

    testWidgets('punya 3 tab yang sama: Latar / Isi / Ukuran', (tester) async {
      await bukaSheet(tester, item);

      expect(find.text('Bagikan Hadis'), findsWidgets);
      expect(find.text('Latar'), findsOneWidget);
      expect(find.text('Isi'), findsOneWidget);
      expect(find.text('Ukuran'), findsOneWidget);
    });

    testWidgets('tab Latar memuat mode yang sama seperti share ayat',
        (tester) async {
      await bukaSheet(tester, item);

      for (final mode in ['Solid', 'Gradasi', 'Estetik', 'Foto Saya']) {
        expect(find.text(mode), findsOneWidget, reason: 'mode $mode hilang');
      }
    });

    testWidgets('tab Ukuran memuat 3 rasio yang sama', (tester) async {
      await bukaSheet(tester, item);
      await tester.tap(find.text('Ukuran'));
      await tester.pumpAndSettle();

      expect(find.text('9:16'), findsOneWidget);
      expect(find.text('3:4'), findsOneWidget);
      expect(find.text('1:1'), findsOneWidget);
    });

    testWidgets('chip Isi: Arab, Terjemahan, dan Hikmah (bila ada)',
        (tester) async {
      await bukaSheet(tester, item);
      await tester.tap(find.text('Isi'));
      await tester.pumpAndSettle();

      expect(find.text('Arab'), findsOneWidget);
      expect(find.text('Terjemahan'), findsOneWidget);
      // Hikmah hanya ada di hadis, bukan di kartu ayat.
      expect(find.text('Hikmah'), findsOneWidget);
    });

    testWidgets('chip Hikmah tidak muncul kalau hadis tanpa hikmah',
        (tester) async {
      await bukaSheet(tester, tanpaHikmah);
      await tester.tap(find.text('Isi'));
      await tester.pumpAndSettle();

      expect(find.text('Arab'), findsOneWidget);
      expect(find.text('Hikmah'), findsNothing,
          reason: 'jangan tawarkan toggle untuk konten yang tidak ada');
    });

    testWidgets('tidak boleh mematikan Arab dan Terjemahan sekaligus',
        (tester) async {
      await bukaSheet(tester, item);
      await tester.tap(find.text('Isi'));
      await tester.pumpAndSettle();

      // Matikan Terjemahan -> sisa Arab saja.
      await tester.tap(find.text('Terjemahan'));
      await tester.pumpAndSettle();
      // Percobaan mematikan Arab juga harus DITOLAK (ini yang terakhir).
      await tester.tap(find.text('Arab'));
      await tester.pumpAndSettle();

      expect(find.textContaining(item.ar.split(' ').first), findsWidgets,
          reason: 'Arab harus tetap tampil: keduanya tidak boleh mati');
    });

    testWidgets('Hikmah default MATI, baru tampil setelah dipilih',
        (tester) async {
      await bukaSheet(tester, item);

      // Default: hikmah TIDAK ikut di kartu. Kalau ikut, kartu jadi padat dan
      // teks utamanya (Arab/terjemahan) yang tergeser.
      expect(find.textContaining('Niat menentukan'), findsNothing,
          reason: 'hikmah harus opt-in, bukan tampil sejak awal');

      await tester.tap(find.text('Isi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hikmah'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Niat menentukan'), findsWidgets,
          reason: 'setelah dipilih, hikmah harus muncul di kartu');
    });

    testWidgets('tombol Bagikan ada dan tidak overflow di 320x568',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await bukaSheet(tester, item);
      expect(find.text('Bagikan'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Ketiga tab dibuka bergantian: satu pun tidak boleh overflow.
      for (final tab in ['Isi', 'Ukuran', 'Latar']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'overflow di tab $tab');
      }
    });
  });

  group('pintu masuk dari layar hadis', () {
    testWidgets('tombol share ada di detail hadis dan membuka sheet',
        (tester) async {
      await tester.pumpWidget(
        appWrap(const Scaffold(body: HadisDetailScreen(item: item))),
      );
      await tester.pumpAndSettle();

      // Pintu masuk punya label a11y, bukan cuma ikon.
      final btn = find.byIcon(Icons.share_outlined);
      expect(btn, findsOneWidget);
      expect(find.bySemanticsLabel('Bagikan hadis ini'), findsOneWidget);

      await tester.tap(btn);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }

      // Sheet terbuka dengan settingan yang sama.
      expect(find.text('Bagikan Hadis'), findsWidgets);
      expect(find.text('Latar'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/doa_screen.dart';
import 'package:muslim_leveling/services/doa_api.dart';
import 'package:muslim_leveling/services/doa_en_map.dart';
import 'helpers/app_wrap.dart';

/// Penjaga terjemahan Inggris doa (opsional, untuk sebagian doa saja).
///
/// Latar: sumber Indonesia (equran.id) tidak punya versi Inggris. Sumber Inggris
/// (ummahapi.com) adalah koleksi TERPISAH, bukan terjemahan katalog itu, jadi
/// hanya sebagian doa punya pasangan. Karena itu `DoaItem.en == null` itu NORMAL
/// dan UI tidak boleh bergantung padanya.
void main() {
  final en = const DoaEnEntry(
    title: 'Increase in Knowledge',
    translation: 'My Lord, increase me in knowledge.',
    transliteration: 'Rabbi zidni ilma',
    source: 'Quran 20:114',
  );

  DoaItem doa({DoaEnEntry? en}) => DoaItem(
        id: 95,
        grup: 'Doa Memohon Ilmu',
        nama: 'Doa Memohon Ilmu 1',
        ar: 'رَبِّ زِدْنِي عِلْمًا',
        tr: 'Rabbi zidni ilma',
        idn: 'Ya Tuhanku, tambahkanlah kepadaku ilmu.',
        tentang: 'QS. Thaha: 114',
        tag: const ['umum'],
        en: en,
      );

  group('pemetaan', () {
    test('setiap entri punya terjemahan + sumber', () {
      expect(doaEnByArabic, isNotEmpty);
      for (final e in doaEnByArabic.entries) {
        expect(e.value.translation.trim(), isNotEmpty,
            reason: 'entri ${e.key} tanpa terjemahan');
        expect(e.value.title.trim(), isNotEmpty,
            reason: 'entri ${e.key} tanpa judul');
        // Sumber dipakai untuk label rujukan di layar.
        expect(e.value.source.trim(), isNotEmpty,
            reason: 'entri ${e.key} tanpa sumber');
      }
    });

    test('kunci peta hanya huruf Arab (harakat dibuang)', () {
      final arabicOnly = RegExp(r'^[\u0621-\u064A]+$');
      for (final k in doaEnByArabic.keys) {
        expect(arabicOnly.hasMatch(k), isTrue,
            reason: 'kunci bukan huruf Arab murni: $k');
      }
    });

    test('frasa umum TIDAK dipetakan (sumber salah pasang)', () {
      // بسم الله (Bismillah) dan ألحمد لله muncul di banyak doa berbeda. Kalau
      // dipetakan, "Before Eating" akan menempel ke doa wudhu dan doa masuk
      // rumah. Aturan pembangkit: Arab harus unik di kedua katalog.
      for (final k in doaEnByArabic.keys) {
        expect(k.length, greaterThanOrEqualTo(8),
            reason: 'kunci terlalu pendek (frasa umum): $k');
      }
      expect(doaEnByArabic.containsKey(normalizeArabic('بِسْمِ اللَّهِ')), isFalse);
      expect(doaEnByArabic.containsKey(normalizeArabic('اَلْحَمْدُ لِلَّهِ')),
          isFalse);
    });

    test('fromJson mengaitkan Inggris lewat ARAB, bukan nomor id', () {
      // Inti pemetaan: kunci peta = Arab tanpa harakat. Kalau normalisasi Dart
      // menyimpang dari sisi pembangkit (Python), semua pasangan hilang diam-diam
      // dan tak ada yang gagal — jadi ini yang harus dijaga.
      final kena = DoaItem.fromJson({
        'id': 95,
        'grup': 'Doa Memohon Ilmu',
        'nama': 'Doa Memohon Ilmu 1',
        'ar': 'رَبِّ زِدْنِي عِلْمًا', // berharakat: normalisasi harus jalan
        'tr': 'Rabbi zidni ilma',
        'idn': 'Ya Tuhanku, tambahkanlah kepadaku ilmu.',
        'tentang': 'QS. Thaha: 114',
        'tag': <String>['umum'],
      });
      expect(kena.en, isNotNull,
          reason: 'Arab berharakat harus cocok dengan kunci peta');
      expect(kena.en!.translation, contains('knowledge'));
      expect(kena.en!.source, isNotEmpty);

      // Arab yang tidak ada di peta → null (bukan crash, bukan tebakan).
      final tak = DoaItem.fromJson({
        'id': 999,
        'grup': 'g',
        'nama': 'n',
        'ar': 'نَصٌّ لَيْسَ فِي الْخَرِيطَةِ',
        'tr': 't',
        'idn': 'i',
        'tentang': '',
        'tag': <String>[],
      });
      expect(tak.en, isNull);
    });

    test('normalizeArabic cocok dengan sisi pembangkit', () {
      expect(normalizeArabic('رَبِّ زِدْنِي عِلْمًا'), 'ربزدنيعلما');
      expect(normalizeArabic(''), '');
      // Harakat & spasi dibuang, huruf tetap.
      expect(normalizeArabic('بِسْمِ اللَّهِ'), 'بسمالله');
    });
  });

  group('UI detail', () {
    /// Layar detail = ListView; anak yang belum terlihat TIDAK dibangun, jadi
    /// `find.text` mengembalikan nol untuk section di bawah lipatan meski
    /// teksnya benar. Viewport tinggi membuat seluruh isi ter-render — lebih
    /// deterministik daripada menggulir.
    void tallViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    testWidgets('doa ber-Inggris menampilkan section terjemahan Inggris', (
      tester,
    ) async {
      tallViewport(tester);
      await tester.pumpWidget(
        appWrap(DoaDetailScreen(doa: doa(en: en))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // _section meng-uppercase labelnya (HudHeader).
      expect(find.text('TERJEMAHAN INGGRIS'), findsOneWidget);
      expect(find.text('My Lord, increase me in knowledge.'), findsOneWidget);
      expect(find.text('Terjemahan Inggris: Quran 20:114'), findsOneWidget);
      // Arti Indonesia tetap ada — Inggris hanya tambahan.
      expect(find.text('Ya Tuhanku, tambahkanlah kepadaku ilmu.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('doa tanpa versi Inggris: layar tampil normal, tanpa section', (
      tester,
    ) async {
      await tester.pumpWidget(appWrap(DoaDetailScreen(doa: doa())));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('TERJEMAHAN INGGRIS'), findsNothing);
      expect(find.text('Ya Tuhanku, tambahkanlah kepadaku ilmu.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('locale en: label section berbahasa Inggris', (tester) async {
      tallViewport(tester);
      await tester.pumpWidget(
        appWrap(DoaDetailScreen(doa: doa(en: en)), locale: const Locale('en')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('ENGLISH TRANSLATION'), findsOneWidget);
      expect(find.text('English translation: Quran 20:114'), findsOneWidget);
    });
  });

  group('pencarian', () {
    setUp(() => doaApi.seedForTest([doa(en: en), doa()]));
    tearDown(() => doaApi.seedForTest(const []));

    test('kata Inggris menemukan doa lewat terjemahan Inggrisnya', () {
      // 'knowledge' tidak ada di nama/grup/tag/arti Indonesia mana pun.
      expect(doaApi.search('knowledge').map((d) => d.id), contains(95));
      expect(doaApi.search('Increase in Knowledge').map((d) => d.id),
          contains(95));
    });

    test('doa tanpa versi Inggris tidak ikut cocok lewat jalur Inggris', () {
      // Keduanya doa yang sama; pencarian kata Indonesia menemukan keduanya.
      expect(doaApi.search('ilmu').length, 2);
    });
  });
}

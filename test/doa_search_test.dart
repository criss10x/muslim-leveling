import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/doa_screen.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'package:muslim_leveling/services/doa_api.dart';
import 'helpers/app_wrap.dart';

/// Penjaga pencarian halaman Doa (level 1).
///
/// Pencarian ini LOKAL: API equran.id tidak punya pencarian (`/api/doa/cari/x`
/// → 404, `?q=`/`?search=` diabaikan) dan seluruh 227 doa sudah ada di memori
/// sejak layar dibuka. Jadi tidak boleh ada request tambahan per ketikan.
DoaItem doa({
  int id = 1,
  String grup = 'Doa Sebelum Tidur',
  String nama = 'Doa Sebelum Tidur 1',
  String idn = 'Dengan nama-Mu aku tidur',
  List<String> tag = const ['tidur', 'malam'],
  String ar = 'بِاسْمِكَ',
}) =>
    DoaItem(
      id: id,
      grup: grup,
      nama: nama,
      ar: ar,
      tr: 'Bismika',
      idn: idn,
      tentang: 'HR. Bukhari',
      tag: tag,
    );

void main() {
  final tidur = doa();
  final perjalanan = doa(
    id: 2,
    grup: 'Doa Bepergian',
    nama: 'Doa Naik Kendaraan',
    idn: 'Maha Suci yang menundukkan kendaraan ini untuk kami',
    tag: ['perjalanan'],
  );
  // Tidak ada kata "rezeki" di nama/grup/tag, hanya di arti → harus muncul
  // sebagai hasil sekunder (di bawah).
  // Hanya menyebut "tidur" di ARTInya; nama/grup/tagnya tidak. Dipakai menguji
  // janji urutan: yang cocok di nama/tag harus di atas yang cocok di arti.
  final artiSaja = doa(
    id: 5,
    grup: 'Doa Umum',
    nama: 'Doa Kebaikan Dunia Akhirat',
    idn: 'Ya Allah, berilah kebaikan sebelum aku tidur dan sesudahnya',
    tag: ['umum'],
  );
  final hutang = doa(
    id: 4,
    grup: 'Doa Hutang',
    nama: 'Doa Agar Terbebas Hutang',
    idn: 'Ya Allah, cukupkanlah aku dengan yang halal',
    tag: ['hutang', 'harta'],
  );
  final pakaian = doa(
    id: 3,
    grup: 'Doa Mengenakan Pakaian',
    nama: 'Doa Mengenakan Pakaian',
    idn: 'Ya Allah, berilah aku pakaian yang baik dan rezeki yang halal',
    tag: ['pakaian'],
  );

  setUp(() =>
        doaApi.seedForTest([artiSaja, tidur, perjalanan, hutang, pakaian]));
  tearDown(() => doaApi.seedForTest(const []));

  group('service', () {
    test('cocok di nama, grup, dan tag', () {
      expect(doaApi.search('tidur').map((d) => d.id), contains(1));
      expect(doaApi.search('bepergian').map((d) => d.id), contains(2));
      // 'malam' hanya ada di tag, bukan nama/grup.
      expect(doaApi.search('malam').map((d) => d.id), contains(1));
    });

    test('kata kunci kosong → hasil kosong, bukan seluruh katalog', () {
      expect(doaApi.search(''), isEmpty);
      expect(doaApi.search('   '), isEmpty);
    });

    test('cocok di arti tetap muncul, tapi DI BAWAH yang cocok di nama/tag',
        () {
      // 'rezeki' hanya ada di arti doa pakaian → tetap ketemu.
      expect(doaApi.search('rezeki').map((d) => d.id), contains(3));

      // 'tidur': id 1 cocok di nama+tag, id 5 hanya di arti. Urutannya wajib
      // id 1 dulu.
      final hasil = doaApi.search('tidur');
      expect(hasil.map((d) => d.id), containsAll([1, 5]));
      expect(hasil.first.id, 1);
      expect(hasil.last.id, 5);
    });

    test('alias non-Indonesia: "sleep" menemukan doa bertag tidur', () {
      // Konten doa seluruhnya Indonesia; alias ini jembatan pencarian.
      expect(doaApi.search('sleep').map((d) => d.id), contains(1));
      expect(doaApi.search('uyku').map((d) => d.id), contains(1));
      expect(doaApi.search('travel').map((d) => d.id), contains(2));
      expect(doaApi.search('debt').map((d) => d.id), contains(4));
      expect(doaApi.search('borç').map((d) => d.id), contains(4));
    });

    test('cache kosong → tidak melempar, hanya kosong', () {
      doaApi.seedForTest(const []);
      expect(doaApi.search('tidur'), isEmpty);
    });
  });

  group('layar', () {
    testWidgets('mengetik menampilkan hasil, tap masuk ke detail', (
      tester,
    ) async {
      await tester.pumpWidget(appWrap(const DoaScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      // Daftar grup tampil lebih dulu.
      expect(find.text('Doa Bepergian'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'tidur');
      await tester.pump();

      // Hasil menggantikan daftar grup.
      expect(find.text('Doa Sebelum Tidur 1'), findsOneWidget);
      expect(find.text('Doa Bepergian'), findsNothing);

      // Tap hasil → detail, bukan lewat level 2.
      await tester.tap(find.text('Doa Sebelum Tidur 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('HR. Bukhari'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tanpa hasil → pesan kosong, bukan layar kosong', (
      tester,
    ) async {
      await tester.pumpWidget(appWrap(const DoaScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();

      expect(find.text('Tidak ada doa ditemukan. Coba kata lain, mis. tidur, '
          'hutang, atau perjalanan.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tombol X mengosongkan → daftar grup kembali', (tester) async {
      await tester.pumpWidget(appWrap(const DoaScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'tidur');
      await tester.pump();
      expect(find.text('Doa Bepergian'), findsNothing);

      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pump();

      expect(find.text('Doa Bepergian'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('locale en: hint pencarian berbahasa Inggris', (tester) async {
      await tester.pumpWidget(
        appWrap(const DoaScreen(), locale: const Locale('en')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Search dua…'), findsOneWidget);
    });
  });
}

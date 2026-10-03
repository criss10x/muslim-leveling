// Regresi layar Doa level 1: halaman ini di-push dari aksi cepat Home, jadi
// WAJIB punya tombol kembali dan judul. Dulu isinya ListView polos tanpa
// Scaffold: tidak ada jalan pulang, tidak ada judul, dan status memuat/error
// juga buntu. Level 2 & 3 sudah punya sejak awal, jadi bug ini hanya di level 1.
//
// Juga: sumber bisa menjawab 200 dengan daftar kosong. Itu bukan error, tapi
// tanpa cabang khusus layarnya tampil benar-benar kosong tanpa penjelasan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/doa_screen.dart';
import 'package:muslim_leveling/services/doa_api.dart';
import 'package:muslim_leveling/theme/app_icons.dart';

import 'helpers/app_wrap.dart';

const _items = [
  DoaItem(
      id: 1,
      grup: 'Doa Sebelum Tidur',
      nama: 'Doa Sebelum Tidur',
      ar: 'بِسْمِكَ اللَّهُمَّ',
      tr: 'Bismikallahumma',
      idn: 'Dengan nama-Mu ya Allah',
      tentang: 'HR Bukhari'),
];

void main() {
  testWidgets('level 1 punya tombol kembali yang benar-benar pop',
      (tester) async {
    doaApi.seedForTest(_items);

    // Layar ini harus berada di atas rute lain supaya pop bisa dibuktikan.
    await tester.pumpWidget(appWrap(Builder(builder: (context) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DoaScreen()),
            ),
            child: const Text('buka'),
          ),
        ),
      );
    })));

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    expect(find.byType(DoaScreen), findsOneWidget);

    // Tombol kembali wajib ada. Inilah yang hilang di versi lama.
    final back = find.byIcon(AppIcons.arrowBack);
    expect(back, findsOneWidget,
        reason: 'level 1 harus punya tombol kembali (dulu tidak ada sama sekali)');

    await tester.tap(back);
    await tester.pumpAndSettle();

    // Kembali ke layar pemanggil, bukan menutup aplikasi diam-diam.
    expect(find.byType(DoaScreen), findsNothing,
        reason: 'tombol kembali harus menutup layar Doa');
    expect(find.text('buka'), findsOneWidget);
  });

  testWidgets('daftar grup kosong menampilkan pesan, bukan layar kosong',
      (tester) async {
    doaApi.seedForTest(const []);

    await tester.pumpWidget(appWrap(const DoaScreen()));
    await tester.pumpAndSettle();

    // Guard lama memakai `groups == null`, jadi 0 grup lolos ke ListView kosong.
    expect(find.textContaining('Belum ada doa'), findsOneWidget,
        reason: 'daftar kosong harus dijelaskan, bukan layar tanpa pesan');
  });

  testWidgets('judul + jumlah doa tampil di level 1', (tester) async {
    doaApi.seedForTest(_items);

    await tester.pumpWidget(appWrap(const DoaScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Doa'), findsOneWidget, reason: 'judul layar');
    expect(find.text('1 doa'), findsOneWidget,
        reason: 'meta jumlah doa dihitung dari daftar grup');
  });
}

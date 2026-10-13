import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/hadis_bookmarks_screen.dart';
import 'package:muslim_leveling/screens/hadis_screen.dart';
import 'package:muslim_leveling/services/hadis_api.dart';
import 'package:muslim_leveling/services/hadis_bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

/// Bookmark hadis di UI: pintu masuk, daftar tersimpan, dan hapus.
///
/// Catatan harness: animasi perlu 2 pump (frame pertama masih opacity 0), jadi
/// tiap interaksi di-pump bertahap — bukan satu lompatan waktu besar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // load() selalu menimpa isi dari prefs → sekaligus mereset singleton
    // antar-tes (restoreFromRemote tidak, karena ia menghormati "lokal menang").
    await hadisBookmarks.load();
  });
  tearDown(() => hadisApi.resetForTest());

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  List<String> satuBookmark() => [
        jsonEncode({
          'id': 1751,
          'arabic': 'teks arab',
          'translation': 'terjemahan hadis',
          'grade': 'Sahih',
          'takhrij': '',
          'addedAt': '2026-10-01T00:00:00.000',
        }),
      ];

  testWidgets('layar tersimpan: kosong menampilkan ajakan, bukan blank', (
    tester,
  ) async {
    await tester.pumpWidget(appWrap(const HadisBookmarksScreen()));
    await settle(tester);

    expect(find.text('Belum ada hadis tersimpan'), findsOneWidget);
    expect(find.text('Tap ikon bookmark di hadis yang mau disimpan.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('layar tersimpan: memuat bookmark dari prefs', (tester) async {
    SharedPreferences.setMockInitialValues({'hadis_bookmarks_v1': satuBookmark()});

    // Sengaja TIDAK memanggil load() di sini: yang diuji adalah layarnya
    // memuat sendiri isi prefs (kalau tidak, daftar tampil kosong saat dibuka).
    await tester.pumpWidget(appWrap(const HadisBookmarksScreen()));
    await settle(tester);

    // Snapshot dirender tanpa API: nomor + terjemahan tersimpan.
    expect(find.text('no. 1751'), findsOneWidget);
    expect(find.text('terjemahan hadis'), findsOneWidget);
    expect(find.text('teks arab'), findsOneWidget);
    expect(find.text('Belum ada hadis tersimpan'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hapus dari layar tersimpan mengosongkan daftar + prefs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'hadis_bookmarks_v1': satuBookmark()});

    await tester.pumpWidget(appWrap(const HadisBookmarksScreen()));
    await settle(tester);
    expect(find.text('terjemahan hadis'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus dari tersimpan'));
    await settle(tester);

    expect(find.text('terjemahan hadis'), findsNothing);
    expect(find.text('Belum ada hadis tersimpan'), findsOneWidget);
    final p = await SharedPreferences.getInstance();
    expect(p.getStringList('hadis_bookmarks_v1'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('layar daftar hadis punya pintu ke hadis tersimpan', (
    tester,
  ) async {
    await tester.pumpWidget(appWrap(const HadisScreen()));
    await settle(tester);

    // Tombol pintu masuk: ikon bookmark di baris pencarian.
    final entry = find.byIcon(Icons.bookmark_border);
    expect(entry, findsOneWidget);

    await tester.tap(entry);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Mendarat di layar tersimpan (kosong) — bukan layar lain.
    expect(find.text('Hadis Tersimpan'), findsOneWidget);
    expect(find.text('Belum ada hadis tersimpan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('layar detail hadis', () {
    const item = HadisItem(
      id: 1234,
      ar: 'teks arab',
      idn: 'terjemahan',
      grade: 'Sahih Hadis',
      takhrij: 'HR. Bukhari no. 1',
      hikmah: 'pelajaran',
    );

    testWidgets('tombol simpan/hapus menyimpan snapshot lengkap', (
      tester,
    ) async {
      await tester.pumpWidget(
        appWrap(const Scaffold(body: HadisDetailScreen(item: item))),
      );
      await settle(tester);

      expect(find.byTooltip('Simpan hadis'), findsOneWidget);
      await tester.tap(find.byTooltip('Simpan hadis'));
      await settle(tester);

      // Tersimpan lengkap: siap dibuka lagi tanpa jaringan.
      final b = hadisBookmarks.items.single;
      expect(b.id, 1234);
      expect(b.arabic, 'teks arab');
      expect(b.translation, 'terjemahan');
      expect(b.grade, 'Sahih Hadis');
      expect(b.takhrij, 'HR. Bukhari no. 1');
      expect(b.hikmah, 'pelajaran');

      // Ikon berganti + tooltip jadi aksi hapus.
      expect(find.byTooltip('Hapus dari tersimpan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('buka tersimpan yang sudah dihapus dari sumber tetap utuh', (
      tester,
    ) async {
      // Hadis lama: grade/takhrij kosong (hasil pencarian) tetap bisa disimpan.
      const minim = HadisItem(
        id: 77,
        ar: '',
        idn: 'hanya terjemahan',
        grade: '',
        takhrij: '',
      );
      await tester.pumpWidget(
        appWrap(const Scaffold(body: HadisDetailScreen(item: minim))),
      );
      await settle(tester);
      await tester.tap(find.byTooltip('Simpan hadis'));
      await settle(tester);

      final b = hadisBookmarks.items.single;
      expect(b.id, 77);
      expect(b.translation, 'hanya terjemahan');
      expect(b.arabic, '');
      expect(tester.takeException(), isNull);
    });
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/cloud_sync.dart';
import 'package:muslim_leveling/services/hadis_bookmark.dart';
import 'package:muslim_leveling/services/quran_bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bookmark hadis: simpan snapshot lokal + ikut backup cloud, lokal menang.
/// Pola yang sama dengan bookmark ayat (lihat bookmark_notif_backup_test).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  HadisBookmark snap(int id) => HadisBookmark(
        id: id,
        arabic: 'arab$id',
        translation: 'terjemah$id',
        grade: 'Sahih',
        takhrij: 'takhrij$id',
        addedAt: DateTime(2026, 10, 1),
      );

  group('HadisBookmarks lokal', () {
    test('toggle menyimpan snapshot lengkap ke prefs', () async {
      final b = HadisBookmarks();
      await b.toggle(snap(1751));

      expect(b.isBookmarked(1751), isTrue);
      final p = await SharedPreferences.getInstance();
      final raw = p.getStringList('hadis_bookmarks_v1');
      expect(raw, hasLength(1));
      // Snapshot: arab + terjemahan + grade + takhrij + addedAt.
      final j = jsonDecode(raw!.first) as Map<String, dynamic>;
      expect(j['arabic'], 'arab1751');
      expect(j['translation'], 'terjemah1751');
      expect(j['grade'], 'Sahih');
      expect(j['takhrij'], 'takhrij1751');
      expect(j['addedAt'], isNotEmpty);
    });

    test('toggle kedua menghapus, bukan menyimpan ganda', () async {
      final b = HadisBookmarks();
      await b.toggle(snap(42));
      await b.toggle(snap(42));

      expect(b.isBookmarked(42), isFalse);
      final p = await SharedPreferences.getInstance();
      expect(p.getStringList('hadis_bookmarks_v1'), isEmpty);
    });

    test('load membaca kembali dari prefs', () async {
      SharedPreferences.setMockInitialValues({
        'hadis_bookmarks_v1': [
          jsonEncode({
            'id': 100,
            'arabic': 'a',
            'translation': 't',
            'grade': '',
            'takhrij': '',
            'addedAt': '2026-09-01T00:00:00.000',
          }),
        ],
      });
      final b = HadisBookmarks();
      await b.load();

      expect(b.items, hasLength(1));
      expect(b.isBookmarked(100), isTrue);
    });

    test('prefs rusak tidak melempar, bookmark dianggap kosong', () async {
      SharedPreferences.setMockInitialValues({
        'hadis_bookmarks_v1': ['{bukan json'],
      });
      final b = HadisBookmarks();
      await b.load();

      expect(b.items, isEmpty);
    });
  });

  group('HadisBookmarks.restoreFromRemote', () {
    test('mengisi dari cloud saat lokal kosong', () async {
      final b = HadisBookmarks();
      await b.restoreFromRemote({
        'hadisBookmarks': [
          {
            'id': 1751,
            'arabic': 'arab',
            'translation': 'terjemah',
            'grade': '',
            'takhrij': '',
            'addedAt': '2026-09-01T00:00:00.000',
          },
        ],
      });

      expect(b.items, hasLength(1));
      expect(b.isBookmarked(1751), isTrue);
      // Ditulis balik ke prefs: baca berikutnya tanpa cloud.
      final p = await SharedPreferences.getInstance();
      expect(p.getStringList('hadis_bookmarks_v1'), hasLength(1));
    });

    test('lokal yang sudah ada tidak ditimpa cloud', () async {
      final b = HadisBookmarks();
      await b.toggle(snap(1));
      await b.restoreFromRemote({
        'hadisBookmarks': [
          {
            'id': 999,
            'arabic': 'x',
            'translation': 'y',
            'addedAt': '2026-09-01T00:00:00.000',
          },
        ],
      });

      expect(b.isBookmarked(1), isTrue);
      expect(b.isBookmarked(999), isFalse);
    });

    test('tidak ada field hadisBookmarks → tetap kosong', () async {
      final b = HadisBookmarks();
      await b.restoreFromRemote({'bookmarks': <dynamic>[]});
      expect(b.items, isEmpty);
    });
  });

  group('CloudSync: field hadis terpisah dari bookmark ayat', () {
    test('saveHadisBookmarks menulis kunci hadisBookmarks, bukan bookmarks',
        () async {
      final written = <Map<String, dynamic>>[];
      CloudSync.documentReader = (_) async => null;
      CloudSync.documentWriter = (_, data) async => written.add(data);
      await CloudSync.initWithUser('user-1');

      await CloudSync.saveHadisBookmarks([
        {'id': 1, 'arabic': 'a', 'translation': 't'},
      ]);

      expect(written, hasLength(1));
      expect(written.single.containsKey('hadisBookmarks'), isTrue);
      // Kunci 'bookmarks' milik bookmark AYAT: tidak boleh ikut tertulis,
      // karena tiap tulisan mengganti seluruh array.
      expect(written.single.containsKey('bookmarks'), isFalse);
    });

    test('saveBookmarks (ayat) tidak menyentuh kunci hadis', () async {
      final written = <Map<String, dynamic>>[];
      CloudSync.documentReader = (_) async => null;
      CloudSync.documentWriter = (_, data) async => written.add(data);
      await CloudSync.initWithUser('user-1');

      await CloudSync.saveBookmarks([
        {'surah': 2, 'ayah': 255, 'arabic': 'a', 'translation': 't'},
      ]);

      expect(written.single.containsKey('bookmarks'), isTrue);
      expect(written.single.containsKey('hadisBookmarks'), isFalse);
    });

    test('menyimpan hadis tidak mengosongkan bookmark ayat di prefs',
        () async {
      final q = QuranBookmarks();
      await q.toggle(2, 255, 'arab', 'terjemah');
      final p = await SharedPreferences.getInstance();
      expect(p.getStringList('quran_bookmarks_v1'), hasLength(1));

      final h = HadisBookmarks();
      await h.toggle(snap(7));

      // Dua store terpisah: aktivitas hadis tidak menyentuh store ayat.
      expect(p.getStringList('quran_bookmarks_v1'), hasLength(1));
      expect(p.getStringList('hadis_bookmarks_v1'), hasLength(1));
      expect(q.isBookmarked(2, 255), isTrue);
    });

    test('teardown', () {
      CloudSync.resetDocumentReader();
      CloudSync.resetDocumentWriter();
    });
  });
}

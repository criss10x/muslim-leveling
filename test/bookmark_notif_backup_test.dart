import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/notification_service.dart';
import 'package:muslim_leveling/services/quran_bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Backup bookmark & pengaturan notifikasi: lokal selalu menang, cloud cuma
/// mengisi kekosongan (jalur utama: reinstall / ganti HP).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('QuranBookmarks.restoreFromRemote', () {
    test('mengisi dari cloud saat lokal kosong', () async {
      final b = QuranBookmarks();
      await b.restoreFromRemote({
        'bookmarks': [
          {
            'surah': 2,
            'ayah': 255,
            'arabic': 'arab',
            'translation': 'terjemah',
            'addedAt': '2026-09-01T00:00:00.000',
          },
        ],
      });

      expect(b.items.length, 1);
      expect(b.isBookmarked(2, 255), isTrue);
      // Ditulis balik ke prefs → baca berikutnya tanpa cloud lagi.
      final p = await SharedPreferences.getInstance();
      expect(p.getStringList('quran_bookmarks_v1'), hasLength(1));
    });

    test('lokal yang sudah ada tidak ditimpa cloud', () async {
      SharedPreferences.setMockInitialValues({
        'quran_bookmarks_v1': [
          '{"surah":1,"ayah":1,"arabic":"a","translation":"t",'
              '"addedAt":"2026-09-02T00:00:00.000"}'
        ],
      });
      final b = QuranBookmarks();
      await b.load();
      await b.restoreFromRemote({
        'bookmarks': [
          {'surah': 9, 'ayah': 9, 'arabic': 'x', 'translation': 'y'},
        ],
      });

      expect(b.items, hasLength(1));
      expect(b.isBookmarked(1, 1), isTrue);
      expect(b.isBookmarked(9, 9), isFalse);
    });

    test('dokumen null / payload rusak tidak melempar', () async {
      final b = QuranBookmarks();
      await b.restoreFromRemote(null);
      await b.restoreFromRemote({'bookmarks': 'bukan list'});
      expect(b.items, isEmpty);
    });
  });

  group('NotificationService.restoreFromRemote', () {
    test('mengisi mode/sound/perPrayer saat prefs kosong', () async {
      await NotificationService.restoreFromRemote({
        'notif': {
          'mode': 'intensif',
          'sound': 'suara',
          'perPrayer': '{"subuh":"senyap"}',
        },
      });

      expect(await NotificationService.getNotifMode(), 'intensif');
      expect(await NotificationService.getSoundMode(), 'suara');
      expect(
        await NotificationService.getPerPrayerSounds(),
        {'subuh': 'senyap'},
      );
    });

    test('nilai lokal yang sudah ada menang; nilai tak dikenal ditolak',
        () async {
      SharedPreferences.setMockInitialValues({
        'notif_mode': 'fokus',
        'notif_sound_mode': 'senyap',
      });
      await NotificationService.restoreFromRemote({
        'notif': {
          'mode': 'mode-ngawur',
          'sound': 'adzan',
          'perPrayer': '{"isya":"adzan"}',
        },
      });

      expect(await NotificationService.getNotifMode(), 'fokus');
      expect(await NotificationService.getSoundMode(), 'senyap');
      // perPrayer lokal kosong → tetap diisi cloud.
      expect(await NotificationService.getPerPrayerSounds(), {'isya': 'adzan'});
    });

    test('tanpa field notif di dokumen → tidak mengubah apa pun', () async {
      await NotificationService.restoreFromRemote({'game': {}});
      expect(await NotificationService.getNotifMode(), 'seimbang');
      expect(await NotificationService.getSoundMode(), 'adzan');
      expect(await NotificationService.getPerPrayerSounds(), isEmpty);
    });
  });
}

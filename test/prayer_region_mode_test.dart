import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/prayer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mode wilayah: Indonesia tetap equran, luar negeri lewat Aladhan.
///
/// Tes ini tidak memanggil jaringan. Yang diuji adalah bagian yang bisa salah
/// diam-diam: pemilihan mode, bentuk koordinat, dan pemetaan kunci waktu —
/// kalau salah, jadwal tampil kosong atau terjemahan nyantol ke waktu yang
/// bukan waktunya.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('mode wilayah', () {
    test('default Indonesia (equran)', () async {
      expect(await PrayerService.isAbroad(), isFalse);
    });

    test('setAbroad bertahan di prefs', () async {
      await PrayerService.setAbroad(true);
      expect(await PrayerService.isAbroad(), isTrue);
      await PrayerService.setAbroad(false);
      expect(await PrayerService.isAbroad(), isFalse);
    });

    test('saveLocation bisa sekaligus mengubah mode', () async {
      await PrayerService.saveLocation('51.5,-0.12', 'London, UK', abroad: true);
      expect(await PrayerService.isAbroad(), isTrue);
      final loc = await PrayerService.loadLocation();
      expect(loc!.id, '51.5,-0.12');
      expect(loc.name, 'London, UK');
    });

    test('saveLocation tanpa abroad tidak mengubah mode', () async {
      // Pemanggil lama (ganti kota dalam mode yang sama) tidak boleh
      // diam-diam menendang user keluar dari mode luar negeri.
      await PrayerService.setAbroad(true);
      await PrayerService.saveLocation('Bali/Kab. Badung', 'Kab. Badung');
      expect(await PrayerService.isAbroad(), isTrue);
    });
  });

  group('pencarian kota luar negeri', () {
    test('kueri < 3 huruf tidak memanggil jaringan', () async {
      // Nominatim dibatasi 1 req/detik; menembak "Lo" membuang jatah.
      expect(await PrayerService.searchAbroadCities('Lo'), isEmpty);
      expect(await PrayerService.searchAbroadCities(''), isEmpty);
    });
  });

  group('pemetaan waktu Aladhan', () {
    // Balasan asli Aladhan (dipangkas) — sufiks zona '(BST)' dan tanda '(+1)'
    // inilah yang bikin parsing naif menghasilkan '--:--'.
    const aladhanTimings = {
      'Fajr': '04:49 (BST)',
      'Sunrise': '06:43 (BST)',
      'Dhuhr': '12:54 (BST)',
      'Asr': '16:15 (BST)',
      'Maghrib': '19:04 (BST)',
      'Isha': '20:51 (BST)',
      'Imsak': '04:39 (BST)',
      'Midnight': '00:00 (BST)',
      'Firstthird': '23:00 (BST)',
      'Lastthird': '02:32 (+1)',
    };

    test('jam utuh walau ada sufiks zona dan tanda hari', () {
      final mapped = PrayerService.mapAladhanTimings(aladhanTimings);
      expect(mapped['subuh'], '04:49');
      expect(mapped['terbit'], '06:43');
      expect(mapped['dzuhur'], '12:54');
      expect(mapped['ashar'], '16:15');
      expect(mapped['maghrib'], '19:04');
      expect(mapped['isya'], '20:51');
      expect(mapped['imsak'], '04:39');
      // Kunci yang tidak dikenali equran tidak boleh bocor ke jadwal.
      expect(mapped.containsKey('Midnight'), isFalse);
    });

    test('setiap kunci yang dipakai layar jadwal terisi, bukan --:--', () {
      // Kalau salah satu kosong, baris sholat tampil '--:--' di HP user.
      final mapped = PrayerService.mapAladhanTimings(aladhanTimings);
      for (final key in ['imsak', 'subuh', 'terbit', 'dhuha', 'dzuhur', 'ashar', 'maghrib', 'isya']) {
        expect(mapped[key], isNotNull, reason: key);
        expect(mapped[key], isNot('--:--'), reason: key);
      }
    });

    test('dhuha dihitung dari terbit, bukan dikosongkan', () {
      final mapped = PrayerService.mapAladhanTimings(aladhanTimings);
      expect(mapped['dhuha'], '07:08'); // 06:43 + 25m
    });

    test('dhuha melewati tengah malam tidak menghasilkan jam 25', () {
      final mapped = PrayerService.mapAladhanTimings({
        ...aladhanTimings,
        'Sunrise': '23:50',
      });
      expect(mapped['dhuha'], '00:15');
    });

    test('nilai rusak jadi --:--, bukan crash', () {
      final mapped = PrayerService.mapAladhanTimings({
        'Fajr': null,
        'Sunrise': 'tidak ada',
        'Dhuhr': '12:54',
      });
      expect(mapped['subuh'], '--:--');
      expect(mapped['terbit'], '--:--');
      expect(mapped['dzuhur'], '12:54');
    });
  });
}

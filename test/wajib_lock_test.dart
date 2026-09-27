import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';

void main() {
  final t = Timings(
    imsak: '04:10', subuh: '04:20', terbit: '05:35',
    dzuhur: '12:10', ashar: '15:30', maghrib: '18:15', isya: '19:30',
  );

  setUp(() {
    GameService.setTestSkipTimeWindow(false);
  });
  tearDown(() {
    GameService.clearTestNow();
    GameService.setTestSkipTimeWindow(true);
  });

  void at(String hhmm) => GameService.setTestNow(hhmm);
  bool open(String p) => GameService.isPrayerWindowOpen(p, t);

  test('wajib: locked di [03:00, adzan), open adzan → 03:00', () {
    at('02:59'); expect(open('dzuhur'), isTrue, reason: 'dzuhur open sebelum 03:00');
    at('03:00'); expect(open('dzuhur'), isFalse, reason: 'dzuhur locked jam 03:00');
    at('11:00'); expect(open('dzuhur'), isFalse, reason: 'dzuhur locked sebelum adzan');
    at('12:10'); expect(open('dzuhur'), isTrue, reason: 'dzuhur open saat adzan');
    at('23:30'); expect(open('dzuhur'), isTrue, reason: 'dzuhur masih open malam');

    at('03:00'); expect(open('isya'), isFalse, reason: 'isya locked jam 03:00');
    at('19:30'); expect(open('isya'), isTrue, reason: 'isya open saat adzan');
    at('02:30'); expect(open('isya'), isTrue, reason: 'isya open lewat tengah malam');
  });

  test('subuh: jendela sama dengan wajib lain — adzan → 03:00', () {
    at('03:00'); expect(open('subuh'), isFalse, reason: 'subuh locked jam 03:00');
    at('04:19'); expect(open('subuh'), isFalse, reason: 'subuh locked sebelum adzan');
    at('04:20'); expect(open('subuh'), isTrue, reason: 'subuh open saat adzan');
    at('07:19'); expect(open('subuh'), isTrue, reason: 'subuh masih open pagi');
    at('12:00'); expect(open('subuh'), isTrue, reason: 'subuh open sampai 03:00');
  });

  test('sunnah windows tidak berubah', () {
    at('06:00'); expect(GameService.isSunnahOnTime('dhuha', t), isTrue);
    at('13:00'); expect(GameService.isSunnahOnTime('dhuha', t), isFalse);
    at('22:00'); expect(GameService.isSunnahOnTime('tahajjud', t), isTrue);
    at('01:00'); expect(GameService.isSunnahOnTime('tahajjud', t), isTrue);
    at('05:00'); expect(GameService.isSunnahOnTime('tahajjud', t), isFalse);
    at('19:31'); expect(GameService.isSunnahOnTime('rawatib_isya_ba_diyyah', t), isTrue);
  });
}

import 'package:muslim_leveling/services/game_service.dart';

void main() {
  final t = Timings(
    imsak: '04:10', subuh: '04:20', terbit: '05:35',
    dzuhur: '12:10', ashar: '15:30', maghrib: '18:15', isya: '19:30',
  );

  GameService.setTestSkipTimeWindow(false);

  void at(String hhmm) => GameService.setTestNow(hhmm);
  bool open(String p) => GameService.isPrayerWindowOpen(p, t);

  // ── Wajib: locked di [03:00, adzan), open adzan → 03:00 ──
  at('02:59'); assert(open('dzuhur') == true,  'dzuhur open sebelum 03:00');
  at('03:00'); assert(open('dzuhur') == false, 'dzuhur locked jam 03:00');
  at('11:00'); assert(open('dzuhur') == false, 'dzuhur locked sebelum adzan');
  at('12:10'); assert(open('dzuhur') == true,  'dzuhur open saat adzan');
  at('23:30'); assert(open('dzuhur') == true,  'dzuhur masih open malam');

  at('03:00'); assert(open('isya') == false, 'isya locked jam 03:00');
  at('19:30'); assert(open('isya') == true,  'isya open saat adzan');
  at('02:30'); assert(open('isya') == true,  'isya open lewat tengah malam');

  // ── Subuh: open adzan → +3 jam, tetap locked 03:00 → adzan ──
  at('03:00'); assert(open('subuh') == false, 'subuh locked jam 03:00');
  at('04:19'); assert(open('subuh') == false, 'subuh locked sebelum adzan');
  at('04:20'); assert(open('subuh') == true,  'subuh open saat adzan');
  at('07:19'); assert(open('subuh') == true,  'subuh open +2j59m');
  at('07:20'); assert(open('subuh') == false, 'subuh locked +3 jam');

  // ── Sunnah windows tidak berubah ──
  at('06:00'); assert(GameService.isSunnahOnTime('dhuha', t) == true);
  at('13:00'); assert(GameService.isSunnahOnTime('dhuha', t) == false);
  at('22:00'); assert(GameService.isSunnahOnTime('tahajjud', t) == true);
  at('01:00'); assert(GameService.isSunnahOnTime('tahajjud', t) == true);
  at('05:00'); assert(GameService.isSunnahOnTime('tahajjud', t) == false);
  at('19:31'); assert(GameService.isSunnahOnTime('rawatib_isya_ba_diyyah', t) == true);

  GameService.clearTestNow();
  GameService.setTestSkipTimeWindow(true);
}

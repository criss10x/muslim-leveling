import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/services/game_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.setTestSkipTimeWindow(true);
    GameService.setTestNow('10:00');
  });
  tearDown(() {
    GameService.clearTestNow();
    GameService.setTestSkipTimeWindow(true);
  });

  test('quest_timely_prayers: 3 wajib bebas waktu → selesai (tanpa ambang 10 menit)', () async {
    final t = Timings(
      imsak: '04:10', subuh: '04:20', terbit: '05:35',
      dzuhur: '12:10', ashar: '15:30', maghrib: '18:15', isya: '19:30',
    );
    GameService.resetForTest();
    final initial = GameService.current;

    // Suntik pool yang deterministik: hanya quest yang dites, supaya rotasi
    // harian (shuffle berdasarkan tanggal) tidak mengacaukan asersi.
    final onlyTimely = initial.copyWith(quests: [
      Quest(
        id: 'quest_timely_prayers',
        desc: 'test',
        xpReward: 60,
        target: 3,
        progress: 0,
        completed: false,
        claimed: false,
      ),
    ]);

    // Log 3 wajib dengan waktu SANGAT telat (mis. 2 jam setelah adzan):
    // dengan perilaku lama (≤10 menit) ini tidak dihitung; perilaku baru
    // (bebas waktu, dari tombol) harus selesai.
    final withLogs = onlyTimely.copyWith(prayerLog: [
      PrayerLog(date: GameService.todayStr(), prayer: 'subuh', time: '07:00', type: 'wajib'),
      PrayerLog(date: GameService.todayStr(), prayer: 'dzuhur', time: '14:30', type: 'wajib'),
      PrayerLog(date: GameService.todayStr(), prayer: 'ashar', time: '17:00', type: 'wajib'),
    ]);
    final quests = GameService.progressQuestsForTest(withLogs, t);

    final q = quests.firstWhere((q) => q.id == 'quest_timely_prayers');
    expect(q.progress, 3);
    expect(q.completed, isTrue);
  });

  test('quest_timely_prayers: kurang dari 3 wajib → belum selesai', () async {
    final t = Timings(
      imsak: '04:10', subuh: '04:20', terbit: '05:35',
      dzuhur: '12:10', ashar: '15:30', maghrib: '18:15', isya: '19:30',
    );
    GameService.resetForTest();
    final initial = GameService.current;
    final onlyTimely = initial.copyWith(quests: [
      Quest(
        id: 'quest_timely_prayers',
        desc: 'test',
        xpReward: 60,
        target: 3,
        progress: 0,
        completed: false,
        claimed: false,
      ),
    ]);

    final withLogs = onlyTimely.copyWith(prayerLog: [
      PrayerLog(date: GameService.todayStr(), prayer: 'subuh', time: '04:25', type: 'wajib'),
      PrayerLog(date: GameService.todayStr(), prayer: 'dzuhur', time: '12:15', type: 'wajib'),
    ]);
    final quests = GameService.progressQuestsForTest(withLogs, t);

    final q = quests.firstWhere((q) => q.id == 'quest_timely_prayers');
    expect(q.progress, 2);
    expect(q.completed, isFalse);
  });
}

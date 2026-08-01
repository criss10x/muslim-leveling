import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';

void main() {
  test('backfill membangun streak per salat dari riwayat wajib yang ada', () {
    final state = GameState(
      prayerLog: [
        PrayerLog(
          date: '2026-07-01',
          prayer: 'subuh',
          time: '04:45',
          type: 'wajib',
        ),
        PrayerLog(
          date: '2026-07-02',
          prayer: 'subuh',
          time: '04:44',
          type: 'wajib',
        ),
        PrayerLog(
          date: '2026-07-03',
          prayer: 'subuh',
          time: '04:46',
          type: 'wajib',
        ),
      ],
    );

    final restored = GameService.backfillPrayerStreaks(state);
    final subuh = restored.perPrayerStreaks['subuh']!;

    expect(subuh.current, 3);
    expect(subuh.best, 3);
    expect(subuh.lastDate, '2026-07-03');
  });

  test('backfill tidak menimpa streak per salat yang sudah tersimpan', () {
    final state = GameState(
      prayerLog: [
        PrayerLog(
          date: '2026-07-01',
          prayer: 'subuh',
          time: '04:45',
          type: 'wajib',
        ),
      ],
      perPrayerStreaks: {
        'subuh': StreakState(current: 8, best: 12, lastDate: '2026-08-01'),
      },
    );

    final restored = GameService.backfillPrayerStreaks(state);

    expect(restored.perPrayerStreaks['subuh']!.current, 8);
    expect(restored.perPrayerStreaks['subuh']!.best, 12);
  });
}

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

  test(
    'backfill memperbaiki streak yang tersimpan 1 (korup/reset sync) dari riwayat',
    () {
      final state = GameState(
        prayerLog: [
          PrayerLog(
            date: '2026-07-01',
            prayer: 'isya',
            time: '19:45',
            type: 'wajib',
          ),
          PrayerLog(
            date: '2026-07-02',
            prayer: 'isya',
            time: '19:44',
            type: 'wajib',
          ),
          PrayerLog(
            date: '2026-07-03',
            prayer: 'isya',
            time: '19:46',
            type: 'wajib',
          ),
        ],
        perPrayerStreaks: {
          'isya': StreakState(current: 1, best: 1, lastDate: '2026-07-03'),
        },
      );

      final healed = GameService.backfillPrayerStreaks(state);

      expect(healed.perPrayerStreaks['isya']!.current, 3);
      expect(healed.perPrayerStreaks['isya']!.best, 3);
      expect(healed.perPrayerStreaks['isya']!.lastDate, '2026-07-03');
    },
  );

  test(
    'backfill biarkan streak tersimpan yang sudah lebih kaya dari log (tidak turun)',
    () {
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
      expect(restored.perPrayerStreaks['subuh']!.lastDate, '2026-08-01');
    },
  );

  test(
    'rebuild streak kembali ke hari sebelumnya setelah catatan hari ini dihapus',
    () {
      final remainingLogs = [
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
      ];

      final rebuilt = GameService.restorePrayerStreakAfterUnlog(
        remainingLogs,
        'subuh',
        previous: StreakState(current: 3, best: 3, lastDate: '2026-07-03'),
      );

      expect(rebuilt.current, 2);
      expect(rebuilt.best, 3);
      expect(rebuilt.lastDate, '2026-07-02');
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/achievement_service.dart';
import 'package:muslim_leveling/services/game_service.dart';

// ponytail: runnable check untuk penghapusan Bonus Quest "Ba'diyah Subuh".
// Tiga hal yang bisa rusak diam-diam:
//  (a) state lama user masih menyimpan kunci medali yang sudah dihapus, dan
//      unlockedCount membaca panjang map — bukan irisan dengan defs.
//  (b) medali `collector` jadi mustahil dibuka kalau daftar syaratnya tidak
//      ikut diperbarui saat satu jenis sunnah dibuang.
//  (c) id itu masih bisa dicatat lewat jalur lain (mis. cloud restore).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
    AchievementService.resetForTest();
  });

  test('kunci medali yang sudah dihapus dibuang saat load', () async {
    SharedPreferences.setMockInitialValues({
      'achievements_unlocked':
          '{"dawn_finisher":"2026-01-01","langkah_pertama":"2026-01-01"}',
    });
    await AchievementService.load();

    expect(AchievementService.isUnlocked('dawn_finisher'), isFalse);
    expect(AchievementService.isUnlocked('langkah_pertama'), isTrue);
    expect(AchievementService.unlockedCount, 1);
  });

  test('defs tidak lagi memuat dawn_finisher', () {
    expect(
      AchievementService.defs.any((d) => d.id == 'dawn_finisher'),
      isFalse,
    );
    expect(
      AchievementService.defs.any((d) => d.id == 'dawn_buff'),
      isTrue,
      reason: 'Qobliyah Subuh tetap ada; hanya ba\'diyah yang dibuang',
    );
  });

  test('collector terbuka dengan 8 jenis sunnah (tanpa ba\'diyah subuh)',
      () async {
    GameService.setStateForTest(GameState(prayerLog: [
      for (final p in const [
        'dhuha', 'tahajjud',
        'rawatib_subuh_qobliyah',
        'rawatib_dzuhur_qobliyah', 'rawatib_dzuhur_ba_diyyah',
        'rawatib_ashar_qobliyah',
        'rawatib_maghrib_ba_diyyah', 'rawatib_isya_ba_diyyah',
      ])
        PrayerLog(date: '2026-01-01', prayer: p, time: '12:00', type: 'sunnah'),
    ]));
    await AchievementService.load();
    await AchievementService.refresh(silent: true);

    expect(AchievementService.isUnlocked('collector'), isTrue);
  });

  test('collector tetap terkunci kalau satu jenis sunnah belum dicatat',
      () async {
    GameService.setStateForTest(GameState(prayerLog: [
      for (final p in const ['dhuha', 'tahajjud', 'rawatib_subuh_qobliyah'])
        PrayerLog(date: '2026-01-01', prayer: p, time: '12:00', type: 'sunnah'),
    ]));
    await AchievementService.load();
    await AchievementService.refresh(silent: true);

    expect(AchievementService.isUnlocked('collector'), isFalse);
  });
}

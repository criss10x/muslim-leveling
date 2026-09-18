// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppL10nId extends AppL10n {
  AppL10nId([String locale = 'id']) : super(locale);

  @override
  String get achBtnAwesome => 'MANTAP!';

  @override
  String get achBtnShare => 'Bagikan';

  @override
  String get achBtnSkipAll => 'Lewati semua';

  @override
  String achEarnedOn(String date, String tier) {
    return 'Terbuka $date • $tier';
  }

  @override
  String achHintFallback(String desc) {
    return 'Selesaikan: $desc.';
  }

  @override
  String achLockedTier(String tier) {
    return 'Terkunci • $tier';
  }

  @override
  String achScreenProgress(int total) {
    return ' / $total medali terbuka';
  }

  @override
  String get achScreenTitle => 'Achievements';

  @override
  String get achSectionTitle => 'ACHIEVEMENTS';

  @override
  String get achSeeAll => 'Lihat semua';

  @override
  String achSemanticsDetail(
    String state,
    String title,
    String desc,
    String tier,
  ) {
    return '$state: $title. $desc. Tier $tier.';
  }

  @override
  String achSemanticsUnlocked(String title, String desc, String tier) {
    return 'Achievement terbuka: $title. $desc. Tier $tier.';
  }

  @override
  String get achStateLocked => 'Terkunci';

  @override
  String get achStateUnlocked => 'Terbuka';

  @override
  String get achTierElite => 'ELITE';

  @override
  String get achTierEpic => 'EPIC';

  @override
  String get achTierGold => 'GOLD';

  @override
  String get achTierLegendary => 'LEGENDARY';

  @override
  String get achTierRookie => 'ROOKIE';

  @override
  String get achUnlockedBanner => 'PENCAPAIAN TERBUKA!';

  @override
  String get ach_collector_desc => 'Log semua 8 jenis sholat sunnah minimal 1×';

  @override
  String get ach_collector_hint =>
      'Catat minimal 1× dari 8 jenis sunnah: Dhuha, Tahajjud, dan 6 rawatib.';

  @override
  String get ach_collector_title => 'COLLECTOR';

  @override
  String get ach_comeback_real_desc => 'Bangkit lagi setelah streak putus';

  @override
  String get ach_comeback_real_title => 'COMEBACK IS REAL';

  @override
  String get ach_critical_hit_desc => 'Sholat wajib ≤5 menit setelah adzan';

  @override
  String get ach_critical_hit_title => 'CRITICAL HIT!';

  @override
  String get ach_dawn_buff_desc => 'Pertama kali Qobliyah Subuh';

  @override
  String get ach_dawn_buff_title => 'DAWN BUFF';

  @override
  String get ach_dhuha_secured_desc => 'Pertama kali log sholat Dhuha';

  @override
  String get ach_dhuha_secured_title => 'DHUHA SECURED';

  @override
  String get ach_dominating_desc => 'Hero Streak 7 hari beruntun';

  @override
  String get ach_dominating_title => 'DOMINATING!';

  @override
  String get ach_double_kill_desc => 'Hero Streak 2 hari beruntun';

  @override
  String get ach_double_kill_title => 'DOUBLE KILL';

  @override
  String get ach_dusk_finisher_desc => 'Pertama kali Ba\\\'diyah Maghrib';

  @override
  String get ach_dusk_finisher_title => 'DUSK FINISHER';

  @override
  String get ach_dzikir_legend_desc => 'Dzikir 50.000x';

  @override
  String get ach_dzikir_legend_hint =>
      'Total hitungan dzikir dari tab Dzikir seumur hidup akun.';

  @override
  String get ach_dzikir_legend_title => 'DZIKIR LEGEND';

  @override
  String get ach_dzikir_master_desc => 'Dzikir 10.000x';

  @override
  String get ach_dzikir_master_title => 'DZIKIR MASTER';

  @override
  String get ach_dzikir_pemula_desc => 'Dzikir 1.000x';

  @override
  String get ach_dzikir_pemula_title => 'DZIKIR PEMULA';

  @override
  String get ach_early_bird_desc => '20x sholat tepat waktu (±10m)';

  @override
  String get ach_early_bird_hint =>
      '20× sholat tepat waktu (≤10 menit setelah adzan).';

  @override
  String get ach_early_bird_title => 'EARLY BIRD';

  @override
  String get ach_early_game_desc => 'Sholat Subuh pertamamu tercatat';

  @override
  String get ach_early_game_title => 'EARLY GAME';

  @override
  String get ach_first_blood_desc =>
      'Selesaikan 5 sholat wajib dalam 1 hari (Hero Streak dimulai!)';

  @override
  String get ach_first_blood_hint =>
      'Catat 5 sholat wajib dalam satu hari (Subuh, Dzuhur, Ashar, Maghrib, Isya).';

  @override
  String get ach_first_blood_title => 'FIRST BLOOD!';

  @override
  String get ach_first_clear_module_desc =>
      'Selesaikan modul Belajar pertamamu';

  @override
  String get ach_first_clear_module_title => 'FIRST CLEAR';

  @override
  String get ach_first_strike_desc => 'Sholat Subuh ≤15 menit setelah adzan';

  @override
  String get ach_first_strike_hint =>
      'Sholat Subuh dalam 15 menit setelah adzan.';

  @override
  String get ach_first_strike_title => 'FIRST STRIKE';

  @override
  String get ach_full_combo_desc => 'Dalam 1 hari: 5 wajib + Tilawah + Dhuha';

  @override
  String get ach_full_combo_hint =>
      'Dalam satu hari: catat 5 wajib + Tilawah + Dhuha.';

  @override
  String get ach_full_combo_title => 'FULL COMBO';

  @override
  String get ach_godlike_desc => 'Hero Streak 30 hari beruntun';

  @override
  String get ach_godlike_title => 'GODLIKE!';

  @override
  String get ach_gold_buff_desc => 'Pertama kali Qobliyah Ashar';

  @override
  String get ach_gold_buff_title => 'GOLD BUFF';

  @override
  String get ach_gold_lane_desc => 'Pertama kali log sholat Ashar';

  @override
  String get ach_gold_lane_title => 'GOLD LANE';

  @override
  String get ach_hadis_champion_desc => 'Baca 200 hadis';

  @override
  String get ach_hadis_champion_title => 'HADIS CHAMPION';

  @override
  String get ach_hadis_elite_desc => 'Baca 50 hadis';

  @override
  String get ach_hadis_elite_title => 'HADIS ELITE';

  @override
  String get ach_hadis_grinder_desc => 'Baca 10 hadis';

  @override
  String get ach_hadis_grinder_title => 'HADIS GRINDER';

  @override
  String get ach_hadis_hero_desc => 'Baca 350 hadis';

  @override
  String get ach_hadis_hero_title => 'HADIS HERO';

  @override
  String get ach_hadis_legend_desc => 'Baca 500 hadis';

  @override
  String get ach_hadis_legend_title => 'HADIS LEGEND';

  @override
  String get ach_hadis_rookie_desc => 'Baca 5 hadis';

  @override
  String get ach_hadis_rookie_title => 'HADIS ROOKIE';

  @override
  String get ach_hadis_veteran_desc => 'Baca 100 hadis';

  @override
  String get ach_hadis_veteran_title => 'HADIS VETERAN';

  @override
  String get ach_hadis_warrior_desc => 'Baca 25 hadis';

  @override
  String get ach_hadis_warrior_title => 'HADIS WARRIOR';

  @override
  String get ach_hall_of_fame_desc => 'Buka semua achievement lainnya 👑';

  @override
  String get ach_hall_of_fame_hint =>
      'Buka semua achievement lainnya satu per satu — terakhir dari 87 medali biasa.';

  @override
  String get ach_hall_of_fame_title => 'HALL OF FAME';

  @override
  String get ach_jamaah_champion_desc => '200x sholat berjamaah';

  @override
  String get ach_jamaah_champion_title => 'JAMAAH CHAMPION';

  @override
  String get ach_jamaah_elite_desc => '50x sholat berjamaah';

  @override
  String get ach_jamaah_elite_title => 'JAMAAH ELITE';

  @override
  String get ach_jamaah_grinder_desc => '10x sholat berjamaah';

  @override
  String get ach_jamaah_grinder_title => 'JAMAAH GRINDER';

  @override
  String get ach_jamaah_hero_desc => '350x sholat berjamaah';

  @override
  String get ach_jamaah_hero_title => 'JAMAAH HERO';

  @override
  String get ach_jamaah_legend_desc => '500x sholat berjamaah';

  @override
  String get ach_jamaah_legend_title => 'JAMAAH LEGEND';

  @override
  String get ach_jamaah_rookie_desc => '5x sholat berjamaah';

  @override
  String get ach_jamaah_rookie_title => 'JAMAAH ROOKIE';

  @override
  String get ach_jamaah_veteran_desc => '100x sholat berjamaah';

  @override
  String get ach_jamaah_veteran_title => 'JAMAAH VETERAN';

  @override
  String get ach_jamaah_warrior_desc => '25x sholat berjamaah';

  @override
  String get ach_jamaah_warrior_title => 'JAMAAH WARRIOR';

  @override
  String get ach_jungler_desc => 'Streak Tilawah 7 hari beruntun';

  @override
  String get ach_jungler_title => 'JUNGLER';

  @override
  String get ach_langkah_pertama_desc => 'Log sholat pertama kamu';

  @override
  String get ach_langkah_pertama_title => 'LANGKAH PERTAMA';

  @override
  String get ach_late_game_desc => 'Pertama kali log sholat Isya';

  @override
  String get ach_late_game_title => 'LATE GAME';

  @override
  String get ach_legendary_desc => 'Hero Streak 100 hari beruntun';

  @override
  String get ach_legendary_title => 'LEGENDARY!';

  @override
  String get ach_mana_regen_desc => 'Pertama kali log Tilawah/Dzikir';

  @override
  String get ach_mana_regen_title => 'MANA REGEN';

  @override
  String get ach_maniac_desc => 'Hero Streak 14 hari beruntun';

  @override
  String get ach_maniac_title => 'MANIAC!';

  @override
  String get ach_mid_buff_desc => 'Pertama kali Qobliyah Dzuhur';

  @override
  String get ach_mid_buff_title => 'MID BUFF';

  @override
  String get ach_mid_finisher_desc => 'Pertama kali Ba\\\'diyah Dzuhur';

  @override
  String get ach_mid_finisher_title => 'MID FINISHER';

  @override
  String get ach_mid_game_desc => 'Pertama kali log sholat Dzuhur';

  @override
  String get ach_mid_game_title => 'MID GAME';

  @override
  String get ach_night_finisher_desc => 'Pertama kali Ba\\\'diyah Isya';

  @override
  String get ach_night_finisher_title => 'NIGHT FINISHER';

  @override
  String get ach_phoenix_desc =>
      'Bangkit 3× setelah streak putus — gak pernah nyerah';

  @override
  String get ach_phoenix_hint =>
      'Setelah streak putus, mulai lagi sampai tercatat 3 kali bangkit.';

  @override
  String get ach_phoenix_title => 'PHOENIX';

  @override
  String get ach_quiz_mvp_desc => 'Skor sempurna 100% di satu quiz';

  @override
  String get ach_quiz_mvp_hint =>
      'Kerjakan kuis di akhir modul Belajar dan jawab semua benar (100%).';

  @override
  String get ach_quiz_mvp_title => 'MVP';

  @override
  String get ach_quran_adept_desc => 'Baca 100 ayat';

  @override
  String get ach_quran_adept_title => 'QURAN ADEPT';

  @override
  String get ach_quran_apprentice_desc => 'Baca 50 ayat';

  @override
  String get ach_quran_apprentice_title => 'QURAN APPRENTICE';

  @override
  String get ach_quran_champion_desc => 'Baca 4.000 ayat';

  @override
  String get ach_quran_champion_title => 'QURAN CHAMPION';

  @override
  String get ach_quran_guardian_desc => 'Baca 2.000 ayat';

  @override
  String get ach_quran_guardian_title => 'QURAN GUARDIAN';

  @override
  String get ach_quran_hafizh_desc => 'Baca 1.000 ayat';

  @override
  String get ach_quran_hafizh_title => 'HAFIZH MUDA';

  @override
  String get ach_quran_master_desc => 'Baca 6.236 ayat (khatam)';

  @override
  String get ach_quran_master_hint =>
      'Baca total 6.236 ayat (seluruh Al-Qur\\\'an) sejak pertama install.';

  @override
  String get ach_quran_master_title => 'HAFIZH MASTER';

  @override
  String get ach_quran_novice_desc => 'Baca 10 ayat';

  @override
  String get ach_quran_novice_title => 'QURAN NOVICE';

  @override
  String get ach_quran_sage_desc => 'Baca 500 ayat';

  @override
  String get ach_quran_sage_title => 'QURAN SAGE';

  @override
  String get ach_quran_scholar_desc => 'Baca 200 ayat';

  @override
  String get ach_quran_scholar_title => 'QURAN SCHOLAR';

  @override
  String get ach_rank_elite_desc => 'Capai Level 25';

  @override
  String get ach_rank_elite_title => 'ELITE';

  @override
  String get ach_rank_epic_desc => 'Capai Level 60';

  @override
  String get ach_rank_epic_title => 'EPIC';

  @override
  String get ach_rank_master_desc => 'Capai Level 40';

  @override
  String get ach_rank_master_title => 'MASTER';

  @override
  String get ach_rank_mythic_desc => 'Capai Level 80 — Muslim Mythic!';

  @override
  String get ach_rank_mythic_hint =>
      'Naik level lewat XP dari ibadah harian — naik level 80 butuh waktu.';

  @override
  String get ach_rank_mythic_title => 'MYTHIC';

  @override
  String get ach_rank_warrior_desc => 'Capai Level 10';

  @override
  String get ach_rank_warrior_title => 'WARRIOR';

  @override
  String get ach_sage_desc => 'Tamatkan semua 16 modul Belajar';

  @override
  String get ach_sage_hint =>
      'Selesaikan semua 16 modul Belajar (skor kuis terserah).';

  @override
  String get ach_sage_title => 'SAGE';

  @override
  String get ach_santri_scholar_desc => 'Selesaikan 40 modul Belajar';

  @override
  String get ach_santri_scholar_hint =>
      'Selesaikan 40 modul di tab Belajar (saat ini 16 modul, naik bertahap).';

  @override
  String get ach_santri_scholar_title => 'SANTRI SCHOLAR';

  @override
  String get ach_savage_desc => 'Hero Streak 60 hari beruntun';

  @override
  String get ach_savage_title => 'SAVAGE!';

  @override
  String get ach_sharpshooter_desc => '10× sholat tepat waktu (≤10 menit)';

  @override
  String get ach_sharpshooter_hint =>
      '10× sholat tepat waktu (≤10 menit setelah adzan).';

  @override
  String get ach_sharpshooter_title => 'SHARPSHOOTER';

  @override
  String get ach_subuh_legend_desc => 'Streak Subuh 30 hari';

  @override
  String get ach_subuh_legend_title => 'SUBUH LEGEND';

  @override
  String get ach_subuh_solo_carry_desc =>
      'Streak Subuh 7 hari beruntun — lane tersulit';

  @override
  String get ach_subuh_solo_carry_title => 'SUBUH SOLO CARRY';

  @override
  String get ach_sultan_sunnah_desc => '50 sholat sunnah total';

  @override
  String get ach_sultan_sunnah_title => 'SULTAN SUNNAH';

  @override
  String get ach_sunnah_master_desc => '200 sholat sunnah total';

  @override
  String get ach_sunnah_master_hint =>
      'Total catatan 8 jenis sholat sunnah (Dhuha, Rawatib, Tahajjud, dll).';

  @override
  String get ach_sunnah_master_title => 'SUNNAH MASTER';

  @override
  String get ach_sunset_strike_desc => 'Pertama kali log sholat Maghrib';

  @override
  String get ach_sunset_strike_title => 'SUNSET STRIKE';

  @override
  String get ach_tahajjud_secured_desc => 'Pertama kali log sholat Tahajjud';

  @override
  String get ach_tahajjud_secured_title => 'TAHAJJUD SECURED';

  @override
  String get ach_tilawah_streak_14_desc => 'Streak Tilawah 14 hari';

  @override
  String get ach_tilawah_streak_14_title => 'TILAWAH STREAK';

  @override
  String get ach_triple_kill_desc => 'Hero Streak 3 hari beruntun';

  @override
  String get ach_triple_kill_title => 'TRIPLE KILL';

  @override
  String get ach_unstoppable_desc => 'Hero Streak 5 hari beruntun';

  @override
  String get ach_unstoppable_title => 'UNSTOPPABLE!';

  @override
  String get ach_wajib_champion_desc => '400x sholat wajib';

  @override
  String get ach_wajib_champion_title => 'WAJIB CHAMPION';

  @override
  String get ach_wajib_elite_desc => '100x sholat wajib';

  @override
  String get ach_wajib_elite_title => 'WAJIB ELITE';

  @override
  String get ach_wajib_grinder_desc => '25x sholat wajib';

  @override
  String get ach_wajib_grinder_title => 'WAJIB GRINDER';

  @override
  String get ach_wajib_hero_desc => '700x sholat wajib';

  @override
  String get ach_wajib_hero_title => 'WAJIB HERO';

  @override
  String get ach_wajib_immortal_desc => '2.000x sholat wajib';

  @override
  String get ach_wajib_immortal_hint =>
      'Total catatan sholat wajib kumulatif seumur hidup akun.';

  @override
  String get ach_wajib_immortal_title => 'WAJIB IMMORTAL';

  @override
  String get ach_wajib_master_desc => '1.000x sholat wajib';

  @override
  String get ach_wajib_master_title => 'WAJIB MASTER';

  @override
  String get ach_wajib_mythic_desc => '1.500x sholat wajib';

  @override
  String get ach_wajib_mythic_title => 'WAJIB MYTHIC';

  @override
  String get ach_wajib_rookie_desc => '10x sholat wajib';

  @override
  String get ach_wajib_rookie_title => 'WAJIB ROOKIE';

  @override
  String get ach_wajib_veteran_desc => '200x sholat wajib';

  @override
  String get ach_wajib_veteran_title => 'WAJIB VETERAN';

  @override
  String get ach_wajib_warrior_desc => '50x sholat wajib';

  @override
  String get ach_wajib_warrior_title => 'WAJIB WARRIOR';

  @override
  String get ach_wombo_combo_desc => 'Tuntaskan Daily Zikir 100 pertama kali';

  @override
  String get ach_wombo_combo_title => 'WOMBO COMBO';

  @override
  String get appTitle => 'Muslim Leveling';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonLogout => 'Keluar';

  @override
  String get commonOk => 'Oke';

  @override
  String get commonSave => 'Simpan';

  @override
  String get homeAskWajibBody => 'Pilih kondisi sholatmu untuk bonus XP';

  @override
  String homeAskWajibTitle(String prayer) {
    return 'Sudah Sholat ($prayer)?';
  }

  @override
  String get homeBonusJamaah => 'Berjamaah';

  @override
  String get homeBonusJamaahSub => 'sholat berjamaah';

  @override
  String get homeBonusOnTime => 'Tepat waktu';

  @override
  String get homeBonusOnTimeSub => 'di bawah 30 menit setelah adzan';

  @override
  String get homeBonusPlain => 'Sudah';

  @override
  String get homeBonusPlainSub => 'tanpa bonus XP';

  @override
  String get homeBonusQuestSunnah => 'BONUS QUEST · SUNNAH';

  @override
  String get homeChestLocked => 'Selesaikan 5 wajib';

  @override
  String get homeChestMetaOpened => 'DIBUKA';

  @override
  String homeChestMetaProgress(int done, int total) {
    return '$done/$total WAJIB';
  }

  @override
  String get homeChestOpenedLabel => 'CHEST DIBUKA';

  @override
  String get homeChestOpenedSub => 'Besok lagi ya kak! 🌙';

  @override
  String get homeChestReadyLabel => 'REWARD SIAP!';

  @override
  String get homeChestReadySub => 'Klik untuk klaim 🎉';

  @override
  String get homeChestTitle => 'DAILY CHEST';

  @override
  String get homeDefaultCity => 'Jakarta';

  @override
  String homeLevelUpSource(String prayer) {
    return 'Sholat $prayer';
  }

  @override
  String homeLockAfterTime(String prayer) {
    return 'Waktu $prayer sudah lewat.';
  }

  @override
  String homeLockBeforeTime(String prayer, String time) {
    return 'Belum masuk waktu $prayer (adzan $time).';
  }

  @override
  String homeLockSubuh(int hours, String until) {
    return 'Quest Subuh terkunci $hours jam setelah adzan (sampai $until). Besok jangan kelewat ya! 💪';
  }

  @override
  String get homeLogDuplicate => 'Sholat ini udah dicatat hari ini!';

  @override
  String get homeNext => 'BERIKUTNYA';

  @override
  String homeQuestClaimable(int n) {
    return '$n SIAP KLAIM';
  }

  @override
  String get homeQuestDaily => 'QUEST HARIAN';

  @override
  String get homeQuickActions => 'AKSES CEPAT';

  @override
  String homeQuickActionsMeta(int done, int total) {
    return 'RENUNGAN $done/$total';
  }

  @override
  String get homeQuickDoa => 'Doa';

  @override
  String get homeQuickDzikir => 'Dzikir';

  @override
  String get homeQuickHadis => 'Hadis';

  @override
  String get homeQuickKiblat => 'Kiblat';

  @override
  String get homeQuickRenungan => 'Renungan';

  @override
  String get homeRevealBtn => 'Alhamdulillah! 🤲';

  @override
  String get homeRevealCosmetic => 'KOSMETIK BARU!';

  @override
  String get homeRevealDuplicate =>
      'Item duplikat — koleksi tetap tersimpan 📦';

  @override
  String homeRevealLevelUp(String suffix) {
    return '⬆️ Level Up!$suffix';
  }

  @override
  String get homeRevealReward => 'REWARD DIDAPAT!';

  @override
  String get homeRevealShield => 'FREEZE SHIELD!';

  @override
  String homeRevealShieldBody(int count) {
    return 'Streak aman 1 hari saat lupa sholat. Total: $count ❄️';
  }

  @override
  String get homeRingWajib => 'WAJIB';

  @override
  String get homeRitualToday => 'RITUAL HARI INI';

  @override
  String get homeSideDone => 'Selesai hari ini ✓';

  @override
  String get homeSideDzikir => 'Dzikir 100x';

  @override
  String homeSideDzikirSub(int count, int target) {
    return '$count/$target dzikir';
  }

  @override
  String get homeSideHadis => 'Belajar Hadis';

  @override
  String homeSideHadisSub(int count, int target) {
    return '$count/$target hadis dibaca';
  }

  @override
  String get homeSideQuestTitle => 'SIDE QUEST';

  @override
  String get homeSideQuran => 'Baca Quran';

  @override
  String homeSideQuranSub(int done, int target) {
    return '$done/$target ayat hari ini';
  }

  @override
  String get homeSideSedekah => 'Sedekah';

  @override
  String get homeSideSedekahSub => 'Bersedekah hari ini';

  @override
  String get homeSunnahHintBadiyahDzuhur =>
      'Ba\'diyah Dzuhur waktunya setelah Dzuhur sampai sebelum Ashar.';

  @override
  String get homeSunnahHintBadiyahIsya =>
      'Ba\'diyah Isya waktunya setelah Isya sampai tengah malam.';

  @override
  String get homeSunnahHintBadiyahMaghrib =>
      'Ba\'diyah Maghrib waktunya setelah Maghrib sampai sebelum Isya.';

  @override
  String get homeSunnahHintDhuha =>
      'Dhuha bisa setelah matahari naik (±15 min setelah terbit) sampai sebelum Dzuhur.';

  @override
  String get homeSunnahHintFallback => 'Coba lagi nanti ya.';

  @override
  String get homeSunnahHintQobliyahAshar =>
      'Qobliyah Ashar waktunya dari Ashar sampai sebelum Maghrib.';

  @override
  String get homeSunnahHintQobliyahDzuhur =>
      'Qobliyah Dzuhur waktunya dari Dzuhur sampai sebelum Ashar.';

  @override
  String get homeSunnahHintQobliyahSubuh =>
      'Qobliyah Subuh waktunya sama dengan sholat Subuh (dari Subuh sampai Terbit).';

  @override
  String get homeSunnahHintTahajjud =>
      'Tahajjud waktu setelah Isya sampai sebelum Imsak.';

  @override
  String get homeUnitDays => 'hari';

  @override
  String get homeWajibQuest => 'WAJIB QUEST';

  @override
  String get homeXpToNextRank => 'XP TO NEXT RANK';

  @override
  String get localeEnglish => 'English';

  @override
  String get localeIndonesian => 'Bahasa Indonesia';

  @override
  String get localePicked => 'Bahasa dipilih';

  @override
  String get localeSystem => 'Ikut Sistem (HP)';

  @override
  String get localeTitle => 'Bahasa aplikasi';

  @override
  String get onbContinue => 'Lanjut';

  @override
  String get onbDefaultNickname => 'Pejuang';

  @override
  String get onbGenderAkhwat => 'AKHWAT';

  @override
  String get onbGenderIkhwan => 'IKHWAN';

  @override
  String get onbGenderPrivacy =>
      'Jawabanmu cuma dipakai untuk menyembunyikan menu. Kamu bisa ubah kapan saja di Profil.';

  @override
  String get onbGenderSkip => 'Lewati';

  @override
  String get onbGenderTitle => 'Kamu Ikhwan atau Akhwat?';

  @override
  String get onbGenderWhy =>
      'Akhwat punya fitur Periode Haid: saat datang bulan, streak sholat otomatis di-freeze supaya tidak ada penalti. Fitur itu kami sembunyikan dari tampilan Ikhwan supaya menunya bersih.';

  @override
  String get onbHowAchBody => 'Buka medali dari streak, tilawah, dan dzikir.';

  @override
  String get onbHowAchTitle => 'Achievement';

  @override
  String get onbHowBody =>
      'Tiga hal ini yang bikin ibadah harianmu terasa seperti naik level.';

  @override
  String get onbHowDemoHint => 'Coba ketuk kartunya';

  @override
  String get onbHowQuestBody => 'Tandai sholat wajib & sunnah tiap hari.';

  @override
  String get onbHowQuestTitle => 'Quest Harian';

  @override
  String get onbHowTitle => 'Cara Main';

  @override
  String get onbHowXpBody =>
      'Tiap quest selesai dapat XP. Naik level, naik pangkat.';

  @override
  String get onbHowXpTitle => 'XP & Level';

  @override
  String get onbLangBody => 'Kamu bisa ubah kapan saja di Profil.';

  @override
  String get onbLangTitle => 'Mau pakai bahasa apa?';

  @override
  String get onbLocationAllow => 'Izinkan Lokasi';

  @override
  String get onbLocationBody =>
      'Untuk menghitung jadwal sholat & arah qiblat yang akurat, kami perlu akses lokasi. Lokasi tidak dibagikan ke siapa pun — semua perhitungan terjadi di HP-mu.';

  @override
  String get onbLocationLoading => 'MENGAMBIL LOKASI...';

  @override
  String get onbLocationPickManual => 'Pilih kota manual';

  @override
  String get onbLocationTitle => 'Butuh Lokasimu';

  @override
  String get onbNameBody =>
      'Nama ini muncul di Beranda dan kartu medali. Boleh dikosongkan.';

  @override
  String get onbNameTitle => 'Siapa nama pejuangmu?';

  @override
  String get onbNicknameHint => 'Nama pejuang (opsional — kosong: Pejuang)';

  @override
  String get onbNotifAllow => 'Izinkan Notifikasi';

  @override
  String get onbNotifBody =>
      'Biar tidak kelewat, kami kirim pengingat saat waktu sholat tiba.';

  @override
  String get onbNotifLoading => 'MENYALA...';

  @override
  String get onbNotifSkip => 'Lewati, nanti saja';

  @override
  String get onbNotifTitle => 'Pengingat Adzan';

  @override
  String get onbSkip => 'Lewati';

  @override
  String onbStepOf(String step, String total) {
    return 'Langkah $step dari $total';
  }

  @override
  String get onbWelcomeBody =>
      'Selesaikan quest sholat, kumpulkan XP, naikkan level.';

  @override
  String get onbWelcomeTitle => 'Selamat Datang, Muslim Warrior!';

  @override
  String get onbXpDemoSemantics => 'Contoh: Subuh selesai, ditambah 50 XP';

  @override
  String get prayerAshar => 'Ashar';

  @override
  String get prayerDzuhur => 'Dzuhur';

  @override
  String get prayerIsya => 'Isya';

  @override
  String get prayerJumat => 'Jumat';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerSubuh => 'Subuh';

  @override
  String get profilAbout => 'Tentang Aplikasi';

  @override
  String get profilAboutBody =>
      'Ibadah itu konsisten, bukan sempurna. Muslim Leveling membantu kamu membangun kebiasaan sholat lima waktu dan membaca Quran dengan cara yang seru — setiap sholat yang dicatat memberi XP, setiap hari tanpa putus menambah streak, dan setiap pencapaian membuka skin avatar baru.';

  @override
  String get profilAboutFooter =>
      'Dibuat dengan penuh doa untuk setiap pejuang akhirat.';

  @override
  String get profilAboutOffline =>
      'Tidak ada server, tidak ada iklan, tidak ada langganan. Semua datamu tinggal di perangkat — milikmu sepenuhnya.';

  @override
  String get profilAccountSettings => 'Pengaturan Akun';

  @override
  String get profilAlreadyPrayedToday => ', sudah shalat hari ini';

  @override
  String get profilAndroidNotifSettings => 'Pengaturan Notifikasi Android';

  @override
  String get profilBackupActive => 'Backup aktif';

  @override
  String get profilBatteryPerm =>
      'Izinkan \"Tanpa batasan baterai\" supaya pengingat tetap bunyi saat app ditutup.';

  @override
  String get profilCalendarHeader => 'KALENDER SHOLAT';

  @override
  String get profilChangePhoto => 'Ganti Foto';

  @override
  String get profilCloudVerifyFailed => 'Gagal verifikasi cloud. Coba lagi.';

  @override
  String get profilConnecting => 'MENGHUBUNGKAN...';

  @override
  String get profilContinueGoogle => 'Lanjut dengan Google';

  @override
  String get profilCycleExplain =>
      'Aktifkan saat haid agar streak sholat tetap aman tanpa penalti.';

  @override
  String get profilCycleFrozenMeta => 'mode haid · streak di-freeze';

  @override
  String get profilCycleFrozenSemantics => 'Mode haid aktif, streak di-freeze';

  @override
  String get profilCycleModeShort => 'mode haid';

  @override
  String get profilCyclePeriod => 'Periode Haid';

  @override
  String get profilEditName => 'Edit Nama';

  @override
  String get profilEditProfile => 'Edit profil';

  @override
  String get profilEnableReminders => 'Aktifkan pengingat';

  @override
  String get profilExactAlarmPerm =>
      'Izin \"Alarm & pengingat\" belum aktif — pengingat bisa telat beberapa menit.';

  @override
  String get profilFriday => 'Jumat';

  @override
  String get profilFromCamera => 'Ambil dari Kamera';

  @override
  String get profilFromGallery => 'Pilih dari Galeri';

  @override
  String get profilGender => 'Jenis Kelamin';

  @override
  String get profilGenderAkhwat => 'Akhwat';

  @override
  String get profilGenderExplain =>
      'Dipakai untuk menyembunyikan atau menampilkan menu Periode Haid. Tidak ikut sinkron ke cloud.';

  @override
  String get profilGenderIkhwan => 'Ikhwan';

  @override
  String get profilGenderUnset => 'Belum dipilih';

  @override
  String get profilHeatmapBody =>
      'Makin hijau makin lengkap — 5 shade = 5 sholat wajib.';

  @override
  String get profilHeatmapHeader => 'KALENDER SHOLAT WAJIB';

  @override
  String get profilHeatmapRow => 'Heatmap sholat wajib per bulan';

  @override
  String get profilHeatmapSemantics => 'Buka kalender sholat wajib';

  @override
  String profilHeroSemantics(String tier) {
    return 'Profile hero — $tier';
  }

  @override
  String profilLevelBadge(int level) {
    return 'LVL $level';
  }

  @override
  String get profilLockerRow => 'Atur aura dan gelar aktif';

  @override
  String get profilLockerSemantics => 'Buka loker skin';

  @override
  String get profilLockerSkin => 'LOKER SKIN';

  @override
  String get profilLoginCancelled => 'Login dibatalkan.';

  @override
  String profilLoginFailed(String msg) {
    return '❌ Login gagal: $msg';
  }

  @override
  String get profilLoginMerged => '☁️ Login OK — progress digabung.';

  @override
  String get profilLoginNotSaved => '⚠️ Login OK, tapi backup belum tersimpan.';

  @override
  String get profilLoginOffline =>
      '⚠️ Login OK, tapi backup belum aktif (offline).';

  @override
  String get profilLogoutConfirm =>
      'Hapus data lokal dan kembali ke layar awal?';

  @override
  String get profilLogoutSuccess => 'Logout berhasil.';

  @override
  String get profilMiniLevel => 'Level';

  @override
  String get profilMiniStreak => 'Streak';

  @override
  String get profilMiniXp => 'XP';

  @override
  String get profilModeBalanced => '⚖️ Seimbang';

  @override
  String get profilModeBalancedDesc =>
      'Diingetin 15 menit sebelum & saat adzan';

  @override
  String get profilModeFocus => '🎯 Fokus';

  @override
  String get profilModeFocusDesc => 'Hanya pengingat utama di waktu adzan';

  @override
  String get profilModeIntense => '🔥 Intensif';

  @override
  String get profilModeIntenseDesc => '30 menit, 5 menit sebelum & saat adzan';

  @override
  String get profilNicknameHint => 'Nama panggilan';

  @override
  String get profilNotifPermAction =>
      'Izin notifikasi belum aktif. Buka Pengaturan Notifikasi Android lalu izinkan.';

  @override
  String get profilNotifPermBody =>
      'Izin notifikasi belum aktif. Aktifkan untuk menerima pengingat adzan.';

  @override
  String get profilNotifications => 'Notifikasi';

  @override
  String get profilOemBody =>
      'Aktifkan \"Autostart\" & \"Tanpa batasan baterai\" di pengaturan HP agar alarm tetap bunyi saat app ditutup, dan notif muncul di lock screen.';

  @override
  String get profilOemManual =>
      'Buka Pengaturan > Aplikasi > Muslim Leveling > Baterai & Autostart manual.';

  @override
  String get profilOemTitle => 'Adzan tak muncul di Xiaomi/Oppo/Vivo?';

  @override
  String get profilOpenAutostart => 'Buka Pengaturan Auto-start';

  @override
  String profilPhotoFailed(String msg) {
    return 'Gagal mengambil foto: $msg';
  }

  @override
  String get profilPhotoSection => 'FOTO PROFIL';

  @override
  String get profilPrivacy => 'Privasi & Data';

  @override
  String get profilPrivacyDeleteBody =>
      'Masuk Profil → Keluar untuk menghapus semua data lokal sekaligus. Tidak ada yang tersisa di perangkat.';

  @override
  String get profilPrivacyDeleteTitle => 'Hapus kapan saja';

  @override
  String get profilPrivacyLocalBody =>
      'Semua data — sholat, bacaan Quran, statistik, dan preferensi — hanya tinggal di HP kamu. Tidak ada server, tidak ada cloud.';

  @override
  String get profilPrivacyLocalTitle => 'Tersimpan di perangkat';

  @override
  String get profilPrivacyLocationBody =>
      'Lokasi hanya dipakai sekali untuk menentukan jadwal sholat daerahmu. Lokasi tidak disimpan atau dibagikan.';

  @override
  String get profilPrivacyLocationTitle => 'Lokasi privat';

  @override
  String get profilPrivacyTraceBody =>
      'Aplikasi tidak mengirim aktivitas kamu ke pihak ketiga dan tidak memantau perilaku.';

  @override
  String get profilPrivacyTraceTitle => 'Tanpa jejak online';

  @override
  String get profilReminderMode => 'Mode Pengingat';

  @override
  String get profilReminderTitle => 'Pengingat Adzan';

  @override
  String profilRemindersChangeFailed(String msg) {
    return 'Gagal mengubah pengingat: $msg';
  }

  @override
  String get profilRemindersFailed =>
      'Gagal menjadwalkan pengingat — cek izin notifikasi & alarm di pengaturan HP.';

  @override
  String get profilRemindersNone =>
      'Mode tersimpan, tapi belum ada pengingat terjadwal — cek izin notifikasi & alarm di pengaturan HP.';

  @override
  String get profilRemindersOff => 'Pengingat adzan dimatikan';

  @override
  String profilRemindersScheduled(String mode, int n) {
    return 'Pengingat adzan aktif: mode $mode — $n pengingat terjadwal';
  }

  @override
  String profilRemindersScheduledCount(int n) {
    return '$n pengingat adzan terjadwal 🔔';
  }

  @override
  String get profilRemovePhoto => 'Hapus Foto';

  @override
  String profilSaveFailed(String msg) {
    return 'Gagal menyimpan: $msg';
  }

  @override
  String get profilSettingsHeader => 'PENGATURAN';

  @override
  String profilSettingsOpenFailed(String msg) {
    return 'Pengaturan notifikasi gagal dibuka: $msg';
  }

  @override
  String get profilSoundAdzan => '🕌 Adzan';

  @override
  String get profilSoundAdzanDesc =>
      'Suara adzan penuh saat masuk waktu sholat';

  @override
  String get profilSoundMode => 'Suara Notifikasi';

  @override
  String get profilSoundNormal => '🔔 Suara';

  @override
  String get profilSoundNormalDesc => 'Notifikasi dengan suara standar HP';

  @override
  String get profilSoundSilent => '🔕 Senyap';

  @override
  String get profilSoundSilentDesc => 'Hanya muncul notifikasi, tanpa suara';

  @override
  String get profilStatsDailyAvg => 'Rata-rata Harian';

  @override
  String get profilStatsEmptyBody =>
      'Centang sholat pertamamu — statistik mulai terisi di sini.';

  @override
  String get profilStatsEmptyTitle => 'Belum ada catatan.';

  @override
  String get profilStatsHeader => 'STATISTIK';

  @override
  String get profilStatsQuranStreak => 'Streak Baca Quran';

  @override
  String profilStatsSince(String date) {
    return 'Sejak $date';
  }

  @override
  String get profilStatsVerses => 'Ayat Quran Terbaca';

  @override
  String get profilStatsWajib => 'Sholat wajib';

  @override
  String profilStreakBest(int count) {
    return 'best $count';
  }

  @override
  String get profilStreakFreeze => 'freeze';

  @override
  String get profilStreakPerPrayer => 'STREAK PER SHOLAT';

  @override
  String profilStreakSemanticsItem(String prayer, int days) {
    return '$prayer $days hari';
  }

  @override
  String get profilStreakSemanticsTitle => 'Streak per salat';

  @override
  String get profilTestAdzan => 'Tes Adzan';

  @override
  String get profilTestNotif => 'Tes Notifikasi';

  @override
  String profilTestNotifFailed(String msg) {
    return 'Tes notifikasi gagal: $msg';
  }

  @override
  String get profilTheme => 'Tema aplikasi';

  @override
  String get profilUnitDays => 'hari';

  @override
  String get profilUnitVerses => 'ayat';

  @override
  String get profilUnitWeeks => 'minggu';

  @override
  String profilVersion(String version) {
    return 'Versi $version';
  }

  @override
  String profilXpToNext(int xp, int level) {
    return '$xp XP lagi → LVL $level';
  }

  @override
  String profilXpWithinLevel(int current, int needed) {
    return '$current/$needed XP';
  }

  @override
  String get settingLanguage => 'Bahasa';

  @override
  String get shareBtnShareAgain => 'Bagikan Lagi';

  @override
  String shareCaption(String title) {
    return 'Aku unlock \"$title\" di Muslim Leveling! 🎮🕌';
  }

  @override
  String shareEarnedOn(String date) {
    return 'Diraih $date';
  }

  @override
  String get shareErrImage => 'Gagal membuat gambar kartu. Coba lagi.';

  @override
  String get shareErrPrepare => 'Gagal menyiapkan kartu. Coba lagi.';

  @override
  String get shareErrShare => 'Gagal membagikan kartu. Coba lagi.';

  @override
  String get shareStatAllModules => '📚 Semua 16 modul selesai!';

  @override
  String get shareStatCollector => '👑 Kolektor sejati!';

  @override
  String shareStatComeback(int count) {
    return 'Total comeback: $count kali 💪';
  }

  @override
  String get shareStatDhikr => '📿 Target zikir tercapai!';

  @override
  String get shareStatFajr15 => '🎯 Subuh sebelum 15 menit';

  @override
  String get shareStatFajrStreak => 'hari Subuh beruntun 🔥';

  @override
  String get shareStatFullCombo => '🔥 5 wajib + Tilawah + Dhuha';

  @override
  String get shareStatHeroStreak => 'hari Hero Streak 🔥';

  @override
  String get shareStatLearning => '📖 Mulai belajar — teruskan!';

  @override
  String shareStatLevel(int level, String rank) {
    return 'Level $level — $rank';
  }

  @override
  String get shareStatOnTime10 => '🎯 10× sholat tepat waktu';

  @override
  String get shareStatOnTimeFirst => '⚡ Tepat waktu sejak pertama';

  @override
  String get shareStatQuizPerfect => '⭐ Skor sempurna!';

  @override
  String get shareStatSunnah => '🏛️ Semua 8 sunnah terkumpul';

  @override
  String get shareStatTilawahStreak => 'hari Tilawah beruntun 🔥';

  @override
  String get sunnahBadiyahDzuhurDesc => 'Sunnah sesudah Dzuhur';

  @override
  String get sunnahBadiyahDzuhurName => 'Ba\'diyah Dzuhur';

  @override
  String get sunnahBadiyahIsyaDesc => 'Sunnah sesudah Isya';

  @override
  String get sunnahBadiyahIsyaName => 'Ba\'diyah Isya';

  @override
  String get sunnahBadiyahMaghribDesc => 'Sunnah sesudah Maghrib';

  @override
  String get sunnahBadiyahMaghribName => 'Ba\'diyah Maghrib';

  @override
  String get sunnahDhuhaDesc => 'Sunnah mutlak di pagi hari';

  @override
  String get sunnahDhuhaName => 'Dhuha';

  @override
  String get sunnahQobliyahAsharDesc => 'Sunnah sebelum Ashar';

  @override
  String get sunnahQobliyahAsharName => 'Qobliyah Ashar';

  @override
  String get sunnahQobliyahDzuhurDesc => 'Sunnah sebelum Dzuhur';

  @override
  String get sunnahQobliyahDzuhurName => 'Qobliyah Dzuhur';

  @override
  String get sunnahQobliyahSubuhDesc => 'Sunnah sebelum Subuh';

  @override
  String get sunnahQobliyahSubuhName => 'Qobliyah Subuh';

  @override
  String get sunnahTahajjudDesc => 'Sunnah malam (qiyamul lail)';

  @override
  String get sunnahTahajjudName => 'Tahajjud';

  @override
  String get tabHome => 'Beranda';

  @override
  String get tabJadwal => 'Jadwal';

  @override
  String get tabQuran => 'Al-Quran';
}

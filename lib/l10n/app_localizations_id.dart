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
  String get cityPickerEmptyKab => 'Kabupaten/kota tidak ditemukan';

  @override
  String get cityPickerEmptyProv => 'Provinsi tidak ditemukan';

  @override
  String get cityPickerHintKab => 'Ketik nama kabupaten/kota...';

  @override
  String get cityPickerHintProv => 'Ketik nama provinsi...';

  @override
  String get cityPickerNotFound =>
      'Kabupaten/kota tidak ditemukan. Coba pilih provinsi lain.';

  @override
  String get cityPickerLoadFailed =>
      'Gagal memuat daftar kabupaten/kota. Periksa koneksi lalu coba lagi.';

  @override
  String get cityPickerRetry => 'Coba lagi';

  @override
  String get cityPickerTitleKab => 'Pilih Kabupaten/Kota';

  @override
  String get cityPickerTitleProv => 'Pilih Provinsi';

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
  String get localeMalay => 'Bahasa Melayu';

  @override
  String get localeTurkish => 'Türkçe';

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
  String get onbGenderMeaning =>
      'Ikhwan artinya laki-laki, akhwat artinya perempuan.';

  @override
  String get onbGenderPrivacy =>
      'Jawabanmu cuma dipakai untuk menyembunyikan menu. Kamu bisa ubah kapan saja di Profil.';

  @override
  String get onbGenderSkip => 'Tidak perlu';

  @override
  String get onbGenderTitle => 'Kamu Ikhwan atau Akhwat?';

  @override
  String get onbGenderWhy =>
      'Akhwat punya fitur Periode Haid: saat datang bulan, streak sholat otomatis di-freeze supaya tidak ada penalti. Fitur itu kami sembunyikan dari tampilan Ikhwan supaya menunya bersih.';

  @override
  String get onbHowAchBody => 'Buka medali dari streak, tilawah, dan dzikir.';

  @override
  String get onbHowAchTitle => 'Achievements';

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
  String get onbLocationLater => 'Pakai kota default dulu';

  @override
  String get onbLocationLaterHint =>
      'Belum ada lokasi? Jadwal memakai kota default dulu — bisa diubah kapan saja di Profil.';

  @override
  String get onbLocationPickManual => 'Pilih kota manual';

  @override
  String get onbLocationRetry => 'Coba lagi';

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
      'Biar tidak kelewat, kami kirim pengingat saat waktu sholat tiba. Kami minta izin notifikasi + pengecualian baterai — tanpa itu ponsel bisa mematikan pengingat diam-diam saat app ditutup.';

  @override
  String get onbNotifDenied =>
      'Pengingat tidak aktif. Bisa dinyalakan kapan saja di Profil.';

  @override
  String get onbNotifLoading => 'MENYALA...';

  @override
  String get onbNotifSkip => 'Lewati, nanti saja';

  @override
  String get onbNotifTitle => 'Pengingat Adzan';

  @override
  String get onbProgressLabel => 'Persiapan';

  @override
  String onbStepOf(String step, String total) {
    return 'Langkah $step dari $total';
  }

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
      'Ikhwan = laki-laki, akhwat = perempuan. Dipakai untuk menyembunyikan atau menampilkan menu Periode Haid. Tidak ikut sinkron ke cloud.';

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

  @override
  String get dlTitle => 'Renungan Hari Ini';

  @override
  String get dlBack => 'Kembali';

  @override
  String dlCiteSurah(String surah, int ayah) {
    return 'QS. $surah : $ayah';
  }

  @override
  String get dlCiteHadis => 'HADIS HARI INI';

  @override
  String dlCiteDoa(String name) {
    return 'DOA · $name';
  }

  @override
  String dlCiteUlama(String name) {
    return 'KATA ULAMA · $name';
  }

  @override
  String get dlActListen => 'Dengar';

  @override
  String get dlActPause => 'Jeda';

  @override
  String get dlActSave => 'Simpan';

  @override
  String get dlActSaved => 'Tersimpan';

  @override
  String get dlActTafsir => 'Tafsir';

  @override
  String get dlErrLoad =>
      'Renungan hari ini belum bisa dimuat.\nSambungkan internet lalu coba lagi.';

  @override
  String get dlErrTafsir => 'Tafsir tidak bisa dimuat. Coba lagi.';

  @override
  String get dlDone => 'Renungan hari ini tuntas';

  @override
  String dlProgress(int done, int count) {
    return '$done dari $count renungan dibaca · swipe untuk lanjut';
  }

  @override
  String get qsTitle => 'Bagikan Ayat';

  @override
  String get qsShare => 'Bagikan';

  @override
  String get qsPreparing => 'Menyiapkan…';

  @override
  String get qsErr => 'Gagal membagikan ayat. Coba lagi.';

  @override
  String get qsModeSolid => 'Solid';

  @override
  String get qsModeGradient => 'Gradasi';

  @override
  String get qsModeEsthetic => 'Estetik';

  @override
  String get qsContentArabic => 'Arab';

  @override
  String get qsContentTranslation => 'Terjemahan';

  @override
  String get quest_subuh_tepat_desc =>
      'Sholat Subuh tepat waktu (≤30 menit setelah adzan)';

  @override
  String get quest_five_rings_desc => 'Lengkapin 5/5 sholat hari ini';

  @override
  String get quest_timely_prayers_desc =>
      'Sholat tepat waktu (≤10 menit), 3x hari ini';

  @override
  String get quest_dhuha_before_dzuhur_desc => 'Sholat Dhuha sebelum Dzuhur';

  @override
  String get quest_rawatib_two_desc => 'Rawatib 2x hari ini';

  @override
  String get quest_dzuhur_tepat_desc =>
      'Sholat Dzuhur tepat waktu (≤30 menit setelah adzan)';

  @override
  String get quest_maghrib_tepat_desc =>
      'Sholat Maghrib tepat waktu (≤30 menit setelah adzan)';

  @override
  String get quest_isya_hadir_desc => 'Jangan lewatkan sholat Isya malam ini';

  @override
  String get quest_any_three_desc =>
      'Kerjakan 3 sholat wajib hari ini (bebas yang mana)';

  @override
  String get quest_subuh_isya_desc => 'Kunci dua ujung hari: Subuh + Isya';

  @override
  String get quest_one_sunnah_desc =>
      'Kerjakan 1 sholat sunnah apa saja hari ini';

  @override
  String get quest_rawatib_one_desc =>
      'Rawatib 1x hari ini (qobliyah/ba\'diyah bebas)';

  @override
  String get quest_zikir_33_desc => 'Zikir 33x lewat tombol Daily Zikir';

  @override
  String quest_zikir_goal_desc(Object goal) {
    return 'Tuntaskan Daily Zikir sampai $goal';
  }

  @override
  String get quest_quran_10ayat_desc => 'Baca Quran 10 ayat hari ini';

  @override
  String get quest_hadis_3_desc => 'Baca 3 hadis hari ini (≥5 dtk tiap hadis)';

  @override
  String get quest_dzikir_33_subuh_desc =>
      'Dzikir Subhanallah 33x (tasbih setelah sholat)';

  @override
  String get quest_quran_1halaman_desc =>
      'Baca Quran 20 ayat (≈1 halaman mushaf)';

  @override
  String get quest_hadis_5_desc => 'Baca 5 hadis hari ini (≥5 dtk tiap hadis)';

  @override
  String get quest_berjamaah_1_desc =>
      'Sholat berjamaah 1x hari ini (pilih bonus berjamaah saat claim)';

  @override
  String get quest_hero_streak_7_desc => 'Pertahanin Hero Streak 7 hari! 🔥';

  @override
  String get questCopy_sholat_1 =>
      'Kamu mungkin lagi sibuk, tapi tetap nyempetin. Good job.';

  @override
  String get questCopy_sholat_2 =>
      'Adzan selesai, kamu langsung jalan. Mantap.';

  @override
  String get questCopy_sholat_3 =>
      'Tepat waktu hari ini. Satu hal baik yang kamu jaga.';

  @override
  String get questCopy_sholat_4 =>
      'Capek tetap capek. Tapi kamu tetap datang. 🤍';

  @override
  String get questCopy_sunnah_1 =>
      'Nggak wajib, tapi kamu tetap memilih untuk melakukannya.';

  @override
  String get questCopy_sunnah_2 =>
      'Nggak ada yang maksa. Kamu sendiri yang memilih untuk datang.';

  @override
  String get questCopy_sunnah_3 => 'Dua rakaat hari ini. Kecil, tapi berarti.';

  @override
  String get questCopy_sunnah_4 =>
      'Pelan-pelan, kebiasaan baik seperti ini yang kamu bangun.';

  @override
  String get questCopy_zikir_1 =>
      'Di tengah ramainya hari, kamu masih menyempatkan ingat Allah.';

  @override
  String get questCopy_zikir_2 =>
      'Berhenti sebentar. Tarik napas. Ingat Allah.';

  @override
  String get questCopy_zikir_3 =>
      'Apa pun yang lagi kamu pikirin, kamu tetap meluangkan waktu untuk zikir.';

  @override
  String get questCopy_zikir_4 =>
      'Selesai zikir. Semoga hati terasa sedikit lebih ringan. 🤍';

  @override
  String get questCopy_quran_1 =>
      'Satu ayat hari ini. Pelan-pelan, yang penting terus.';

  @override
  String get questCopy_quran_2 =>
      'Hari ini kamu kembali membuka Al-Quran. Senang lihatnya.';

  @override
  String get questCopy_quran_3 =>
      'Nggak harus banyak. Satu halaman pun tetap sebuah langkah.';

  @override
  String get questCopy_quran_4 =>
      'Satu halaman selesai. Besok lanjut lagi, ya.';

  @override
  String get questCopy_hadis_1 =>
      'Hari ini kamu meluangkan waktu untuk belajar dari sabda Nabi.';

  @override
  String get questCopy_hadis_2 =>
      'Satu hadis kamu baca hari ini. Semoga ada yang bisa kamu bawa ke harimu.';

  @override
  String get questCopy_hadis_3 =>
      'Nemu hadis yang ngena? Simpan. Siapa tahu kamu butuh mengingatnya lagi.';

  @override
  String get questCopy_hadis_4 =>
      'Sedikit belajar hari ini, semoga jadi bekal untuk besok.';

  @override
  String get questCopy_fiveRings_1 =>
      'Subuh, Dzuhur, Ashar, Maghrib, Isya. Kamu hadir di semuanya hari ini.';

  @override
  String get questCopy_fiveRings_2 =>
      'Lima waktu selesai. Alhamdulillah, hari ini kamu berhasil menjaganya.';

  @override
  String get questCopy_fiveRings_3 => 'Satu hari, lima waktu. Lengkap. 🤍';

  @override
  String get questCopy_fiveRings_4 =>
      'Hari ini selesai dengan baik. Besok kita mulai lagi.';

  @override
  String get questCopy_subuhIsya_1 =>
      'Subuh kamu jaga, Isya kamu jaga. Alhamdulillah.';

  @override
  String get questCopy_subuhIsya_2 =>
      'Dari awal sampai akhir hari, kamu tetap menyempatkan diri.';

  @override
  String get questCopy_subuhIsya_3 =>
      'Dua waktu ini kamu jaga hari ini. Good job.';

  @override
  String get questCopy_subuhIsya_4 =>
      'Hari ini kamu berhasil menjaga Subuh dan Isya. Besok lanjut lagi.';

  @override
  String get questHaid_1 =>
      'Hari ini waktunya istirahat. Tetap semangat, ya. 🤍';

  @override
  String get questHaid_2 =>
      'Nggak apa-apa berhenti sebentar. Kamu tetap bagian dari perjalanan ini.';

  @override
  String get questHaid_3 =>
      'Hari ini kamu nggak perlu mengejar quest ini. Jaga diri dan tetap dekat dengan Allah.';

  @override
  String get questHaid_4 =>
      'Quest boleh berhenti sebentar. Perjalananmu tetap lanjut.';

  @override
  String get questClaimAlhamdulillah => 'Alhamdulillah';

  @override
  String get questClaimContinue => 'Lanjut';

  @override
  String sqCombinedTitle(Object count) {
    return 'Alhamdulillah, $count Quest Tuntas!';
  }

  @override
  String get sqCombinedDesc =>
      'Semua quest harian selesai hari ini. Semoga istiqomah!';

  @override
  String get sqZikirTitle => 'Dzikir 100x Selesai!';

  @override
  String get sqZikirDesc => 'Konsisten berdzikir hari ini. Istiqomah!';

  @override
  String get sqTilawahTitle => 'Baca Quran 10 Ayat Selesai!';

  @override
  String get sqTilawahDesc => 'Tilawah hari ini tuntas. Lanjutkan besok!';

  @override
  String get sqHadisTitle => 'Belajar 5 Hadis Selesai!';

  @override
  String get sqHadisDesc => 'Lima hadis baru terbaca hari ini. Terus belajar!';

  @override
  String get sqBadgeCombined => 'QUEST HARIAN TUNTAS';

  @override
  String get sqBadgeSingle => 'QUEST SELESAI';

  @override
  String get sqButton => 'MANTAP!';

  @override
  String get sqBarrierLabel => 'side quest selesai';

  @override
  String sqSemantics(Object desc, Object title, Object xp) {
    return '$title. $desc. Bonus $xp XP.';
  }

  @override
  String get sqSourceZikir => 'Dzikir 100x';

  @override
  String get sqSourceTilawah => 'Baca Quran';

  @override
  String get sqSourceHadis => 'Belajar Hadis';

  @override
  String get naikTitle => 'NAIK LEVEL!';

  @override
  String get naikBadgeSemantics => 'Bulan sabit emas, lambang naik level';

  @override
  String naikReached(Object level, Object rank) {
    return 'Masha Allah, kamu mencapai $rank — Level $level';
  }

  @override
  String naikFrom(Object source) {
    return 'dari $source';
  }

  @override
  String get naikBack => 'KEMBALI';

  @override
  String naikRewardSemanticsFull(Object level, Object rank, Object xp) {
    return 'Hadiah: tambah $xp XP, level $level, gelar baru $rank';
  }

  @override
  String naikRewardSemanticsLevel(Object level, Object rank) {
    return 'Hadiah: level $level, gelar baru $rank';
  }

  @override
  String get naikChipLevelJumps => 'Lonjakan';

  @override
  String get naikChipLevel => 'Level';

  @override
  String get naikChipRank => 'GELAR BARU';

  @override
  String naikProgressSemantics(Object have, Object need, Object next) {
    return 'Menuju level $next: $have dari $need XP';
  }

  @override
  String get naikClosing =>
      'Barakallah — terus istiqomah, level berikutnya menantimu ✨';

  @override
  String naikLevelLabel(Object level) {
    return 'Level $level';
  }

  @override
  String get uq_ulama_ilmu_itu_lebih_baik_daripada_harta_ilmu =>
      'Ilmu itu lebih baik daripada harta. Ilmu menjaga kamu, sedangkan harta justru kamu yang menjaganya.';

  @override
  String get uq_ulama_orang_berilmu_itu_hidup_walau_sudah_wafa =>
      'Orang berilmu itu hidup walau sudah wafat, sedangkan orang bodoh itu mati walau masih hidup.';

  @override
  String get uq_ulama_jangan_melihat_siapa_yang_berbicara_tapi =>
      'Jangan melihat siapa yang berbicara, tapi lihatlah apa yang dia katakan.';

  @override
  String get uq_ulama_nilai_seseorang_diukur_dari_apa_yang_dia =>
      'Nilai seseorang diukur dari apa yang dia tekuni dengan sungguh-sungguh.';

  @override
  String get uq_ulama_hisablah_dirimu_sendiri_sebelum_kamu_dih =>
      'Hisablah dirimu sendiri sebelum kamu dihisab, dan timbanglah amalmu sebelum ditimbang.';

  @override
  String get uq_ulama_aku_tidak_pernah_menyesal_karena_diam_ta =>
      'Aku tidak pernah menyesal karena diam, tapi aku sering menyesal karena berbicara.';

  @override
  String get uq_ulama_kehormatanmu_adalah_agamamu_dan_harga_di =>
      'Kehormatanmu adalah agamamu, dan harga dirimu adalah akhlakmu.';

  @override
  String get uq_ulama_waktu_itu_seperti_pedang_kalau_kamu_tida =>
      'Waktu itu seperti pedang — kalau kamu tidak memotongnya, dia yang memotongmu.';

  @override
  String get uq_ulama_ilmu_bukanlah_yang_dihafal_tetapi_ilmu_a =>
      'Ilmu bukanlah yang dihafal, tetapi ilmu adalah yang memberi manfaat.';

  @override
  String get uq_ulama_ilmu_itu_cahaya_dan_cahaya_allah_tidak_a =>
      'Ilmu itu cahaya, dan cahaya Allah tidak akan masuk ke dalam hati orang yang bermaksiat.';

  @override
  String get uq_ulama_barangsiapa_tidak_tahan_lelahnya_belajar =>
      'Barangsiapa tidak tahan lelahnya belajar, dia harus tahan perihnya kebodohan.';

  @override
  String get uq_ulama_aku_tidak_berhenti_belajar_sejak_aku_men =>
      'Aku tidak berhenti belajar sejak aku menyadari bahwa aku masih bodoh.';

  @override
  String get uq_ulama_aku_tidak_memberi_fatwa_sampai_aku_berta =>
      'Aku tidak memberi fatwa sampai aku bertanya kepada orang yang lebih berilmu dariku.';

  @override
  String get uq_ulama_manusia_lebih_membutuhkan_ilmu_daripada =>
      'Manusia lebih membutuhkan ilmu daripada makanan dan minuman.';

  @override
  String get uq_ulama_aku_tidak_menulis_satu_hadis_pun_melaink =>
      'Aku tidak menulis satu hadis pun melainkan aku amalkan dulu isinya.';

  @override
  String get uq_ulama_ilmu_tanpa_amal_seperti_pohon_tanpa_buah =>
      'Ilmu tanpa amal seperti pohon tanpa buah.';

  @override
  String get uq_ulama_anak_adam_hanyalah_kumpulan_hari_hari_se =>
      'Anak Adam hanyalah kumpulan hari-hari. Setiap satu hari berlalu, sebagian dari dirinya ikut pergi.';

  @override
  String get uq_ulama_barangsiapa_mengenal_allah_dia_akan_menc =>
      'Barangsiapa mengenal Allah, dia akan mencintai-Nya; dan yang mencintai-Nya akan sibuk dengan-Nya.';

  @override
  String get uq_ulama_sesungguhnya_dunia_ini_hanya_sebentar_ja =>
      'Sesungguhnya dunia ini hanya sebentar, jangan sampai kita bekerja untuknya seolah selamanya.';

  @override
  String get uq_ulama_jadikan_dunia_ini_cukup_berada_di_tangan =>
      'Jadikan dunia ini cukup berada di tanganmu, jangan sampai masuk ke dalam hatimu.';

  @override
  String get uq_ulama_perbanyaklah_mengingat_mati_karena_itu_m =>
      'Perbanyaklah mengingat mati, karena itu menghapus cinta kepada dunia.';

  @override
  String get uq_ulama_aku_tidak_mengobati_sesuatu_yang_lebih_b =>
      'Aku tidak mengobati sesuatu yang lebih berat daripada niatku sendiri.';

  @override
  String get uq_ulama_ilmu_itu_untuk_diamalkan_kalau_tidak_dia =>
      'Ilmu itu untuk diamalkan; kalau tidak diamalkan, dia akan pergi.';

  @override
  String get uq_ulama_diam_adalah_hikmah_tapi_sedikit_orang_ya =>
      'Diam adalah hikmah, tapi sedikit orang yang mau mengamalkannya.';

  @override
  String get uq_ulama_sebaik_baik_hati_adalah_yang_dipenuhi_ra =>
      'Sebaik-baik hati adalah yang dipenuhi rasa takut dan harap kepada Allah.';

  @override
  String get uq_ulama_tidak_ada_yang_lebih_bermanfaat_bagi_hat =>
      'Tidak ada yang lebih bermanfaat bagi hati daripada membaca Al-Qur\'an dengan tadabbur.';

  @override
  String get uq_ulama_hati_bisa_sakit_seperti_badan_sakit_dan =>
      'Hati bisa sakit seperti badan sakit, dan obatnya adalah istigfar.';

  @override
  String get uq_ulama_kesabaran_itu_cahaya_dengannya_jalan_yan =>
      'Kesabaran itu cahaya — dengannya jalan yang sempit terasa lapang.';

  @override
  String get uq_ulama_ilmu_tanpa_amal_adalah_sia_sia_dan_amal =>
      'Ilmu tanpa amal adalah sia-sia, dan amal tanpa ilmu tidak akan sempurna.';

  @override
  String get uq_ulama_kebahagiaan_bukan_pada_banyaknya_harta_t =>
      'Kebahagiaan bukan pada banyaknya harta, tetapi pada lapangnya hati.';

  @override
  String get uq_ulama_siapa_yang_menuntut_ilmu_semata_untuk_me =>
      'Siapa yang menuntut ilmu semata untuk membanggakan diri, ilmunya akan menjadi hujjah atas dirinya.';

  @override
  String get uq_ulama_jaga_hatimu_karena_allah_melihat_bukan_h =>
      'Jaga hatimu, karena Allah melihat bukan hanya amalmu, tapi juga apa yang ada di dalamnya.';

  @override
  String get uq_month_1 => 'Muharam';

  @override
  String get uq_month_2 => 'Safar';

  @override
  String get uq_month_3 => 'Rabiulawal';

  @override
  String get uq_month_4 => 'Rabiulakhir';

  @override
  String get uq_month_5 => 'Jumadilawal';

  @override
  String get uq_month_6 => 'Jumadilakhir';

  @override
  String get uq_month_7 => 'Rajab';

  @override
  String get uq_month_8 => 'Syaban';

  @override
  String get uq_month_9 => 'Ramadan';

  @override
  String get uq_month_10 => 'Syawal';

  @override
  String get uq_month_11 => 'Zulkaidah';

  @override
  String get uq_month_12 => 'Zulhijah';

  @override
  String get uq_ev_1_1 => 'Tahun Baru Hijriah';

  @override
  String get uq_ev_1_10 => 'Hari Asyura';

  @override
  String get uq_ev_3_12 => 'Maulid Nabi';

  @override
  String get uq_ev_7_27 => 'Isra Mikraj';

  @override
  String get uq_ev_8_15 => 'Nisfu Syaban';

  @override
  String get uq_ev_9_1 => 'Awal Ramadan';

  @override
  String get uq_ev_9_17 => 'Nuzulul Quran';

  @override
  String get uq_ev_10_1 => 'Idulfitri';

  @override
  String get uq_ev_12_9 => 'Hari Arafah';

  @override
  String get uq_ev_12_10 => 'Iduladha';

  @override
  String get hjHariPentingTitle => 'Hari Penting Islam';

  @override
  String get hjHariPentingEmpty => 'Tidak bisa memuat tanggal penting.';

  @override
  String get hjHariPentingSemantics =>
      'Tanggal Hijriah, buka Hari Penting Islam';

  @override
  String get hjToday => 'Hari ini!';

  @override
  String get hjPassed => 'Sudah lewat';

  @override
  String hjDaysLeft(Object days) {
    return '$days hari lagi';
  }

  @override
  String get hjHijriSuffix => 'H';

  @override
  String get qiblaCalibrationHint =>
      '💡 Kalibrasi kompas: putar perangkat membentuk angka 8 beberapa kali untuk akurasi terbaik.';

  @override
  String get qiblaCompassLabel => 'KOMPAS KIBLAT';

  @override
  String get qiblaTitle => 'Arah Kiblat';

  @override
  String get qiblaAligned => '🎯 Pas! Tahan posisi ini';

  @override
  String qiblaTurnRight(String degrees) {
    return 'Putar $degrees° ke kanan →';
  }

  @override
  String qiblaTurnLeft(String degrees) {
    return '← Putar $degrees° ke kiri';
  }

  @override
  String get qiblaNoSensorTitle => 'Sensor Kompas Tidak Tersedia';

  @override
  String get qiblaNoSensorBody =>
      'Perangkat ini tidak memiliki sensor magnetometer. Gunakan panduan arah di bawah ini sebagai alternatif.';

  @override
  String get qiblaAlignedTitle => 'Sudah Menghadap Kiblat!';

  @override
  String get qiblaAimTitle => 'Arahkan Perangkat ke Kiblat';

  @override
  String get qiblaStatTitle => 'ARAH KIBLAT';

  @override
  String get qiblaDistanceTitle => 'JARAK KA\'BAH';

  @override
  String qiblaCityDistance(String city, String km) {
    return '📍 $city • $km km ke Ka\'bah';
  }

  @override
  String qiblaCityBearing(String city) {
    return 'Arah Kiblat dari $city:';
  }

  @override
  String qiblaNorthDegrees(String degrees) {
    return '$degrees° dari Utara';
  }

  @override
  String qiblaTurnInstruction(String degrees) {
    return 'Putar perangkat $degrees° searah jarum jam dari utara untuk menghadap kiblat.';
  }

  @override
  String qiblaOffset(String degrees) {
    return 'Selisih $degrees° dari kiblat';
  }

  @override
  String get dzResetTitle => 'Reset counter?';

  @override
  String dzResetBody(String item) {
    return 'Counter \"$item\" akan di-nolkan dari 0.\\nTotal dzikir hari ini TETAP dihitung.';
  }

  @override
  String get dzResetCancel => 'BATAL';

  @override
  String get dzResetConfirm => 'RESET';

  @override
  String get dzTapHint => 'Ketuk di mana saja untuk berdzikir';

  @override
  String dzToday(String total) {
    return 'Hari ini: $total';
  }

  @override
  String get dzVibrateOff => 'Matikan getar';

  @override
  String get dzVibrateOn => 'Nyalakan getar';

  @override
  String get dzResetThis => 'Reset counter ini';

  @override
  String get dzTargetDone => 'TARGET TERCAPAI';

  @override
  String get hdEmptyPage => 'Tidak ada hadis di halaman ini.';

  @override
  String get hdLoadFailed => 'Gagal memuat hadis.';

  @override
  String get hdLoadFailedRetry => 'Gagal memuat hadis. Coba lagi.';

  @override
  String get hdSearchFailed => 'Gagal mencari hadis.';

  @override
  String get hdRandomFailed => 'Gagal mengambil hadis acak. Coba lagi.';

  @override
  String get hdSearchHint => 'Cari hadis…';

  @override
  String hdSearchFound(String total) {
    return '$total hadis ditemukan';
  }

  @override
  String get hdSearchEmpty => 'Tidak ada hadis ditemukan.';

  @override
  String get hdBackToList => 'Kembali ke daftar';

  @override
  String get hdLoadMore => 'Muat Lagi';

  @override
  String hdNumber(String id) {
    return 'no. $id';
  }

  @override
  String hdDetailTitle(String id) {
    return 'Hadis no. $id';
  }

  @override
  String get dzTransSubhanallah => 'Maha Suci Allah';

  @override
  String get dzTransAlhamdulillah => 'Segala puji bagi Allah';

  @override
  String get dzTransAllahuakbar => 'Allah Maha Besar';

  @override
  String get dzTransAstaghfirullah => 'Aku memohon ampun kepada Allah';

  @override
  String get dzTransHawla => 'Tiada daya & kekuatan kecuali dengan Allah';

  @override
  String get blModulNotFound => 'Modul tidak ditemukan';

  @override
  String get blModulDone => 'Modul Selesai!';

  @override
  String get blKnowledgeUp => 'Pengetahuanmu semakin bertambah.';

  @override
  String get blMinScore70 => 'Minimal 70% untuk lulus. Coba lagi ya!';

  @override
  String get blReadAgain =>
      'Baca lagi artikelnya, lalu coba quiz lagi. Kamu pasti bisa!';

  @override
  String get blBackToHub => 'Kembali ke Hub';

  @override
  String get qdArabicSize => 'Ukuran teks Arab';

  @override
  String get qdTransSize => 'Ukuran terjemahan';

  @override
  String get qdLatinHint => 'Bacaan latin untuk membantu membaca Arab';

  @override
  String get qdTajwidColors => 'Warna Tajwid';

  @override
  String get qdTafsirMuyassar => 'Tafsir Muyassar (ringkas, mudah dicerna)';

  @override
  String get qdTafsirKemenag => 'Tafsir Kemenag (lengkap)';

  @override
  String get ppUnlockSkins => 'Buka semua skin premium';

  @override
  String get ppActivateDev => 'Aktifkan Pro (dev)';

  @override
  String get deExpTitle => 'DAPET EXP!';

  @override
  String get bqModulNotFound => 'Modul tidak ditemukan';

  @override
  String get bqQuizUnavailable => 'Quiz belum tersedia';

  @override
  String get bqNotYetRight => 'Belum tepat';

  @override
  String get qpPrevAyah => 'Ayat sebelumnya';

  @override
  String get qpNextAyah => 'Ayat berikutnya';

  @override
  String get qpMurrotalSettings => 'Setelan murrotal';

  @override
  String get qpbRepeatRange => 'Ulangi rentang';

  @override
  String get qpbSleepTimer => 'Tidur otomatis';

  @override
  String get qpbEndOfSurah => 'Akhir surat';

  @override
  String get qbNoBookmark => 'Belum ada bookmark';

  @override
  String get qbDeleteBookmark => 'Hapus bookmark';

  @override
  String get qacDeleteBookmark => 'Hapus bookmark';

  @override
  String get phPrevMonth => 'Bulan sebelumnya';

  @override
  String get phNextMonth => 'Bulan berikutnya';

  @override
  String get clProLocked => 'Pro terkunci';

  @override
  String get clCompleteQuest =>
      'Selesaikan quest harian untuk membuka skin dari Daily Chest.';

  @override
  String get qdTajwidLegend => 'Merah=Ghunnah, Biru=Qalqalah/Idgham, Hijau=Mad';

  @override
  String get ppProPitch =>
      'Perisai, aura, dan gelar eksklusif. Gaya baru untuk avatarmu — tanpa memengaruhi XP, streak, atau peringkatmu.';

  @override
  String deQuizDone(String moduleTitle) {
    return 'Kamu menyelesaikan quiz $moduleTitle!';
  }

  @override
  String deLevelShort(int level) {
    return 'Lv $level';
  }

  @override
  String deLevel(int level) {
    return 'Level $level';
  }

  @override
  String bqQuestionOf(int current, int total) {
    return 'PERTANYAAN $current/$total';
  }

  @override
  String qbSurahName(int number) {
    return 'Surat $number';
  }

  @override
  String qacAyahNumber(int number) {
    return 'Ayat $number';
  }

  @override
  String get jdLoadFailed => 'Gagal memuat jadwal. Periksa koneksi.';

  @override
  String get jdAlreadyLogged => '✓ SUDAH DILOG';

  @override
  String get jdTesSuara => 'Tes suara';

  @override
  String get jdAdzanDownloadFailed =>
      'Gagal mengunduh suara adzan. Periksa koneksi lalu coba lagi.';

  @override
  String get qtLoadFailed => 'Gagal memuat data Quran';

  @override
  String get qtSurahNotFound => 'Surat tidak ditemukan';

  @override
  String get qtContinueReading => 'Lanjutkan membaca';

  @override
  String get spTagline => 'Level Up iman, Level Up Kehidupanmu';

  @override
  String get spLoading => 'MEMUAT DATA PEJUANG...';

  @override
  String get btSubtitle => 'Tingkatkan ilmu, raih lebih banyak XP.';

  @override
  String get doaLoadFailed => 'Gagal memuat doa.';

  @override
  String get taProSignature => 'Pro signature finish';

  @override
  String get tpSelected => 'Tema dipilih';

  @override
  String get qrDisplaySettings => 'Setelan tampilan';

  @override
  String get jdSoundFollowGlobal => 'Mengikuti global';

  @override
  String jdNotifFor(String prayer) {
    return 'Notifikasi $prayer';
  }

  @override
  String get jdSoundSilent => 'Senyap — tanpa suara';

  @override
  String get jdSoundNormal => 'Suara — notifikasi standar HP';

  @override
  String get jdSoundAdzan => 'Adzan — suara adzan penuh';

  @override
  String get jdSoundGlobalOption => 'Ikuti pengaturan global';

  @override
  String jdFootnote(String city) {
    return 'Jadwal dari data KEMENAG RI via api.myquran.com untuk $city. Ter-update otomatis saat tab dibuka; tap nama kota di atas untuk ganti lokasi.';
  }

  @override
  String qtSearchEmpty(String example) {
    return 'Tidak ditemukan. Coba kata lain di terjemahan, atau tulis nama surat + nomor ayat — mis. $example.';
  }

  @override
  String qtOpenSurah(String surah) {
    return 'Buka surat $surah';
  }

  @override
  String qtAyahOf(int ayah, int total) {
    return 'Ayat $ayah dari $total';
  }

  @override
  String qtSurahAyah(int surah, int ayah) {
    return 'Surat $surah · Ayat $ayah';
  }

  @override
  String btQuizScore(int score) {
    return 'Quiz: $score%';
  }

  @override
  String nlLevelShort(int level) {
    return 'Lv $level';
  }

  @override
  String homeLevelShort(int level) {
    return 'LV $level';
  }

  @override
  String qtsTafsirAyah(int ayah) {
    return 'Tafsir Ayat $ayah';
  }

  @override
  String get locFailureDisabled =>
      'Aktifkan layanan lokasi perangkat, lalu coba lagi.';

  @override
  String get locFailureDenied =>
      'Izinkan akses lokasi untuk menggunakan lokasi saat ini.';

  @override
  String get locFailureDeniedForever =>
      'Izin lokasi diblokir. Buka Pengaturan untuk mengizinkannya.';

  @override
  String get locFailureTimeout =>
      'Lokasi terlalu lama ditemukan. Coba lagi di area terbuka.';

  @override
  String get locFailureLookup =>
      'Kota tidak dapat ditemukan. Periksa koneksi atau pilih kota manual.';

  @override
  String get authNoIdToken =>
      'Google tidak kirim idToken. Cek SHA-1 di Firebase Console.';

  @override
  String get authEmptyUser => 'Firebase Auth gagal — user kosong.';

  @override
  String get authDevError10 =>
      'Google DEVELOPER_ERROR (10): SHA-1 belum terdaftar di Firebase Console.';

  @override
  String get authMisconfigured =>
      'Google Sign-In misconfigured. Cek OAuth consent + SHA-1.';

  @override
  String get authNetworkError => 'Jaringan error saat login Google.';

  @override
  String get authCredInvalid => 'Firebase Auth gagal validasi credential.';

  @override
  String get authNotEnabled =>
      'Google Sign-In belum diaktifkan di Firebase Console.';

  @override
  String get authEmailInUse => 'Email sudah terdaftar dengan metode lain.';

  @override
  String get notifModeFokus =>
      'Mode Fokus aktif! Pengingat hanya saat masuk waktu adzan.';

  @override
  String get notifModeSeimbang =>
      'Mode Seimbang aktif! Pengingat semua sholat wajib 15 menit sebelum adzan.';

  @override
  String get notifModeIntensif =>
      'Mode Intensif aktif! Diingetin 30 menit & 5 menit sebelum sholat. Pertahanin streak! 🔥';

  @override
  String get notifReady => 'Notifikasi Muslim Leveling siap! 🔔';

  @override
  String get notifTestBody =>
      'Kalau adzan terdengar, notifikasi kamu siap! Kalau tidak, cek volume alarm HP.';

  @override
  String get notifTestTitle => '🕌 Tes Suara Adzan';

  @override
  String get notifChannelReminder => 'Notifikasi pengingat waktu sholat';

  @override
  String notifModeTitle(String mode) {
    return 'Muslim Leveling Mode: $mode';
  }

  @override
  String notifTitleMarker(String prayer) {
    return '🕌 $prayer';
  }

  @override
  String notifTitlePrayer(String prayer) {
    return '🕌 Waktunya Sholat $prayer';
  }

  @override
  String notifBodyImsak(String loc) {
    return 'Sudah masuk imsak$loc. Berhenti makan & minum ya. 🌙';
  }

  @override
  String notifBodyTerbit(String loc) {
    return 'Matahari terbit$loc. Waktu Subuh berakhir, Dhuha sudah masuk. ☀️';
  }

  @override
  String notifBody30min(String prayer, String loc) {
    return '30 menit lagi masuk waktu $prayer$loc. Persiapan ya! 🔥';
  }

  @override
  String notifBody5min(String prayer, String loc) {
    return '5 menit lagi masuk waktu $prayer$loc. Segera siap! ⚡';
  }

  @override
  String notifBody15min(String prayer, String loc) {
    return '15 menit lagi masuk waktu $prayer$loc. Persiapan ya! 🌙';
  }

  @override
  String notifBodyNow(String prayer, String loc) {
    return 'Sudah masuk waktu sholat $prayer$loc. Yuk jaga streak! 🔥';
  }

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerTerbit => 'Terbit';

  @override
  String notifLocSuffix(String city) {
    return ' di $city';
  }

  @override
  String blClaimXp(int xp) {
    return 'KLAIM +$xp XP';
  }

  @override
  String get blNotPassed => 'Belum Lulus';

  @override
  String get jdPageTitle => 'Waktu Sholat';

  @override
  String get jdSearchCity => 'Cari Kota';

  @override
  String get jdNextPrayer => 'SHOLAT BERIKUTNYA';

  @override
  String get jdTodaySchedule => 'JADWAL HARI INI';

  @override
  String get jdAdzanSoundTitle => 'SUARA ADZAN';

  @override
  String get jdLoadingShort => 'memuat...';

  @override
  String jdCountdownHm(int hours, int minutes) {
    return '${hours}j ${minutes}m lagi';
  }

  @override
  String jdCountdownM(int minutes) {
    return '${minutes}m lagi';
  }

  @override
  String get jdCountdownTomorrow => 'besok';

  @override
  String get jdRegionTitle => 'Pilih Wilayah';

  @override
  String get jdRegionIndonesia => 'Indonesia';

  @override
  String get jdRegionAbroad => 'Luar Negeri';

  @override
  String get jdAbroadSearchHint => 'Ketik nama kota di luar negeri...';

  @override
  String get jdAbroadEmpty =>
      'Kota tidak ditemukan. Tulis namanya dalam bahasa Inggris — mis. London.';

  @override
  String jdFootnoteAbroad(String city) {
    return 'Jadwal dari Aladhan untuk $city. Metode perhitungan mengikuti negara kota ini. Ter-update otomatis saat tab dibuka; tap nama kota di atas untuk ganti lokasi.';
  }
}

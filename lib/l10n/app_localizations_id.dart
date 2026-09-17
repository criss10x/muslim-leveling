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
  String get tabHome => 'Beranda';

  @override
  String get tabJadwal => 'Jadwal';

  @override
  String get tabQuran => 'Al-Quran';
}

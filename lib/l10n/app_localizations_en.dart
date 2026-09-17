// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get achBtnAwesome => 'NICE!';

  @override
  String get achBtnShare => 'Share';

  @override
  String get achBtnSkipAll => 'Skip all';

  @override
  String achEarnedOn(String date, String tier) {
    return 'Unlocked $date • $tier';
  }

  @override
  String achHintFallback(String desc) {
    return 'Complete: $desc.';
  }

  @override
  String achLockedTier(String tier) {
    return 'Locked • $tier';
  }

  @override
  String achScreenProgress(int total) {
    return ' / $total medals unlocked';
  }

  @override
  String get achScreenTitle => 'Achievements';

  @override
  String get achSectionTitle => 'ACHIEVEMENTS';

  @override
  String get achSeeAll => 'See all';

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
    return 'Achievement unlocked: $title. $desc. Tier $tier.';
  }

  @override
  String get achStateLocked => 'Locked';

  @override
  String get achStateUnlocked => 'Unlocked';

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
  String get achUnlockedBanner => 'ACHIEVEMENT UNLOCKED!';

  @override
  String get ach_collector_desc =>
      'Log all 8 types of sunnah prayer at least once';

  @override
  String get ach_collector_hint =>
      'Log at least 1× of all 8 sunnah types: Dhuha, Tahajjud, and the 6 rawatib.';

  @override
  String get ach_collector_title => 'COLLECTOR';

  @override
  String get ach_comeback_real_desc => 'Bounce back after a broken streak';

  @override
  String get ach_comeback_real_title => 'COMEBACK IS REAL';

  @override
  String get ach_critical_hit_desc => 'Prayed within 5 minutes of the adhan';

  @override
  String get ach_critical_hit_title => 'CRITICAL HIT!';

  @override
  String get ach_dawn_buff_desc => 'First time logging Qabliyah Fajr';

  @override
  String get ach_dawn_buff_title => 'DAWN BUFF';

  @override
  String get ach_dhuha_secured_desc => 'First time logging Dhuha prayer';

  @override
  String get ach_dhuha_secured_title => 'DHUHA SECURED';

  @override
  String get ach_dominating_desc => 'Hero Streak 7 days in a row';

  @override
  String get ach_dominating_title => 'DOMINATING!';

  @override
  String get ach_double_kill_desc => 'Hero Streak 2 days in a row';

  @override
  String get ach_double_kill_title => 'DOUBLE KILL';

  @override
  String get ach_dusk_finisher_desc => 'First time logging Ba\'diyah Maghrib';

  @override
  String get ach_dusk_finisher_title => 'DUSK FINISHER';

  @override
  String get ach_dzikir_legend_desc => '50,000× dhikr';

  @override
  String get ach_dzikir_legend_hint =>
      'Lifetime dhikr count from the Dhikr tab.';

  @override
  String get ach_dzikir_legend_title => 'DZIKIR LEGEND';

  @override
  String get ach_dzikir_master_desc => '10,000× dhikr';

  @override
  String get ach_dzikir_master_title => 'DZIKIR MASTER';

  @override
  String get ach_dzikir_pemula_desc => '1,000× dhikr';

  @override
  String get ach_dzikir_pemula_title => 'DHIKR BEGINNER';

  @override
  String get ach_early_bird_desc => '20× on-time prayers (±10 min)';

  @override
  String get ach_early_bird_hint =>
      '20× on-time prayers (≤10 minutes after the adhan).';

  @override
  String get ach_early_bird_title => 'EARLY BIRD';

  @override
  String get ach_early_game_desc => 'Your first Fajr prayer is logged';

  @override
  String get ach_early_game_title => 'EARLY GAME';

  @override
  String get ach_first_blood_desc =>
      'Complete all 5 obligatory prayers in one day (Hero Streak starts!)';

  @override
  String get ach_first_blood_hint =>
      'Log 5 obligatory prayers in one day (Fajr, Dhuhr, Asr, Maghrib, Isha).';

  @override
  String get ach_first_blood_title => 'FIRST BLOOD!';

  @override
  String get ach_first_clear_module_desc => 'Finish your first Learning module';

  @override
  String get ach_first_clear_module_title => 'FIRST CLEAR';

  @override
  String get ach_first_strike_desc => 'Fajr within 15 minutes of the adhan';

  @override
  String get ach_first_strike_hint =>
      'Pray Fajr within 15 minutes of the adhan.';

  @override
  String get ach_first_strike_title => 'FIRST STRIKE';

  @override
  String get ach_full_combo_desc =>
      'In one day: 5 obligatory + Tilawah + Dhuha';

  @override
  String get ach_full_combo_hint =>
      'In one day: log 5 obligatory + Tilawah + Dhuha.';

  @override
  String get ach_full_combo_title => 'FULL COMBO';

  @override
  String get ach_godlike_desc => 'Hero Streak 30 days in a row';

  @override
  String get ach_godlike_title => 'GODLIKE!';

  @override
  String get ach_gold_buff_desc => 'First time logging Qabliyah Asr';

  @override
  String get ach_gold_buff_title => 'GOLD BUFF';

  @override
  String get ach_gold_lane_desc => 'First time logging Asr prayer';

  @override
  String get ach_gold_lane_title => 'GOLD LANE';

  @override
  String get ach_hadis_champion_desc => 'Read 200 hadith';

  @override
  String get ach_hadis_champion_title => 'HADIS CHAMPION';

  @override
  String get ach_hadis_elite_desc => 'Read 50 hadith';

  @override
  String get ach_hadis_elite_title => 'HADIS ELITE';

  @override
  String get ach_hadis_grinder_desc => 'Read 10 hadith';

  @override
  String get ach_hadis_grinder_title => 'HADIS GRINDER';

  @override
  String get ach_hadis_hero_desc => 'Read 350 hadith';

  @override
  String get ach_hadis_hero_title => 'HADIS HERO';

  @override
  String get ach_hadis_legend_desc => 'Read 500 hadith';

  @override
  String get ach_hadis_legend_title => 'HADIS LEGEND';

  @override
  String get ach_hadis_rookie_desc => 'Read 5 hadith';

  @override
  String get ach_hadis_rookie_title => 'HADIS ROOKIE';

  @override
  String get ach_hadis_veteran_desc => 'Read 100 hadith';

  @override
  String get ach_hadis_veteran_title => 'HADIS VETERAN';

  @override
  String get ach_hadis_warrior_desc => 'Read 25 hadith';

  @override
  String get ach_hadis_warrior_title => 'HADIS WARRIOR';

  @override
  String get ach_hall_of_fame_desc => 'Unlock every other achievement 👑';

  @override
  String get ach_hall_of_fame_hint =>
      'Unlock every other achievement one by one — the last of 87 regular medals.';

  @override
  String get ach_hall_of_fame_title => 'HALL OF FAME';

  @override
  String get ach_jamaah_champion_desc => '200× prayers in congregation';

  @override
  String get ach_jamaah_champion_title => 'JAMAAH CHAMPION';

  @override
  String get ach_jamaah_elite_desc => '50× prayers in congregation';

  @override
  String get ach_jamaah_elite_title => 'JAMAAH ELITE';

  @override
  String get ach_jamaah_grinder_desc => '10× prayers in congregation';

  @override
  String get ach_jamaah_grinder_title => 'JAMAAH GRINDER';

  @override
  String get ach_jamaah_hero_desc => '350× prayers in congregation';

  @override
  String get ach_jamaah_hero_title => 'JAMAAH HERO';

  @override
  String get ach_jamaah_legend_desc => '500× prayers in congregation';

  @override
  String get ach_jamaah_legend_title => 'JAMAAH LEGEND';

  @override
  String get ach_jamaah_rookie_desc => '5× prayers in congregation';

  @override
  String get ach_jamaah_rookie_title => 'JAMAAH ROOKIE';

  @override
  String get ach_jamaah_veteran_desc => '100× prayers in congregation';

  @override
  String get ach_jamaah_veteran_title => 'JAMAAH VETERAN';

  @override
  String get ach_jamaah_warrior_desc => '25× prayers in congregation';

  @override
  String get ach_jamaah_warrior_title => 'JAMAAH WARRIOR';

  @override
  String get ach_jungler_desc => '7-day Tilawah streak';

  @override
  String get ach_jungler_title => 'JUNGLER';

  @override
  String get ach_langkah_pertama_desc => 'Log your very first prayer';

  @override
  String get ach_langkah_pertama_title => 'FIRST STEP';

  @override
  String get ach_late_game_desc => 'First time logging Isha prayer';

  @override
  String get ach_late_game_title => 'LATE GAME';

  @override
  String get ach_legendary_desc => 'Hero Streak 100 days in a row';

  @override
  String get ach_legendary_title => 'LEGENDARY!';

  @override
  String get ach_mana_regen_desc => 'First time logging Tilawah/Dhikr';

  @override
  String get ach_mana_regen_title => 'MANA REGEN';

  @override
  String get ach_maniac_desc => 'Hero Streak 14 days in a row';

  @override
  String get ach_maniac_title => 'MANIAC!';

  @override
  String get ach_mid_buff_desc => 'First time logging Qabliyah Dhuhr';

  @override
  String get ach_mid_buff_title => 'MID BUFF';

  @override
  String get ach_mid_finisher_desc => 'First time logging Ba\'diyah Dhuhr';

  @override
  String get ach_mid_finisher_title => 'MID FINISHER';

  @override
  String get ach_mid_game_desc => 'First time logging Dhuhr prayer';

  @override
  String get ach_mid_game_title => 'MID GAME';

  @override
  String get ach_night_finisher_desc => 'First time logging Ba\'diyah Isha';

  @override
  String get ach_night_finisher_title => 'NIGHT FINISHER';

  @override
  String get ach_phoenix_desc =>
      'Bounce back 3× after a broken streak — never give up';

  @override
  String get ach_phoenix_hint =>
      'After a broken streak, start again until 3 comebacks are logged.';

  @override
  String get ach_phoenix_title => 'PHOENIX';

  @override
  String get ach_quiz_mvp_desc => 'Perfect 100% score on one quiz';

  @override
  String get ach_quiz_mvp_hint =>
      'Take the quiz at the end of a Learning module and answer every question right (100%).';

  @override
  String get ach_quiz_mvp_title => 'MVP';

  @override
  String get ach_quran_adept_desc => 'Read 100 verses';

  @override
  String get ach_quran_adept_title => 'QURAN ADEPT';

  @override
  String get ach_quran_apprentice_desc => 'Read 50 verses';

  @override
  String get ach_quran_apprentice_title => 'QURAN APPRENTICE';

  @override
  String get ach_quran_champion_desc => 'Read 4,000 verses';

  @override
  String get ach_quran_champion_title => 'QURAN CHAMPION';

  @override
  String get ach_quran_guardian_desc => 'Read 2,000 verses';

  @override
  String get ach_quran_guardian_title => 'QURAN GUARDIAN';

  @override
  String get ach_quran_hafizh_desc => 'Read 1,000 verses';

  @override
  String get ach_quran_hafizh_title => 'YOUNG HAFIZH';

  @override
  String get ach_quran_master_desc => 'Read all 6,236 verses (khatm)';

  @override
  String get ach_quran_master_hint =>
      'Read 6,236 verses in total (the entire Quran) since first install.';

  @override
  String get ach_quran_master_title => 'HAFIZH MASTER';

  @override
  String get ach_quran_novice_desc => 'Read 10 verses';

  @override
  String get ach_quran_novice_title => 'QURAN NOVICE';

  @override
  String get ach_quran_sage_desc => 'Read 500 verses';

  @override
  String get ach_quran_sage_title => 'QURAN SAGE';

  @override
  String get ach_quran_scholar_desc => 'Read 200 verses';

  @override
  String get ach_quran_scholar_title => 'QURAN SCHOLAR';

  @override
  String get ach_rank_elite_desc => 'Reach Level 25';

  @override
  String get ach_rank_elite_title => 'ELITE';

  @override
  String get ach_rank_epic_desc => 'Reach Level 60';

  @override
  String get ach_rank_epic_title => 'EPIC';

  @override
  String get ach_rank_master_desc => 'Reach Level 40';

  @override
  String get ach_rank_master_title => 'MASTER';

  @override
  String get ach_rank_mythic_desc => 'Reach Level 80 — Muslim Mythic!';

  @override
  String get ach_rank_mythic_hint =>
      'Level up through XP from daily worship — reaching level 80 takes time.';

  @override
  String get ach_rank_mythic_title => 'MYTHIC';

  @override
  String get ach_rank_warrior_desc => 'Reach Level 10';

  @override
  String get ach_rank_warrior_title => 'WARRIOR';

  @override
  String get ach_sage_desc => 'Complete all 16 Learning modules';

  @override
  String get ach_sage_hint =>
      'Complete all 16 Learning modules (quiz score doesn\'t matter).';

  @override
  String get ach_sage_title => 'SAGE';

  @override
  String get ach_santri_scholar_desc => 'Complete 40 Learning modules';

  @override
  String get ach_santri_scholar_hint =>
      'Complete 40 modules in the Learning tab (currently 16, growing over time).';

  @override
  String get ach_santri_scholar_title => 'SANTRI SCHOLAR';

  @override
  String get ach_savage_desc => 'Hero Streak 60 days in a row';

  @override
  String get ach_savage_title => 'SAVAGE!';

  @override
  String get ach_sharpshooter_desc => '10× on-time prayers (≤10 minutes)';

  @override
  String get ach_sharpshooter_hint =>
      '10× on-time prayers (≤10 minutes after the adhan).';

  @override
  String get ach_sharpshooter_title => 'SHARPSHOOTER';

  @override
  String get ach_subuh_legend_desc => '30-day Fajr streak';

  @override
  String get ach_subuh_legend_title => 'SUBUH LEGEND';

  @override
  String get ach_subuh_solo_carry_desc =>
      '7-day Fajr streak — the hardest lane';

  @override
  String get ach_subuh_solo_carry_title => 'SUBUH SOLO CARRY';

  @override
  String get ach_sultan_sunnah_desc => '50 sunnah prayers in total';

  @override
  String get ach_sultan_sunnah_title => 'SUNNAH SULTAN';

  @override
  String get ach_sunnah_master_desc => '200 sunnah prayers in total';

  @override
  String get ach_sunnah_master_hint =>
      'Total logs across all 8 types of sunnah prayer (Dhuha, Rawatib, Tahajjud, etc.).';

  @override
  String get ach_sunnah_master_title => 'SUNNAH MASTER';

  @override
  String get ach_sunset_strike_desc => 'First time logging Maghrib prayer';

  @override
  String get ach_sunset_strike_title => 'SUNSET STRIKE';

  @override
  String get ach_tahajjud_secured_desc => 'First time logging Tahajjud prayer';

  @override
  String get ach_tahajjud_secured_title => 'TAHAJJUD SECURED';

  @override
  String get ach_tilawah_streak_14_desc => '14-day Tilawah streak';

  @override
  String get ach_tilawah_streak_14_title => 'RECITATION STREAK';

  @override
  String get ach_triple_kill_desc => 'Hero Streak 3 days in a row';

  @override
  String get ach_triple_kill_title => 'TRIPLE KILL';

  @override
  String get ach_unstoppable_desc => 'Hero Streak 5 days in a row';

  @override
  String get ach_unstoppable_title => 'UNSTOPPABLE!';

  @override
  String get ach_wajib_champion_desc => '400× obligatory prayers';

  @override
  String get ach_wajib_champion_title => 'WAJIB CHAMPION';

  @override
  String get ach_wajib_elite_desc => '100× obligatory prayers';

  @override
  String get ach_wajib_elite_title => 'WAJIB ELITE';

  @override
  String get ach_wajib_grinder_desc => '25× obligatory prayers';

  @override
  String get ach_wajib_grinder_title => 'WAJIB GRINDER';

  @override
  String get ach_wajib_hero_desc => '700× obligatory prayers';

  @override
  String get ach_wajib_hero_title => 'WAJIB HERO';

  @override
  String get ach_wajib_immortal_desc => 'Lifetime total of obligatory prayers';

  @override
  String get ach_wajib_immortal_hint =>
      'Lifetime cumulative total of obligatory prayers.';

  @override
  String get ach_wajib_immortal_title => 'WAJIB IMMORTAL';

  @override
  String get ach_wajib_master_desc => '1,000× obligatory prayers';

  @override
  String get ach_wajib_master_title => 'WAJIB MASTER';

  @override
  String get ach_wajib_mythic_desc => '1,500× obligatory prayers';

  @override
  String get ach_wajib_mythic_title => 'WAJIB MYTHIC';

  @override
  String get ach_wajib_rookie_desc => '10× obligatory prayers';

  @override
  String get ach_wajib_rookie_title => 'WAJIB ROOKIE';

  @override
  String get ach_wajib_veteran_desc => '200× obligatory prayers';

  @override
  String get ach_wajib_veteran_title => 'WAJIB VETERAN';

  @override
  String get ach_wajib_warrior_desc => '50× obligatory prayers';

  @override
  String get ach_wajib_warrior_title => 'WAJIB WARRIOR';

  @override
  String get ach_wombo_combo_desc =>
      'Finish Daily Dhikr 100 for the first time';

  @override
  String get ach_wombo_combo_title => 'WOMBO COMBO';

  @override
  String get appTitle => 'Muslim Leveling';

  @override
  String get localeEnglish => 'English';

  @override
  String get localeIndonesian => 'Bahasa Indonesia';

  @override
  String get localePicked => 'Language selected';

  @override
  String get localeSystem => 'Follow System (Phone)';

  @override
  String get localeTitle => 'App language';

  @override
  String get settingLanguage => 'Language';

  @override
  String get shareBtnShareAgain => 'Share Again';

  @override
  String shareCaption(String title) {
    return 'I unlocked \"$title\" in Muslim Leveling! 🎮🕌';
  }

  @override
  String shareEarnedOn(String date) {
    return 'Earned $date';
  }

  @override
  String get shareErrImage => 'Could not render the card image. Try again.';

  @override
  String get shareErrPrepare => 'Could not prepare the card. Try again.';

  @override
  String get shareErrShare => 'Could not share the card. Try again.';

  @override
  String get shareStatAllModules => '📚 All 16 modules complete!';

  @override
  String get shareStatCollector => '👑 True collector!';

  @override
  String shareStatComeback(int count) {
    return 'Total comebacks: $count 💪';
  }

  @override
  String get shareStatDhikr => '📿 Dhikr goal reached!';

  @override
  String get shareStatFajr15 => '🎯 Fajr under 15 minutes';

  @override
  String get shareStatFajrStreak => 'days of Fajr streak 🔥';

  @override
  String get shareStatFullCombo => '🔥 5 obligatory + Tilawah + Dhuha';

  @override
  String get shareStatHeroStreak => 'days of Hero Streak 🔥';

  @override
  String get shareStatLearning => '📖 Learning started — keep going!';

  @override
  String shareStatLevel(int level, String rank) {
    return 'Level $level — $rank';
  }

  @override
  String get shareStatOnTime10 => '🎯 10× on-time prayers';

  @override
  String get shareStatOnTimeFirst => '⚡ On time from the very first';

  @override
  String get shareStatQuizPerfect => '⭐ Perfect score!';

  @override
  String get shareStatSunnah => '🏛️ All 8 sunnah collected';

  @override
  String get shareStatTilawahStreak => 'days of Tilawah streak 🔥';

  @override
  String get tabHome => 'Home';

  @override
  String get tabJadwal => 'Schedule';

  @override
  String get tabQuran => 'Quran';
}

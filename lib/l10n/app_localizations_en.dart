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
  String get commonCancel => 'Cancel';

  @override
  String get cityPickerEmptyKab => 'No city found';

  @override
  String get cityPickerEmptyProv => 'No province found';

  @override
  String get cityPickerHintKab => 'Type a city name...';

  @override
  String get cityPickerHintProv => 'Type a province name...';

  @override
  String get cityPickerNotFound => 'No city found. Try another province.';

  @override
  String get cityPickerLoadFailed =>
      'Could not load the city list. Check your connection and try again.';

  @override
  String get cityPickerRetry => 'Try again';

  @override
  String get cityPickerTitleKab => 'Pick a City';

  @override
  String get cityPickerTitleProv => 'Pick a Province';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLogout => 'Sign out';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSave => 'Save';

  @override
  String get homeAskWajibBody => 'Pick how you prayed to earn bonus XP';

  @override
  String homeAskWajibTitle(String prayer) {
    return 'Have you prayed $prayer?';
  }

  @override
  String get homeBonusJamaah => 'In congregation';

  @override
  String get homeBonusJamaahSub => 'prayed in congregation';

  @override
  String get homeBonusOnTime => 'On time';

  @override
  String get homeBonusOnTimeSub => 'within 30 minutes of the adhan';

  @override
  String get homeBonusPlain => 'Already';

  @override
  String get homeBonusPlainSub => 'no bonus XP';

  @override
  String get homeBonusQuestSunnah => 'BONUS QUEST · SUNNAH';

  @override
  String get homeChestLocked => 'Complete all 5 obligatory prayers';

  @override
  String get homeChestMetaOpened => 'OPENED';

  @override
  String homeChestMetaProgress(int done, int total) {
    return '$done/$total OBLIGATORY';
  }

  @override
  String get homeChestOpenedLabel => 'CHEST OPENED';

  @override
  String get homeChestOpenedSub => 'Come back tomorrow! 🌙';

  @override
  String get homeChestReadyLabel => 'REWARD READY!';

  @override
  String get homeChestReadySub => 'Tap to claim 🎉';

  @override
  String get homeChestTitle => 'DAILY CHEST';

  @override
  String get homeDefaultCity => 'Jakarta';

  @override
  String homeLevelUpSource(String prayer) {
    return '$prayer prayer';
  }

  @override
  String homeLockAfterTime(String prayer) {
    return '$prayer time has passed.';
  }

  @override
  String homeLockBeforeTime(String prayer, String time) {
    return 'It is not $prayer time yet (adhan $time).';
  }

  @override
  String homeLockSubuh(int hours, String until) {
    return 'The Fajr quest locks $hours hours after adhan (until $until). Do not miss it tomorrow! 💪';
  }

  @override
  String get homeLogDuplicate => 'This prayer is already logged today!';

  @override
  String get homeNext => 'NEXT';

  @override
  String homeQuestClaimable(int n) {
    return '$n READY TO CLAIM';
  }

  @override
  String get homeQuestDaily => 'DAILY QUEST';

  @override
  String get homeQuickActions => 'QUICK ACCESS';

  @override
  String homeQuickActionsMeta(int done, int total) {
    return 'REFLECTION $done/$total';
  }

  @override
  String get homeQuickDoa => 'Duas';

  @override
  String get homeQuickDzikir => 'Dhikr';

  @override
  String get homeQuickHadis => 'Hadith';

  @override
  String get homeQuickKiblat => 'Qibla';

  @override
  String get homeQuickRenungan => 'Reflection';

  @override
  String get homeRevealBtn => 'Alhamdulillah! 🤲';

  @override
  String get homeRevealCosmetic => 'NEW COSMETIC!';

  @override
  String get homeRevealDuplicate =>
      'Duplicate item — your collection keeps it 📦';

  @override
  String homeRevealLevelUp(String suffix) {
    return '⬆️ Level Up!$suffix';
  }

  @override
  String get homeRevealReward => 'REWARD GET!';

  @override
  String get homeRevealShield => 'FREEZE SHIELD!';

  @override
  String homeRevealShieldBody(int count) {
    return 'Your streak survives 1 missed day. Total: $count ❄️';
  }

  @override
  String get homeRingWajib => 'OBLIGATORY';

  @override
  String get homeRitualToday => 'TODAY\'S RITUALS';

  @override
  String get homeSideDone => 'Done today ✓';

  @override
  String get homeSideDzikir => 'Dhikr 100x';

  @override
  String homeSideDzikirSub(int count, int target) {
    return '$count/$target dhikr';
  }

  @override
  String get homeSideHadis => 'Study Hadith';

  @override
  String homeSideHadisSub(int count, int target) {
    return '$count/$target hadith read';
  }

  @override
  String get homeSideQuestTitle => 'SIDE QUEST';

  @override
  String get homeSideQuran => 'Read Quran';

  @override
  String homeSideQuranSub(int done, int target) {
    return '$done/$target verses today';
  }

  @override
  String get homeSideSedekah => 'Charity';

  @override
  String get homeSideSedekahSub => 'Give charity today';

  @override
  String get homeSunnahHintBadiyahDzuhur =>
      'Ba\'diyah Dhuhr runs after Dhuhr until before Asr.';

  @override
  String get homeSunnahHintBadiyahIsya =>
      'Ba\'diyah Isha runs after Isha until midnight.';

  @override
  String get homeSunnahHintBadiyahMaghrib =>
      'Ba\'diyah Maghrib runs after Maghrib until before Isha.';

  @override
  String get homeSunnahHintDhuha =>
      'Duha can be prayed after sunrise (±15 min in) until before Dhuhr.';

  @override
  String get homeSunnahHintFallback => 'Try again later.';

  @override
  String get homeSunnahHintQobliyahAshar =>
      'Qabliyah Asr runs from Asr until before Maghrib.';

  @override
  String get homeSunnahHintQobliyahDzuhur =>
      'Qabliyah Dhuhr runs from Dhuhr until before Asr.';

  @override
  String get homeSunnahHintQobliyahSubuh =>
      'Qabliyah Fajr shares Fajr\'s window (Fajr until sunrise).';

  @override
  String get homeSunnahHintTahajjud =>
      'Tahajjud runs after Isha until before Imsak.';

  @override
  String get homeUnitDays => 'days';

  @override
  String get homeWajibQuest => 'OBLIGATORY QUEST';

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
  String get localePicked => 'Language selected';

  @override
  String get localeSystem => 'Follow System (Phone)';

  @override
  String get localeTitle => 'App language';

  @override
  String get onbContinue => 'Continue';

  @override
  String get onbDefaultNickname => 'Pejuang';

  @override
  String get onbGenderAkhwat => 'AKHWAT';

  @override
  String get onbGenderIkhwan => 'IKHWAN';

  @override
  String get onbGenderMeaning =>
      'Ikhwan is Arabic for male, akhwat for female.';

  @override
  String get onbGenderPrivacy =>
      'Your answer is only used to hide that menu. You can change it anytime in Profile.';

  @override
  String get onbGenderSkip => 'Not needed';

  @override
  String get onbGenderTitle => 'Are you Ikhwan or Akhwat?';

  @override
  String get onbGenderWhy =>
      'Akhwat get the Menstrual Period feature: during your period your prayer streak is frozen automatically, so there is no penalty. We hide it from the Ikhwan view to keep the menu clean.';

  @override
  String get onbHowAchBody =>
      'Unlock medals from streaks, recitation, and dhikr.';

  @override
  String get onbHowAchTitle => 'Achievements';

  @override
  String get onbHowBody =>
      'Three things that make your daily worship feel like leveling up.';

  @override
  String get onbHowDemoHint => 'Try tapping the card';

  @override
  String get onbHowQuestBody => 'Mark obligatory & sunnah prayers every day.';

  @override
  String get onbHowQuestTitle => 'Daily Quests';

  @override
  String get onbHowTitle => 'How to Play';

  @override
  String get onbHowXpBody => 'Every quest gives XP. Level up, rank up.';

  @override
  String get onbHowXpTitle => 'XP & Levels';

  @override
  String get onbLangBody => 'You can change this anytime in Profile.';

  @override
  String get onbLangTitle => 'Which language do you want?';

  @override
  String get onbLocationAllow => 'Allow Location';

  @override
  String get onbLocationBody =>
      'To calculate accurate prayer times and qibla direction we need location access. Your location is not shared with anyone — all calculations happen on your phone.';

  @override
  String get onbLocationLoading => 'GETTING LOCATION...';

  @override
  String get onbLocationLater => 'Use the default city for now';

  @override
  String get onbLocationLaterHint =>
      'No location yet? The schedule uses a default city for now — you can change it anytime in Profile.';

  @override
  String get onbLocationPickManual => 'Pick city manually';

  @override
  String get onbLocationRetry => 'Try again';

  @override
  String get onbLocationTitle => 'We Need Your Location';

  @override
  String get onbNameBody =>
      'This name shows on Home and your medal cards. You can leave it blank.';

  @override
  String get onbNameTitle => 'What\'s your warrior name?';

  @override
  String get onbNicknameHint => 'Warrior name (optional — blank: Pejuang)';

  @override
  String get onbNotifAllow => 'Allow Notifications';

  @override
  String get onbNotifBody =>
      'So you never miss it, we send a reminder when prayer time comes. We ask for notification permission plus a battery exemption — without it your phone can silently kill reminders when the app is closed.';

  @override
  String get onbNotifDenied =>
      'Reminders are off. You can turn them on anytime in Profile.';

  @override
  String get onbNotifLoading => 'ENABLING...';

  @override
  String get onbNotifSkip => 'Skip for now';

  @override
  String get onbNotifTitle => 'Adhan Reminders';

  @override
  String get onbProgressLabel => 'Setup';

  @override
  String onbStepOf(String step, String total) {
    return 'Step $step of $total';
  }

  @override
  String get onbXpDemoSemantics => 'Example: Fajr done, +50 XP added';

  @override
  String get prayerAshar => 'Asr';

  @override
  String get prayerDzuhur => 'Dhuhr';

  @override
  String get prayerIsya => 'Isha';

  @override
  String get prayerJumat => 'Friday';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerSubuh => 'Fajr';

  @override
  String get profilAbout => 'About the App';

  @override
  String get profilAboutBody =>
      'Worship is about consistency, not perfection. Muslim Leveling helps you build the habit of the five daily prayers and Quran reading in a way that feels fun — every logged prayer earns XP, every unbroken day grows your streak, and every milestone unlocks a new avatar skin.';

  @override
  String get profilAboutFooter =>
      'Made with prayer for everyone striving for the hereafter.';

  @override
  String get profilAboutOffline =>
      'No server, no ads, no subscription. All your data stays on the device — entirely yours.';

  @override
  String get profilAccountSettings => 'Account Settings';

  @override
  String get profilAlreadyPrayedToday => ', already prayed today';

  @override
  String get profilAndroidNotifSettings => 'Android Notification Settings';

  @override
  String get profilBackupActive => 'Backup active';

  @override
  String get profilBatteryPerm =>
      'Allow \"Unrestricted battery\" so reminders still ring when the app is closed.';

  @override
  String get profilCalendarHeader => 'PRAYER CALENDAR';

  @override
  String get profilChangePhoto => 'Change Photo';

  @override
  String get profilCloudVerifyFailed => 'Cloud verification failed. Try again.';

  @override
  String get profilConnecting => 'CONNECTING...';

  @override
  String get profilContinueGoogle => 'Continue with Google';

  @override
  String get profilCycleExplain =>
      'Turn on during your period so prayer streaks stay safe with no penalty.';

  @override
  String get profilCycleFrozenMeta => 'period mode · streaks frozen';

  @override
  String get profilCycleFrozenSemantics =>
      'Period mode is on, streaks are frozen';

  @override
  String get profilCycleModeShort => 'period mode';

  @override
  String get profilCyclePeriod => 'Menstrual Period';

  @override
  String get profilEditName => 'Edit Name';

  @override
  String get profilEditProfile => 'Edit profile';

  @override
  String get profilEnableReminders => 'Enable reminders';

  @override
  String get profilExactAlarmPerm =>
      '\"Alarms & reminders\" permission is off — reminders may arrive a few minutes late.';

  @override
  String get profilFriday => 'Friday';

  @override
  String get profilFromCamera => 'Take a Photo';

  @override
  String get profilFromGallery => 'Choose from Gallery';

  @override
  String get profilGender => 'Gender';

  @override
  String get profilGenderAkhwat => 'Akhwat';

  @override
  String get profilGenderExplain =>
      'Ikhwan = male, akhwat = female. Used to show or hide the Menstrual Period menu. It is not synced to the cloud.';

  @override
  String get profilGenderIkhwan => 'Ikhwan';

  @override
  String get profilGenderUnset => 'Not set';

  @override
  String get profilHeatmapBody =>
      'The greener, the more complete — 5 shades = 5 obligatory prayers.';

  @override
  String get profilHeatmapHeader => 'OBLIGATORY PRAYER CALENDAR';

  @override
  String get profilHeatmapRow => 'Monthly obligatory prayer heatmap';

  @override
  String get profilHeatmapSemantics => 'Open obligatory prayer calendar';

  @override
  String profilHeroSemantics(String tier) {
    return 'Profile hero — $tier';
  }

  @override
  String profilLevelBadge(int level) {
    return 'LVL $level';
  }

  @override
  String get profilLockerRow => 'Set your active aura and title';

  @override
  String get profilLockerSemantics => 'Open skin locker';

  @override
  String get profilLockerSkin => 'SKIN LOCKER';

  @override
  String get profilLoginCancelled => 'Sign-in cancelled.';

  @override
  String profilLoginFailed(String msg) {
    return '❌ Sign-in failed: $msg';
  }

  @override
  String get profilLoginMerged => '☁️ Signed in — progress merged.';

  @override
  String get profilLoginNotSaved =>
      '⚠️ Signed in, but the backup was not saved.';

  @override
  String get profilLoginOffline =>
      '⚠️ Signed in, but backup is not active yet (offline).';

  @override
  String get profilLogoutConfirm =>
      'Erase local data and return to the first screen?';

  @override
  String get profilLogoutSuccess => 'Signed out.';

  @override
  String get profilMiniLevel => 'Level';

  @override
  String get profilMiniStreak => 'Streak';

  @override
  String get profilMiniXp => 'XP';

  @override
  String get profilModeBalanced => '⚖️ Balanced';

  @override
  String get profilModeBalancedDesc =>
      'Reminders 15 minutes before & at adhan time';

  @override
  String get profilModeFocus => '🎯 Focus';

  @override
  String get profilModeFocusDesc => 'Only the main reminder at adhan time';

  @override
  String get profilModeIntense => '🔥 Intense';

  @override
  String get profilModeIntenseDesc =>
      '30 minutes, 5 minutes before & at adhan time';

  @override
  String get profilNicknameHint => 'Display name';

  @override
  String get profilNotifPermAction =>
      'Notification permission is off. Open Android Notification Settings and allow it.';

  @override
  String get profilNotifPermBody =>
      'Notification permission is off. Turn it on to receive adhan reminders.';

  @override
  String get profilNotifications => 'Notifications';

  @override
  String get profilOemBody =>
      'Turn on \"Autostart\" & \"Unrestricted battery\" in your phone settings so alarms still ring when the app is closed and notifications show on the lock screen.';

  @override
  String get profilOemManual =>
      'Open Settings > Apps > Muslim Leveling > Battery & Autostart manually.';

  @override
  String get profilOemTitle => 'Adhan not showing on Xiaomi/Oppo/Vivo?';

  @override
  String get profilOpenAutostart => 'Open Autostart Settings';

  @override
  String profilPhotoFailed(String msg) {
    return 'Could not take the photo: $msg';
  }

  @override
  String get profilPhotoSection => 'PROFILE PHOTO';

  @override
  String get profilPrivacy => 'Privacy & Data';

  @override
  String get profilPrivacyDeleteBody =>
      'Go to Profile → Sign out to erase all local data at once. Nothing is left on the device.';

  @override
  String get profilPrivacyDeleteTitle => 'Delete any time';

  @override
  String get profilPrivacyLocalBody =>
      'All your data — prayers, Quran reading, stats, and preferences — stays on your phone. No server, no cloud.';

  @override
  String get profilPrivacyLocalTitle => 'Stored on your device';

  @override
  String get profilPrivacyLocationBody =>
      'Location is used once to determine your local prayer schedule. It is never stored or shared.';

  @override
  String get profilPrivacyLocationTitle => 'Private location';

  @override
  String get profilPrivacyTraceBody =>
      'The app never sends your activity to third parties and never tracks your behaviour.';

  @override
  String get profilPrivacyTraceTitle => 'No online trail';

  @override
  String get profilReminderMode => 'Reminder Mode';

  @override
  String get profilReminderTitle => 'Adhan Reminders';

  @override
  String profilRemindersChangeFailed(String msg) {
    return 'Could not change reminders: $msg';
  }

  @override
  String get profilRemindersFailed =>
      'Could not schedule reminders — check notification & alarm permissions in your phone settings.';

  @override
  String get profilRemindersNone =>
      'Mode saved, but no reminders are scheduled — check notification & alarm permissions in your phone settings.';

  @override
  String get profilRemindersOff => 'Adhan reminders turned off';

  @override
  String profilRemindersScheduled(String mode, int n) {
    return 'Adhan reminders on: $mode mode — $n reminders scheduled';
  }

  @override
  String profilRemindersScheduledCount(int n) {
    return '$n adhan reminders scheduled 🔔';
  }

  @override
  String get profilRemovePhoto => 'Remove Photo';

  @override
  String profilSaveFailed(String msg) {
    return 'Could not save: $msg';
  }

  @override
  String get profilSettingsHeader => 'SETTINGS';

  @override
  String profilSettingsOpenFailed(String msg) {
    return 'Could not open notification settings: $msg';
  }

  @override
  String get profilSoundAdzan => '🕌 Adhan';

  @override
  String get profilSoundAdzanDesc => 'Full adhan sound at prayer time';

  @override
  String get profilSoundMode => 'Notification Sound';

  @override
  String get profilSoundNormal => '🔔 Sound';

  @override
  String get profilSoundNormalDesc =>
      'Notification with your phone\'s default sound';

  @override
  String get profilSoundSilent => '🔕 Silent';

  @override
  String get profilSoundSilentDesc => 'Notification only, no sound';

  @override
  String get profilStatsDailyAvg => 'Daily Average';

  @override
  String get profilStatsEmptyBody =>
      'Tick your first prayer — your stats start filling in here.';

  @override
  String get profilStatsEmptyTitle => 'No records yet.';

  @override
  String get profilStatsHeader => 'STATS';

  @override
  String get profilStatsQuranStreak => 'Quran Reading Streak';

  @override
  String profilStatsSince(String date) {
    return 'Since $date';
  }

  @override
  String get profilStatsVerses => 'Quran Verses Read';

  @override
  String get profilStatsWajib => 'Obligatory prayers';

  @override
  String profilStreakBest(int count) {
    return 'best $count';
  }

  @override
  String get profilStreakFreeze => 'frozen';

  @override
  String get profilStreakPerPrayer => 'STREAK PER PRAYER';

  @override
  String profilStreakSemanticsItem(String prayer, int days) {
    return '$prayer $days days';
  }

  @override
  String get profilStreakSemanticsTitle => 'Streak per prayer';

  @override
  String get profilTestAdzan => 'Test Adhan';

  @override
  String get profilTestNotif => 'Test Notification';

  @override
  String profilTestNotifFailed(String msg) {
    return 'Test notification failed: $msg';
  }

  @override
  String get profilTheme => 'App theme';

  @override
  String get profilUnitDays => 'days';

  @override
  String get profilUnitVerses => 'verses';

  @override
  String get profilUnitWeeks => 'weeks';

  @override
  String profilVersion(String version) {
    return 'Version $version';
  }

  @override
  String profilXpToNext(int xp, int level) {
    return '$xp XP to go → LVL $level';
  }

  @override
  String profilXpWithinLevel(int current, int needed) {
    return '$current/$needed XP';
  }

  @override
  String get settingLanguage => 'Language';

  @override
  String get sunnahBadiyahDzuhurDesc => 'Sunnah after Dhuhr';

  @override
  String get sunnahBadiyahDzuhurName => 'Ba\'diyah Dhuhr';

  @override
  String get sunnahBadiyahIsyaDesc => 'Sunnah after Isha';

  @override
  String get sunnahBadiyahIsyaName => 'Ba\'diyah Isha';

  @override
  String get sunnahBadiyahMaghribDesc => 'Sunnah after Maghrib';

  @override
  String get sunnahBadiyahMaghribName => 'Ba\'diyah Maghrib';

  @override
  String get sunnahDhuhaDesc => 'Sunnah encouraged in the morning';

  @override
  String get sunnahDhuhaName => 'Duha';

  @override
  String get sunnahQobliyahAsharDesc => 'Sunnah before Asr';

  @override
  String get sunnahQobliyahAsharName => 'Qabliyah Asr';

  @override
  String get sunnahQobliyahDzuhurDesc => 'Sunnah before Dhuhr';

  @override
  String get sunnahQobliyahDzuhurName => 'Qabliyah Dhuhr';

  @override
  String get sunnahQobliyahSubuhDesc => 'Sunnah before Fajr';

  @override
  String get sunnahQobliyahSubuhName => 'Qabliyah Fajr';

  @override
  String get sunnahTahajjudDesc => 'Night prayer (qiyamul lail)';

  @override
  String get sunnahTahajjudName => 'Tahajjud';

  @override
  String get tabHome => 'Home';

  @override
  String get tabJadwal => 'Schedule';

  @override
  String get tabQuran => 'Quran';

  @override
  String get dlTitle => 'Today\'s Reflection';

  @override
  String get dlBack => 'Back';

  @override
  String dlCiteSurah(String surah, int ayah) {
    return 'Quran $surah:$ayah';
  }

  @override
  String get dlCiteHadis => 'HADITH OF THE DAY';

  @override
  String dlCiteDoa(String name) {
    return 'DUA · $name';
  }

  @override
  String dlCiteUlama(String name) {
    return 'SCHOLAR\'S WORDS · $name';
  }

  @override
  String get dlActListen => 'Listen';

  @override
  String get dlActPause => 'Pause';

  @override
  String get dlActSave => 'Save';

  @override
  String get dlActSaved => 'Saved';

  @override
  String get dlActTafsir => 'Tafsir';

  @override
  String get dlErrLoad =>
      'Today\'s reflection couldn\'t be loaded.\nConnect to the internet and try again.';

  @override
  String get dlErrTafsir => 'Couldn\'t load the tafsir. Try again.';

  @override
  String get dlDone => 'Today\'s reflection complete';

  @override
  String dlProgress(int done, int count) {
    return '$done of $count reflections read · swipe to continue';
  }

  @override
  String get qsTitle => 'Share Verse';

  @override
  String get qsShare => 'Share';

  @override
  String get qsPreparing => 'Preparing…';

  @override
  String get qsErr => 'Couldn\'t share the verse. Try again.';

  @override
  String get qsModeSolid => 'Solid';

  @override
  String get qsModeGradient => 'Gradient';

  @override
  String get qsModeEsthetic => 'Esthetic';

  @override
  String get qsContentArabic => 'Arabic';

  @override
  String get qsContentTranslation => 'Translation';

  @override
  String get quest_subuh_tepat_desc =>
      'Pray Fajr on time (within 30 minutes of the adhan)';

  @override
  String get quest_five_rings_desc => 'Complete all 5/5 prayers today';

  @override
  String get quest_timely_prayers_desc =>
      'Pray on time (within 10 minutes), 3x today';

  @override
  String get quest_dhuha_before_dzuhur_desc => 'Pray Dhuha before Dhuhr';

  @override
  String get quest_rawatib_two_desc => 'Pray 2 rawatib today';

  @override
  String get quest_dzuhur_tepat_desc =>
      'Pray Dhuhr on time (within 30 minutes of the adhan)';

  @override
  String get quest_maghrib_tepat_desc =>
      'Pray Maghrib on time (within 30 minutes of the adhan)';

  @override
  String get quest_isya_hadir_desc => 'Don\'t miss Isha tonight';

  @override
  String get quest_any_three_desc =>
      'Complete 3 obligatory prayers today (any of them)';

  @override
  String get quest_subuh_isya_desc => 'Lock both ends of the day: Fajr + Isha';

  @override
  String get quest_one_sunnah_desc => 'Pray 1 sunnah prayer today, any kind';

  @override
  String get quest_rawatib_one_desc =>
      'Pray 1 rawatib today (qobliyah/ba\'diyah, either)';

  @override
  String get quest_zikir_33_desc => 'Dhikr 33x using the Daily Dhikr button';

  @override
  String quest_zikir_goal_desc(Object goal) {
    return 'Finish Daily Dhikr up to $goal';
  }

  @override
  String get quest_quran_10ayat_desc => 'Read 10 Quran verses today';

  @override
  String get quest_hadis_3_desc => 'Read 3 hadith today (≥5 sec each)';

  @override
  String get quest_dzikir_33_subuh_desc =>
      'Dhikr Subhanallah 33x (tasbih after prayer)';

  @override
  String get quest_quran_1halaman_desc =>
      'Read 20 Quran verses (≈1 mushaf page)';

  @override
  String get quest_hadis_5_desc => 'Read 5 hadith today (≥5 sec each)';

  @override
  String get quest_berjamaah_1_desc =>
      'Pray in congregation once today (pick the jamaah bonus when claiming)';

  @override
  String get quest_hero_streak_7_desc =>
      'Keep your 7-day Hero Streak alive! 🔥';

  @override
  String get questCopy_sholat_1 =>
      'You were probably busy, but you made time anyway. Good job.';

  @override
  String get questCopy_sholat_2 =>
      'The adhan ended and you moved right away. Solid.';

  @override
  String get questCopy_sholat_3 =>
      'On time today. One good thing you kept safe.';

  @override
  String get questCopy_sholat_4 =>
      'Tired is still tired. But you showed up anyway. 🤍';

  @override
  String get questCopy_sunnah_1 =>
      'Not required, yet you chose to do it anyway.';

  @override
  String get questCopy_sunnah_2 =>
      'Nobody forced you. You chose to come on your own.';

  @override
  String get questCopy_sunnah_3 => 'Two rakaat today. Small, but it counts.';

  @override
  String get questCopy_sunnah_4 =>
      'Slowly — this is the kind of habit you are building.';

  @override
  String get questCopy_zikir_1 =>
      'In the middle of a loud day, you still made room to remember Allah.';

  @override
  String get questCopy_zikir_2 =>
      'Pause for a moment. Breathe. Remember Allah.';

  @override
  String get questCopy_zikir_3 =>
      'Whatever is on your mind, you still made time for dhikr.';

  @override
  String get questCopy_zikir_4 =>
      'Dhikr done. May your heart feel a little lighter. 🤍';

  @override
  String get questCopy_quran_1 =>
      'One verse today. Slowly — what matters is that you keep going.';

  @override
  String get questCopy_quran_2 =>
      'You opened the Quran again today. Good to see.';

  @override
  String get questCopy_quran_3 =>
      'It does not have to be much. One page is still a step.';

  @override
  String get questCopy_quran_4 => 'One page down. Pick it up again tomorrow.';

  @override
  String get questCopy_hadis_1 =>
      'Today you made time to learn from the words of the Prophet.';

  @override
  String get questCopy_hadis_2 =>
      'You read a hadith today. May something from it stay with you.';

  @override
  String get questCopy_hadis_3 =>
      'Found one that hits home? Save it. You may need the reminder again.';

  @override
  String get questCopy_hadis_4 =>
      'A little learning today, may it carry you into tomorrow.';

  @override
  String get questCopy_fiveRings_1 =>
      'Fajr, Dhuhr, Asr, Maghrib, Isha. You showed up for every one today.';

  @override
  String get questCopy_fiveRings_2 =>
      'All five done. Alhamdulillah, you kept them today.';

  @override
  String get questCopy_fiveRings_3 => 'One day, five prayers. Complete. 🤍';

  @override
  String get questCopy_fiveRings_4 =>
      'Today closed well. Tomorrow we start again.';

  @override
  String get questCopy_subuhIsya_1 =>
      'You kept Fajr, you kept Isha. Alhamdulillah.';

  @override
  String get questCopy_subuhIsya_2 =>
      'From the start of the day to the end, you still made time.';

  @override
  String get questCopy_subuhIsya_3 => 'You kept these two today. Good job.';

  @override
  String get questCopy_subuhIsya_4 =>
      'You kept Fajr and Isha today. Keep it going tomorrow.';

  @override
  String get questHaid_1 => 'Today is for resting. Stay strong. 🤍';

  @override
  String get questHaid_2 =>
      'It is okay to pause. You are still part of this journey.';

  @override
  String get questHaid_3 =>
      'You do not need to chase this quest today. Take care of yourself and stay close to Allah.';

  @override
  String get questHaid_4 => 'The quest can wait. Your journey still continues.';

  @override
  String get questClaimAlhamdulillah => 'Alhamdulillah';

  @override
  String get questClaimContinue => 'Continue';

  @override
  String sqCombinedTitle(Object count) {
    return 'Alhamdulillah, $count Quests Done!';
  }

  @override
  String get sqCombinedDesc =>
      'All daily quests finished today. May you stay consistent!';

  @override
  String get sqZikirTitle => 'Dhikr 100x Done!';

  @override
  String get sqZikirDesc => 'Consistent in dhikr today. Keep it up!';

  @override
  String get sqTilawahTitle => 'Read 10 Quran Verses — Done!';

  @override
  String get sqTilawahDesc => 'Recitation done for today. Continue tomorrow!';

  @override
  String get sqHadisTitle => 'Study 5 Hadith — Done!';

  @override
  String get sqHadisDesc => 'Five new hadith read today. Keep learning!';

  @override
  String get sqBadgeCombined => 'ALL DAILY QUESTS DONE';

  @override
  String get sqBadgeSingle => 'QUEST COMPLETE';

  @override
  String get sqButton => 'NICE!';

  @override
  String get sqBarrierLabel => 'side quest complete';

  @override
  String sqSemantics(Object desc, Object title, Object xp) {
    return '$title. $desc. Bonus $xp XP.';
  }

  @override
  String get sqSourceZikir => 'Dhikr 100x';

  @override
  String get sqSourceTilawah => 'Read Quran';

  @override
  String get sqSourceHadis => 'Study Hadith';

  @override
  String get naikTitle => 'LEVEL UP!';

  @override
  String get naikBadgeSemantics => 'Golden crescent, the mark of a level up';

  @override
  String naikReached(Object level, Object rank) {
    return 'Masha Allah, you reached $rank — Level $level';
  }

  @override
  String naikFrom(Object source) {
    return 'from $source';
  }

  @override
  String get naikBack => 'BACK';

  @override
  String naikRewardSemanticsFull(Object level, Object rank, Object xp) {
    return 'Reward: +$xp XP, level $level, new title $rank';
  }

  @override
  String naikRewardSemanticsLevel(Object level, Object rank) {
    return 'Reward: level $level, new title $rank';
  }

  @override
  String get naikChipLevelJumps => 'Jump';

  @override
  String get naikChipLevel => 'Level';

  @override
  String get naikChipRank => 'NEW TITLE';

  @override
  String naikProgressSemantics(Object have, Object need, Object next) {
    return 'Toward level $next: $have of $need XP';
  }

  @override
  String get naikClosing =>
      'Barakallah — stay consistent, the next level is waiting ✨';

  @override
  String naikLevelLabel(Object level) {
    return 'Level $level';
  }

  @override
  String get uq_ulama_ilmu_itu_lebih_baik_daripada_harta_ilmu =>
      'Knowledge is better than wealth. Knowledge guards you, while you are the one guarding wealth.';

  @override
  String get uq_ulama_orang_berilmu_itu_hidup_walau_sudah_wafa =>
      'The learned live on even after death, while the ignorant are dead even while alive.';

  @override
  String get uq_ulama_jangan_melihat_siapa_yang_berbicara_tapi =>
      'Do not look at who is speaking, but look at what he says.';

  @override
  String get uq_ulama_nilai_seseorang_diukur_dari_apa_yang_dia =>
      'A person’s worth is measured by what he pursues with sincerity.';

  @override
  String get uq_ulama_hisablah_dirimu_sendiri_sebelum_kamu_dih =>
      'Hold yourself to account before you are held to account, and weigh your deeds before they are weighed.';

  @override
  String get uq_ulama_aku_tidak_pernah_menyesal_karena_diam_ta =>
      'I never regretted silence, but I often regretted speaking.';

  @override
  String get uq_ulama_kehormatanmu_adalah_agamamu_dan_harga_di =>
      'Your honour is your religion, and your dignity is your character.';

  @override
  String get uq_ulama_waktu_itu_seperti_pedang_kalau_kamu_tida =>
      'Time is like a sword — if you do not cut it, it cuts you.';

  @override
  String get uq_ulama_ilmu_bukanlah_yang_dihafal_tetapi_ilmu_a =>
      'Knowledge is not what is memorised, but what brings benefit.';

  @override
  String get uq_ulama_ilmu_itu_cahaya_dan_cahaya_allah_tidak_a =>
      'Knowledge is light, and the light of Allah does not enter the heart of a disobedient person.';

  @override
  String get uq_ulama_barangsiapa_tidak_tahan_lelahnya_belajar =>
      'Whoever cannot endure the fatigue of learning must endure the pain of ignorance.';

  @override
  String get uq_ulama_aku_tidak_berhenti_belajar_sejak_aku_men =>
      'I have never stopped learning since I realised how ignorant I still am.';

  @override
  String get uq_ulama_aku_tidak_memberi_fatwa_sampai_aku_berta =>
      'I do not give a fatwa until I have asked someone more knowledgeable than me.';

  @override
  String get uq_ulama_manusia_lebih_membutuhkan_ilmu_daripada =>
      'People need knowledge more than they need food and drink.';

  @override
  String get uq_ulama_aku_tidak_menulis_satu_hadis_pun_melaink =>
      'I did not write down a single hadith without first practising what it says.';

  @override
  String get uq_ulama_ilmu_tanpa_amal_seperti_pohon_tanpa_buah =>
      'Knowledge without practice is like a tree without fruit.';

  @override
  String get uq_ulama_anak_adam_hanyalah_kumpulan_hari_hari_se =>
      'The son of Adam is nothing but a bundle of days. Each day that passes takes part of him with it.';

  @override
  String get uq_ulama_barangsiapa_mengenal_allah_dia_akan_menc =>
      'Whoever knows Allah will love Him; and whoever loves Him will keep busy with Him.';

  @override
  String get uq_ulama_sesungguhnya_dunia_ini_hanya_sebentar_ja =>
      'This world is only brief, so let us not work for it as though it lasts forever.';

  @override
  String get uq_ulama_jadikan_dunia_ini_cukup_berada_di_tangan =>
      'Let this world rest in your hand, and never let it enter your heart.';

  @override
  String get uq_ulama_perbanyaklah_mengingat_mati_karena_itu_m =>
      'Remember death often, for it erases the love of this world.';

  @override
  String get uq_ulama_aku_tidak_mengobati_sesuatu_yang_lebih_b =>
      'I have never had to remedy anything heavier than my own intention.';

  @override
  String get uq_ulama_ilmu_itu_untuk_diamalkan_kalau_tidak_dia =>
      'Knowledge is meant to be practised; if it is not, it leaves.';

  @override
  String get uq_ulama_diam_adalah_hikmah_tapi_sedikit_orang_ya =>
      'Silence is wisdom, but few are willing to practise it.';

  @override
  String get uq_ulama_sebaik_baik_hati_adalah_yang_dipenuhi_ra =>
      'The best heart is the one filled with fear and hope of Allah.';

  @override
  String get uq_ulama_tidak_ada_yang_lebih_bermanfaat_bagi_hat =>
      'Nothing benefits the heart more than reading the Quran with reflection.';

  @override
  String get uq_ulama_hati_bisa_sakit_seperti_badan_sakit_dan =>
      'The heart can fall ill as the body does, and its cure is seeking forgiveness.';

  @override
  String get uq_ulama_kesabaran_itu_cahaya_dengannya_jalan_yan =>
      'Patience is light — with it a narrow road feels wide.';

  @override
  String get uq_ulama_ilmu_tanpa_amal_adalah_sia_sia_dan_amal =>
      'Knowledge without practice is wasted, and practice without knowledge is incomplete.';

  @override
  String get uq_ulama_kebahagiaan_bukan_pada_banyaknya_harta_t =>
      'Happiness is not in having much, but in having a spacious heart.';

  @override
  String get uq_ulama_siapa_yang_menuntut_ilmu_semata_untuk_me =>
      'Whoever seeks knowledge only to boast, his knowledge will become a case against him.';

  @override
  String get uq_ulama_jaga_hatimu_karena_allah_melihat_bukan_h =>
      'Guard your heart, for Allah sees not only your deeds but what lies within them.';

  @override
  String get uq_month_1 => 'Muharram';

  @override
  String get uq_month_2 => 'Safar';

  @override
  String get uq_month_3 => 'Rabi al-Awwal';

  @override
  String get uq_month_4 => 'Rabi al-Thani';

  @override
  String get uq_month_5 => 'Jumada al-Awwal';

  @override
  String get uq_month_6 => 'Jumada al-Thani';

  @override
  String get uq_month_7 => 'Rajab';

  @override
  String get uq_month_8 => 'Shaban';

  @override
  String get uq_month_9 => 'Ramadan';

  @override
  String get uq_month_10 => 'Shawwal';

  @override
  String get uq_month_11 => 'Dhu al-Qadah';

  @override
  String get uq_month_12 => 'Dhu al-Hijjah';

  @override
  String get uq_ev_1_1 => 'Hijri New Year';

  @override
  String get uq_ev_1_10 => 'Day of Ashura';

  @override
  String get uq_ev_3_12 => 'Mawlid al-Nabi';

  @override
  String get uq_ev_7_27 => 'Isra and Mi’raj';

  @override
  String get uq_ev_8_15 => 'Mid-Shaban';

  @override
  String get uq_ev_9_1 => 'Start of Ramadan';

  @override
  String get uq_ev_9_17 => 'Nuzul al-Quran';

  @override
  String get uq_ev_10_1 => 'Eid al-Fitr';

  @override
  String get uq_ev_12_9 => 'Day of Arafah';

  @override
  String get uq_ev_12_10 => 'Eid al-Adha';

  @override
  String get hjHariPentingTitle => 'Important Islamic Dates';

  @override
  String get hjHariPentingEmpty => 'Could not load the important dates.';

  @override
  String get hjHariPentingSemantics =>
      'Hijri date, opens Important Islamic Dates';

  @override
  String get hjToday => 'Today!';

  @override
  String get hjPassed => 'Passed';

  @override
  String hjDaysLeft(Object days) {
    return '$days days left';
  }

  @override
  String get hjHijriSuffix => 'AH';

  @override
  String get qiblaCalibrationHint =>
      '💡 Compass calibration: rotate your device in a figure-8 motion a few times for best accuracy.';

  @override
  String get qiblaCompassLabel => 'QIBLA COMPASS';

  @override
  String get qiblaTitle => 'Qibla Direction';

  @override
  String get qiblaAligned => '🎯 Locked! Hold this position';

  @override
  String qiblaTurnRight(String degrees) {
    return 'Turn $degrees° right →';
  }

  @override
  String qiblaTurnLeft(String degrees) {
    return '← Turn $degrees° left';
  }

  @override
  String get qiblaNoSensorTitle => 'Compass Sensor Unavailable';

  @override
  String get qiblaNoSensorBody =>
      'This device has no magnetometer sensor. Use the direction guide below instead.';

  @override
  String get qiblaAlignedTitle => 'Facing the Qibla!';

  @override
  String get qiblaAimTitle => 'Point Your Device at the Qibla';

  @override
  String get qiblaStatTitle => 'QIBLA DIRECTION';

  @override
  String get qiblaDistanceTitle => 'DISTANCE TO KAABA';

  @override
  String qiblaCityDistance(String city, String km) {
    return '📍 $city • $km km to the Kaaba';
  }

  @override
  String qiblaCityBearing(String city) {
    return 'Qibla direction from $city:';
  }

  @override
  String qiblaNorthDegrees(String degrees) {
    return '$degrees° from North';
  }

  @override
  String qiblaTurnInstruction(String degrees) {
    return 'Rotate your device $degrees° clockwise from north to face the qibla.';
  }

  @override
  String qiblaOffset(String degrees) {
    return '$degrees° off from the qibla';
  }

  @override
  String get dzResetTitle => 'Reset counter?';

  @override
  String dzResetBody(String item) {
    return 'The \"$item\" counter will be reset to 0.\\nToday\'s dzikir total still counts.';
  }

  @override
  String get dzResetCancel => 'CANCEL';

  @override
  String get dzResetConfirm => 'RESET';

  @override
  String get dzTapHint => 'Tap anywhere to do dzikir';

  @override
  String dzToday(String total) {
    return 'Today: $total';
  }

  @override
  String get dzVibrateOff => 'Turn off vibration';

  @override
  String get dzVibrateOn => 'Turn on vibration';

  @override
  String get dzResetThis => 'Reset this counter';

  @override
  String get dzTargetDone => 'TARGET REACHED';

  @override
  String get hdEmptyPage => 'No hadith on this page.';

  @override
  String get hdLoadFailed => 'Failed to load hadith.';

  @override
  String get hdLoadFailedRetry => 'Failed to load hadith. Try again.';

  @override
  String get hdSearchFailed => 'Failed to search hadith.';

  @override
  String get hdRandomFailed => 'Failed to fetch a random hadith. Try again.';

  @override
  String get hdSearchHint => 'Search hadith…';

  @override
  String hdSearchFound(String total) {
    return '$total hadith found';
  }

  @override
  String get hdSearchEmpty => 'No hadith found.';

  @override
  String get hdBackToList => 'Back to list';

  @override
  String get hdLoadMore => 'Load More';

  @override
  String hdNumber(String id) {
    return 'no. $id';
  }

  @override
  String hdDetailTitle(String id) {
    return 'Hadith no. $id';
  }

  @override
  String get dzTransSubhanallah => 'Glorified is Allah';

  @override
  String get dzTransAlhamdulillah => 'All praise is due to Allah';

  @override
  String get dzTransAllahuakbar => 'Allah is the Greatest';

  @override
  String get dzTransAstaghfirullah => 'I seek forgiveness from Allah';

  @override
  String get dzTransHawla => 'There is no power or strength except with Allah';

  @override
  String get blModulNotFound => 'Module not found';

  @override
  String get blModulDone => 'Module Completed!';

  @override
  String get blKnowledgeUp => 'Your knowledge has increased.';

  @override
  String get blMinScore70 =>
      'A minimum score of 70% is required to pass. Please try again!';

  @override
  String get blReadAgain =>
      'Read the article again, then try the quiz again. You can do it!';

  @override
  String get blBackToHub => 'Back to Hub';

  @override
  String get qdArabicSize => 'Arabic text size';

  @override
  String get qdTransSize => 'Translation size';

  @override
  String get qdLatinHint => 'Transliteration to assist in reading Arabic';

  @override
  String get qdTajwidColors => 'Tajweed colors';

  @override
  String get qdTafsirMuyassar =>
      'Tafsir Muyassar (concise, easy to understand)';

  @override
  String get qdTafsirKemenag => 'Tafsir Kemenag (comprehensive)';

  @override
  String get ppUnlockSkins => 'Unlock all premium skins';

  @override
  String get ppActivateDev => 'Activate Pro (dev)';

  @override
  String get deExpTitle => 'XP EARNED!';

  @override
  String get bqModulNotFound => 'Module not found';

  @override
  String get bqQuizUnavailable => 'Quiz is not yet available';

  @override
  String get bqNotYetRight => 'Incorrect';

  @override
  String get qpPrevAyah => 'Previous Ayah';

  @override
  String get qpNextAyah => 'Next Ayah';

  @override
  String get qpMurrotalSettings => 'Murottal settings';

  @override
  String get qpbRepeatRange => 'Repeat range';

  @override
  String get qpbSleepTimer => 'Sleep timer';

  @override
  String get qpbEndOfSurah => 'End of Surah';

  @override
  String get qbNoBookmark => 'No bookmarks yet';

  @override
  String get qbDeleteBookmark => 'Delete bookmark';

  @override
  String get qacDeleteBookmark => 'Delete bookmark';

  @override
  String get phPrevMonth => 'Previous month';

  @override
  String get phNextMonth => 'Next month';

  @override
  String get clProLocked => 'Pro locked';

  @override
  String get clCompleteQuest =>
      'Complete daily quests to unlock skins from the Daily Chest.';

  @override
  String get qdTajwidLegend => 'Red=Ghunnah, Blue=Qalqalah/Idgham, Green=Mad';

  @override
  String get ppProPitch =>
      'Exclusive shields, auras, and titles. A new style for your avatar — without affecting your XP, streak, or rank.';

  @override
  String deQuizDone(String moduleTitle) {
    return 'You completed the $moduleTitle quiz!';
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
    return 'QUESTION $current/$total';
  }

  @override
  String qbSurahName(int number) {
    return 'Surah $number';
  }

  @override
  String qacAyahNumber(int number) {
    return 'Ayah $number';
  }

  @override
  String get jdLoadFailed =>
      'Failed to load schedule. Please check your connection.';

  @override
  String get jdAlreadyLogged => '✓ LOGGED';

  @override
  String get jdTesSuara => 'Sound test';

  @override
  String get jdAdzanDownloadFailed =>
      'Failed to download Adhan audio. Please check your connection and try again.';

  @override
  String get qtLoadFailed => 'Failed to load Al-Qur\'an data';

  @override
  String get qtSurahNotFound => 'Surah not found';

  @override
  String get qtContinueReading => 'Continue reading';

  @override
  String get spTagline => 'Level up your faith, level up your life';

  @override
  String get spLoading => 'LOADING WARRIOR DATA...';

  @override
  String get btSubtitle => 'Increase your knowledge, earn more XP.';

  @override
  String get doaLoadFailed => 'Failed to load supplication.';

  @override
  String get taProSignature => 'Pro signature finish';

  @override
  String get tpSelected => 'Theme selected';

  @override
  String get qrDisplaySettings => 'Display settings';

  @override
  String get jdSoundFollowGlobal => 'Follow global';

  @override
  String jdNotifFor(String prayer) {
    return 'Notification for $prayer';
  }

  @override
  String get jdSoundSilent => 'Silent — no sound';

  @override
  String get jdSoundNormal => 'Sound — standard phone notification';

  @override
  String get jdSoundAdzan => 'Adhan — full Adhan sound';

  @override
  String get jdSoundGlobalOption => 'Follow global settings';

  @override
  String jdFootnote(String city) {
    return 'Schedule from Ministry of Religious Affairs (KEMENAG RI) data via api.myquran.com for $city. Automatically updated when the tab is opened; tap the city name above to change location.';
  }

  @override
  String qtSearchEmpty(String example) {
    return 'No results found. Try another word in the translation, or type the Surah name + Ayah number — e.g., $example.';
  }

  @override
  String qtOpenSurah(String surah) {
    return 'Open Surah $surah';
  }

  @override
  String qtAyahOf(int ayah, int total) {
    return 'Ayah $ayah of $total';
  }

  @override
  String qtSurahAyah(String surah, int ayah) {
    return 'Surah $surah · Ayah $ayah';
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
    return 'Tafsir of Ayah $ayah';
  }

  @override
  String get locFailureDisabled =>
      'Please enable device location services and try again.';

  @override
  String get locFailureDenied =>
      'Please grant location access to use your current location.';

  @override
  String get locFailureDeniedForever =>
      'Location permission is blocked. Please open Settings to enable it.';

  @override
  String get locFailureTimeout =>
      'Location request timed out. Please try again in an open area.';

  @override
  String get locFailureLookup =>
      'The city could not be found. Please check your connection or select a city manually.';

  @override
  String get authNoIdToken =>
      'Google did not return an idToken. Please check the SHA-1 fingerprint in the Firebase Console.';

  @override
  String get authEmptyUser => 'Firebase Auth failed — user is empty.';

  @override
  String get authDevError10 =>
      'Google DEVELOPER_ERROR (10): The SHA-1 fingerprint is not registered in the Firebase Console.';

  @override
  String get authMisconfigured =>
      'Google Sign-In is misconfigured. Please check the OAuth consent screen and SHA-1 fingerprint.';

  @override
  String get authNetworkError =>
      'A network error occurred during Google Sign-In.';

  @override
  String get authCredInvalid => 'Firebase Auth failed to validate credentials.';

  @override
  String get authNotEnabled =>
      'Google Sign-In is not enabled in the Firebase Console.';

  @override
  String get authEmailInUse =>
      'This email address is already registered using another sign-in method.';

  @override
  String get notifModeFokus =>
      'Focus Mode is active! Reminders will only be sent at the start of prayer times.';

  @override
  String get notifModeSeimbang =>
      'Balanced Mode is active! Reminders for all obligatory prayers will be sent 15 minutes before the call to prayer.';

  @override
  String get notifModeIntensif =>
      'Intensive Mode is active! You will be reminded 30 minutes and 5 minutes before prayer. Keep up your streak! 🔥';

  @override
  String get notifReady => 'Muslim Leveling notifications are ready! 🔔';

  @override
  String get notifTestBody =>
      'If you hear the call to prayer, your notifications are ready! If not, please check your device\'s alarm volume.';

  @override
  String get notifTestTitle => '🕌 Call to Prayer Sound Test';

  @override
  String get notifChannelReminder => 'Prayer time reminder notifications';

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
    return '🕌 Time for $prayer Prayer';
  }

  @override
  String notifBodyImsak(String loc) {
    return 'It is now Imsak$loc. Please stop eating and drinking. 🌙';
  }

  @override
  String notifBodyTerbit(String loc) {
    return 'Sunrise$loc. Fajr time has ended, and Dhuha has begun. ☀️';
  }

  @override
  String notifBody30min(String prayer, String loc) {
    return '30 minutes remaining until $prayer prayer$loc. Please prepare yourself. 🔥';
  }

  @override
  String notifBody5min(String prayer, String loc) {
    return '5 minutes remaining until $prayer prayer$loc. Please get ready. ⚡';
  }

  @override
  String notifBody15min(String prayer, String loc) {
    return '15 minutes remaining until $prayer prayer$loc. Please prepare yourself. 🌙';
  }

  @override
  String notifBodyNow(String prayer, String loc) {
    return 'It is now time for $prayer prayer$loc. Let\'s maintain your streak! 🔥';
  }

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerTerbit => 'Sunrise';

  @override
  String notifLocSuffix(String city) {
    return ' in $city';
  }

  @override
  String blClaimXp(int xp) {
    return 'CLAIM +$xp XP';
  }

  @override
  String get blNotPassed => 'Not Passed';

  @override
  String get jdPageTitle => 'Prayer Times';

  @override
  String get jdSearchCity => 'Search City';

  @override
  String get jdNextPrayer => 'NEXT PRAYER';

  @override
  String get jdTodaySchedule => 'TODAY\'S SCHEDULE';

  @override
  String get jdAdzanSoundTitle => 'ADHAN SOUND';

  @override
  String get jdLoadingShort => 'loading...';

  @override
  String jdCountdownHm(int hours, int minutes) {
    return '${hours}h ${minutes}m left';
  }

  @override
  String jdCountdownM(int minutes) {
    return '${minutes}m left';
  }

  @override
  String get jdCountdownTomorrow => 'tomorrow';

  @override
  String get jdRegionTitle => 'Select Region';

  @override
  String get jdRegionIndonesia => 'Indonesia';

  @override
  String get jdRegionAbroad => 'Abroad';

  @override
  String get jdAbroadSearchHint => 'Type the name of a city abroad...';

  @override
  String get jdAbroadEmpty =>
      'City not found. Enter the name in English — e.g., London.';

  @override
  String jdFootnoteAbroad(String city) {
    return 'Schedule from Aladhan for $city. The calculation method follows this city\'s country. Automatically updated when the tab is opened; tap the city name above to change the location.';
  }

  @override
  String get commonRetry => 'Retry';

  @override
  String qtSearchHint(String example) {
    return 'Search surah, word, or verse — e.g., $example';
  }

  @override
  String qtVerseHits(int count) {
    return '$count verses found in translation';
  }

  @override
  String qtVerseHitsTruncated(int count) {
    return '$count+ verses found — refine your search';
  }

  @override
  String get qtBookmarkTooltip => 'Bookmark verse';

  @override
  String get qtSubtitle => '114 surahs · 30 juz';

  @override
  String get qbTitle => 'Bookmarks';

  @override
  String get qbEmptyHint =>
      'Tap the bookmark icon on the verses you wish to save.';

  @override
  String get qacPlayFromHere => 'Play from this verse';

  @override
  String get qrBasmalah =>
      'In the name of Allah, the Most Gracious, the Most Merciful';

  @override
  String get qs_meaning_1 => 'The Opening';

  @override
  String get qs_meaning_2 => 'The Cow';

  @override
  String get qs_meaning_3 => 'The Family of Imran';

  @override
  String get qs_meaning_4 => 'The Women';

  @override
  String get qs_meaning_5 => 'The Table Spread';

  @override
  String get qs_meaning_6 => 'The Cattle';

  @override
  String get qs_meaning_7 => 'The Heights';

  @override
  String get qs_meaning_8 => 'The Spoils of War';

  @override
  String get qs_meaning_9 => 'The Repentance';

  @override
  String get qs_meaning_10 => 'Jonah';

  @override
  String get qs_meaning_11 => 'Hud';

  @override
  String get qs_meaning_12 => 'Joseph';

  @override
  String get qs_meaning_13 => 'The Thunder';

  @override
  String get qs_meaning_14 => 'Abraham';

  @override
  String get qs_meaning_15 => 'The Rocky Tract';

  @override
  String get qs_meaning_16 => 'The Bee';

  @override
  String get qs_meaning_17 => 'The Night Journey';

  @override
  String get qs_meaning_18 => 'The Cave';

  @override
  String get qs_meaning_19 => 'Mary';

  @override
  String get qs_meaning_20 => 'Ta-Ha';

  @override
  String get qs_meaning_21 => 'The Prophets';

  @override
  String get qs_meaning_22 => 'The Pilgrimage';

  @override
  String get qs_meaning_23 => 'The Believers';

  @override
  String get qs_meaning_24 => 'The Light';

  @override
  String get qs_meaning_25 => 'The Criterion';

  @override
  String get qs_meaning_26 => 'The Poets';

  @override
  String get qs_meaning_27 => 'The Ants';

  @override
  String get qs_meaning_28 => 'The Stories';

  @override
  String get qs_meaning_29 => 'The Spider';

  @override
  String get qs_meaning_30 => 'The Romans';

  @override
  String get qs_meaning_31 => 'Luqman';

  @override
  String get qs_meaning_32 => 'The Prostration';

  @override
  String get qs_meaning_33 => 'The Combined Forces';

  @override
  String get qs_meaning_34 => 'Sheba';

  @override
  String get qs_meaning_35 => 'The Originator';

  @override
  String get qs_meaning_36 => 'Ya-Sin';

  @override
  String get qs_meaning_37 => 'Those Ranged in Ranks';

  @override
  String get qs_meaning_38 => 'Sad';

  @override
  String get qs_meaning_39 => 'The Crowds';

  @override
  String get qs_meaning_40 => 'The Forgiver';

  @override
  String get qs_meaning_41 => 'Explained in Detail';

  @override
  String get qs_meaning_42 => 'The Consultation';

  @override
  String get qs_meaning_43 => 'The Ornaments of Gold';

  @override
  String get qs_meaning_44 => 'The Smoke';

  @override
  String get qs_meaning_45 => 'The Kneeling';

  @override
  String get qs_meaning_46 => 'The Wind-Curved Sandhills';

  @override
  String get qs_meaning_47 => 'Muhammad';

  @override
  String get qs_meaning_48 => 'The Victory';

  @override
  String get qs_meaning_49 => 'The Rooms';

  @override
  String get qs_meaning_50 => 'Qaf';

  @override
  String get qs_meaning_51 => 'The Winnowing Winds';

  @override
  String get qs_meaning_52 => 'The Mount';

  @override
  String get qs_meaning_53 => 'The Star';

  @override
  String get qs_meaning_54 => 'The Moon';

  @override
  String get qs_meaning_55 => 'The Beneficent';

  @override
  String get qs_meaning_56 => 'The Inevitable';

  @override
  String get qs_meaning_57 => 'The Iron';

  @override
  String get qs_meaning_58 => 'The Pleading Woman';

  @override
  String get qs_meaning_59 => 'The Exile';

  @override
  String get qs_meaning_60 => 'The Examined One';

  @override
  String get qs_meaning_61 => 'The Ranks';

  @override
  String get qs_meaning_62 => 'Friday';

  @override
  String get qs_meaning_63 => 'The Hypocrites';

  @override
  String get qs_meaning_64 => 'The Mutual Disillusion';

  @override
  String get qs_meaning_65 => 'The Divorce';

  @override
  String get qs_meaning_66 => 'The Prohibition';

  @override
  String get qs_meaning_67 => 'The Sovereignty';

  @override
  String get qs_meaning_68 => 'The Pen';

  @override
  String get qs_meaning_69 => 'The Reality';

  @override
  String get qs_meaning_70 => 'The Ascending Stairways';

  @override
  String get qs_meaning_71 => 'Noah';

  @override
  String get qs_meaning_72 => 'The Jinn';

  @override
  String get qs_meaning_73 => 'The Enshrouded One';

  @override
  String get qs_meaning_74 => 'The Cloaked One';

  @override
  String get qs_meaning_75 => 'The Resurrection';

  @override
  String get qs_meaning_76 => 'Man';

  @override
  String get qs_meaning_77 => 'The Emissaries';

  @override
  String get qs_meaning_78 => 'The Great News';

  @override
  String get qs_meaning_79 => 'Those Who Drag Forth';

  @override
  String get qs_meaning_80 => 'He Frowned';

  @override
  String get qs_meaning_81 => 'The Overthrowing';

  @override
  String get qs_meaning_82 => 'The Cleaving';

  @override
  String get qs_meaning_83 => 'The Defrauders';

  @override
  String get qs_meaning_84 => 'The Sundering';

  @override
  String get qs_meaning_85 => 'The Constellations';

  @override
  String get qs_meaning_86 => 'The Nightcomer';

  @override
  String get qs_meaning_87 => 'The Most High';

  @override
  String get qs_meaning_88 => 'The Overwhelming';

  @override
  String get qs_meaning_89 => 'The Dawn';

  @override
  String get qs_meaning_90 => 'The City';

  @override
  String get qs_meaning_91 => 'The Sun';

  @override
  String get qs_meaning_92 => 'The Night';

  @override
  String get qs_meaning_93 => 'The Morning Hours';

  @override
  String get qs_meaning_94 => 'The Relief';

  @override
  String get qs_meaning_95 => 'The Fig';

  @override
  String get qs_meaning_96 => 'The Clot';

  @override
  String get qs_meaning_97 => 'The Power';

  @override
  String get qs_meaning_98 => 'The Clear Proof';

  @override
  String get qs_meaning_99 => 'The Earthquake';

  @override
  String get qs_meaning_100 => 'The Chargers';

  @override
  String get qs_meaning_101 => 'The Calamity';

  @override
  String get qs_meaning_102 => 'The Rivalry in World Increase';

  @override
  String get qs_meaning_103 => 'The Time';

  @override
  String get qs_meaning_104 => 'The Slanderer';

  @override
  String get qs_meaning_105 => 'The Elephant';

  @override
  String get qs_meaning_106 => 'Quraysh';

  @override
  String get qs_meaning_107 => 'The Small Kindnesses';

  @override
  String get qs_meaning_108 => 'Abundance';

  @override
  String get qs_meaning_109 => 'The Disbelievers';

  @override
  String get qs_meaning_110 => 'The Help';

  @override
  String get qs_meaning_111 => 'The Flame';

  @override
  String get qs_meaning_112 => 'Sincerity';

  @override
  String get qs_meaning_113 => 'The Daybreak';

  @override
  String get qs_meaning_114 => 'Mankind';

  @override
  String get qsRevelationMeccan => 'Meccan';

  @override
  String get qsRevelationMedinan => 'Medinan';

  @override
  String qtContinueReadingDetail(String surah, int ayah) {
    return 'Continue reading $surah ayah $ayah';
  }

  @override
  String qtOpenSurahAyah(String surah, int ayah) {
    return 'Open $surah ayah $ayah';
  }

  @override
  String get qpbAyahRange => 'Ayah range';

  @override
  String get qpbFrom => 'From';

  @override
  String get qpbTo => 'To';

  @override
  String qpbRepeatRangeDetail(int from, int to) {
    return 'Return to ayah $from after ayah $to is completed';
  }

  @override
  String get qpbSpeed => 'Speed';

  @override
  String get qpbQari => 'Qari';

  @override
  String get qpbOff => 'Off';

  @override
  String qpbMinutes(int m) {
    return '$m min';
  }

  @override
  String get qdTitle => 'Display Settings';

  @override
  String get qdTranslationLabel => 'Indonesian Translation';

  @override
  String get qdTransliteration => 'Latin Transliteration';

  @override
  String get qdTafsirBrief => 'Brief Tafsir';

  @override
  String get qdBasmalahLatin => 'Bismillaahir Rahmaanir Raheem';

  @override
  String get qdBasmalahTranslation =>
      'In the name of Allah, the Most Gracious, the Most Merciful.';

  @override
  String get qpPlay => 'Play';

  @override
  String qpNowPlaying(String surah, int ayah) {
    return 'Surah $surah : $ayah';
  }
}

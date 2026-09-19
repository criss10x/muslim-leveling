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
      'So you never miss it, we send a reminder when prayer time comes. Notification permission only — alarm & battery settings are offered later in Profile, with their reasons.';

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
      'Used to show or hide the Menstrual Period menu. It is not synced to the cloud.';

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
}

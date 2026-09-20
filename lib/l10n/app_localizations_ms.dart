// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppL10nMs extends AppL10n {
  AppL10nMs([String locale = 'ms']) : super(locale);

  @override
  String get achBtnAwesome => 'HEBAT!';

  @override
  String get achBtnSkipAll => 'Langkau semua';

  @override
  String achEarnedOn(String date, String tier) {
    return 'Diperoleh pada $date • $tier';
  }

  @override
  String achHintFallback(String desc) {
    return 'Selesaikan: $desc.';
  }

  @override
  String achLockedTier(String tier) {
    return 'Dikunci • $tier';
  }

  @override
  String achScreenProgress(int total) {
    return ' / $total pingat dibuka';
  }

  @override
  String get achScreenTitle => 'Pencapaian';

  @override
  String get achSectionTitle => 'PENCAPAIAN';

  @override
  String get achSeeAll => 'Lihat semua';

  @override
  String achSemanticsDetail(
    String state,
    String title,
    String desc,
    String tier,
  ) {
    return '$state: $title. $desc. Tahap $tier.';
  }

  @override
  String achSemanticsUnlocked(String title, String desc, String tier) {
    return 'Pencapaian dibuka: $title. $desc. Tahap $tier.';
  }

  @override
  String get achStateLocked => 'Dikunci';

  @override
  String get achStateUnlocked => 'Dibuka';

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
  String get achUnlockedBanner => 'PENCAPAIAN DIBUKA!';

  @override
  String get ach_collector_desc =>
      'Log kesemua 8 jenis solat sunat sekurang-kurangnya 1×';

  @override
  String get ach_collector_hint =>
      'Catat sekurang-kurangnya 1× daripada 8 jenis sunat: Dhuha, Tahajjud, dan 6 rawatib.';

  @override
  String get ach_collector_title => 'COLLECTOR';

  @override
  String get ach_comeback_real_desc => 'Bangkit semula selepas streak terputus';

  @override
  String get ach_comeback_real_title => 'COMEBACK IS REAL';

  @override
  String get ach_critical_hit_desc => 'Solat fardu ≤5 minit selepas azan';

  @override
  String get ach_critical_hit_title => 'CRITICAL HIT!';

  @override
  String get ach_dawn_buff_desc => 'Kali pertama Qobliyah Subuh';

  @override
  String get ach_dawn_buff_title => 'DAWN BUFF';

  @override
  String get ach_dhuha_secured_desc => 'Kali pertama log solat Dhuha';

  @override
  String get ach_dhuha_secured_title => 'DHUHA SECURED';

  @override
  String get ach_dominating_desc => 'Hero Streak 7 hari berturut-turut';

  @override
  String get ach_dominating_title => 'DOMINATING!';

  @override
  String get ach_double_kill_desc => 'Hero Streak 2 hari berturut-turut';

  @override
  String get ach_double_kill_title => 'DOUBLE KILL';

  @override
  String get ach_dusk_finisher_desc => 'Kali pertama Ba\'diyah Maghrib';

  @override
  String get ach_dusk_finisher_title => 'DUSK FINISHER';

  @override
  String get ach_dzikir_legend_desc => 'Zikir 50,000x';

  @override
  String get ach_dzikir_legend_hint =>
      'Jumlah hitungan zikir daripada tab Zikir sepanjang hayat akaun.';

  @override
  String get ach_dzikir_legend_title => 'ZIKIR LEGEND';

  @override
  String get ach_dzikir_master_desc => 'Zikir 10,000x';

  @override
  String get ach_dzikir_master_title => 'ZIKIR MASTER';

  @override
  String get ach_dzikir_pemula_desc => 'Zikir 1,000x';

  @override
  String get ach_dzikir_pemula_title => 'ZIKIR PEMULA';

  @override
  String get ach_early_bird_desc => '20x solat tepat pada waktunya (±10m)';

  @override
  String get ach_early_bird_hint =>
      '20× solat tepat pada waktunya (≤10 minit selepas azan).';

  @override
  String get ach_early_bird_title => 'EARLY BIRD';

  @override
  String get ach_early_game_desc => 'Solat Subuh pertama anda dicatatkan';

  @override
  String get ach_early_game_title => 'EARLY GAME';

  @override
  String get ach_first_blood_desc =>
      'Selesaikan 5 solat fardu dalam 1 hari (Hero Streak bermula!)';

  @override
  String get ach_first_blood_hint =>
      'Catat 5 solat fardu dalam satu hari (Subuh, Zohor, Asar, Maghrib, Isyak).';

  @override
  String get ach_first_blood_title => 'FIRST BLOOD!';

  @override
  String get ach_first_clear_module_desc =>
      'Selesaikan modul Belajar pertama anda';

  @override
  String get ach_first_clear_module_title => 'FIRST CLEAR';

  @override
  String get ach_first_strike_desc => 'Solat Subuh ≤15 minit selepas azan';

  @override
  String get ach_first_strike_hint =>
      'Solat Subuh dalam tempoh 15 minit selepas azan.';

  @override
  String get ach_first_strike_title => 'FIRST STRIKE';

  @override
  String get ach_full_combo_desc => 'Dalam 1 hari: 5 fardu + Tilawah + Dhuha';

  @override
  String get ach_full_combo_hint =>
      'Dalam satu hari: catat 5 fardu + Tilawah + Dhuha.';

  @override
  String get ach_full_combo_title => 'FULL COMBO';

  @override
  String get ach_godlike_desc => 'Hero Streak 30 hari berturut-turut';

  @override
  String get ach_godlike_title => 'GODLIKE!';

  @override
  String get ach_gold_buff_desc => 'Kali pertama Qobliyah Asar';

  @override
  String get ach_gold_buff_title => 'GOLD BUFF';

  @override
  String get ach_gold_lane_desc => 'Kali pertama log solat Asar';

  @override
  String get ach_gold_lane_title => 'GOLD LANE';

  @override
  String get ach_hadis_champion_desc => 'Baca 200 Hadis';

  @override
  String get ach_hadis_champion_title => 'HADIS CHAMPION';

  @override
  String get ach_hadis_elite_desc => 'Baca 50 Hadis';

  @override
  String get ach_hadis_elite_title => 'HADIS ELITE';

  @override
  String get ach_hadis_grinder_desc => 'Baca 10 Hadis';

  @override
  String get ach_hadis_grinder_title => 'HADIS GRINDER';

  @override
  String get ach_hadis_hero_desc => 'Baca 350 Hadis';

  @override
  String get ach_hadis_hero_title => 'HADIS HERO';

  @override
  String get ach_hadis_legend_desc => 'Baca 500 Hadis';

  @override
  String get ach_hadis_legend_title => 'HADIS LEGEND';

  @override
  String get ach_hadis_rookie_desc => 'Baca 5 Hadis';

  @override
  String get ach_hadis_rookie_title => 'HADIS ROOKIE';

  @override
  String get ach_hadis_veteran_desc => 'Baca 100 Hadis';

  @override
  String get ach_hadis_veteran_title => 'HADIS VETERAN';

  @override
  String get ach_hadis_warrior_desc => 'Baca 25 Hadis';

  @override
  String get ach_hadis_warrior_title => 'HADIS WARRIOR';

  @override
  String get ach_hall_of_fame_desc => 'Buka semua pencapaian lain 👑';

  @override
  String get ach_hall_of_fame_hint =>
      'Buka semua pencapaian lain satu demi satu — yang terakhir daripada 87 pingat biasa.';

  @override
  String get ach_hall_of_fame_title => 'HALL OF FAME';

  @override
  String get ach_jamaah_champion_desc => '200x solat berjemaah';

  @override
  String get ach_jamaah_champion_title => 'JAMAAH CHAMPION';

  @override
  String get ach_jamaah_elite_desc => '50x solat berjemaah';

  @override
  String get ach_jamaah_elite_title => 'JAMAAH ELITE';

  @override
  String get ach_jamaah_grinder_desc => '10x solat berjemaah';

  @override
  String get ach_jamaah_grinder_title => 'JAMAAH GRINDER';

  @override
  String get ach_jamaah_hero_desc => '350x solat berjemaah';

  @override
  String get ach_jamaah_hero_title => 'JAMAAH HERO';

  @override
  String get ach_jamaah_legend_desc => '500x solat berjemaah';

  @override
  String get ach_jamaah_legend_title => 'JAMAAH LEGEND';

  @override
  String get ach_jamaah_rookie_desc => '5x solat berjemaah';

  @override
  String get ach_jamaah_rookie_title => 'JAMAAH ROOKIE';

  @override
  String get ach_jamaah_veteran_desc => '100x solat berjemaah';

  @override
  String get ach_jamaah_veteran_title => 'JAMAAH VETERAN';

  @override
  String get ach_jamaah_warrior_desc => '25x solat berjemaah';

  @override
  String get ach_jamaah_warrior_title => 'JAMAAH WARRIOR';

  @override
  String get ach_jungler_desc => 'Rentetan Tilawah 7 hari berturut-turut';

  @override
  String get ach_jungler_title => 'JUNGLER';

  @override
  String get ach_langkah_pertama_desc => 'Log solat pertama anda';

  @override
  String get ach_langkah_pertama_title => 'LANGKAH PERTAMA';

  @override
  String get ach_late_game_desc => 'Kali pertama log solat Isyak';

  @override
  String get ach_late_game_title => 'LATE GAME';

  @override
  String get ach_legendary_desc => 'Rentetan Hero 100 hari berturut-turut';

  @override
  String get ach_legendary_title => 'LEGENDARY!';

  @override
  String get ach_mana_regen_desc => 'Kali pertama log Tilawah/Zikir';

  @override
  String get ach_mana_regen_title => 'MANA REGEN';

  @override
  String get ach_maniac_desc => 'Rentetan Hero 14 hari berturut-turut';

  @override
  String get ach_maniac_title => 'MANIAC!';

  @override
  String get ach_mid_buff_desc => 'Kali pertama Qobliyah Zohor';

  @override
  String get ach_mid_buff_title => 'MID BUFF';

  @override
  String get ach_mid_finisher_desc => 'Kali pertama Ba\'diyah Zohor';

  @override
  String get ach_mid_finisher_title => 'MID FINISHER';

  @override
  String get ach_mid_game_desc => 'Kali pertama log solat Zohor';

  @override
  String get ach_mid_game_title => 'MID GAME';

  @override
  String get ach_night_finisher_desc => 'Kali pertama Ba\'diyah Isyak';

  @override
  String get ach_night_finisher_title => 'NIGHT FINISHER';

  @override
  String get ach_phoenix_desc =>
      'Bangkit 3× selepas rentetan terputus — tidak pernah menyerah';

  @override
  String get ach_phoenix_hint =>
      'Selepas rentetan terputus, mula semula sehingga direkodkan 3 kali bangkit.';

  @override
  String get ach_phoenix_title => 'PHOENIX';

  @override
  String get ach_quiz_mvp_desc => 'Skor sempurna 100% dalam satu kuiz';

  @override
  String get ach_quiz_mvp_hint =>
      'Selesaikan kuiz di akhir modul Belajar dan jawab semua dengan betul (100%).';

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
  String get ach_quran_champion_desc => 'Baca 4,000 ayat';

  @override
  String get ach_quran_champion_title => 'QURAN CHAMPION';

  @override
  String get ach_quran_guardian_desc => 'Baca 2,000 ayat';

  @override
  String get ach_quran_guardian_title => 'QURAN GUARDIAN';

  @override
  String get ach_quran_hafizh_desc => 'Baca 1,000 ayat';

  @override
  String get ach_quran_hafizh_title => 'HAFIZ MUDA';

  @override
  String get ach_quran_master_desc => 'Baca 6,236 ayat (khatam)';

  @override
  String get ach_quran_master_hint =>
      'Baca sejumlah 6,236 ayat (seluruh Al-Qur\'an) sejak pertama kali dipasang.';

  @override
  String get ach_quran_master_title => 'HAFIZ MASTER';

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
  String get ach_rank_elite_desc => 'Capai Tahap 25';

  @override
  String get ach_rank_elite_title => 'ELITE';

  @override
  String get ach_rank_epic_desc => 'Capai Tahap 60';

  @override
  String get ach_rank_epic_title => 'EPIC';

  @override
  String get ach_rank_master_desc => 'Capai Tahap 40';

  @override
  String get ach_rank_master_title => 'MASTER';

  @override
  String get ach_rank_mythic_desc => 'Capai Tahap 80 — Muslim Mythic!';

  @override
  String get ach_rank_mythic_hint =>
      'Naik tahap melalui XP daripada ibadah harian — peningkatan ke tahap 80 memerlukan masa.';

  @override
  String get ach_rank_mythic_title => 'MYTHIC';

  @override
  String get ach_rank_warrior_desc => 'Capai Tahap 10';

  @override
  String get ach_rank_warrior_title => 'WARRIOR';

  @override
  String get ach_sage_desc => 'Selesaikan kesemua 16 modul Belajar';

  @override
  String get ach_sage_hint =>
      'Selesaikan kesemua 16 modul Belajar (skor kuiz adalah bebas).';

  @override
  String get ach_sage_title => 'SAGE';

  @override
  String get ach_santri_scholar_desc => 'Selesaikan 40 modul Belajar';

  @override
  String get ach_santri_scholar_hint =>
      'Selesaikan 40 modul di tab Belajar (pada masa ini 16 modul, akan ditambah secara berperingkat).';

  @override
  String get ach_santri_scholar_title => 'SANTRI SCHOLAR';

  @override
  String get ach_savage_desc => 'Rentetan Hero 60 hari berturut-turut';

  @override
  String get ach_savage_title => 'SAVAGE!';

  @override
  String get ach_sharpshooter_desc =>
      '10× solat tepat pada waktunya (≤10 minit)';

  @override
  String get ach_sharpshooter_hint =>
      '10× solat tepat pada waktunya (≤10 minit selepas azan).';

  @override
  String get ach_sharpshooter_title => 'SHARPSHOOTER';

  @override
  String get ach_subuh_legend_desc => 'Rentetan Subuh 30 hari';

  @override
  String get ach_subuh_legend_title => 'SUBUH LEGEND';

  @override
  String get ach_subuh_solo_carry_desc =>
      'Rentetan Subuh 7 hari berturut-turut — laluan paling sukar';

  @override
  String get ach_subuh_solo_carry_title => 'SUBUH SOLO CARRY';

  @override
  String get ach_sultan_sunnah_desc => 'Jumlah 50 solat sunat';

  @override
  String get ach_sultan_sunnah_title => 'SULTAN SUNNAH';

  @override
  String get ach_sunnah_master_desc => 'Jumlah 200 solat sunat';

  @override
  String get ach_sunnah_master_hint =>
      'Jumlah rekod bagi 8 jenis solat sunat (Dhuha, Rawatib, Tahajjud, dll).';

  @override
  String get ach_sunnah_master_title => 'SUNNAH MASTER';

  @override
  String get ach_sunset_strike_desc => 'Kali pertama log solat Maghrib';

  @override
  String get ach_sunset_strike_title => 'SUNSET STRIKE';

  @override
  String get ach_tahajjud_secured_desc => 'Kali pertama log solat Tahajjud';

  @override
  String get ach_tahajjud_secured_title => 'TAHAJJUD SECURED';

  @override
  String get ach_tilawah_streak_14_desc => 'Rentetan Tilawah 14 hari';

  @override
  String get ach_tilawah_streak_14_title => 'TILAWAH STREAK';

  @override
  String get ach_triple_kill_desc => 'Rentetan Hero 3 hari berturut-turut';

  @override
  String get ach_triple_kill_title => 'TRIPLE KILL';

  @override
  String get ach_unstoppable_desc => 'Rentetan Hero 5 hari berturut-turut';

  @override
  String get ach_unstoppable_title => 'UNSTOPPABLE!';

  @override
  String get ach_wajib_champion_desc => '400x solat fardu';

  @override
  String get ach_wajib_champion_title => 'WAJIB CHAMPION';

  @override
  String get ach_wajib_elite_desc => '100x solat fardu';

  @override
  String get ach_wajib_elite_title => 'WAJIB ELITE';

  @override
  String get ach_wajib_grinder_desc => '25x solat fardu';

  @override
  String get ach_wajib_grinder_title => 'WAJIB GRINDER';

  @override
  String get ach_wajib_hero_desc => '700x solat fardu';

  @override
  String get ach_wajib_hero_title => 'WAJIB HERO';

  @override
  String get ach_wajib_immortal_desc => '2,000x solat fardu';

  @override
  String get ach_wajib_immortal_hint =>
      'Jumlah rekod solat fardu terkumpul sepanjang hayat akaun.';

  @override
  String get ach_wajib_immortal_title => 'WAJIB IMMORTAL';

  @override
  String get ach_wajib_master_desc => '1,000x solat fardu';

  @override
  String get ach_wajib_master_title => 'WAJIB MASTER';

  @override
  String get ach_wajib_mythic_desc => '1,500x solat fardu';

  @override
  String get ach_wajib_mythic_title => 'WAJIB MYTHIC';

  @override
  String get ach_wajib_rookie_desc => '10x solat fardu';

  @override
  String get ach_wajib_rookie_title => 'WAJIB ROOKIE';

  @override
  String get ach_wajib_veteran_desc => '200x solat fardu';

  @override
  String get ach_wajib_veteran_title => 'WAJIB VETERAN';

  @override
  String get ach_wajib_warrior_desc => '50x solat fardu';

  @override
  String get ach_wajib_warrior_title => 'WAJIB WARRIOR';

  @override
  String get ach_wombo_combo_desc =>
      'Selesaikan Zikir Harian 100 buat kali pertama';

  @override
  String get ach_wombo_combo_title => 'WOMBO COMBO';

  @override
  String get appTitle => 'Muslim Leveling';

  @override
  String get commonCancel => 'Batal';

  @override
  String get cityPickerEmptyKab => 'Daerah/bandar tidak ditemui';

  @override
  String get cityPickerEmptyProv => 'Negeri tidak ditemui';

  @override
  String get cityPickerHintKab => 'Taip nama daerah/bandar...';

  @override
  String get cityPickerHintProv => 'Taip nama negeri...';

  @override
  String get cityPickerNotFound =>
      'Daerah/bandar tidak ditemui. Sila cuba pilih negeri lain.';

  @override
  String get cityPickerLoadFailed =>
      'Gagal memuatkan senarai daerah/bandar. Sila periksa sambungan internet dan cuba lagi.';

  @override
  String get cityPickerRetry => 'Cuba lagi';

  @override
  String get cityPickerTitleKab => 'Pilih Daerah/Bandar';

  @override
  String get cityPickerTitleProv => 'Pilih Negeri';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonLogout => 'Log keluar';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSave => 'Simpan';

  @override
  String get homeAskWajibBody => 'Pilih keadaan solat anda untuk bonus XP';

  @override
  String homeAskWajibTitle(String prayer) {
    return 'Sudah Solat ($prayer)?';
  }

  @override
  String get homeBonusJamaah => 'Berjemaah';

  @override
  String get homeBonusJamaahSub => 'solat berjemaah';

  @override
  String get homeBonusOnTime => 'Tepat waktu';

  @override
  String get homeBonusOnTimeSub => 'kurang daripada 30 minit selepas azan';

  @override
  String get homeBonusPlain => 'Sudah';

  @override
  String get homeBonusPlainSub => 'tanpa bonus XP';

  @override
  String get homeBonusQuestSunnah => 'QUEST BONUS · SUNNAH';

  @override
  String get homeChestLocked => 'Selesaikan 5 solat fardu';

  @override
  String get homeChestMetaOpened => 'DIBUKA';

  @override
  String homeChestMetaProgress(int done, int total) {
    return '$done/$total WAJIB';
  }

  @override
  String get homeChestOpenedLabel => 'PETI DIBUKA';

  @override
  String get homeChestOpenedSub => 'Kembali lagi esok! 🌙';

  @override
  String get homeChestReadyLabel => 'GANJARAN SEDIA!';

  @override
  String get homeChestReadySub => 'Klik untuk tuntut 🎉';

  @override
  String get homeChestTitle => 'PETI HARIAN';

  @override
  String get homeDefaultCity => 'Kuala Lumpur';

  @override
  String homeLevelUpSource(String prayer) {
    return 'Solat $prayer';
  }

  @override
  String homeLockAfterTime(String prayer) {
    return 'Waktu $prayer telah berlalu.';
  }

  @override
  String homeLockBeforeTime(String prayer, String time) {
    return 'Belum masuk waktu $prayer (azan $time).';
  }

  @override
  String homeLockSubuh(int hours, String until) {
    return 'Quest Subuh terkunci $hours jam selepas azan (sehingga $until). Jangan terlepas esok ya! 💪';
  }

  @override
  String get homeLogDuplicate => 'Solat ini telah direkodkan hari ini!';

  @override
  String get homeNext => 'SETERUSNYA';

  @override
  String homeQuestClaimable(int n) {
    return '$n SEDIA DITUNTUT';
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
  String get homeQuickDzikir => 'Zikir';

  @override
  String get homeQuickHadis => 'Hadis';

  @override
  String get homeQuickKiblat => 'Kiblat';

  @override
  String get homeQuickRenungan => 'Renungan';

  @override
  String get homeRevealBtn => 'Alhamdulillah! 🤲';

  @override
  String get homeRevealCosmetic => 'KOSMETIK BAHARU!';

  @override
  String get homeRevealDuplicate => 'Item pendua — koleksi tetap disimpan 📦';

  @override
  String homeRevealLevelUp(String suffix) {
    return '⬆️ Naik Tahap!$suffix';
  }

  @override
  String get homeRevealReward => 'GANJARAN DIPEROLEH!';

  @override
  String get homeRevealShield => 'PERISAI BEKU!';

  @override
  String homeRevealShieldBody(int count) {
    return 'Streak selamat 1 hari apabila terlupa solat. Jumlah: $count ❄️';
  }

  @override
  String get homeRingWajib => 'WAJIB';

  @override
  String get homeRitualToday => 'RITUAL HARI INI';

  @override
  String get homeSideDone => 'Selesai hari ini ✓';

  @override
  String get homeSideDzikir => 'Zikir 100x';

  @override
  String homeSideDzikirSub(int count, int target) {
    return '$count/$target zikir';
  }

  @override
  String get homeSideHadis => 'Belajar Hadis';

  @override
  String homeSideHadisSub(int count, int target) {
    return '$count/$target hadis dibaca';
  }

  @override
  String get homeSideQuestTitle => 'QUEST SAMPINGAN';

  @override
  String get homeSideQuran => 'Baca Al-Qur\'an';

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
      'Ba\'diyah Zohor waktunya selepas Zohor sehingga sebelum Asar.';

  @override
  String get homeSunnahHintBadiyahIsya =>
      'Ba\'diyah Isyak waktunya selepas Isyak sehingga tengah malam.';

  @override
  String get homeSunnahHintBadiyahMaghrib =>
      'Ba\'diyah Maghrib waktunya selepas Maghrib sehingga sebelum Isyak.';

  @override
  String get homeSunnahHintDhuha =>
      'Dhuha boleh dilakukan selepas matahari naik (±15 minit selepas terbit) sehingga sebelum Zohor.';

  @override
  String get homeSunnahHintFallback => 'Cuba lagi nanti.';

  @override
  String get homeSunnahHintQobliyahAshar =>
      'Qobliyah Asar waktunya dari Asar sehingga sebelum Maghrib.';

  @override
  String get homeSunnahHintQobliyahDzuhur =>
      'Qobliyah Zohor waktunya dari Zohor sehingga sebelum Asar.';

  @override
  String get homeSunnahHintQobliyahSubuh =>
      'Qobliyah Subuh waktunya sama dengan solat Subuh (dari Subuh sehingga Terbit).';

  @override
  String get homeSunnahHintTahajjud =>
      'Tahajjud waktunya selepas Isyak sehingga sebelum Imsak.';

  @override
  String get homeUnitDays => 'hari';

  @override
  String get homeWajibQuest => 'QUEST WAJIB';

  @override
  String get homeXpToNextRank => 'XP KE PANGKAT SETERUSNYA';

  @override
  String get localeEnglish => 'Bahasa Inggeris';

  @override
  String get localeIndonesian => 'Bahasa Indonesia';

  @override
  String get localeMalay => 'Bahasa Melayu';

  @override
  String get localeTurkish => 'Türkçe';

  @override
  String get localePicked => 'Bahasa dipilih';

  @override
  String get localeSystem => 'Ikut Sistem (Telefon)';

  @override
  String get localeTitle => 'Bahasa aplikasi';

  @override
  String get onbContinue => 'Teruskan';

  @override
  String get onbDefaultNickname => 'Pejuang';

  @override
  String get onbGenderAkhwat => 'AKHWAT';

  @override
  String get onbGenderIkhwan => 'IKHWAN';

  @override
  String get onbGenderMeaning =>
      'Ikhwan bermaksud lelaki, akhwat bermaksud perempuan.';

  @override
  String get onbGenderPrivacy =>
      'Jawapan anda hanya digunakan untuk menyembunyikan menu. Anda boleh mengubahnya pada bila-bila masa di Profil.';

  @override
  String get onbGenderSkip => 'Tidak perlu';

  @override
  String get onbGenderTitle => 'Adakah anda Ikhwan atau Akhwat?';

  @override
  String get onbGenderWhy =>
      'Akhwat mempunyai ciri Tempoh Haid: apabila datang bulan, streak solat akan dibekukan secara automatik supaya tiada penalti dikenakan. Ciri ini disembunyikan daripada paparan Ikhwan untuk memastikan menu kelihatan kemas.';

  @override
  String get onbHowAchBody =>
      'Buka kunci pingat daripada streak, tilawah dan zikir.';

  @override
  String get onbHowAchTitle => 'Pencapaian';

  @override
  String get onbHowBody =>
      'Tiga perkara ini yang membuatkan ibadah harian anda terasa seperti meningkat ke tahap seterusnya.';

  @override
  String get onbHowDemoHint => 'Cuba ketik kad ini';

  @override
  String get onbHowQuestBody => 'Tandakan solat fardu & sunat setiap hari.';

  @override
  String get onbHowQuestTitle => 'Quest Harian';

  @override
  String get onbHowTitle => 'Cara Bermain';

  @override
  String get onbHowXpBody =>
      'Setiap quest yang selesai akan memberikan XP. Meningkat tahap, meningkat pangkat.';

  @override
  String get onbHowXpTitle => 'XP & Tahap';

  @override
  String get onbLangBody =>
      'Anda boleh mengubahnya pada bila-bila masa di Profil.';

  @override
  String get onbLangTitle => 'Apakah bahasa pilihan anda?';

  @override
  String get onbLocationAllow => 'Benarkan Lokasi';

  @override
  String get onbLocationBody =>
      'Untuk menghitung jadual solat & arah kiblat yang tepat, kami memerlukan akses lokasi. Lokasi anda tidak akan dikongsi dengan sesiapa — semua pengiraan dilakukan pada peranti anda.';

  @override
  String get onbLocationLoading => 'MENDAPATKAN LOKASI...';

  @override
  String get onbLocationLater => 'Gunakan bandar lalai dahulu';

  @override
  String get onbLocationLaterHint =>
      'Belum ada lokasi? Jadual akan menggunakan bandar lalai dahulu — boleh diubah pada bila-bila masa di Profil.';

  @override
  String get onbLocationPickManual => 'Pilih bandar secara manual';

  @override
  String get onbLocationRetry => 'Cuba lagi';

  @override
  String get onbLocationTitle => 'Memerlukan Lokasi Anda';

  @override
  String get onbNameBody =>
      'Nama ini akan dipaparkan di Laman Utama dan kad pingat. Boleh dikosongkan.';

  @override
  String get onbNameTitle => 'Apakah nama pejuang anda?';

  @override
  String get onbNicknameHint => 'Nama pejuang (pilihan — kosong: Pejuang)';

  @override
  String get onbNotifAllow => 'Benarkan Notifikasi';

  @override
  String get onbNotifBody =>
      'Agar tidak terlepas, kami akan menghantar peringatan apabila masuk waktu solat. Kami memerlukan kebenaran notifikasi + pengecualian bateri — tanpa kebenaran ini, peranti anda mungkin mematikan peringatan secara senyap apabila aplikasi ditutup.';

  @override
  String get onbNotifDenied =>
      'Peringatan tidak aktif. Boleh diaktifkan pada bila-bila masa di Profil.';

  @override
  String get onbNotifLoading => 'MENGAKTIFKAN...';

  @override
  String get onbNotifSkip => 'Langkau, kemudian sahaja';

  @override
  String get onbNotifTitle => 'Peringatan Azan';

  @override
  String get onbProgressLabel => 'Persediaan';

  @override
  String onbStepOf(String step, String total) {
    return 'Langkah $step daripada $total';
  }

  @override
  String get onbXpDemoSemantics => 'Contoh: Subuh selesai, ditambah 50 XP';

  @override
  String get prayerAshar => 'Asar';

  @override
  String get prayerDzuhur => 'Zohor';

  @override
  String get prayerIsya => 'Isyak';

  @override
  String get prayerJumat => 'Jumaat';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerSubuh => 'Subuh';

  @override
  String get profilAbout => 'Mengenai Aplikasi';

  @override
  String get profilAboutBody =>
      'Ibadah itu adalah tentang konsistensi, bukan kesempurnaan. Muslim Leveling membantu anda membina tabiat solat lima waktu dan membaca Al-Qur\'an dengan cara yang menyeronokkan — setiap solat yang direkodkan memberikan XP, setiap hari tanpa putus meningkatkan streak, dan setiap pencapaian membuka kunci skin avatar baharu.';

  @override
  String get profilAboutFooter =>
      'Dibuat dengan penuh doa untuk setiap pejuang akhirat.';

  @override
  String get profilAboutOffline =>
      'Tiada pelayan, tiada iklan, tiada langganan. Semua data anda disimpan pada peranti — milik anda sepenuhnya.';

  @override
  String get profilAccountSettings => 'Tetapan Akaun';

  @override
  String get profilAlreadyPrayedToday => ', sudah solat hari ini';

  @override
  String get profilAndroidNotifSettings => 'Tetapan Notifikasi Android';

  @override
  String get profilBackupActive => 'Sandaran aktif';

  @override
  String get profilBatteryPerm =>
      'Benarkan \"Tiada sekatan bateri\" supaya peringatan tetap berbunyi apabila aplikasi ditutup.';

  @override
  String get profilCalendarHeader => 'KALENDAR SOLAT';

  @override
  String get profilChangePhoto => 'Tukar Foto';

  @override
  String get profilCloudVerifyFailed => 'Gagal mengesahkan awan. Cuba lagi.';

  @override
  String get profilConnecting => 'MENYAMBUNGKAN...';

  @override
  String get profilContinueGoogle => 'Teruskan dengan Google';

  @override
  String get profilCycleExplain =>
      'Aktifkan semasa haid agar streak solat tetap selamat tanpa penalti.';

  @override
  String get profilCycleFrozenMeta => 'mod haid · streak dibekukan';

  @override
  String get profilCycleFrozenSemantics => 'Mod haid aktif, streak dibekukan';

  @override
  String get profilCycleModeShort => 'mod haid';

  @override
  String get profilCyclePeriod => 'Tempoh Haid';

  @override
  String get profilEditName => 'Edit Nama';

  @override
  String get profilEditProfile => 'Edit profil';

  @override
  String get profilEnableReminders => 'Aktifkan peringatan';

  @override
  String get profilExactAlarmPerm =>
      'Kebenaran \"Penggera & peringatan\" belum aktif — peringatan mungkin lewat beberapa minit.';

  @override
  String get profilFriday => 'Jumaat';

  @override
  String get profilFromCamera => 'Ambil dari Kamera';

  @override
  String get profilFromGallery => 'Pilih dari Galeri';

  @override
  String get profilGender => 'Jantina';

  @override
  String get profilGenderAkhwat => 'Akhwat';

  @override
  String get profilGenderExplain =>
      'Ikhwan = lelaki, Akhwat = perempuan. Digunakan untuk menyembunyikan atau memaparkan menu Tempoh Haid. Tidak disinkronkan ke awan.';

  @override
  String get profilGenderIkhwan => 'Ikhwan';

  @override
  String get profilGenderUnset => 'Belum dipilih';

  @override
  String get profilHeatmapBody =>
      'Semakin hijau semakin lengkap — 5 rona = 5 solat fardu.';

  @override
  String get profilHeatmapHeader => 'KALENDAR SOLAT FARDU';

  @override
  String get profilHeatmapRow => 'Peta haba solat fardu setiap bulan';

  @override
  String get profilHeatmapSemantics => 'Buka kalendar solat fardu';

  @override
  String profilHeroSemantics(String tier) {
    return 'Wira profil — $tier';
  }

  @override
  String profilLevelBadge(int level) {
    return 'LVL $level';
  }

  @override
  String get profilLockerRow => 'Tetapkan aura dan gelaran aktif';

  @override
  String get profilLockerSemantics => 'Buka loker skin';

  @override
  String get profilLockerSkin => 'LOKER SKIN';

  @override
  String get profilLoginCancelled => 'Log masuk dibatalkan.';

  @override
  String profilLoginFailed(String msg) {
    return '❌ Log masuk gagal: $msg';
  }

  @override
  String get profilLoginMerged =>
      '☁️ Log masuk berjaya — kemajuan digabungkan.';

  @override
  String get profilLoginNotSaved =>
      '⚠️ Log masuk berjaya, tetapi sandaran belum disimpan.';

  @override
  String get profilLoginOffline =>
      '⚠️ Log masuk berjaya, tetapi sandaran belum aktif (luar talian).';

  @override
  String get profilLogoutConfirm =>
      'Padamkan data tempatan dan kembali ke skrin utama?';

  @override
  String get profilLogoutSuccess => 'Log keluar berjaya.';

  @override
  String get profilMiniLevel => 'Tahap';

  @override
  String get profilMiniStreak => 'Streak';

  @override
  String get profilMiniXp => 'XP';

  @override
  String get profilModeBalanced => '⚖️ Seimbang';

  @override
  String get profilModeBalancedDesc =>
      'Diingatkan 15 minit sebelum & semasa azan';

  @override
  String get profilModeFocus => '🎯 Fokus';

  @override
  String get profilModeFocusDesc => 'Hanya peringatan utama pada waktu azan';

  @override
  String get profilModeIntense => '🔥 Intensif';

  @override
  String get profilModeIntenseDesc => '30 minit, 5 minit sebelum & semasa azan';

  @override
  String get profilNicknameHint => 'Nama panggilan';

  @override
  String get profilNotifPermAction =>
      'Kebenaran notifikasi belum aktif. Buka Tetapan Notifikasi Android dan benarkannya.';

  @override
  String get profilNotifPermBody =>
      'Kebenaran notifikasi belum aktif. Aktifkan untuk menerima peringatan azan.';

  @override
  String get profilNotifications => 'Notifikasi';

  @override
  String get profilOemBody =>
      'Aktifkan \"Mula automatik\" & \"Tiada had bateri\" dalam tetapan telefon agar penggera tetap berbunyi apabila aplikasi ditutup, dan notifikasi dipaparkan pada skrin kunci.';

  @override
  String get profilOemManual =>
      'Buka Tetapan > Aplikasi > Muslim Leveling > Bateri & Mula automatik secara manual.';

  @override
  String get profilOemTitle => 'Azan tidak muncul pada Xiaomi/Oppo/Vivo?';

  @override
  String get profilOpenAutostart => 'Buka Tetapan Mula Automatik';

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
      'Buka Profil → Log keluar untuk memadam semua data tempatan sekali gus. Tiada data yang akan tertinggal pada peranti.';

  @override
  String get profilPrivacyDeleteTitle => 'Padam pada bila-bila masa';

  @override
  String get profilPrivacyLocalBody =>
      'Semua data — solat, bacaan Al-Qur\'an, statistik, dan tetapan pilihan — hanya disimpan di dalam telefon anda. Tiada pelayan, tiada storan awan.';

  @override
  String get profilPrivacyLocalTitle => 'Disimpan pada peranti';

  @override
  String get profilPrivacyLocationBody =>
      'Lokasi hanya digunakan sekali untuk menentukan jadual solat di kawasan anda. Lokasi tidak disimpan atau dikongsi.';

  @override
  String get profilPrivacyLocationTitle => 'Lokasi peribadi';

  @override
  String get profilPrivacyTraceBody =>
      'Aplikasi tidak menghantar aktiviti anda kepada pihak ketiga dan tidak memantau tingkah laku anda.';

  @override
  String get profilPrivacyTraceTitle => 'Tanpa jejak dalam talian';

  @override
  String get profilReminderMode => 'Mod Peringatan';

  @override
  String get profilReminderTitle => 'Peringatan Azan';

  @override
  String profilRemindersChangeFailed(String msg) {
    return 'Gagal mengubah peringatan: $msg';
  }

  @override
  String get profilRemindersFailed =>
      'Gagal menjadualkan peringatan — sila semak kebenaran notifikasi & penggera dalam tetapan telefon.';

  @override
  String get profilRemindersNone =>
      'Mod disimpan, tetapi tiada peringatan dijadualkan — sila semak kebenaran notifikasi & penggera dalam tetapan telefon.';

  @override
  String get profilRemindersOff => 'Peringatan azan dimatikan';

  @override
  String profilRemindersScheduled(String mode, int n) {
    return 'Peringatan azan aktif: mod $mode — $n peringatan dijadualkan';
  }

  @override
  String profilRemindersScheduledCount(int n) {
    return '$n peringatan azan dijadualkan 🔔';
  }

  @override
  String get profilRemovePhoto => 'Padam Foto';

  @override
  String profilSaveFailed(String msg) {
    return 'Gagal menyimpan: $msg';
  }

  @override
  String get profilSettingsHeader => 'TETAPAN';

  @override
  String profilSettingsOpenFailed(String msg) {
    return 'Gagal membuka tetapan notifikasi: $msg';
  }

  @override
  String get profilSoundAdzan => '🕌 Azan';

  @override
  String get profilSoundAdzanDesc =>
      'Alunan azan penuh apabila masuk waktu solat';

  @override
  String get profilSoundMode => 'Bunyi Notifikasi';

  @override
  String get profilSoundNormal => '🔔 Berbunyi';

  @override
  String get profilSoundNormalDesc =>
      'Notifikasi dengan bunyi standard telefon';

  @override
  String get profilSoundSilent => '🔕 Senyap';

  @override
  String get profilSoundSilentDesc => 'Hanya paparkan notifikasi, tanpa bunyi';

  @override
  String get profilStatsDailyAvg => 'Purata Harian';

  @override
  String get profilStatsEmptyBody =>
      'Tandakan solat pertama anda — statistik akan mula dipaparkan di sini.';

  @override
  String get profilStatsEmptyTitle => 'Tiada rekod lagi.';

  @override
  String get profilStatsHeader => 'STATISTIK';

  @override
  String get profilStatsQuranStreak => 'Streak Bacaan Al-Qur\'an';

  @override
  String profilStatsSince(String date) {
    return 'Sejak $date';
  }

  @override
  String get profilStatsVerses => 'Ayat Al-Qur\'an Dibaca';

  @override
  String get profilStatsWajib => 'Solat fardu';

  @override
  String profilStreakBest(int count) {
    return 'terbaik $count';
  }

  @override
  String get profilStreakFreeze => 'beku';

  @override
  String get profilStreakPerPrayer => 'STREAK SETIAP SOLAT';

  @override
  String profilStreakSemanticsItem(String prayer, int days) {
    return '$prayer $days hari';
  }

  @override
  String get profilStreakSemanticsTitle => 'Streak setiap solat';

  @override
  String get profilTestAdzan => 'Uji Azan';

  @override
  String get profilTestNotif => 'Uji Notifikasi';

  @override
  String profilTestNotifFailed(String msg) {
    return 'Ujian notifikasi gagal: $msg';
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
  String get sunnahBadiyahDzuhurDesc => 'Solat sunat selepas Zohor';

  @override
  String get sunnahBadiyahDzuhurName => 'Ba\'diyah Zohor';

  @override
  String get sunnahBadiyahIsyaDesc => 'Solat sunat selepas Isyak';

  @override
  String get sunnahBadiyahIsyaName => 'Ba\'diyah Isyak';

  @override
  String get sunnahBadiyahMaghribDesc => 'Solat sunat selepas Maghrib';

  @override
  String get sunnahBadiyahMaghribName => 'Ba\'diyah Maghrib';

  @override
  String get sunnahDhuhaDesc => 'Solat sunat pada waktu pagi';

  @override
  String get sunnahDhuhaName => 'Dhuha';

  @override
  String get sunnahQobliyahAsharDesc => 'Solat sunat sebelum Asar';

  @override
  String get sunnahQobliyahAsharName => 'Qobliyah Asar';

  @override
  String get sunnahQobliyahDzuhurDesc => 'Solat sunat sebelum Zohor';

  @override
  String get sunnahQobliyahDzuhurName => 'Qobliyah Zohor';

  @override
  String get sunnahQobliyahSubuhDesc => 'Solat sunat sebelum Subuh';

  @override
  String get sunnahQobliyahSubuhName => 'Qobliyah Subuh';

  @override
  String get sunnahTahajjudDesc => 'Solat sunat malam (qiyamullail)';

  @override
  String get sunnahTahajjudName => 'Tahajjud';

  @override
  String get tabHome => 'Utama';

  @override
  String get tabJadwal => 'Jadual';

  @override
  String get tabQuran => 'Al-Qur\'an';

  @override
  String get dlTitle => 'Renungan Hari Ini';

  @override
  String get dlBack => 'Kembali';

  @override
  String dlCiteSurah(String surah, int ayah) {
    return 'Surah $surah : $ayah';
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
  String get dlActSaved => 'Disimpan';

  @override
  String get dlActTafsir => 'Tafsir';

  @override
  String get dlErrLoad =>
      'Renungan hari ini tidak dapat dimuat.\nSila sambungkan ke internet dan cuba lagi.';

  @override
  String get dlErrTafsir => 'Tafsir tidak dapat dimuat. Cuba lagi.';

  @override
  String get dlDone => 'Renungan hari ini selesai';

  @override
  String dlProgress(int done, int count) {
    return '$done daripada $count renungan dibaca · leret untuk teruskan';
  }

  @override
  String get qsTitle => 'Kongsi Ayat';

  @override
  String get qsShare => 'Kongsi';

  @override
  String get qsPreparing => 'Menyediakan…';

  @override
  String get qsErr => 'Gagal berkongsi ayat. Cuba lagi.';

  @override
  String get qsModeSolid => 'Warna Padu';

  @override
  String get qsModeGradient => 'Gradien';

  @override
  String get qsModeEsthetic => 'Estetik';

  @override
  String get qsContentArabic => 'Arab';

  @override
  String get qsContentTranslation => 'Terjemahan';

  @override
  String get quest_subuh_tepat_desc =>
      'Solat Subuh tepat pada waktunya (≤30 minit selepas azan)';

  @override
  String get quest_five_rings_desc => 'Lengkapkan 5/5 solat hari ini';

  @override
  String get quest_timely_prayers_desc =>
      'Solat tepat pada waktunya (≤10 minit), 3x hari ini';

  @override
  String get quest_dhuha_before_dzuhur_desc => 'Solat Dhuha sebelum Zohor';

  @override
  String get quest_rawatib_two_desc => 'Rawatib 2x hari ini';

  @override
  String get quest_dzuhur_tepat_desc =>
      'Solat Zohor tepat pada waktunya (≤30 minit selepas azan)';

  @override
  String get quest_maghrib_tepat_desc =>
      'Solat Maghrib tepat pada waktunya (≤30 minit selepas azan)';

  @override
  String get quest_isya_hadir_desc => 'Jangan lepaskan solat Isyak malam ini';

  @override
  String get quest_any_three_desc =>
      'Tunaikan 3 solat fardu hari ini (bebas mana-mana)';

  @override
  String get quest_subuh_isya_desc =>
      'Kunci dua penghujung hari: Subuh + Isyak';

  @override
  String get quest_one_sunnah_desc =>
      'Tunaikan 1 solat sunat apa-apa sahaja hari ini';

  @override
  String get quest_rawatib_one_desc =>
      'Rawatib 1x hari ini (qobliyah/ba\'diyah bebas)';

  @override
  String get quest_zikir_33_desc => 'Zikir 33x melalui butang Daily Zikir';

  @override
  String quest_zikir_goal_desc(Object goal) {
    return 'Selesaikan Daily Zikir sehingga $goal';
  }

  @override
  String get quest_quran_10ayat_desc => 'Baca Al-Qur\'an 10 ayat hari ini';

  @override
  String get quest_hadis_3_desc =>
      'Baca 3 Hadis hari ini (≥5 saat setiap Hadis)';

  @override
  String get quest_dzikir_33_subuh_desc =>
      'Zikir Subhanallah 33x (tasbih selepas solat)';

  @override
  String get quest_quran_1halaman_desc =>
      'Baca Al-Qur\'an 20 ayat (≈1 halaman mushaf)';

  @override
  String get quest_hadis_5_desc =>
      'Baca 5 Hadis hari ini (≥5 saat setiap Hadis)';

  @override
  String get quest_berjamaah_1_desc =>
      'Solat berjemaah 1x hari ini (pilih bonus berjemaah semasa menuntut)';

  @override
  String get quest_hero_streak_7_desc => 'Kekalkan Hero Streak 7 hari! 🔥';

  @override
  String get questCopy_sholat_1 =>
      'Anda mungkin sedang sibuk, tetapi tetap meluangkan masa. Syabas.';

  @override
  String get questCopy_sholat_2 =>
      'Azan selesai, anda terus melangkah. Terbaik.';

  @override
  String get questCopy_sholat_3 =>
      'Tepat pada waktunya hari ini. Satu perkara baik yang anda pelihara.';

  @override
  String get questCopy_sholat_4 =>
      'Penat tetap penat. Namun anda tetap hadir. 🤍';

  @override
  String get questCopy_sunnah_1 =>
      'Tidak wajib, tetapi anda tetap memilih untuk melakukannya.';

  @override
  String get questCopy_sunnah_2 =>
      'Tiada paksaan. Anda sendiri yang memilih untuk hadir.';

  @override
  String get questCopy_sunnah_3 =>
      'Dua rakaat hari ini. Kecil, tetapi bermakna.';

  @override
  String get questCopy_sunnah_4 =>
      'Perlahan-lahan, tabiat baik seperti inilah yang anda bina.';

  @override
  String get questCopy_zikir_1 =>
      'Di tengah-tengah kesibukan hari, anda masih meluangkan masa untuk mengingati Allah.';

  @override
  String get questCopy_zikir_2 =>
      'Berhenti sebentar. Tarik nafas. Ingatlah Allah.';

  @override
  String get questCopy_zikir_3 =>
      'Apa jua yang sedang anda fikirkan, anda tetap meluangkan masa untuk berzikir.';

  @override
  String get questCopy_zikir_4 =>
      'Selesai berzikir. Semoga hati terasa sedikit lebih tenang. 🤍';

  @override
  String get questCopy_quran_1 =>
      'Satu ayat hari ini. Perlahan-lahan, yang penting berterusan.';

  @override
  String get questCopy_quran_2 =>
      'Hari ini anda kembali membuka Al-Qur\'an. Sejuk mata memandang.';

  @override
  String get questCopy_quran_3 =>
      'Tidak semestinya banyak. Satu halaman pun tetap satu langkah ke hadapan.';

  @override
  String get questCopy_quran_4 =>
      'Satu halaman selesai. Esok sambung lagi, ya.';

  @override
  String get questCopy_hadis_1 =>
      'Hari ini anda meluangkan masa untuk belajar daripada sabda Nabi.';

  @override
  String get questCopy_hadis_2 =>
      'Satu Hadis anda baca hari ini. Semoga ada pengajaran yang boleh anda bawa dalam hari anda.';

  @override
  String get questCopy_hadis_3 =>
      'Menemui Hadis yang menyentuh hati? Simpan. Mana tahu anda perlu mengingatinya semula.';

  @override
  String get questCopy_hadis_4 =>
      'Sedikit pembelajaran hari ini, semoga menjadi bekal untuk esok.';

  @override
  String get questCopy_fiveRings_1 =>
      'Subuh, Zohor, Asar, Maghrib, Isyak. Anda hadir untuk kesemuanya hari ini.';

  @override
  String get questCopy_fiveRings_2 =>
      'Lima waktu selesai. Alhamdulillah, hari ini anda berjaya memeliharanya.';

  @override
  String get questCopy_fiveRings_3 => 'Satu hari, lima waktu. Lengkap. 🤍';

  @override
  String get questCopy_fiveRings_4 =>
      'Hari ini berakhir dengan baik. Esok kita mulakan lagi.';

  @override
  String get questCopy_subuhIsya_1 =>
      'Subuh anda pelihara, Isyak anda pelihara. Alhamdulillah.';

  @override
  String get questCopy_subuhIsya_2 =>
      'Dari awal hingga akhir hari, anda tetap meluangkan masa.';

  @override
  String get questCopy_subuhIsya_3 =>
      'Dua waktu ini anda pelihara hari ini. Syabas.';

  @override
  String get questCopy_subuhIsya_4 =>
      'Hari ini anda berjaya memelihara Subuh dan Isyak. Esok sambung lagi.';

  @override
  String get questHaid_1 =>
      'Hari ini masanya untuk berehat. Tetap bersemangat, ya. 🤍';

  @override
  String get questHaid_2 =>
      'Tidak mengapa berhenti seketika. Anda tetap sebahagian daripada perjalanan ini.';

  @override
  String get questHaid_3 =>
      'Hari ini anda tidak perlu mengejar quest ini. Jaga diri dan tetap dekat dengan Allah.';

  @override
  String get questHaid_4 =>
      'Quest boleh ditangguhkan seketika. Perjalanan anda tetap diteruskan.';

  @override
  String get questClaimAlhamdulillah => 'Alhamdulillah';

  @override
  String get questClaimContinue => 'Seterusnya';

  @override
  String sqCombinedTitle(Object count) {
    return 'Alhamdulillah, $count Quest Selesai!';
  }

  @override
  String get sqCombinedDesc =>
      'Semua quest harian selesai hari ini. Semoga istiqamah!';

  @override
  String get sqZikirTitle => 'Zikir 100x Selesai!';

  @override
  String get sqZikirDesc => 'Konsisten berzikir hari ini. Istiqamah!';

  @override
  String get sqTilawahTitle => 'Baca Al-Qur\'an 10 Ayat Selesai!';

  @override
  String get sqTilawahDesc => 'Tilawah hari ini selesai. Teruskan esok!';

  @override
  String get sqHadisTitle => 'Belajar 5 Hadis Selesai!';

  @override
  String get sqHadisDesc =>
      'Lima Hadis baharu dibaca hari ini. Teruskan belajar!';

  @override
  String get sqBadgeCombined => 'QUEST HARIAN SELESAI';

  @override
  String get sqBadgeSingle => 'QUEST SELESAI';

  @override
  String get sqButton => 'TERBAIK!';

  @override
  String get sqBarrierLabel => 'side quest selesai';

  @override
  String sqSemantics(Object desc, Object title, Object xp) {
    return '$title. $desc. Bonus $xp XP.';
  }

  @override
  String get sqSourceZikir => 'Zikir 100x';

  @override
  String get sqSourceTilawah => 'Baca Al-Qur\'an';

  @override
  String get sqSourceHadis => 'Belajar Hadis';

  @override
  String get naikTitle => 'NAIK LEVEL!';

  @override
  String get naikBadgeSemantics => 'Bulan sabit emas, lambang naik level';

  @override
  String naikReached(Object level, Object rank) {
    return 'Masya-Allah, anda mencapai $rank — Level $level';
  }

  @override
  String naikFrom(Object source) {
    return 'daripada $source';
  }

  @override
  String get naikBack => 'KEMBALI';

  @override
  String naikRewardSemanticsFull(Object level, Object rank, Object xp) {
    return 'Ganjaran: tambah $xp XP, level $level, gelaran baharu $rank';
  }

  @override
  String naikRewardSemanticsLevel(Object level, Object rank) {
    return 'Ganjaran: level $level, gelaran baharu $rank';
  }

  @override
  String get naikChipLevelJumps => 'Lonjakan';

  @override
  String get naikChipLevel => 'Level';

  @override
  String get naikChipRank => 'GELARAN BAHARU';

  @override
  String naikProgressSemantics(Object have, Object need, Object next) {
    return 'Menuju level $next: $have daripada $need XP';
  }

  @override
  String get naikClosing =>
      'Barakallah — terus istiqamah, level seterusnya menanti anda ✨';

  @override
  String naikLevelLabel(Object level) {
    return 'Level $level';
  }

  @override
  String get uq_ulama_ilmu_itu_lebih_baik_daripada_harta_ilmu =>
      'Ilmu itu lebih baik daripada harta. Ilmu menjaga anda, manakala harta pula anda yang perlu menjaganya.';

  @override
  String get uq_ulama_orang_berilmu_itu_hidup_walau_sudah_wafa =>
      'Orang yang berilmu itu hidup walaupun sudah wafat, manakala orang yang jahil itu mati walaupun masih hidup.';

  @override
  String get uq_ulama_jangan_melihat_siapa_yang_berbicara_tapi =>
      'Jangan melihat kepada siapa yang berbicara, tetapi lihatlah apa yang dikatakannya.';

  @override
  String get uq_ulama_nilai_seseorang_diukur_dari_apa_yang_dia =>
      'Nilai seseorang diukur daripada apa yang diusahakannya dengan bersungguh-sungguh.';

  @override
  String get uq_ulama_hisablah_dirimu_sendiri_sebelum_kamu_dih =>
      'Hisablah diri anda sendiri sebelum anda dihisab, dan timbanglah amalan anda sebelum ia ditimbang.';

  @override
  String get uq_ulama_aku_tidak_pernah_menyesal_karena_diam_ta =>
      'Aku tidak pernah menyesal kerana diam, tetapi aku sering menyesal kerana berbicara.';

  @override
  String get uq_ulama_kehormatanmu_adalah_agamamu_dan_harga_di =>
      'Kehormatan anda adalah agama anda, dan harga diri anda adalah akhlak anda.';

  @override
  String get uq_ulama_waktu_itu_seperti_pedang_kalau_kamu_tida =>
      'Waktu itu seperti pedang — jika anda tidak memotongnya, ia akan memotong anda.';

  @override
  String get uq_ulama_ilmu_bukanlah_yang_dihafal_tetapi_ilmu_a =>
      'Ilmu itu bukanlah apa yang dihafal, tetapi ilmu itu adalah apa yang memberi manfaat.';

  @override
  String get uq_ulama_ilmu_itu_cahaya_dan_cahaya_allah_tidak_a =>
      'Ilmu itu cahaya, dan cahaya Allah tidak akan masuk ke dalam hati orang yang melakukan maksiat.';

  @override
  String get uq_ulama_barangsiapa_tidak_tahan_lelahnya_belajar =>
      'Sesiapa yang tidak tahan dengan penat lelah belajar, dia harus menanggung peritnya kejahilan.';

  @override
  String get uq_ulama_aku_tidak_berhenti_belajar_sejak_aku_men =>
      'Aku tidak berhenti belajar sejak aku menyedari bahawa aku masih jahil.';

  @override
  String get uq_ulama_aku_tidak_memberi_fatwa_sampai_aku_berta =>
      'Aku tidak memberikan fatwa sehingga aku bertanya kepada orang yang lebih berilmu daripada diriku.';

  @override
  String get uq_ulama_manusia_lebih_membutuhkan_ilmu_daripada =>
      'Manusia lebih memerlukan ilmu daripada makanan dan minuman.';

  @override
  String get uq_ulama_aku_tidak_menulis_satu_hadis_pun_melaink =>
      'Aku tidak menulis satu Hadis pun melainkan aku mengamalkannya terlebih dahulu.';

  @override
  String get uq_ulama_ilmu_tanpa_amal_seperti_pohon_tanpa_buah =>
      'Ilmu tanpa amal ibarat pohon yang tidak berbuah.';

  @override
  String get uq_ulama_anak_adam_hanyalah_kumpulan_hari_hari_se =>
      'Anak Adam hanyalah himpunan hari-hari. Setiap kali satu hari berlalu, sebahagian daripada dirinya turut pergi.';

  @override
  String get uq_ulama_barangsiapa_mengenal_allah_dia_akan_menc =>
      'Sesiapa yang mengenal Allah, dia akan mencintai-Nya; dan sesiapa yang mencintai-Nya akan sibuk dengan-Nya.';

  @override
  String get uq_ulama_sesungguhnya_dunia_ini_hanya_sebentar_ja =>
      'Sesungguhnya dunia ini hanyalah sementara, janganlah kita bekerja untuknya seolah-olah kita akan hidup selamanya.';

  @override
  String get uq_ulama_jadikan_dunia_ini_cukup_berada_di_tangan =>
      'Jadikanlah dunia ini sekadar di tanganmu, jangan biarkan ia masuk ke dalam hatimu.';

  @override
  String get uq_ulama_perbanyaklah_mengingat_mati_karena_itu_m =>
      'Perbanyakkanlah mengingati mati, kerana ia menghapuskan kecintaan terhadap dunia.';

  @override
  String get uq_ulama_aku_tidak_mengobati_sesuatu_yang_lebih_b =>
      'Aku tidak mengubati sesuatu yang lebih berat daripada niatku sendiri.';

  @override
  String get uq_ulama_ilmu_itu_untuk_diamalkan_kalau_tidak_dia =>
      'Ilmu itu untuk diamalkan; jika tidak diamalkan, ia akan pergi.';

  @override
  String get uq_ulama_diam_adalah_hikmah_tapi_sedikit_orang_ya =>
      'Diam itu satu hikmah, tetapi sedikit orang yang mahu mengamalkannya.';

  @override
  String get uq_ulama_sebaik_baik_hati_adalah_yang_dipenuhi_ra =>
      'Sebaik-baik hati adalah yang dipenuhi dengan rasa takut dan harap kepada Allah.';

  @override
  String get uq_ulama_tidak_ada_yang_lebih_bermanfaat_bagi_hat =>
      'Tidak ada yang lebih bermanfaat bagi hati selain membaca Al-Qur\'an dengan tadabbur.';

  @override
  String get uq_ulama_hati_bisa_sakit_seperti_badan_sakit_dan =>
      'Hati boleh sakit seperti mana badan sakit, dan ubatnya adalah istighfar.';

  @override
  String get uq_ulama_kesabaran_itu_cahaya_dengannya_jalan_yan =>
      'Kesabaran itu cahaya — dengannya jalan yang sempit terasa lapang.';

  @override
  String get uq_ulama_ilmu_tanpa_amal_adalah_sia_sia_dan_amal =>
      'Ilmu tanpa amal adalah sia-sia, dan amal tanpa ilmu tidak akan sempurna.';

  @override
  String get uq_ulama_kebahagiaan_bukan_pada_banyaknya_harta_t =>
      'Kebahagiaan bukanlah pada banyaknya harta, tetapi pada lapangnya hati.';

  @override
  String get uq_ulama_siapa_yang_menuntut_ilmu_semata_untuk_me =>
      'Sesiapa yang menuntut ilmu semata-mata untuk membanggakan diri, ilmunya akan menjadi hujah ke atas dirinya.';

  @override
  String get uq_ulama_jaga_hatimu_karena_allah_melihat_bukan_h =>
      'Jagalah hatimu, kerana Allah melihat bukan sahaja amalanmu, tetapi juga apa yang ada di dalamnya.';

  @override
  String get uq_month_1 => 'Muharram';

  @override
  String get uq_month_2 => 'Safar';

  @override
  String get uq_month_3 => 'Rabiulawal';

  @override
  String get uq_month_4 => 'Rabiulakhir';

  @override
  String get uq_month_5 => 'Jamadilawal';

  @override
  String get uq_month_6 => 'Jamadilakhir';

  @override
  String get uq_month_7 => 'Rejab';

  @override
  String get uq_month_8 => 'Syaaban';

  @override
  String get uq_month_9 => 'Ramadan';

  @override
  String get uq_month_10 => 'Syawal';

  @override
  String get uq_month_11 => 'Zulkaedah';

  @override
  String get uq_month_12 => 'Zulhijjah';

  @override
  String get uq_ev_1_1 => 'Tahun Baru Hijrah';

  @override
  String get uq_ev_1_10 => 'Hari Asyura';

  @override
  String get uq_ev_3_12 => 'Maulidur Rasul';

  @override
  String get uq_ev_7_27 => 'Israk Mikraj';

  @override
  String get uq_ev_8_15 => 'Nisfu Syaaban';

  @override
  String get uq_ev_9_1 => 'Awal Ramadan';

  @override
  String get uq_ev_9_17 => 'Nuzul Al-Quran';

  @override
  String get uq_ev_10_1 => 'Hari Raya Aidilfitri';

  @override
  String get uq_ev_12_9 => 'Hari Arafah';

  @override
  String get uq_ev_12_10 => 'Hari Raya Aidiladha';

  @override
  String get hjHariPentingTitle => 'Hari Penting Islam';

  @override
  String get hjHariPentingEmpty => 'Tidak dapat memuatkan tarikh penting.';

  @override
  String get hjHariPentingSemantics => 'Tarikh Hijrah, buka Hari Penting Islam';

  @override
  String get hjToday => 'Hari ini!';

  @override
  String get hjPassed => 'Telah berlalu';

  @override
  String hjDaysLeft(Object days) {
    return '$days hari lagi';
  }

  @override
  String get hjHijriSuffix => 'H';

  @override
  String get qiblaCalibrationHint =>
      '💡 Kalibrasi kompas: putar peranti membentuk angka 8 beberapa kali untuk ketepatan terbaik.';

  @override
  String get qiblaCompassLabel => 'KOMPAS KIBLAT';

  @override
  String get qiblaTitle => 'Arah Kiblat';

  @override
  String get qiblaAligned => '🎯 Tepat! Kekalkan kedudukan ini';

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
      'Peranti ini tidak mempunyai sensor magnetometer. Sila gunakan panduan arah di bawah sebagai alternatif.';

  @override
  String get qiblaAlignedTitle => 'Sudah Menghadap Kiblat!';

  @override
  String get qiblaAimTitle => 'Arahkan Peranti ke Kiblat';

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
    return 'Putar peranti $degrees° mengikut arah jam dari utara untuk menghadap kiblat.';
  }

  @override
  String qiblaOffset(String degrees) {
    return 'Sisihan $degrees° dari kiblat';
  }

  @override
  String get dzResetTitle => 'Set semula kaunter?';

  @override
  String dzResetBody(String item) {
    return 'Kaunter \"$item\" akan ditetapkan semula ke 0.\\nJumlah zikir hari ini TETAP dikira.';
  }

  @override
  String get dzResetCancel => 'BATAL';

  @override
  String get dzResetConfirm => 'SET SEMULA';

  @override
  String get dzTapHint => 'Ketik di mana-mana sahaja untuk berzikir';

  @override
  String dzToday(String total) {
    return 'Hari ini: $total';
  }

  @override
  String get dzVibrateOff => 'Matikan getaran';

  @override
  String get dzVibrateOn => 'Aktifkan getaran';

  @override
  String get dzResetThis => 'Set semula kaunter ini';

  @override
  String get dzTargetDone => 'SASARAN TERCAPAI';

  @override
  String get hdEmptyPage => 'Tiada Hadis di halaman ini.';

  @override
  String get hdLoadFailed => 'Gagal memuatkan Hadis.';

  @override
  String get hdLoadFailedRetry => 'Gagal memuatkan Hadis. Cuba lagi.';

  @override
  String get hdSearchFailed => 'Gagal mencari Hadis.';

  @override
  String get hdRandomFailed => 'Gagal mendapatkan Hadis rawak. Cuba lagi.';

  @override
  String get hdSearchHint => 'Cari Hadis…';

  @override
  String hdSearchFound(String total) {
    return '$total Hadis ditemui';
  }

  @override
  String get hdSearchEmpty => 'Tiada Hadis ditemui.';

  @override
  String get hdBackToList => 'Kembali ke senarai';

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
  String get dzTransHawla => 'Tiada daya & kekuatan melainkan dengan Allah';

  @override
  String get blModulNotFound => 'Modul tidak ditemui';

  @override
  String get blModulDone => 'Modul Selesai!';

  @override
  String get blKnowledgeUp => 'Pengetahuan anda semakin bertambah.';

  @override
  String get blMinScore70 => 'Minimum 70% untuk lulus. Cuba lagi!';

  @override
  String get blReadAgain =>
      'Baca semula artikel, kemudian cuba kuiz lagi. Anda pasti boleh!';

  @override
  String get blBackToHub => 'Kembali ke Hub';

  @override
  String get qdArabicSize => 'Saiz teks Arab';

  @override
  String get qdTransSize => 'Saiz terjemahan';

  @override
  String get qdLatinHint => 'Bacaan rumi untuk membantu membaca Arab';

  @override
  String get qdTajwidColors => 'Warna Tajwid';

  @override
  String get qdTafsirMuyassar => 'Tafsir Muyassar (ringkas, mudah difahami)';

  @override
  String get qdTafsirKemenag => 'Tafsir Kemenag (lengkap)';

  @override
  String get ppUnlockSkins => 'Nyahkunci semua skin premium';

  @override
  String get ppActivateDev => 'Aktifkan Pro (dev)';

  @override
  String get deExpTitle => 'DAPAT XP!';

  @override
  String get bqModulNotFound => 'Modul tidak ditemui';

  @override
  String get bqQuizUnavailable => 'Kuiz belum tersedia';

  @override
  String get bqNotYetRight => 'Belum tepat';

  @override
  String get qpPrevAyah => 'Ayat sebelumnya';

  @override
  String get qpNextAyah => 'Ayat berikutnya';

  @override
  String get qpMurrotalSettings => 'Tetapan murattal';

  @override
  String get qpbRepeatRange => 'Ulangi julat';

  @override
  String get qpbSleepTimer => 'Pemasa tidur';

  @override
  String get qpbEndOfSurah => 'Akhir surah';

  @override
  String get qbNoBookmark => 'Tiada penanda buku';

  @override
  String get qbDeleteBookmark => 'Padam penanda buku';

  @override
  String get qacDeleteBookmark => 'Padam penanda buku';

  @override
  String get phPrevMonth => 'Bulan sebelumnya';

  @override
  String get phNextMonth => 'Bulan berikutnya';

  @override
  String get clProLocked => 'Pro dikunci';

  @override
  String get clCompleteQuest =>
      'Selesaikan misi harian untuk membuka skin daripada Daily Chest.';

  @override
  String get qdTajwidLegend => 'Merah=Ghunnah, Biru=Qalqalah/Idgham, Hijau=Mad';

  @override
  String get ppProPitch =>
      'Perisai, aura dan gelaran eksklusif. Gaya baharu untuk avatar anda — tanpa mempengaruhi XP, streak atau kedudukan anda.';

  @override
  String deQuizDone(String moduleTitle) {
    return 'Anda telah menyelesaikan kuiz $moduleTitle!';
  }

  @override
  String deLevelShort(int level) {
    return 'Lv $level';
  }

  @override
  String deLevel(int level) {
    return 'Tahap $level';
  }

  @override
  String bqQuestionOf(int current, int total) {
    return 'SOALAN $current/$total';
  }

  @override
  String qbSurahName(int number) {
    return 'Surah $number';
  }

  @override
  String qacAyahNumber(int number) {
    return 'Ayat $number';
  }
}

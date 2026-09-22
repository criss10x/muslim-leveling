// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppL10nTr extends AppL10n {
  AppL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get achBtnAwesome => 'HARİKA!';

  @override
  String get achBtnSkipAll => 'Tümünü geç';

  @override
  String achEarnedOn(String date, String tier) {
    return '$date tarihinde kazanıldı • $tier';
  }

  @override
  String achHintFallback(String desc) {
    return 'Tamamlayın: $desc.';
  }

  @override
  String achLockedTier(String tier) {
    return 'Kilitli • $tier';
  }

  @override
  String achScreenProgress(int total) {
    return ' / $total madalya açıldı';
  }

  @override
  String get achScreenTitle => 'Başarımlar';

  @override
  String get achSectionTitle => 'BAŞARIMLAR';

  @override
  String get achSeeAll => 'Tümünü gör';

  @override
  String achSemanticsDetail(
    String state,
    String title,
    String desc,
    String tier,
  ) {
    return '$state: $title. $desc. Seviye $tier.';
  }

  @override
  String achSemanticsUnlocked(String title, String desc, String tier) {
    return 'Başarım açıldı: $title. $desc. Seviye $tier.';
  }

  @override
  String get achStateLocked => 'Kilitli';

  @override
  String get achStateUnlocked => 'Açıldı';

  @override
  String get achTierElite => 'ELİT';

  @override
  String get achTierEpic => 'EPİK';

  @override
  String get achTierGold => 'ALTIN';

  @override
  String get achTierLegendary => 'EFSANEVİ';

  @override
  String get achTierRookie => 'ÇAYLAK';

  @override
  String get achUnlockedBanner => 'BAŞARIM AÇILDI!';

  @override
  String get ach_collector_desc =>
      'En az 1 kez olmak üzere 8 sünnet namaz türünün tamamını kaydedin';

  @override
  String get ach_collector_hint =>
      '8 sünnet türünden en az 1 kez kaydedin: Duha, Teheccüd ve 6 revatib.';

  @override
  String get ach_collector_title => 'KOLEKSİYONCU';

  @override
  String get ach_comeback_real_desc =>
      'Seri bozulduktan sonra yeniden ayağa kalkın';

  @override
  String get ach_comeback_real_title => 'GERİ DÖNÜŞ GERÇEKTİR';

  @override
  String get ach_critical_hit_desc =>
      'Ezan okunduktan sonra ≤5 dakika içinde farz namazı kılın';

  @override
  String get ach_critical_hit_title => 'KRİTİK VURUŞ!';

  @override
  String get ach_dawn_buff_desc =>
      'İlk kez Sabah namazının ilk sünnetini kılın';

  @override
  String get ach_dawn_buff_title => 'ŞAFAK GÜÇLENDİRMESİ';

  @override
  String get ach_dhuha_secured_desc => 'İlk kez Duha namazını kaydedin';

  @override
  String get ach_dhuha_secured_title => 'DHUHA GÜVENCEDE';

  @override
  String get ach_dominating_desc => 'Üst üste 7 gün boyunca Kahraman Serisi';

  @override
  String get ach_dominating_title => 'HÜKMEDİCİ!';

  @override
  String get ach_double_kill_desc => 'Üst üste 2 gün boyunca Kahraman Serisi';

  @override
  String get ach_double_kill_title => 'İKİDE İKİ';

  @override
  String get ach_dusk_finisher_desc =>
      'İlk kez Akşam namazının son sünnetini kılın';

  @override
  String get ach_dusk_finisher_title => 'ALACAKARANLIK BİTİRİCİ';

  @override
  String get ach_dzikir_legend_desc => '50.000 kez zikir yapın';

  @override
  String get ach_dzikir_legend_hint =>
      'Hesabın ömrü boyunca Zikir sekmesinden yapılan toplam zikir sayısı.';

  @override
  String get ach_dzikir_legend_title => 'ZİKİR EFSANESİ';

  @override
  String get ach_dzikir_master_desc => '10.000 kez zikir yapın';

  @override
  String get ach_dzikir_master_title => 'ZİKİR USTASI';

  @override
  String get ach_dzikir_pemula_desc => '1.000 kez zikir yapın';

  @override
  String get ach_dzikir_pemula_title => 'ZİKİR BAŞLANGIÇ';

  @override
  String get ach_early_bird_desc =>
      '20 kez vaktinde namaz kılın (ezandan sonra ≤10 dakika)';

  @override
  String get ach_early_bird_hint =>
      '20 kez vaktinde namaz kılın (ezandan sonra ≤10 dakika içinde).';

  @override
  String get ach_early_bird_title => 'ERKEN KALKAN';

  @override
  String get ach_early_game_desc => 'İlk Sabah namazınız kaydedildi';

  @override
  String get ach_early_game_title => 'ERKEN OYUN';

  @override
  String get ach_first_blood_desc =>
      '1 günde 5 vakit farz namazı tamamlayın (Kahraman Serisi başlasın!)';

  @override
  String get ach_first_blood_hint =>
      'Bir günde 5 vakit farz namazı kaydedin (Sabah, Öğle, İkindi, Akşam, Yatsı).';

  @override
  String get ach_first_blood_title => 'İLK KAN!';

  @override
  String get ach_first_clear_module_desc => 'İlk Öğrenme modülünüzü tamamlayın';

  @override
  String get ach_first_clear_module_title => 'İLK TEMİZLEME';

  @override
  String get ach_first_strike_desc =>
      'Ezan okunduktan sonra ≤15 dakika içinde Sabah namazını kılın';

  @override
  String get ach_first_strike_hint =>
      'Ezan okunduktan sonra 15 dakika içinde Sabah namazını kılın.';

  @override
  String get ach_first_strike_title => 'İLK VURUŞ';

  @override
  String get ach_full_combo_desc => '1 günde: 5 vakit farz + Tilavet + Duha';

  @override
  String get ach_full_combo_hint =>
      'Bir günde: 5 vakit farz + Tilavet + Duha kaydedin.';

  @override
  String get ach_full_combo_title => 'TAM KOMBO';

  @override
  String get ach_godlike_desc => 'Üst üste 30 gün boyunca Kahraman Serisi';

  @override
  String get ach_godlike_title => 'MUHTEŞEM!';

  @override
  String get ach_gold_buff_desc =>
      'İlk kez İkindi namazının ilk sünnetini kılın';

  @override
  String get ach_gold_buff_title => 'ALTIN GÜÇLENDİRME';

  @override
  String get ach_gold_lane_desc => 'İlk kez İkindi namazını kaydedin';

  @override
  String get ach_gold_lane_title => 'ALTIN KORİDOR';

  @override
  String get ach_hadis_champion_desc => '200 Hadis okuyun';

  @override
  String get ach_hadis_champion_title => 'HADİS ŞAMPİYONU';

  @override
  String get ach_hadis_elite_desc => '50 Hadis okuyun';

  @override
  String get ach_hadis_elite_title => 'HADİS ELİT';

  @override
  String get ach_hadis_grinder_desc => '10 Hadis okuyun';

  @override
  String get ach_hadis_grinder_title => 'HADİS GRINDER';

  @override
  String get ach_hadis_hero_desc => '350 Hadis okuyun';

  @override
  String get ach_hadis_hero_title => 'HADİS KAHRAMANI';

  @override
  String get ach_hadis_legend_desc => '500 Hadis okuyun';

  @override
  String get ach_hadis_legend_title => 'HADİS EFSANESİ';

  @override
  String get ach_hadis_rookie_desc => '5 Hadis okuyun';

  @override
  String get ach_hadis_rookie_title => 'HADİS ÇAYLAĞI';

  @override
  String get ach_hadis_veteran_desc => '100 Hadis okuyun';

  @override
  String get ach_hadis_veteran_title => 'HADİS VETERANI';

  @override
  String get ach_hadis_warrior_desc => '25 Hadis okuyun';

  @override
  String get ach_hadis_warrior_title => 'HADİS SAVAŞÇISI';

  @override
  String get ach_hall_of_fame_desc => 'Diğer tüm başarımları açın 👑';

  @override
  String get ach_hall_of_fame_hint =>
      'Diğer tüm başarımları tek tek açın — 87 normal madalyanın sonuncusu.';

  @override
  String get ach_hall_of_fame_title => 'ŞÖHRETLER HOLÜ';

  @override
  String get ach_jamaah_champion_desc => '200 kez cemaatle namaz kılın';

  @override
  String get ach_jamaah_champion_title => 'CEMAAT ŞAMPİYONU';

  @override
  String get ach_jamaah_elite_desc => '50 kez cemaatle namaz kılın';

  @override
  String get ach_jamaah_elite_title => 'CEMAAT ELİT';

  @override
  String get ach_jamaah_grinder_desc => '10 kez cemaatle namaz kılın';

  @override
  String get ach_jamaah_grinder_title => 'CEMAAT GRINDER';

  @override
  String get ach_jamaah_hero_desc => '350 kez cemaatle namaz kılın';

  @override
  String get ach_jamaah_hero_title => 'CEMAAT KAHRAMANI';

  @override
  String get ach_jamaah_legend_desc => '500 kez cemaatle namaz kılın';

  @override
  String get ach_jamaah_legend_title => 'CEMAAT EFSANESİ';

  @override
  String get ach_jamaah_rookie_desc => '5 kez cemaatle namaz kılın';

  @override
  String get ach_jamaah_rookie_title => 'CEMAAT ÇAYLAĞI';

  @override
  String get ach_jamaah_veteran_desc => '100 kez cemaatle namaz kılın';

  @override
  String get ach_jamaah_veteran_title => 'CEMAAT VETERANI';

  @override
  String get ach_jamaah_warrior_desc => '25 kez cemaatle namaz kılın';

  @override
  String get ach_jamaah_warrior_title => 'CEMAAT SAVAŞÇISI';

  @override
  String get ach_jungler_desc => 'Üst üste 7 gün Tilawah serisi';

  @override
  String get ach_jungler_title => 'JUNGLER';

  @override
  String get ach_langkah_pertama_desc => 'İlk namaz kaydınız';

  @override
  String get ach_langkah_pertama_title => 'İLK ADIM';

  @override
  String get ach_late_game_desc => 'İlk kez Yatsı namazı kaydı';

  @override
  String get ach_late_game_title => 'LATE GAME';

  @override
  String get ach_legendary_desc => 'Üst üste 100 gün Kahraman Serisi';

  @override
  String get ach_legendary_title => 'LEGENDARY!';

  @override
  String get ach_mana_regen_desc => 'İlk kez Tilawah/Zikir kaydı';

  @override
  String get ach_mana_regen_title => 'MANA REGEN';

  @override
  String get ach_maniac_desc => 'Üst üste 14 gün Kahraman Serisi';

  @override
  String get ach_maniac_title => 'MANIAC!';

  @override
  String get ach_mid_buff_desc => 'İlk kez Öğle namazının ilk sünneti kaydı';

  @override
  String get ach_mid_buff_title => 'MID BUFF';

  @override
  String get ach_mid_finisher_desc =>
      'İlk kez Öğle namazının son sünneti kaydı';

  @override
  String get ach_mid_finisher_title => 'MID FINISHER';

  @override
  String get ach_mid_game_desc => 'İlk kez Öğle namazı kaydı';

  @override
  String get ach_mid_game_title => 'MID GAME';

  @override
  String get ach_night_finisher_desc =>
      'İlk kez Yatsı namazının son sünneti kaydı';

  @override
  String get ach_night_finisher_title => 'NIGHT FINISHER';

  @override
  String get ach_phoenix_desc =>
      'Seri bozulduktan sonra 3 kez yeniden ayağa kalkın — asla pes etmeyin';

  @override
  String get ach_phoenix_hint =>
      'Seri bozulduktan sonra, 3 kez yeniden ayağa kalkana kadar tekrar başlayın.';

  @override
  String get ach_phoenix_title => 'PHOENIX';

  @override
  String get ach_quiz_mvp_desc => 'Tek bir bilgi yarışmasında %100 tam puan';

  @override
  String get ach_quiz_mvp_hint =>
      'Öğrenme modülünün sonundaki testi çözün ve tüm soruları doğru yanıtlayın (%100).';

  @override
  String get ach_quiz_mvp_title => 'MVP';

  @override
  String get ach_quran_adept_desc => '100 ayet okuyun';

  @override
  String get ach_quran_adept_title => 'AL-QUR\'AN ADEPT';

  @override
  String get ach_quran_apprentice_desc => '50 ayet okuyun';

  @override
  String get ach_quran_apprentice_title => 'AL-QUR\'AN APPRENTICE';

  @override
  String get ach_quran_champion_desc => '4.000 ayet okuyun';

  @override
  String get ach_quran_champion_title => 'AL-QUR\'AN CHAMPION';

  @override
  String get ach_quran_guardian_desc => '2.000 ayet okuyun';

  @override
  String get ach_quran_guardian_title => 'AL-QUR\'AN GUARDIAN';

  @override
  String get ach_quran_hafizh_desc => '1.000 ayet okuyun';

  @override
  String get ach_quran_hafizh_title => 'GENÇ HAFIZ';

  @override
  String get ach_quran_master_desc => '6.236 ayet okuyun (hatim)';

  @override
  String get ach_quran_master_hint =>
      'İlk kurulumdan itibaren toplam 6.236 ayet (tüm Al-Qur\'an) okuyun.';

  @override
  String get ach_quran_master_title => 'HAFIZ MASTER';

  @override
  String get ach_quran_novice_desc => '10 ayet okuyun';

  @override
  String get ach_quran_novice_title => 'AL-QUR\'AN NOVICE';

  @override
  String get ach_quran_sage_desc => '500 ayet okuyun';

  @override
  String get ach_quran_sage_title => 'AL-QUR\'AN SAGE';

  @override
  String get ach_quran_scholar_desc => '200 ayet okuyun';

  @override
  String get ach_quran_scholar_title => 'AL-QUR\'AN SCHOLAR';

  @override
  String get ach_rank_elite_desc => '25. Seviyeye ulaşın';

  @override
  String get ach_rank_elite_title => 'ELITE';

  @override
  String get ach_rank_epic_desc => '60. Seviyeye ulaşın';

  @override
  String get ach_rank_epic_title => 'EPIC';

  @override
  String get ach_rank_master_desc => '40. Seviyeye ulaşın';

  @override
  String get ach_rank_master_title => 'MASTER';

  @override
  String get ach_rank_mythic_desc => '80. Seviyeye ulaşın — Muslim Mythic!';

  @override
  String get ach_rank_mythic_hint =>
      'Günlük ibadetlerden kazanılan XP ile seviye atlayın — 80. seviyeye ulaşmak zaman alır.';

  @override
  String get ach_rank_mythic_title => 'MYTHIC';

  @override
  String get ach_rank_warrior_desc => '10. Seviyeye ulaşın';

  @override
  String get ach_rank_warrior_title => 'WARRIOR';

  @override
  String get ach_sage_desc => '16 Öğrenme modülünün tamamını bitirin';

  @override
  String get ach_sage_hint =>
      '16 Öğrenme modülünün tamamını tamamlayın (test puanı önemli değildir).';

  @override
  String get ach_sage_title => 'SAGE';

  @override
  String get ach_santri_scholar_desc => '40 Öğrenme modülünü tamamlayın';

  @override
  String get ach_santri_scholar_hint =>
      'Öğrenme sekmesindeki 40 modülü tamamlayın (şu anda 16 modül mevcuttur, kademeli olarak artacaktır).';

  @override
  String get ach_santri_scholar_title => 'SANTRI SCHOLAR';

  @override
  String get ach_savage_desc => 'Üst üste 60 gün Kahraman Serisi';

  @override
  String get ach_savage_title => 'SAVAGE!';

  @override
  String get ach_sharpshooter_desc => '10× vaktinde kılınan namaz (≤10 dakika)';

  @override
  String get ach_sharpshooter_hint =>
      'Ezan okunduktan sonraki 10 dakika içinde 10× vaktinde kılınan namaz.';

  @override
  String get ach_sharpshooter_title => 'SHARPSHOOTER';

  @override
  String get ach_subuh_legend_desc => '30 günlük Sabah namazı serisi';

  @override
  String get ach_subuh_legend_title => 'SABAH LEGEND';

  @override
  String get ach_subuh_solo_carry_desc =>
      'Üst üste 7 gün Sabah namazı serisi — en zor koridor';

  @override
  String get ach_subuh_solo_carry_title => 'SABAH SOLO CARRY';

  @override
  String get ach_sultan_sunnah_desc => 'Toplam 50 sünnet namazı';

  @override
  String get ach_sultan_sunnah_title => 'SÜNNET SULTANI';

  @override
  String get ach_sunnah_master_desc => 'Toplam 200 sünnet namazı';

  @override
  String get ach_sunnah_master_hint =>
      '8 çeşit sünnet namazının (Duha, Revatib, Teheccüd vb.) toplam kaydı.';

  @override
  String get ach_sunnah_master_title => 'SÜNNET MASTER';

  @override
  String get ach_sunset_strike_desc => 'İlk kez Akşam namazı kaydı';

  @override
  String get ach_sunset_strike_title => 'SUNSET STRIKE';

  @override
  String get ach_tahajjud_secured_desc => 'İlk kez Teheccüd namazı kaydı';

  @override
  String get ach_tahajjud_secured_title => 'TAHAJJUD SECURED';

  @override
  String get ach_tilawah_streak_14_desc => '14 günlük Tilawah serisi';

  @override
  String get ach_tilawah_streak_14_title => 'TILAWAH STREAK';

  @override
  String get ach_triple_kill_desc => 'Üst üste 3 gün Kahraman Serisi';

  @override
  String get ach_triple_kill_title => 'TRIPLE KILL';

  @override
  String get ach_unstoppable_desc => 'Üst üste 5 gün Kahraman Serisi';

  @override
  String get ach_unstoppable_title => 'UNSTOPPABLE!';

  @override
  String get ach_wajib_champion_desc => '400× farz namaz';

  @override
  String get ach_wajib_champion_title => 'FARZ CHAMPION';

  @override
  String get ach_wajib_elite_desc => '100× farz namaz';

  @override
  String get ach_wajib_elite_title => 'FARZ ELITE';

  @override
  String get ach_wajib_grinder_desc => '25× farz namaz';

  @override
  String get ach_wajib_grinder_title => 'FARZ GRINDER';

  @override
  String get ach_wajib_hero_desc => '700× farz namaz';

  @override
  String get ach_wajib_hero_title => 'FARZ HERO';

  @override
  String get ach_wajib_immortal_desc => '2.000× farz namaz';

  @override
  String get ach_wajib_immortal_hint =>
      'Hesabın ömrü boyunca kaydedilen toplam farz namaz sayısı.';

  @override
  String get ach_wajib_immortal_title => 'FARZ IMMORTAL';

  @override
  String get ach_wajib_master_desc => '1.000× farz namaz';

  @override
  String get ach_wajib_master_title => 'FARZ MASTER';

  @override
  String get ach_wajib_mythic_desc => '1.500× farz namaz';

  @override
  String get ach_wajib_mythic_title => 'MİTİK FARZ';

  @override
  String get ach_wajib_rookie_desc => '10x farz namaz';

  @override
  String get ach_wajib_rookie_title => 'ÇAYLAK FARZ';

  @override
  String get ach_wajib_veteran_desc => '200x farz namaz';

  @override
  String get ach_wajib_veteran_title => 'KIDEMLİ FARZ';

  @override
  String get ach_wajib_warrior_desc => '50x farz namaz';

  @override
  String get ach_wajib_warrior_title => 'SAVAŞÇI FARZ';

  @override
  String get ach_wombo_combo_desc =>
      'Günlük 100 Zikir görevini ilk kez tamamlayın';

  @override
  String get ach_wombo_combo_title => 'WOMBO COMBO';

  @override
  String get appTitle => 'Muslim Leveling';

  @override
  String get commonCancel => 'İptal';

  @override
  String get cityPickerEmptyKab => 'İlçe/şehir bulunamadı';

  @override
  String get cityPickerEmptyProv => 'İl bulunamadı';

  @override
  String get cityPickerHintKab => 'İlçe/şehir adı yazın...';

  @override
  String get cityPickerHintProv => 'İl adı yazın...';

  @override
  String get cityPickerNotFound =>
      'İlçe/şehir bulunamadı. Lütfen başka bir il seçmeyi deneyin.';

  @override
  String get cityPickerLoadFailed =>
      'İlçe/şehir listesi yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get cityPickerRetry => 'Tekrar dene';

  @override
  String get cityPickerTitleKab => 'İlçe/Şehir Seçin';

  @override
  String get cityPickerTitleProv => 'İl Seçin';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonLogout => 'Çıkış Yap';

  @override
  String get commonOk => 'Tamam';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get homeAskWajibBody =>
      'XP bonusu kazanmak için namaz durumunuzu seçin';

  @override
  String homeAskWajibTitle(String prayer) {
    return 'Namazınızı kıldınız mı ($prayer)?';
  }

  @override
  String get homeBonusJamaah => 'Cemaatle';

  @override
  String get homeBonusJamaahSub => 'cemaatle kılınan namaz';

  @override
  String get homeBonusOnTime => 'Vaktinde';

  @override
  String get homeBonusOnTimeSub => 'ezandan sonraki 30 dakika içinde';

  @override
  String get homeBonusPlain => 'Kılındı';

  @override
  String get homeBonusPlainSub => 'XP bonusu olmadan';

  @override
  String get homeBonusQuestSunnah => 'BONUS GÖREV · SÜNNET';

  @override
  String get homeChestLocked => '5 farz namazı tamamlayın';

  @override
  String get homeChestMetaOpened => 'AÇILDI';

  @override
  String homeChestMetaProgress(int done, int total) {
    return '$done/$total FARZ';
  }

  @override
  String get homeChestOpenedLabel => 'SANDIK AÇILDI';

  @override
  String get homeChestOpenedSub => 'Yarın tekrar bekleriz! 🌙';

  @override
  String get homeChestReadyLabel => 'ÖDÜL HAZIR!';

  @override
  String get homeChestReadySub => 'Almak için tıklayın 🎉';

  @override
  String get homeChestTitle => 'GÜNLÜK SANDIK';

  @override
  String get homeDefaultCity => 'Cakarta';

  @override
  String homeLevelUpSource(String prayer) {
    return '$prayer Namazı';
  }

  @override
  String homeLockAfterTime(String prayer) {
    return '$prayer vakti geçti.';
  }

  @override
  String homeLockBeforeTime(String prayer, String time) {
    return 'Henüz $prayer vakti girmedi (ezan $time).';
  }

  @override
  String homeLockSubuh(int hours, String until) {
    return 'Sabah namazı görevi ezandan $hours saat sonra ($until vaktine kadar) kilitlenir. Yarın kaçırmayın! 💪';
  }

  @override
  String get homeLogDuplicate => 'Bu namaz bugün zaten kaydedildi!';

  @override
  String get homeNext => 'SONRAKİ';

  @override
  String homeQuestClaimable(int n) {
    return '$n ALINMAYA HAZIR';
  }

  @override
  String get homeQuestDaily => 'GÜNLÜK GÖREVLER';

  @override
  String get homeQuickActions => 'HIZLI ERİŞİM';

  @override
  String homeQuickActionsMeta(int done, int total) {
    return 'TEFEKKÜR $done/$total';
  }

  @override
  String get homeQuickDoa => 'Dua';

  @override
  String get homeQuickDzikir => 'Zikir';

  @override
  String get homeQuickHadis => 'Hadis';

  @override
  String get homeQuickKiblat => 'Kıble';

  @override
  String get homeQuickRenungan => 'Tefekkür';

  @override
  String get homeRevealBtn => 'Alhamdulillah! 🤲';

  @override
  String get homeRevealCosmetic => 'YENİ KOZMETİK!';

  @override
  String get homeRevealDuplicate =>
      'Yinelenen öge — koleksiyonunuzda saklanmaya devam ediyor 📦';

  @override
  String homeRevealLevelUp(String suffix) {
    return '⬆️ Seviye Atladınız!$suffix';
  }

  @override
  String get homeRevealReward => 'ÖDÜL KAZANILDI!';

  @override
  String get homeRevealShield => 'DONDURMA KALKANI!';

  @override
  String homeRevealShieldBody(int count) {
    return 'Namazı unuttuğunuzda seriniz 1 gün boyunca korunur. Toplam: $count ❄️';
  }

  @override
  String get homeRingWajib => 'FARZ';

  @override
  String get homeRitualToday => 'BUGÜNKÜ İBADETLER';

  @override
  String get homeSideDone => 'Bugün tamamlandı ✓';

  @override
  String get homeSideDzikir => '100x Zikir';

  @override
  String homeSideDzikirSub(int count, int target) {
    return '$count/$target zikir';
  }

  @override
  String get homeSideHadis => 'Hadis Çalış';

  @override
  String homeSideHadisSub(int count, int target) {
    return '$count/$target Hadis okundu';
  }

  @override
  String get homeSideQuestTitle => 'YAN GÖREVLER';

  @override
  String get homeSideQuran => 'Al-Qur\'an Oku';

  @override
  String homeSideQuranSub(int done, int target) {
    return 'Bugün $done/$target ayet';
  }

  @override
  String get homeSideSedekah => 'Sadaka';

  @override
  String get homeSideSedekahSub => 'Bugün sadaka verin';

  @override
  String get homeSunnahHintBadiyahDzuhur =>
      'Öğle namazının son sünneti, öğle namazından sonra başlayıp ikindi namazı vaktine kadar kılınabilir.';

  @override
  String get homeSunnahHintBadiyahIsya =>
      'Yatsı namazının son sünneti, yatsı namazından sonra başlayıp gece yarısına kadar kılınabilir.';

  @override
  String get homeSunnahHintBadiyahMaghrib =>
      'Akşam namazının son sünneti, akşam namazından sonra başlayıp yatsı namazı vaktine kadar kılınabilir.';

  @override
  String get homeSunnahHintDhuha =>
      'Duha (Kuşluk) namazı, güneş doğduktan sonra (yaklaşık 15 dakika sonra) başlayıp öğle namazı vaktine kadar kılınabilir.';

  @override
  String get homeSunnahHintFallback => 'Lütfen daha sonra tekrar deneyin.';

  @override
  String get homeSunnahHintQobliyahAshar =>
      'İkindi namazının ilk sünneti, ikindi namazı vaktinden akşam namazı vaktine kadar kılınabilir.';

  @override
  String get homeSunnahHintQobliyahDzuhur =>
      'Öğle namazının ilk sünneti, öğle namazı vaktinden ikindi namazı vaktine kadar kılınabilir.';

  @override
  String get homeSunnahHintQobliyahSubuh =>
      'Sabah namazının sünneti, sabah namazı vaktiyle aynıdır (imsaktan güneş doğana kadar).';

  @override
  String get homeSunnahHintTahajjud =>
      'Teheccüd namazı, yatsı namazından sonra başlayıp imsak vaktine kadar kılınabilir.';

  @override
  String get homeUnitDays => 'gün';

  @override
  String get homeWajibQuest => 'FARZ GÖREVLERİ';

  @override
  String get homeXpToNextRank => 'SONRAKİ RÜTBE İÇİN XP';

  @override
  String get localeEnglish => 'İngilizce';

  @override
  String get localeIndonesian => 'Endonezce';

  @override
  String get localeMalay => 'Bahasa Melayu';

  @override
  String get localeTurkish => 'Türkçe';

  @override
  String get localePicked => 'Seçilen dil';

  @override
  String get localeSystem => 'Sistem Dilini Kullan';

  @override
  String get localeTitle => 'Uygulama dili';

  @override
  String get onbContinue => 'Devam Et';

  @override
  String get onbDefaultNickname => 'Mücadeleci';

  @override
  String get onbGenderAkhwat => 'AKHWAT';

  @override
  String get onbGenderIkhwan => 'IKHWAN';

  @override
  String get onbGenderMeaning =>
      'Ikhwan erkek, Akhwat ise kadın anlamına gelir.';

  @override
  String get onbGenderPrivacy =>
      'Cevabınız yalnızca menüleri gizlemek için kullanılır. Profilinizden dilediğiniz zaman değiştirebilirsiniz.';

  @override
  String get onbGenderSkip => 'Gerek yok';

  @override
  String get onbGenderTitle => 'Ikhwan mısınız yoksa Akhwat mı?';

  @override
  String get onbGenderWhy =>
      'Akhwat kullanıcıları için Özel Gün Dönemi özelliği mevcuttur: Bu dönemde, herhangi bir ceza almamanız için namaz seriniz otomatik olarak dondurulur. Menünün sade kalması için bu özelliği Ikhwan görünümünden gizliyoruz.';

  @override
  String get onbHowAchBody =>
      'Serilerden, tilavetlerden ve zikirlerden madalyalar kazanın.';

  @override
  String get onbHowAchTitle => 'Başarılar';

  @override
  String get onbHowBody =>
      'Günlük ibadetlerinizi seviye atlama hissine dönüştüren üç unsur.';

  @override
  String get onbHowDemoHint => 'Karta dokunmayı deneyin';

  @override
  String get onbHowQuestBody =>
      'Günlük farz ve sünnet namazlarınızı işaretleyin.';

  @override
  String get onbHowQuestTitle => 'Günlük Görevler';

  @override
  String get onbHowTitle => 'Nasıl Oynanır';

  @override
  String get onbHowXpBody =>
      'Tamamlanan her görevden XP kazanın. Seviye atlayın, rütbe kazanın.';

  @override
  String get onbHowXpTitle => 'XP & Seviye';

  @override
  String get onbLangBody =>
      'Profilinizden dilediğiniz zaman değiştirebilirsiniz.';

  @override
  String get onbLangTitle => 'Hangi dili kullanmak istersiniz?';

  @override
  String get onbLocationAllow => 'Konuma İzin Ver';

  @override
  String get onbLocationBody =>
      'Doğru namaz vakitlerini ve kıble yönünü hesaplamak için konum erişimine ihtiyacımız var. Konumunuz kimseyle paylaşılmaz; tüm hesaplamalar telefonunuzda gerçekleşir.';

  @override
  String get onbLocationLoading => 'KONUM ALINIYOR...';

  @override
  String get onbLocationLater => 'Şimdilik varsayılan şehri kullan';

  @override
  String get onbLocationLaterHint =>
      'Konum bulunamadı mı? Vakitler şimdilik varsayılan şehre göre gösterilecektir; bunu Profilinizden dilediğiniz zaman değiştirebilirsiniz.';

  @override
  String get onbLocationPickManual => 'Şehri manuel seç';

  @override
  String get onbLocationRetry => 'Tekrar dene';

  @override
  String get onbLocationTitle => 'Konumunuza İhtiyacımız Var';

  @override
  String get onbNameBody =>
      'Bu isim Ana Sayfa\'da ve madalya kartlarında görünecektir. Boş bırakabilirsiniz.';

  @override
  String get onbNameTitle => 'Savaşçı adınız nedir?';

  @override
  String get onbNicknameHint =>
      'Savaşçı adı (isteğe bağlı — boş bırakılırsa: Savaşçı)';

  @override
  String get onbNotifAllow => 'Bildirimlere İzin Ver';

  @override
  String get onbNotifBody =>
      'Vakitleri kaçırmamanız için namaz vakti geldiğinde hatırlatıcı gönderiyoruz. Bildirim izni ve pil tasarrufu istisnası talep ediyoruz; bunlar olmadan telefonunuz, uygulama kapandığında hatırlatıcıları sessizce devre dışı bırakabilir.';

  @override
  String get onbNotifDenied =>
      'Hatırlatıcılar aktif değil. Profilinizden dilediğiniz zaman etkinleştirebilirsiniz.';

  @override
  String get onbNotifLoading => 'ETKİNLEŞTİRİLİYOR...';

  @override
  String get onbNotifSkip => 'Geç, daha sonra';

  @override
  String get onbNotifTitle => 'Ezan Hatırlatıcı';

  @override
  String get onbProgressLabel => 'Hazırlık';

  @override
  String onbStepOf(String step, String total) {
    return '$total adımdan $step. adım';
  }

  @override
  String get onbXpDemoSemantics => 'Örnek: Sabah namazı tamamlandı, +50 XP';

  @override
  String get prayerAshar => 'İkindi';

  @override
  String get prayerDzuhur => 'Öğle';

  @override
  String get prayerIsya => 'Yatsı';

  @override
  String get prayerJumat => 'Cuma';

  @override
  String get prayerMaghrib => 'Akşam';

  @override
  String get prayerSubuh => 'Sabah';

  @override
  String get profilAbout => 'Uygulama Hakkında';

  @override
  String get profilAboutBody =>
      'İbadet mükemmellik değil, istikrar gerektirir. Muslim Leveling, beş vakit namaz kılma ve Al-Qur\'an okuma alışkanlığı kazanmanıza eğlenceli bir şekilde yardımcı olur; kaydedilen her namaz XP kazandırır, kesintisiz geçen her gün serinizi (streak) uzatır ve her başarı yeni avatar görünümlerinin kilidini açar.';

  @override
  String get profilAboutFooter =>
      'Ahiret yolundaki her bir savaşçı için dualarla hazırlandı.';

  @override
  String get profilAboutOffline =>
      'Sunucu yok, reklam yok, abonelik yok. Tüm verileriniz cihazınızda kalır — tamamen size aittir.';

  @override
  String get profilAccountSettings => 'Hesap Ayarları';

  @override
  String get profilAlreadyPrayedToday => ', bugün namazını kıldı';

  @override
  String get profilAndroidNotifSettings => 'Android Bildirim Ayarları';

  @override
  String get profilBackupActive => 'Yedekleme aktif';

  @override
  String get profilBatteryPerm =>
      'Uygulama kapalıyken de hatırlatıcıların çalmaya devam etmesi için \"Pil kısıtlaması yok\" seçeneğine izin verin.';

  @override
  String get profilCalendarHeader => 'NAMAZ TAKVİMİ';

  @override
  String get profilChangePhoto => 'Fotoğrafı Değiştir';

  @override
  String get profilCloudVerifyFailed =>
      'Bulut doğrulaması başarısız oldu. Tekrar deneyin.';

  @override
  String get profilConnecting => 'BAĞLANILIYOR...';

  @override
  String get profilContinueGoogle => 'Google ile Devam Et';

  @override
  String get profilCycleExplain =>
      'Namaz serinizin ceza almadan korunması için özel gününüzde bu seçeneği etkinleştirin.';

  @override
  String get profilCycleFrozenMeta => 'özel gün modu · seri donduruldu';

  @override
  String get profilCycleFrozenSemantics =>
      'Özel gün modu aktif, seri donduruldu';

  @override
  String get profilCycleModeShort => 'özel gün modu';

  @override
  String get profilCyclePeriod => 'Özel Gün Dönemi';

  @override
  String get profilEditName => 'İsmi Düzenle';

  @override
  String get profilEditProfile => 'Profili düzenle';

  @override
  String get profilEnableReminders => 'Hatırlatıcıları etkinleştir';

  @override
  String get profilExactAlarmPerm =>
      '\"Alarm ve hatırlatıcılar\" izni etkin değil; hatırlatıcılar birkaç dakika gecikebilir.';

  @override
  String get profilFriday => 'Cuma';

  @override
  String get profilFromCamera => 'Kameradan Çek';

  @override
  String get profilFromGallery => 'Galeriden Seç';

  @override
  String get profilGender => 'Cinsiyet';

  @override
  String get profilGenderAkhwat => 'Akhwat';

  @override
  String get profilGenderExplain =>
      'Ikhwan = erkek, Akhwat = kadın. Özel Gün Dönemi menüsünü gizlemek veya göstermek için kullanılır. Bulut ile senkronize edilmez.';

  @override
  String get profilGenderIkhwan => 'Ikhwan';

  @override
  String get profilGenderUnset => 'Seçilmedi';

  @override
  String get profilHeatmapBody =>
      'Yeşil tonu arttıkça tamamlanma oranı artar — 5 ton = 5 farz namaz.';

  @override
  String get profilHeatmapHeader => 'FARZ NAMAZ TAKVİMİ';

  @override
  String get profilHeatmapRow => 'Aylık farz namaz yoğunluk haritası';

  @override
  String get profilHeatmapSemantics => 'Farz namaz takvimini aç';

  @override
  String profilHeroSemantics(String tier) {
    return 'Profil kahramanı — $tier';
  }

  @override
  String profilLevelBadge(int level) {
    return 'LVL $level';
  }

  @override
  String get profilLockerRow => 'Aktif aurayı ve unvanı ayarla';

  @override
  String get profilLockerSemantics => 'Görünüm dolabını aç';

  @override
  String get profilLockerSkin => 'GÖRÜNÜM DOLABI';

  @override
  String get profilLoginCancelled => 'Giriş iptal edildi.';

  @override
  String profilLoginFailed(String msg) {
    return '❌ Giriş başarısız: $msg';
  }

  @override
  String get profilLoginMerged => '☁️ Giriş başarılı — ilerleme birleştirildi.';

  @override
  String get profilLoginNotSaved =>
      '⚠️ Giriş başarılı, ancak yedek henüz kaydedilmedi.';

  @override
  String get profilLoginOffline =>
      '⚠️ Giriş başarılı, ancak yedekleme aktif değil (çevrimdışı).';

  @override
  String get profilLogoutConfirm =>
      'Yerel veriler silinsin ve başlangıç ekranına dönülsün mü?';

  @override
  String get profilLogoutSuccess => 'Çıkış yapıldı.';

  @override
  String get profilMiniLevel => 'Seviye';

  @override
  String get profilMiniStreak => 'Seri';

  @override
  String get profilMiniXp => 'XP';

  @override
  String get profilModeBalanced => '⚖️ Dengeli';

  @override
  String get profilModeBalancedDesc =>
      'Ezan vaktinde ve 15 dakika öncesinde hatırlatılır';

  @override
  String get profilModeFocus => '🎯 Odaklanmış';

  @override
  String get profilModeFocusDesc => 'Yalnızca ezan vaktinde ana hatırlatıcı';

  @override
  String get profilModeIntense => '🔥 Yoğun';

  @override
  String get profilModeIntenseDesc =>
      'Ezan vaktinde, 5 dakika ve 30 dakika öncesinde hatırlatılır';

  @override
  String get profilNicknameHint => 'Takma ad';

  @override
  String get profilNotifPermAction =>
      'Bildirim izni etkin değil. Android Bildirim Ayarları\'nı açıp izin verin.';

  @override
  String get profilNotifPermBody =>
      'Bildirim izni etkin değil. Ezan hatırlatıcılarını almak için etkinleştirin.';

  @override
  String get profilNotifications => 'Bildirimler';

  @override
  String get profilOemBody =>
      'Uygulama kapalıyken de alarmın çalması ve bildirimlerin kilit ekranında görünmesi için telefon ayarlarından \"Otomatik Başlatma\" ve \"Pil kısıtlaması yok\" seçeneklerini etkinleştirin.';

  @override
  String get profilOemManual =>
      'Ayarlar > Uygulamalar > Muslim Leveling > Pil ve Otomatik Başlatma adımlarını manuel olarak açın.';

  @override
  String get profilOemTitle =>
      'Xiaomi/Oppo/Vivo cihazlarda Ezan sesi gelmiyor mu?';

  @override
  String get profilOpenAutostart => 'Otomatik Başlatma Ayarlarını Aç';

  @override
  String profilPhotoFailed(String msg) {
    return 'Fotoğraf alınamadı: $msg';
  }

  @override
  String get profilPhotoSection => 'PROFİL FOTOĞRAFI';

  @override
  String get profilPrivacy => 'Gizlilik ve Veriler';

  @override
  String get profilPrivacyDeleteBody =>
      'Tüm yerel verileri tek seferde silmek için Profil → Çıkış Yap adımlarını takip edin. Cihazda hiçbir veri kalmayacaktır.';

  @override
  String get profilPrivacyDeleteTitle => 'İstediğiniz Zaman Silin';

  @override
  String get profilPrivacyLocalBody =>
      'Namaz, Al-Qur\'an okumaları, istatistikler ve tercihler dahil tüm verileriniz yalnızca telefonunuzda saklanır. Sunucu veya bulut kullanılmaz.';

  @override
  String get profilPrivacyLocalTitle => 'Cihazda Saklanır';

  @override
  String get profilPrivacyLocationBody =>
      'Konumunuz, yalnızca bölgenize ait namaz vakitlerini belirlemek için bir kez kullanılır. Konum verisi kaydedilmez veya paylaşılmaz.';

  @override
  String get profilPrivacyLocationTitle => 'Gizli Konum';

  @override
  String get profilPrivacyTraceBody =>
      'Uygulama, aktivitelerinizi üçüncü taraflarla paylaşmaz ve davranışlarınızı takip etmez.';

  @override
  String get profilPrivacyTraceTitle => 'Çevrimdışı ve İz Bırakmaz';

  @override
  String get profilReminderMode => 'Hatırlatıcı Modu';

  @override
  String get profilReminderTitle => 'Ezan Hatırlatıcı';

  @override
  String profilRemindersChangeFailed(String msg) {
    return 'Hatırlatıcı değiştirilemedi: $msg';
  }

  @override
  String get profilRemindersFailed =>
      'Hatırlatıcılar planlanamadı — lütfen telefon ayarlarından bildirim ve alarm izinlerini kontrol edin.';

  @override
  String get profilRemindersNone =>
      'Mod kaydedildi ancak henüz planlanmış bir hatırlatıcı yok — lütfen telefon ayarlarından bildirim ve alarm izinlerini kontrol edin.';

  @override
  String get profilRemindersOff => 'Ezan hatırlatıcıları kapatıldı';

  @override
  String profilRemindersScheduled(String mode, int n) {
    return 'Ezan hatırlatıcıları aktif: $mode modu — $n hatırlatıcı planlandı';
  }

  @override
  String profilRemindersScheduledCount(int n) {
    return '$n ezan hatırlatıcısı planlandı 🔔';
  }

  @override
  String get profilRemovePhoto => 'Fotoğrafı Kaldır';

  @override
  String profilSaveFailed(String msg) {
    return 'Kaydedilemedi: $msg';
  }

  @override
  String get profilSettingsHeader => 'AYARLAR';

  @override
  String profilSettingsOpenFailed(String msg) {
    return 'Bildirim ayarları açılamadı: $msg';
  }

  @override
  String get profilSoundAdzan => '🕌 Ezan';

  @override
  String get profilSoundAdzanDesc => 'Namaz vakti girdiğinde tam ezan sesi';

  @override
  String get profilSoundMode => 'Bildirim Sesi';

  @override
  String get profilSoundNormal => '🔔 Sesli';

  @override
  String get profilSoundNormalDesc => 'Telefonun varsayılan sesiyle bildirim';

  @override
  String get profilSoundSilent => '🔕 Sessiz';

  @override
  String get profilSoundSilentDesc =>
      'Yalnızca bildirim gösterilir, ses çalmaz';

  @override
  String get profilStatsDailyAvg => 'Günlük Ortalama';

  @override
  String get profilStatsEmptyBody =>
      'İlk namazınızı işaretleyin — istatistikleriniz burada görünmeye başlayacaktır.';

  @override
  String get profilStatsEmptyTitle => 'Henüz kayıt bulunmuyor.';

  @override
  String get profilStatsHeader => 'İSTATİSTİKLER';

  @override
  String get profilStatsQuranStreak => 'Al-Qur\'an Okuma Serisi';

  @override
  String profilStatsSince(String date) {
    return '$date tarihinden beri';
  }

  @override
  String get profilStatsVerses => 'Okunan Al-Qur\'an Ayetleri';

  @override
  String get profilStatsWajib => 'Farz namazlar';

  @override
  String profilStreakBest(int count) {
    return 'en iyi $count';
  }

  @override
  String get profilStreakFreeze => 'dondur';

  @override
  String get profilStreakPerPrayer => 'NAMAZ BAŞINA SERİ';

  @override
  String profilStreakSemanticsItem(String prayer, int days) {
    return '$prayer $days gün';
  }

  @override
  String get profilStreakSemanticsTitle => 'Namaz başına seri';

  @override
  String get profilTestAdzan => 'Ezanı Test Et';

  @override
  String get profilTestNotif => 'Bildirimi Test Et';

  @override
  String profilTestNotifFailed(String msg) {
    return 'Bildirim testi başarısız oldu: $msg';
  }

  @override
  String get profilTheme => 'Uygulama teması';

  @override
  String get profilUnitDays => 'gün';

  @override
  String get profilUnitVerses => 'ayet';

  @override
  String get profilUnitWeeks => 'hafta';

  @override
  String profilVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String profilXpToNext(int xp, int level) {
    return 'Sonraki seviyeye $xp XP kaldı → Seviye $level';
  }

  @override
  String profilXpWithinLevel(int current, int needed) {
    return '$current/$needed XP';
  }

  @override
  String get settingLanguage => 'Dil';

  @override
  String get sunnahBadiyahDzuhurDesc => 'Öğle namazından sonraki sünnet';

  @override
  String get sunnahBadiyahDzuhurName => 'Ba\'diyah Dzuhur';

  @override
  String get sunnahBadiyahIsyaDesc => 'Yatsı namazından sonraki sünnet';

  @override
  String get sunnahBadiyahIsyaName => 'Ba\'diyah Isya';

  @override
  String get sunnahBadiyahMaghribDesc => 'Akşam namazından sonraki sünnet';

  @override
  String get sunnahBadiyahMaghribName => 'Ba\'diyah Maghrib';

  @override
  String get sunnahDhuhaDesc => 'Sabah vaktindeki nafile namaz';

  @override
  String get sunnahDhuhaName => 'Duha';

  @override
  String get sunnahQobliyahAsharDesc => 'İkindi namazından önceki sünnet';

  @override
  String get sunnahQobliyahAsharName => 'Qobliyah Ashar';

  @override
  String get sunnahQobliyahDzuhurDesc => 'Öğle namazından önceki sünnet';

  @override
  String get sunnahQobliyahDzuhurName => 'Qobliyah Dzuhur';

  @override
  String get sunnahQobliyahSubuhDesc => 'Sabah namazından önceki sünnet';

  @override
  String get sunnahQobliyahSubuhName => 'Qobliyah Subuh';

  @override
  String get sunnahTahajjudDesc => 'Gece namazı (teheccüd)';

  @override
  String get sunnahTahajjudName => 'Teheccüd';

  @override
  String get tabHome => 'Ana Sayfa';

  @override
  String get tabJadwal => 'Vakitler';

  @override
  String get tabQuran => 'Al-Qur\'an';

  @override
  String get tabBelajar => 'Öğren';

  @override
  String get tabProfil => 'Profil';

  @override
  String get dlTitle => 'Günün Tefekkürü';

  @override
  String get dlBack => 'Geri';

  @override
  String dlCiteSurah(String surah, int ayah) {
    return 'Al-Qur\'an $surah:$ayah';
  }

  @override
  String get dlCiteHadis => 'GÜNÜN HADİSİ';

  @override
  String dlCiteDoa(String name) {
    return 'DUA · $name';
  }

  @override
  String dlCiteUlama(String name) {
    return 'ALİMLERİN SÖZÜ · $name';
  }

  @override
  String get dlActListen => 'Dinle';

  @override
  String get dlActPause => 'Duraklat';

  @override
  String get dlActSave => 'Kaydet';

  @override
  String get dlActSaved => 'Kaydedildi';

  @override
  String get dlActTafsir => 'Tefsir';

  @override
  String get dlErrLoad =>
      'Günün tefekkürü yüklenemedi.\nİnternete bağlanıp tekrar deneyin.';

  @override
  String get dlErrTafsir => 'Tefsir yüklenemedi. Tekrar deneyin.';

  @override
  String get dlDone => 'Günün tefekkürü tamamlandı';

  @override
  String dlProgress(int done, int count) {
    return '$done/$count tefekkür okundu · devam etmek için kaydırın';
  }

  @override
  String get qsTitle => 'Ayeti Paylaş';

  @override
  String get qsShare => 'Paylaş';

  @override
  String get qsPreparing => 'Hazırlanıyor…';

  @override
  String get qsErr => 'Ayet paylaşılamadı. Tekrar deneyin.';

  @override
  String get qsModeSolid => 'Düz Renk';

  @override
  String get qsModeGradient => 'Gradyan';

  @override
  String get qsModeEsthetic => 'Estetik';

  @override
  String get qsContentArabic => 'Arapça';

  @override
  String get qsContentTranslation => 'Çeviri';

  @override
  String get quest_subuh_tepat_desc =>
      'Sabah namazını vaktinde kılın (ezandan sonra ≤30 dakika)';

  @override
  String get quest_five_rings_desc => 'Bugün 5/5 vakit namazı tamamlayın';

  @override
  String get quest_timely_prayers_desc =>
      'Bugün 3 vakit namazı vaktinde (≤10 dakika) kılın';

  @override
  String get quest_dhuha_before_dzuhur_desc =>
      'Öğle namazından önce Duha namazı kılın';

  @override
  String get quest_rawatib_two_desc => 'Bugün 2 vakit revatib sünneti kılın';

  @override
  String get quest_dzuhur_tepat_desc =>
      'Öğle namazını vaktinde kılın (ezandan sonra ≤30 dakika)';

  @override
  String get quest_maghrib_tepat_desc =>
      'Akşam namazını vaktinde kılın (ezandan sonra ≤30 dakika)';

  @override
  String get quest_isya_hadir_desc => 'Bu gece Yatsı namazını kaçırmayın';

  @override
  String get quest_any_three_desc => 'Bugün herhangi 3 vakit farz namazı kılın';

  @override
  String get quest_subuh_isya_desc =>
      'Günün iki ucunu sabitleyin: Sabah + Yatsı';

  @override
  String get quest_one_sunnah_desc => 'Bugün herhangi 1 sünnet namazı kılın';

  @override
  String get quest_rawatib_one_desc =>
      'Bugün 1 vakit revatib sünneti kılın (öncesi veya sonrası)';

  @override
  String get quest_zikir_33_desc =>
      'Günlük Zikir butonu ile 33 defa zikir çekin';

  @override
  String quest_zikir_goal_desc(Object goal) {
    return 'Günlük Zikri $goal hedefine ulaşana kadar tamamlayın';
  }

  @override
  String get quest_quran_10ayat_desc => 'Bugün Al-Qur\'an\'dan 10 ayet okuyun';

  @override
  String get quest_hadis_3_desc =>
      'Bugün 3 Hadis okuyun (her Hadis için ≥5 saniye)';

  @override
  String get quest_dzikir_33_subuh_desc =>
      '33 defa Sübhanallah zikri çekin (namaz sonrası tesbihat)';

  @override
  String get quest_quran_1halaman_desc =>
      'Al-Qur\'an\'dan 20 ayet okuyun (yaklaşık 1 sayfa)';

  @override
  String get quest_hadis_5_desc =>
      'Bugün 5 Hadis okuyun (her Hadis için ≥5 saniye)';

  @override
  String get quest_berjamaah_1_desc =>
      'Bugün 1 vakit cemaatle namaz kılın (talep ederken cemaat bonusunu seçin)';

  @override
  String get quest_hero_streak_7_desc =>
      '7 günlük Kahraman Serisini koruyun! 🔥';

  @override
  String get questCopy_sholat_1 =>
      'Meşgul olabilirsiniz ama yine de vakit ayırdınız. Tebrikler.';

  @override
  String get questCopy_sholat_2 =>
      'Ezan bitti ve hemen harekete geçtiniz. Harika.';

  @override
  String get questCopy_sholat_3 =>
      'Bugün tam vaktinde. Koruduğunuz güzel bir alışkanlık.';

  @override
  String get questCopy_sholat_4 => 'Yorgun olsanız bile geldiniz. 🤍';

  @override
  String get questCopy_sunnah_1 =>
      'Farz değildi ama yine de yapmayı tercih ettiniz.';

  @override
  String get questCopy_sunnah_2 =>
      'Zorlayan yoktu. Gelmeyi kendiniz tercih ettiniz.';

  @override
  String get questCopy_sunnah_3 => 'Bugün iki rekat. Küçük ama anlamlı.';

  @override
  String get questCopy_sunnah_4 =>
      'Yavaş yavaş, inşa ettiğiniz güzel alışkanlıklar bunlardır.';

  @override
  String get questCopy_zikir_1 =>
      'Günün yoğunluğu arasında yine de Allah\'ı anmaya vakit ayırdınız.';

  @override
  String get questCopy_zikir_2 => 'Bir an durun. Nefes alın. Allah\'ı anın.';

  @override
  String get questCopy_zikir_3 =>
      'Aklınızda ne olursa olsun, zikir için yine de vakit ayırdınız.';

  @override
  String get questCopy_zikir_4 =>
      'Zikir tamamlandı. Kalbinizin biraz daha hafiflemesini dileriz. 🤍';

  @override
  String get questCopy_quran_1 =>
      'Bugün bir ayet. Yavaş yavaş, önemli olan sürekliliktir.';

  @override
  String get questCopy_quran_2 =>
      'Bugün Al-Qur\'an\'ı yeniden açtınız. Bunu görmek çok güzel.';

  @override
  String get questCopy_quran_3 =>
      'Çok olmasına gerek yok. Bir sayfa bile bir adımdır.';

  @override
  String get questCopy_quran_4 =>
      'Bir sayfa tamamlandı. Yarın devam etmek üzere.';

  @override
  String get questCopy_hadis_1 =>
      'Bugün Peygamberimizin sözlerinden öğrenmek için vakit ayırdınız.';

  @override
  String get questCopy_hadis_2 =>
      'Bugün bir Hadis okudunuz. Gününüze rehberlik etmesini dileriz.';

  @override
  String get questCopy_hadis_3 =>
      'Etkileyici bir Hadis mi buldunuz? Kaydedin. Belki tekrar hatırlamanız gerekir.';

  @override
  String get questCopy_hadis_4 =>
      'Bugün küçük bir öğrenim, yarın için bir azık olsun.';

  @override
  String get questCopy_fiveRings_1 =>
      'Sabah, Öğle, İkindi, Akşam, Yatsı. Bugün hepsini eda ettiniz.';

  @override
  String get questCopy_fiveRings_2 =>
      'Beş vakit tamamlandı. Alhamdulillah, bugün namazlarınızı korumayı başardınız.';

  @override
  String get questCopy_fiveRings_3 => 'Bir gün, beş vakit. Eksiksiz. 🤍';

  @override
  String get questCopy_fiveRings_4 =>
      'Bugün güzelce tamamlandı. Yarın yeniden başlayalım.';

  @override
  String get questCopy_subuhIsya_1 =>
      'Sabahı korudunuz, Yatsıyı korudunuz. Alhamdulillah.';

  @override
  String get questCopy_subuhIsya_2 =>
      'Günün başından sonuna kadar yine de vakit ayırdınız.';

  @override
  String get questCopy_subuhIsya_3 =>
      'Bugün bu iki vakti korudunuz. Tebrikler.';

  @override
  String get questCopy_subuhIsya_4 =>
      'Bugün Sabah ve Yatsı namazlarını korumayı başardınız. Yarın devam etmek üzere.';

  @override
  String get questHaid_1 =>
      'Bugün dinlenme vakti. Moraliniz hep yüksek olsun. 🤍';

  @override
  String get questHaid_2 =>
      'Kısa bir ara vermenizde sakınca yoktur. Siz hâlâ bu yolculuğun bir parçasısınız.';

  @override
  String get questHaid_3 =>
      'Bugün bu görevi yerine getirmeniz gerekmiyor. Kendinize iyi bakın ve Allah\'a yakın kalmaya devam edin.';

  @override
  String get questHaid_4 =>
      'Görevler geçici olarak durabilir. Yolculuğunuz ise devam ediyor.';

  @override
  String get questClaimAlhamdulillah => 'Alhamdulillah';

  @override
  String get questClaimContinue => 'Devam Et';

  @override
  String sqCombinedTitle(Object count) {
    return 'Alhamdulillah, $count Görev Tamamlandı!';
  }

  @override
  String get sqCombinedDesc =>
      'Bugünkü tüm günlük görevler tamamlandı. İstikrarınız daim olsun!';

  @override
  String get sqZikirTitle => '100 Zikir Tamamlandı!';

  @override
  String get sqZikirDesc => 'Bugün zikirde istikrar sağlandı. Daim olsun!';

  @override
  String get sqTilawahTitle => '10 Ayet Al-Qur\'an Okuma Tamamlandı!';

  @override
  String get sqTilawahDesc => 'Bugünkü tilavet tamamlandı. Yarın devam edin!';

  @override
  String get sqHadisTitle => '5 Hadis Öğrenimi Tamamlandı!';

  @override
  String get sqHadisDesc =>
      'Bugün beş yeni Hadis okundu. Öğrenmeye devam edin!';

  @override
  String get sqBadgeCombined => 'GÜNLÜK GÖREVLER TAMAMLANDI';

  @override
  String get sqBadgeSingle => 'GÖREV TAMAMLANDI';

  @override
  String get sqButton => 'HARİKA!';

  @override
  String get sqBarrierLabel => 'yan görev tamamlandı';

  @override
  String sqSemantics(Object desc, Object title, Object xp) {
    return '$title. $desc. Bonus $xp XP.';
  }

  @override
  String get sqSourceZikir => '100 Zikir';

  @override
  String get sqSourceTilawah => 'Al-Qur\'an Okuma';

  @override
  String get sqSourceHadis => 'Hadis Öğrenme';

  @override
  String get naikTitle => 'SEVİYE ATLADINIZ!';

  @override
  String get naikBadgeSemantics => 'Altın hilal, seviye atlama sembolü';

  @override
  String naikReached(Object level, Object rank) {
    return 'Maşallah, $rank unvanına ulaştınız — Seviye $level';
  }

  @override
  String naikFrom(Object source) {
    return 'kaynak: $source';
  }

  @override
  String get naikBack => 'GERİ DÖN';

  @override
  String naikRewardSemanticsFull(Object level, Object rank, Object xp) {
    return 'Ödül: +$xp XP, seviye $level, yeni unvan $rank';
  }

  @override
  String naikRewardSemanticsLevel(Object level, Object rank) {
    return 'Ödül: seviye $level, yeni unvan $rank';
  }

  @override
  String get naikChipLevelJumps => 'Sıçrama';

  @override
  String get naikChipLevel => 'Seviye';

  @override
  String get naikChipRank => 'YENİ UNVAN';

  @override
  String naikProgressSemantics(Object have, Object need, Object next) {
    return '$next seviyesine doğru: $have / $need XP';
  }

  @override
  String get naikClosing =>
      'Barakallah — istikrarınızı koruyun, bir sonraki seviye sizi bekliyor ✨';

  @override
  String naikLevelLabel(Object level) {
    return 'Seviye $level';
  }

  @override
  String get uq_ulama_ilmu_itu_lebih_baik_daripada_harta_ilmu =>
      'İlim maldan hayırlıdır. İlim sizi korur, malı ise siz korursun.';

  @override
  String get uq_ulama_orang_berilmu_itu_hidup_walau_sudah_wafa =>
      'Âlim olan kişi vefat etse de yaşar; cahil ise hayatta olsa bile ölüdür.';

  @override
  String get uq_ulama_jangan_melihat_siapa_yang_berbicara_tapi =>
      'Söyleyene değil, ne söylediğine bakın.';

  @override
  String get uq_ulama_nilai_seseorang_diukur_dari_apa_yang_dia =>
      'Kişinin değeri, özenle ve samimiyetle yaptığı şeylerle ölçülür.';

  @override
  String get uq_ulama_hisablah_dirimu_sendiri_sebelum_kamu_dih =>
      'Hesaba çekilmeden önce kendinizi hesaba çekin, amelleriniz tartılmadan önce onları tartın.';

  @override
  String get uq_ulama_aku_tidak_pernah_menyesal_karena_diam_ta =>
      'Sustuğum için hiç pişman olmadım ama konuştuğum için çok kez pişman oldum.';

  @override
  String get uq_ulama_kehormatanmu_adalah_agamamu_dan_harga_di =>
      'Onurunuz dininizdir, şerefiniz ise ahlakınızdır.';

  @override
  String get uq_ulama_waktu_itu_seperti_pedang_kalau_kamu_tida =>
      'Zaman kılıç gibidir; eğer siz onu kesmezseniz, o sizi keser.';

  @override
  String get uq_ulama_ilmu_bukanlah_yang_dihafal_tetapi_ilmu_a =>
      'İlim ezberlenen değil, fayda veren şeydir.';

  @override
  String get uq_ulama_ilmu_itu_cahaya_dan_cahaya_allah_tidak_a =>
      'İlim bir nurdur ve Allah\'ın nuru günahkâr bir kalbe ulaşmaz.';

  @override
  String get uq_ulama_barangsiapa_tidak_tahan_lelahnya_belajar =>
      'Öğrenmenin zahmetine katlanamayan, cehaletin acısına katlanır.';

  @override
  String get uq_ulama_aku_tidak_berhenti_belajar_sejak_aku_men =>
      'Cahil olduğumu fark ettiğim günden beri öğrenmeyi bırakmadım.';

  @override
  String get uq_ulama_aku_tidak_memberi_fatwa_sampai_aku_berta =>
      'Benden daha bilgili olanlara danışmadan asla fetva vermedim.';

  @override
  String get uq_ulama_manusia_lebih_membutuhkan_ilmu_daripada =>
      'İnsanların ilme olan ihtiyacı, yiyecek ve içeceğe olan ihtiyacından daha fazladır.';

  @override
  String get uq_ulama_aku_tidak_menulis_satu_hadis_pun_melaink =>
      'Önce içeriğini bizzat uygulamadığım tek bir Hadis bile yazmadım.';

  @override
  String get uq_ulama_ilmu_tanpa_amal_seperti_pohon_tanpa_buah =>
      'Amelsiz ilim, meyvesiz ağaç gibidir.';

  @override
  String get uq_ulama_anak_adam_hanyalah_kumpulan_hari_hari_se =>
      'Ademoğlu sadece günlerden ibarettir. Geçen her günle birlikte, onun da bir parçası yok olup gider.';

  @override
  String get uq_ulama_barangsiapa_mengenal_allah_dia_akan_menc =>
      'Kim Allah\'ı tanırsa O\'nu sever; O\'nu seven ise yalnızca O\'nunla meşgul olur.';

  @override
  String get uq_ulama_sesungguhnya_dunia_ini_hanya_sebentar_ja =>
      'Şüphesiz ki bu dünya geçicidir; sanki sonsuza dek kalacakmış gibi onun için çalışmayalım.';

  @override
  String get uq_ulama_jadikan_dunia_ini_cukup_berada_di_tangan =>
      'Dünyayı sadece elinizde tutun, kalbinize girmesine izin vermeyin.';

  @override
  String get uq_ulama_perbanyaklah_mengingat_mati_karena_itu_m =>
      'Ölümü çokça hatırlayın; çünkü o, dünya sevgisini silip götürür.';

  @override
  String get uq_ulama_aku_tidak_mengobati_sesuatu_yang_lebih_b =>
      'Kendi niyetimden daha zor tedavi ettiğim hiçbir şey olmadı.';

  @override
  String get uq_ulama_ilmu_itu_untuk_diamalkan_kalau_tidak_dia =>
      'İlim amel etmek içindir; eğer amel edilmezse uçup gider.';

  @override
  String get uq_ulama_diam_adalah_hikmah_tapi_sedikit_orang_ya =>
      'Sükut bir hikmettir, fakat onu uygulayanlar çok azdır.';

  @override
  String get uq_ulama_sebaik_baik_hati_adalah_yang_dipenuhi_ra =>
      'Kalplerin en hayırlısı, Allah korkusu ve ümidiyle dolu olanıdır.';

  @override
  String get uq_ulama_tidak_ada_yang_lebih_bermanfaat_bagi_hat =>
      'Kalp için Al-Qur\'an\'ı tefekkür ederek okumaktan daha faydalı bir şey yoktur.';

  @override
  String get uq_ulama_hati_bisa_sakit_seperti_badan_sakit_dan =>
      'Beden hastalandığı gibi kalp de hastalanabilir; onun şifası ise istiğfardır.';

  @override
  String get uq_ulama_kesabaran_itu_cahaya_dengannya_jalan_yan =>
      'Sabır bir nurdur; onunla dar yollar genişler.';

  @override
  String get uq_ulama_ilmu_tanpa_amal_adalah_sia_sia_dan_amal =>
      'Amelsiz ilim beyhudedir, ilimsiz amel ise eksiktir.';

  @override
  String get uq_ulama_kebahagiaan_bukan_pada_banyaknya_harta_t =>
      'Huzur mal çokluğunda değil, gönül ferahlığındadır.';

  @override
  String get uq_ulama_siapa_yang_menuntut_ilmu_semata_untuk_me =>
      'Kim sadece övünmek için ilim tahsil ederse, ilmi kendi aleyhine bir delil olur.';

  @override
  String get uq_ulama_jaga_hatimu_karena_allah_melihat_bukan_h =>
      'Kalbinizi koruyun; çünkü Allah sadece amellerinize değil, kalbinizde ne olduğuna da bakar.';

  @override
  String get uq_month_1 => 'Muharrem';

  @override
  String get uq_month_2 => 'Sefer';

  @override
  String get uq_month_3 => 'Rebiülevvel';

  @override
  String get uq_month_4 => 'Rebiülahir';

  @override
  String get uq_month_5 => 'Cemaziyelevvel';

  @override
  String get uq_month_6 => 'Cemaziyelahir';

  @override
  String get uq_month_7 => 'Recep';

  @override
  String get uq_month_8 => 'Şaban';

  @override
  String get uq_month_9 => 'Ramazan';

  @override
  String get uq_month_10 => 'Şevval';

  @override
  String get uq_month_11 => 'Zilkade';

  @override
  String get uq_month_12 => 'Zilhicce';

  @override
  String get uq_ev_1_1 => 'Hicri Yılbaşı';

  @override
  String get uq_ev_1_10 => 'Aşure Günü';

  @override
  String get uq_ev_3_12 => 'Mevlid Kandili';

  @override
  String get uq_ev_7_27 => 'Miraç Kandili';

  @override
  String get uq_ev_8_15 => 'Berat Kandili';

  @override
  String get uq_ev_9_1 => 'Ramazan Başlangıcı';

  @override
  String get uq_ev_9_17 => 'Kur\'an\'ın İndirilişi';

  @override
  String get uq_ev_10_1 => 'Ramazan Bayramı';

  @override
  String get uq_ev_12_9 => 'Arefe Günü';

  @override
  String get uq_ev_12_10 => 'Kurban Bayramı';

  @override
  String get hjHariPentingTitle => 'Önemli İslami Günler';

  @override
  String get hjHariPentingEmpty => 'Önemli günler yüklenemedi.';

  @override
  String get hjHariPentingSemantics => 'Hicri Tarih, Önemli İslami Günleri aç';

  @override
  String get hjToday => 'Bugün!';

  @override
  String get hjPassed => 'Geçti';

  @override
  String hjDaysLeft(Object days) {
    return '$days gün kaldı';
  }

  @override
  String get hjHijriSuffix => 'H';

  @override
  String get qiblaCalibrationHint =>
      '💡 Pusula kalibrasyonu: En iyi doğruluk için cihazı birkaç kez 8 çizecek şekilde döndürün.';

  @override
  String get qiblaCompassLabel => 'KIBLE PUSULASI';

  @override
  String get qiblaTitle => 'Kıble Yönü';

  @override
  String get qiblaAligned => '🎯 Tam isabet! Bu pozisyonu koruyun';

  @override
  String qiblaTurnRight(String degrees) {
    return 'Sağa $degrees° döndürün →';
  }

  @override
  String qiblaTurnLeft(String degrees) {
    return '← Sola $degrees° döndürün';
  }

  @override
  String get qiblaNoSensorTitle => 'Pusula Sensörü Mevcut Değil';

  @override
  String get qiblaNoSensorBody =>
      'Bu cihazda manyetometre sensörü bulunmamaktadır. Alternatif olarak aşağıdaki yön kılavuzunu kullanabilirsiniz.';

  @override
  String get qiblaAlignedTitle => 'Kıbleye Yönelindi!';

  @override
  String get qiblaAimTitle => 'Cihazı Kıbleye Doğrultun';

  @override
  String get qiblaStatTitle => 'KIBLE YÖNÜ';

  @override
  String get qiblaDistanceTitle => 'KABE MESAFESİ';

  @override
  String qiblaCityDistance(String city, String km) {
    return '📍 $city • Kabe\'ye $km km';
  }

  @override
  String qiblaCityBearing(String city) {
    return '$city için Kıble Yönü:';
  }

  @override
  String qiblaNorthDegrees(String degrees) {
    return 'Kuzeyden $degrees°';
  }

  @override
  String qiblaTurnInstruction(String degrees) {
    return 'Kıbleye yönelmek için cihazı kuzeyden saat yönünde $degrees° döndürün.';
  }

  @override
  String qiblaOffset(String degrees) {
    return 'Kıbleden $degrees° sapma';
  }

  @override
  String get dzResetTitle => 'Sayaç sıfırlansın mı?';

  @override
  String dzResetBody(String item) {
    return '\"$item\" sayacı sıfırlanacaktır.\\nBugünkü toplam zikir sayısı YİNE DE hesaplanacaktır.';
  }

  @override
  String get dzResetCancel => 'İPTAL';

  @override
  String get dzResetConfirm => 'SIFIRLA';

  @override
  String get dzTapHint => 'Zikir çekmek için herhangi bir yere dokunun';

  @override
  String dzToday(String total) {
    return 'Bugün: $total';
  }

  @override
  String get dzVibrateOff => 'Titreşimi kapat';

  @override
  String get dzVibrateOn => 'Titreşimi aç';

  @override
  String get dzResetThis => 'Bu sayacı sıfırla';

  @override
  String get dzTargetDone => 'HEDEFE ULAŞILDI';

  @override
  String get hdEmptyPage => 'Bu sayfada Hadis bulunmamaktadır.';

  @override
  String get hdLoadFailed => 'Hadis yüklenemedi.';

  @override
  String get hdLoadFailedRetry => 'Hadis yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get hdSearchFailed => 'Hadis araması başarısız oldu.';

  @override
  String get hdRandomFailed =>
      'Rastgele Hadis alınamadı. Lütfen tekrar deneyin.';

  @override
  String get hdSearchHint => 'Hadis ara…';

  @override
  String hdSearchFound(String total) {
    return '$total Hadis bulundu';
  }

  @override
  String get hdSearchEmpty => 'Hiçbir Hadis bulunamadı.';

  @override
  String get hdBackToList => 'Listeye geri dön';

  @override
  String get hdLoadMore => 'Daha Fazla Yükle';

  @override
  String hdNumber(String id) {
    return 'No. $id';
  }

  @override
  String hdDetailTitle(String id) {
    return 'Hadis No. $id';
  }

  @override
  String get dzTransSubhanallah => 'Allah her türlü eksiklikten uzaktır';

  @override
  String get dzTransAlhamdulillah => 'Hamd, Allah\'a mahsustur';

  @override
  String get dzTransAllahuakbar => 'Allah en büyüktür';

  @override
  String get dzTransAstaghfirullah => 'Allah\'tan bağışlanma dilerim';

  @override
  String get dzTransHawla => 'Güç ve kuvvet ancak Allah\'a aittir';

  @override
  String get blModulNotFound => 'Modül bulunamadı';

  @override
  String get blModulDone => 'Modül Tamamlandı!';

  @override
  String get blKnowledgeUp => 'Bilginiz daha da arttı.';

  @override
  String get blMinScore70 =>
      'Geçmek için en az %70 gereklidir. Lütfen tekrar deneyin!';

  @override
  String get blReadAgain =>
      'Makaleyi tekrar okuyun ve testi yeniden deneyin. Başarabilirsiniz!';

  @override
  String get blBackToHub => 'Merkeze Dön';

  @override
  String get qdArabicSize => 'Arapça metin boyutu';

  @override
  String get qdTransSize => 'Çeviri boyutu';

  @override
  String get qdLatinHint => 'Arapça okumaya yardımcı olacak transkripsiyon';

  @override
  String get qdTajwidColors => 'Tecvid Renkleri';

  @override
  String get qdTafsirMuyassar => 'Tefsir el-Müyesser (özet, anlaşılması kolay)';

  @override
  String get qdTafsirKemenag => 'Kemenag Tefsiri (kapsamlı)';

  @override
  String get ppUnlockSkins => 'Tüm premium görünümlerin kilidini açın';

  @override
  String get ppActivateDev => 'Pro\'yu Etkinleştir (geliştirici)';

  @override
  String get deExpTitle => 'XP KAZANILDI!';

  @override
  String get bqModulNotFound => 'Modül bulunamadı';

  @override
  String get bqQuizUnavailable => 'Test henüz mevcut değil';

  @override
  String get bqNotYetRight => 'Henüz doğru değil';

  @override
  String get qpPrevAyah => 'Önceki ayet';

  @override
  String get qpNextAyah => 'Sonraki ayet';

  @override
  String get qpMurrotalSettings => 'Murattal ayarları';

  @override
  String get qpbRepeatRange => 'Aralığı tekrarla';

  @override
  String get qpbSleepTimer => 'Uyku zamanlayıcısı';

  @override
  String get qpbEndOfSurah => 'Sure sonu';

  @override
  String get qbNoBookmark => 'Henüz yer işareti yok';

  @override
  String get qbDeleteBookmark => 'Yer işaretini sil';

  @override
  String get qacDeleteBookmark => 'Yer işaretini sil';

  @override
  String get phPrevMonth => 'Önceki ay';

  @override
  String get phNextMonth => 'Sonraki ay';

  @override
  String get clProLocked => 'Pro kilitli';

  @override
  String get clCompleteQuest =>
      'Günlük Sandık\'tan görünümlerin kilidini açmak için günlük görevleri tamamlayın.';

  @override
  String get qdTajwidLegend => 'Kırmızı=Gunne, Mavi=Kalkale/İdgam, Yeşil=Med';

  @override
  String get ppProPitch =>
      'Özel kalkanlar, auralar ve unvanlar. Avatarınız için yeni bir tarz — XP, seriniz veya sıralamanız etkilenmez.';

  @override
  String deQuizDone(String moduleTitle) {
    return '$moduleTitle testini tamamladınız!';
  }

  @override
  String deLevelShort(int level) {
    return 'Sv $level';
  }

  @override
  String deLevel(int level) {
    return 'Seviye $level';
  }

  @override
  String bqQuestionOf(int current, int total) {
    return 'SORU $current/$total';
  }

  @override
  String qbSurahName(int number) {
    return 'Sure $number';
  }

  @override
  String qacAyahNumber(int number) {
    return 'Ayet $number';
  }

  @override
  String get jdLoadFailed =>
      'Namaz vakitleri yüklenemedi. Bağlantınızı kontrol edin.';

  @override
  String get jdAlreadyLogged => '✓ KAYDEDİLDİ';

  @override
  String get jdTesSuara => 'Ses testi';

  @override
  String get jdAdzanDownloadFailed =>
      'Ezan sesi indirilemedi. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get qtLoadFailed => 'Al-Qur\'an verileri yüklenemedi';

  @override
  String get qtSurahNotFound => 'Sure bulunamadı';

  @override
  String get qtContinueReading => 'Okumaya devam et';

  @override
  String get spTagline => 'İmanınızı Yükseltin, Hayatınızı Güzelleştirin';

  @override
  String get spLoading => 'MÜCADELECİ VERİLERİ YÜKLENİYOR...';

  @override
  String get btSubtitle => 'Bilginizi artırın, daha fazla XP kazanın.';

  @override
  String get doaLoadFailed => 'Dualar yüklenemedi.';

  @override
  String get taProSignature => 'Pro imza tamamlandı';

  @override
  String get tpSelected => 'Tema seçildi';

  @override
  String get qrDisplaySettings => 'Görünüm ayarları';

  @override
  String get jdSoundFollowGlobal => 'Genel ayarlara uyar';

  @override
  String jdNotifFor(String prayer) {
    return '$prayer vakti bildirimi';
  }

  @override
  String get jdSoundSilent => 'Sessiz — ses yok';

  @override
  String get jdSoundNormal => 'Sesli — standart telefon bildirimi';

  @override
  String get jdSoundAdzan => 'Ezan — tam ezan sesi';

  @override
  String get jdSoundGlobalOption => 'Genel ayarları takip et';

  @override
  String jdFootnote(String city) {
    return '$city için namaz vakitleri api.myquran.com aracılığıyla KEMENAG RI verilerinden alınmıştır. Sekme açıldığında otomatik olarak güncellenir; konumu değiştirmek için yukarıdaki şehir adına dokunun.';
  }

  @override
  String qtSearchEmpty(String example) {
    return 'Sonuç bulunamadı. Çeviride başka bir kelime aramayı deneyin veya sure adı + ayet numarası yazın — örneğin: $example.';
  }

  @override
  String qtOpenSurah(String surah) {
    return '$surah suresini aç';
  }

  @override
  String qtAyahOf(int ayah, int total) {
    return '$total ayet içinden $ayah. ayet';
  }

  @override
  String qtSurahAyah(String surah, int ayah) {
    return '$surah Suresi · $ayah. Ayet';
  }

  @override
  String btQuizScore(int score) {
    return 'Test: %$score';
  }

  @override
  String nlLevelShort(int level) {
    return 'Svy $level';
  }

  @override
  String homeLevelShort(int level) {
    return 'SVY $level';
  }

  @override
  String qtsTafsirAyah(int ayah) {
    return '$ayah. Ayet Tefsiri';
  }

  @override
  String get locFailureDisabled =>
      'Cihaz konum servislerini etkinleştirin ve tekrar deneyin.';

  @override
  String get locFailureDenied =>
      'Mevcut konumu kullanmak için konum erişimine izin verin.';

  @override
  String get locFailureDeniedForever =>
      'Konum izni engellendi. İzin vermek için Ayarlar\'ı açın.';

  @override
  String get locFailureTimeout =>
      'Konum tespiti çok uzun sürdü. Açık bir alanda tekrar deneyin.';

  @override
  String get locFailureLookup =>
      'Şehir bulunamadı. Bağlantınızı kontrol edin veya şehri manuel olarak seçin.';

  @override
  String get authNoIdToken =>
      'Google idToken göndermedi. Firebase Konsolu\'ndaki SHA-1 değerini kontrol edin.';

  @override
  String get authEmptyUser =>
      'Firebase Kimlik Doğrulaması başarısız oldu — kullanıcı boş.';

  @override
  String get authDevError10 =>
      'Google DEVELOPER_ERROR (10): SHA-1, Firebase Konsolu\'nda kayıtlı değil.';

  @override
  String get authMisconfigured =>
      'Google ile Oturum Açma yanlış yapılandırıldı. OAuth izin ekranını ve SHA-1 değerini kontrol edin.';

  @override
  String get authNetworkError =>
      'Google ile giriş yapılırken ağ hatası oluştu.';

  @override
  String get authCredInvalid =>
      'Firebase Kimlik Doğrulaması kimlik bilgilerini doğrulayamadı.';

  @override
  String get authNotEnabled =>
      'Google ile Oturum Açma, Firebase Konsolu\'nda henüz etkinleştirilmemiş.';

  @override
  String get authEmailInUse =>
      'E-posta adresi zaten başka bir yöntemle kayıt edilmiş.';

  @override
  String get notifModeFokus =>
      'Odak Modu aktif! Hatırlatıcılar yalnızca ezan vaktinde gönderilir.';

  @override
  String get notifModeSeimbang =>
      'Dengeli Mod aktif! Tüm farz namazlar için hatırlatıcılar ezandan 15 dakika önce gönderilir.';

  @override
  String get notifModeIntensif =>
      'Yoğun Mod aktif! Namazdan 30 dakika ve 5 dakika önce hatırlatılırsınız. Serinizi koruyun! 🔥';

  @override
  String get notifReady => 'Muslim Leveling bildirimleri hazır! 🔔';

  @override
  String get notifTestBody =>
      'Ezan sesi duyuluyorsa bildirimleriniz hazır demektir! Duyulmuyorsa telefonunuzun alarm ses seviyesini kontrol edin.';

  @override
  String get notifTestTitle => '🕌 Ezan Sesi Testi';

  @override
  String get notifChannelReminder => 'Namaz vakti hatırlatıcı bildirimleri';

  @override
  String notifModeTitle(String mode) {
    return 'Muslim Leveling · $mode';
  }

  @override
  String notifTitleMarker(String prayer) {
    return '🕌 $prayer';
  }

  @override
  String notifTitlePrayer(String prayer) {
    return '🕌 $prayer Namazı Vakti';
  }

  @override
  String notifBodyImsak(String loc) {
    return 'İmsak vakti girdi$loc. Lütfen yeme ve içmeyi bırakınız. 🌙';
  }

  @override
  String notifBodyTerbit(String loc) {
    return 'Güneş doğdu$loc. Sabah namazı vakti sona erdi, Duha vakti girdi. ☀️';
  }

  @override
  String notifBody30min(String prayer, String loc) {
    return '$prayer vaktine 30 dakika kaldı$loc. Hazırlanınız! 🔥';
  }

  @override
  String notifBody5min(String prayer, String loc) {
    return '$prayer vaktine 5 dakika kaldı$loc. Lütfen hazırlıklarınızı tamamlayınız! ⚡';
  }

  @override
  String notifBody15min(String prayer, String loc) {
    return '$prayer vaktine 15 dakika kaldı$loc. Hazırlanınız! 🌙';
  }

  @override
  String notifBodyNow(String prayer, String loc) {
    return '$prayer namazı vakti girdi$loc. Serinizi korumayı unutmayınız! 🔥';
  }

  @override
  String get prayerImsak => 'İmsak';

  @override
  String get prayerTerbit => 'Güneş';

  @override
  String notifLocSuffix(String city) {
    return ' ($city)';
  }

  @override
  String blClaimXp(int xp) {
    return '+$xp XP Talep Et';
  }

  @override
  String get blNotPassed => 'Geçilmedi';

  @override
  String get jdPageTitle => 'Namaz Vakitleri';

  @override
  String get jdSearchCity => 'Şehir Ara';

  @override
  String get jdNextPrayer => 'SONRAKİ NAMAZ';

  @override
  String get jdTodaySchedule => 'BUGÜNKÜ VAKİTLER';

  @override
  String get jdAdzanSoundTitle => 'EZAN SESİ';

  @override
  String get jdLoadingShort => 'yükleniyor...';

  @override
  String jdCountdownHm(int hours, int minutes) {
    return '$hours sa $minutes dk kaldı';
  }

  @override
  String jdCountdownM(int minutes) {
    return '$minutes dk kaldı';
  }

  @override
  String get jdCountdownTomorrow => 'yarın';

  @override
  String get jdRegionTitle => 'Bölge Seçin';

  @override
  String get jdRegionIndonesia => 'Endonezya';

  @override
  String get jdRegionAbroad => 'Yurt Dışı';

  @override
  String get jdAbroadSearchHint => 'Yurt dışındaki bir şehrin adını yazın...';

  @override
  String get jdAbroadEmpty =>
      'Şehir bulunamadı. Adını İngilizce olarak yazın — örn. London.';

  @override
  String jdFootnoteAbroad(String city) {
    return 'Aladhan kaynaklı $city için namaz vakitleri. Hesaplama yöntemi bu şehrin ülkesine göre belirlenir. Sekme açıldığında otomatik olarak güncellenir; konumu değiştirmek için yukarıdaki şehir adına dokunun.';
  }

  @override
  String get commonRetry => 'Tekrar deneyin';

  @override
  String get qtSearchHint => 'Sure veya ayet arayın';

  @override
  String qtSearchHelper(String example) {
    return 'Örn. $example';
  }

  @override
  String qtVerseHits(int count) {
    return 'Mealde $count ayet bulundu';
  }

  @override
  String qtVerseHitsTruncated(int count) {
    return '$count+ ayet bulundu — anahtar kelimeyi daraltın';
  }

  @override
  String get qtBookmarkTooltip => 'Ayeti yer işaretlerine ekleyin';

  @override
  String get qtSubtitle => '114 sure · 30 cüz';

  @override
  String get qbTitle => 'Yer İşaretleri';

  @override
  String get qbEmptyHint =>
      'Kaydetmek istediğiniz ayetteki yer işareti simgesine dokunun.';

  @override
  String get qacPlayFromHere => 'Bu ayetten itibaren oynat';

  @override
  String get qrBasmalah => 'Rahmân ve Rahîm olan Allah\'ın adıyla';

  @override
  String get qs_meaning_1 => 'Açılış';

  @override
  String get qs_meaning_2 => 'Sığır';

  @override
  String get qs_meaning_3 => 'İmran Ailesi';

  @override
  String get qs_meaning_4 => 'Kadınlar';

  @override
  String get qs_meaning_5 => 'Sofra';

  @override
  String get qs_meaning_6 => 'Davarlar';

  @override
  String get qs_meaning_7 => 'Yüksek Yerler';

  @override
  String get qs_meaning_8 => 'Savaş Ganimetleri';

  @override
  String get qs_meaning_9 => 'Bağışlanma';

  @override
  String get qs_meaning_10 => 'Yunus';

  @override
  String get qs_meaning_11 => 'Hûd';

  @override
  String get qs_meaning_12 => 'Yusuf';

  @override
  String get qs_meaning_13 => 'Gök Gürlemesi';

  @override
  String get qs_meaning_14 => 'İbrahim';

  @override
  String get qs_meaning_15 => 'Hicr';

  @override
  String get qs_meaning_16 => 'Bal Arısı';

  @override
  String get qs_meaning_17 => 'Gece Yürüyüşü';

  @override
  String get qs_meaning_18 => 'Mağara';

  @override
  String get qs_meaning_19 => 'Meryem';

  @override
  String get qs_meaning_20 => 'Tâ-Hâ';

  @override
  String get qs_meaning_21 => 'Peygamberler';

  @override
  String get qs_meaning_22 => 'Hac';

  @override
  String get qs_meaning_23 => 'Müminler';

  @override
  String get qs_meaning_24 => 'Nur';

  @override
  String get qs_meaning_25 => 'Furkan';

  @override
  String get qs_meaning_26 => 'Şairler';

  @override
  String get qs_meaning_27 => 'Karıncalar';

  @override
  String get qs_meaning_28 => 'Kıssalar';

  @override
  String get qs_meaning_29 => 'Örümcek';

  @override
  String get qs_meaning_30 => 'Romalılar';

  @override
  String get qs_meaning_31 => 'Lokman';

  @override
  String get qs_meaning_32 => 'Secde';

  @override
  String get qs_meaning_33 => 'Müttefik Gruplar';

  @override
  String get qs_meaning_34 => 'Sebe';

  @override
  String get qs_meaning_35 => 'Yaratıcı';

  @override
  String get qs_meaning_36 => 'Yâ-Sîn';

  @override
  String get qs_meaning_37 => 'Sıra Sıra Duranlar';

  @override
  String get qs_meaning_38 => 'Sâd';

  @override
  String get qs_meaning_39 => 'Zümreler';

  @override
  String get qs_meaning_40 => 'Bağışlayan';

  @override
  String get qs_meaning_41 => 'Detaylı Açıklanan';

  @override
  String get qs_meaning_42 => 'Danışma';

  @override
  String get qs_meaning_43 => 'Süs ve Ziynet';

  @override
  String get qs_meaning_44 => 'Duman';

  @override
  String get qs_meaning_45 => 'Diz Çöken';

  @override
  String get qs_meaning_46 => 'Kum Tepeleri';

  @override
  String get qs_meaning_47 => 'Muhammed';

  @override
  String get qs_meaning_48 => 'Zafer';

  @override
  String get qs_meaning_49 => 'Odalar';

  @override
  String get qs_meaning_50 => 'Kâf';

  @override
  String get qs_meaning_51 => 'Tozutup Savuran Rüzgarlar';

  @override
  String get qs_meaning_52 => 'Tur Dağı';

  @override
  String get qs_meaning_53 => 'Yıldız';

  @override
  String get qs_meaning_54 => 'Ay';

  @override
  String get qs_meaning_55 => 'Rahmân';

  @override
  String get qs_meaning_56 => 'Kıyamet Günü';

  @override
  String get qs_meaning_57 => 'Demir';

  @override
  String get qs_meaning_58 => 'Tartışma';

  @override
  String get qs_meaning_59 => 'Sürgün';

  @override
  String get qs_meaning_60 => 'İmtihan Edilen Kadın';

  @override
  String get qs_meaning_61 => 'Saf Tutma';

  @override
  String get qs_meaning_62 => 'Cuma';

  @override
  String get qs_meaning_63 => 'Münafıklar';

  @override
  String get qs_meaning_64 => 'Karşılıklı Aldanma';

  @override
  String get qs_meaning_65 => 'Boşanma';

  @override
  String get qs_meaning_66 => 'Haram Kılma';

  @override
  String get qs_meaning_67 => 'Mülk';

  @override
  String get qs_meaning_68 => 'Kalem';

  @override
  String get qs_meaning_69 => 'Kıyamet Günü';

  @override
  String get qs_meaning_70 => 'Yükselme Dereceleri';

  @override
  String get qs_meaning_71 => 'Nûh';

  @override
  String get qs_meaning_72 => 'Cin';

  @override
  String get qs_meaning_73 => 'Örtüsüne Bürünen';

  @override
  String get qs_meaning_74 => 'Örtüsüne Bürünen';

  @override
  String get qs_meaning_75 => 'Kıyamet Günü';

  @override
  String get qs_meaning_76 => 'İnsan';

  @override
  String get qs_meaning_77 => 'Gönderilenler';

  @override
  String get qs_meaning_78 => 'Büyük Haber';

  @override
  String get qs_meaning_79 => 'Söküp Çıkaranlar';

  @override
  String get qs_meaning_80 => 'Yüzünü Ekşitti';

  @override
  String get qs_meaning_81 => 'Dürülme';

  @override
  String get qs_meaning_82 => 'Yarılma';

  @override
  String get qs_meaning_83 => 'Ölçü ve Tartıda Hile Yapanlar';

  @override
  String get qs_meaning_84 => 'Yarılma';

  @override
  String get qs_meaning_85 => 'Burçlar';

  @override
  String get qs_meaning_86 => 'Gece Gelen Yıldız';

  @override
  String get qs_meaning_87 => 'En Yüce';

  @override
  String get qs_meaning_88 => 'Kuşatan';

  @override
  String get qs_meaning_89 => 'Tan Vakti';

  @override
  String get qs_meaning_90 => 'Şehir';

  @override
  String get qs_meaning_91 => 'Güneş';

  @override
  String get qs_meaning_92 => 'Gece';

  @override
  String get qs_meaning_93 => 'Kuşluk Vakti';

  @override
  String get qs_meaning_94 => 'Genişleme';

  @override
  String get qs_meaning_95 => 'İncir';

  @override
  String get qs_meaning_96 => 'Kan Pıhtısı';

  @override
  String get qs_meaning_97 => 'Yücelik';

  @override
  String get qs_meaning_98 => 'Apaçık Delil';

  @override
  String get qs_meaning_99 => 'Sarsıntı';

  @override
  String get qs_meaning_100 => 'Koşan Atlar';

  @override
  String get qs_meaning_101 => 'Kıyamet Günü';

  @override
  String get qs_meaning_102 => 'Çokluk Yarışı';

  @override
  String get qs_meaning_103 => 'Zaman';

  @override
  String get qs_meaning_104 => 'Arkadan Çekiştiren';

  @override
  String get qs_meaning_105 => 'Fil';

  @override
  String get qs_meaning_106 => 'Kureyş';

  @override
  String get qs_meaning_107 => 'Faydalı Şeyler';

  @override
  String get qs_meaning_108 => 'Bol Nimet';

  @override
  String get qs_meaning_109 => 'Kafirler';

  @override
  String get qs_meaning_110 => 'Yardım';

  @override
  String get qs_meaning_111 => 'Alevli Ateş';

  @override
  String get qs_meaning_112 => 'İhlas';

  @override
  String get qs_meaning_113 => 'Sabah';

  @override
  String get qs_meaning_114 => 'İnsanlar';

  @override
  String get qsRevelationMeccan => 'Mekki';

  @override
  String get qsRevelationMedinan => 'Medeni';

  @override
  String qtContinueReadingDetail(String surah, int ayah) {
    return '$surah suresi $ayah. ayetten okumaya devam edin';
  }

  @override
  String qtOpenSurahAyah(String surah, int ayah) {
    return '$surah suresi $ayah. ayeti açın';
  }

  @override
  String get qpbAyahRange => 'Ayet aralığı';

  @override
  String get qpbFrom => 'Başlangıç';

  @override
  String get qpbTo => 'Bitiş';

  @override
  String qpbRepeatRangeDetail(int from, int to) {
    return '$to. ayet bittikten sonra $from. ayete geri dönün';
  }

  @override
  String get qpbSpeed => 'Hız';

  @override
  String get qpbQari => 'Kari';

  @override
  String get qpbOff => 'Kapalı';

  @override
  String qpbMinutes(int m) {
    return '$m dk';
  }

  @override
  String get qdTitle => 'Görünüm Ayarları';

  @override
  String get qdTranslationLabel => 'İngilizce Çeviri';

  @override
  String get qdTransliteration => 'Transliterasyon';

  @override
  String get qdTafsirBrief => 'Kısa Tefsir';

  @override
  String get qdBasmalahLatin => 'Bismillahirrahmanirrahim';

  @override
  String get qdBasmalahTranslation => 'Rahman ve Rahim olan Allah\'ın adıyla.';

  @override
  String get qpPlay => 'Oynat';

  @override
  String qpNowPlaying(String surah, int ayah) {
    return 'Sure $surah : $ayah';
  }

  @override
  String get btHubCaps => 'ÖĞRENME MERKEZİ';

  @override
  String get btHeroTitle => 'Birlikte Öğrenin';

  @override
  String get btRibbon => 'DİJİTAL ÖĞRENCİ';

  @override
  String btModulesDone(int done, int total) {
    return '$done/$total modül tamamlandı';
  }

  @override
  String btMinutes(int m) {
    return '$m dk';
  }

  @override
  String blMinutesRead(int m) {
    return '$m dk okuma';
  }

  @override
  String get blContinueQuiz => 'TESTE DEVAM EDİN';

  @override
  String get bqNextQuestion => 'SONRAKİ SORU';

  @override
  String get bqSeeResult => 'SONUCU GÖRÜNTÜLE';

  @override
  String get bqCorrect => 'DOĞRU!';

  @override
  String get blResultCaps => 'TEST SONUCU';

  @override
  String blCorrectCount(int correct, int total) {
    return '$correct/$total Doğru';
  }

  @override
  String get blEarned => 'Kazanılan';

  @override
  String get blTryAgain => 'TEKRAR DENEYİN';

  @override
  String get dzCapsTarget => 'HEDEF';

  @override
  String get tpDark => 'Koyu';

  @override
  String get tpLight => 'Açık';

  @override
  String get btCatAkidah => 'Akide';

  @override
  String get btCatAlquran => 'Al-Qur\'an';

  @override
  String get btCatKeyakinan => 'İnanç';

  @override
  String get btCatRukunIslam => 'İslam\'ın Şartları';

  @override
  String get btCatPraktikIbadah => 'İbadet Uygulamaları';

  @override
  String get homeCapsCurrentRank => 'MEVCUT RÜTBE';

  @override
  String get homeCapsXpProgress => 'XP İLERLEMESİ';

  @override
  String get homeCapsStreak => 'SERİ';

  @override
  String get homeCapsSunnah => 'SÜNNET';

  @override
  String get homeCapsLocked => 'KİLİTLİ';

  @override
  String get homeCapsDone => 'TAMAMLANDI';

  @override
  String get homeCapsClaim => 'TALEP ET';

  @override
  String get homeLabelMenujuWaktu => 'VAKTE KALAN';

  @override
  String get homeLabelSunnahDhuha => 'DUHA SÜNNETİ';

  @override
  String get naikCapsProgressLevel => 'İLERLEME SEVİYESİ';

  @override
  String get doaEmpty => 'Boş';

  @override
  String get doaSectionTranslit => 'Transkripsiyon';

  @override
  String get doaSectionMeaning => 'Anlamı';

  @override
  String get doaSectionSource => 'Kaynak';

  @override
  String get hdRandom => 'Rastgele';

  @override
  String get hdCapsTranslation => 'ÇEVİRİ';

  @override
  String get hdCapsHikmah => 'HİKMET';

  @override
  String get hmLegendLess => 'Az';

  @override
  String get hmLegendFull => 'Çok';

  @override
  String get lockerCapsCollection => 'KOLEKSİYON';

  @override
  String lockerUnlockedCount(int n) {
    return '$n KİLİDİ AÇILDI';
  }

  @override
  String get lockerSlotAura => 'Aura';

  @override
  String get lockerSlotTitle => 'Unvan';

  @override
  String get contentNoteIndonesian => 'Endonezce Metin';

  @override
  String get contentNoteInEnglish => 'İngilizce Metin';
}

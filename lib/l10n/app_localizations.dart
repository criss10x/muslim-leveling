import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @achBtnAwesome.
  ///
  /// In id, this message translates to:
  /// **'MANTAP!'**
  String get achBtnAwesome;

  /// No description provided for @achBtnShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get achBtnShare;

  /// No description provided for @achBtnSkipAll.
  ///
  /// In id, this message translates to:
  /// **'Lewati semua'**
  String get achBtnSkipAll;

  /// No description provided for @achEarnedOn.
  ///
  /// In id, this message translates to:
  /// **'Terbuka {date} • {tier}'**
  String achEarnedOn(String date, String tier);

  /// No description provided for @achHintFallback.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan: {desc}.'**
  String achHintFallback(String desc);

  /// No description provided for @achLockedTier.
  ///
  /// In id, this message translates to:
  /// **'Terkunci • {tier}'**
  String achLockedTier(String tier);

  /// No description provided for @achScreenProgress.
  ///
  /// In id, this message translates to:
  /// **' / {total} medali terbuka'**
  String achScreenProgress(int total);

  /// No description provided for @achScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Achievements'**
  String get achScreenTitle;

  /// No description provided for @achSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'ACHIEVEMENTS'**
  String get achSectionTitle;

  /// No description provided for @achSeeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get achSeeAll;

  /// No description provided for @achSemanticsDetail.
  ///
  /// In id, this message translates to:
  /// **'{state}: {title}. {desc}. Tier {tier}.'**
  String achSemanticsDetail(
    String state,
    String title,
    String desc,
    String tier,
  );

  /// No description provided for @achSemanticsUnlocked.
  ///
  /// In id, this message translates to:
  /// **'Achievement terbuka: {title}. {desc}. Tier {tier}.'**
  String achSemanticsUnlocked(String title, String desc, String tier);

  /// No description provided for @achStateLocked.
  ///
  /// In id, this message translates to:
  /// **'Terkunci'**
  String get achStateLocked;

  /// No description provided for @achStateUnlocked.
  ///
  /// In id, this message translates to:
  /// **'Terbuka'**
  String get achStateUnlocked;

  /// No description provided for @achTierElite.
  ///
  /// In id, this message translates to:
  /// **'ELITE'**
  String get achTierElite;

  /// No description provided for @achTierEpic.
  ///
  /// In id, this message translates to:
  /// **'EPIC'**
  String get achTierEpic;

  /// No description provided for @achTierGold.
  ///
  /// In id, this message translates to:
  /// **'GOLD'**
  String get achTierGold;

  /// No description provided for @achTierLegendary.
  ///
  /// In id, this message translates to:
  /// **'LEGENDARY'**
  String get achTierLegendary;

  /// No description provided for @achTierRookie.
  ///
  /// In id, this message translates to:
  /// **'ROOKIE'**
  String get achTierRookie;

  /// No description provided for @achUnlockedBanner.
  ///
  /// In id, this message translates to:
  /// **'PENCAPAIAN TERBUKA!'**
  String get achUnlockedBanner;

  /// No description provided for @ach_collector_desc.
  ///
  /// In id, this message translates to:
  /// **'Log semua 8 jenis sholat sunnah minimal 1×'**
  String get ach_collector_desc;

  /// No description provided for @ach_collector_hint.
  ///
  /// In id, this message translates to:
  /// **'Catat minimal 1× dari 8 jenis sunnah: Dhuha, Tahajjud, dan 6 rawatib.'**
  String get ach_collector_hint;

  /// No description provided for @ach_collector_title.
  ///
  /// In id, this message translates to:
  /// **'COLLECTOR'**
  String get ach_collector_title;

  /// No description provided for @ach_comeback_real_desc.
  ///
  /// In id, this message translates to:
  /// **'Bangkit lagi setelah streak putus'**
  String get ach_comeback_real_desc;

  /// No description provided for @ach_comeback_real_title.
  ///
  /// In id, this message translates to:
  /// **'COMEBACK IS REAL'**
  String get ach_comeback_real_title;

  /// No description provided for @ach_critical_hit_desc.
  ///
  /// In id, this message translates to:
  /// **'Sholat wajib ≤5 menit setelah adzan'**
  String get ach_critical_hit_desc;

  /// No description provided for @ach_critical_hit_title.
  ///
  /// In id, this message translates to:
  /// **'CRITICAL HIT!'**
  String get ach_critical_hit_title;

  /// No description provided for @ach_dawn_buff_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali Qobliyah Subuh'**
  String get ach_dawn_buff_desc;

  /// No description provided for @ach_dawn_buff_title.
  ///
  /// In id, this message translates to:
  /// **'DAWN BUFF'**
  String get ach_dawn_buff_title;

  /// No description provided for @ach_dhuha_secured_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali log sholat Dhuha'**
  String get ach_dhuha_secured_desc;

  /// No description provided for @ach_dhuha_secured_title.
  ///
  /// In id, this message translates to:
  /// **'DHUHA SECURED'**
  String get ach_dhuha_secured_title;

  /// No description provided for @ach_dominating_desc.
  ///
  /// In id, this message translates to:
  /// **'Hero Streak 7 hari beruntun'**
  String get ach_dominating_desc;

  /// No description provided for @ach_dominating_title.
  ///
  /// In id, this message translates to:
  /// **'DOMINATING!'**
  String get ach_dominating_title;

  /// No description provided for @ach_double_kill_desc.
  ///
  /// In id, this message translates to:
  /// **'Hero Streak 2 hari beruntun'**
  String get ach_double_kill_desc;

  /// No description provided for @ach_double_kill_title.
  ///
  /// In id, this message translates to:
  /// **'DOUBLE KILL'**
  String get ach_double_kill_title;

  /// No description provided for @ach_dusk_finisher_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali Ba\\\'diyah Maghrib'**
  String get ach_dusk_finisher_desc;

  /// No description provided for @ach_dusk_finisher_title.
  ///
  /// In id, this message translates to:
  /// **'DUSK FINISHER'**
  String get ach_dusk_finisher_title;

  /// No description provided for @ach_dzikir_legend_desc.
  ///
  /// In id, this message translates to:
  /// **'Dzikir 50.000x'**
  String get ach_dzikir_legend_desc;

  /// No description provided for @ach_dzikir_legend_hint.
  ///
  /// In id, this message translates to:
  /// **'Total hitungan dzikir dari tab Dzikir seumur hidup akun.'**
  String get ach_dzikir_legend_hint;

  /// No description provided for @ach_dzikir_legend_title.
  ///
  /// In id, this message translates to:
  /// **'DZIKIR LEGEND'**
  String get ach_dzikir_legend_title;

  /// No description provided for @ach_dzikir_master_desc.
  ///
  /// In id, this message translates to:
  /// **'Dzikir 10.000x'**
  String get ach_dzikir_master_desc;

  /// No description provided for @ach_dzikir_master_title.
  ///
  /// In id, this message translates to:
  /// **'DZIKIR MASTER'**
  String get ach_dzikir_master_title;

  /// No description provided for @ach_dzikir_pemula_desc.
  ///
  /// In id, this message translates to:
  /// **'Dzikir 1.000x'**
  String get ach_dzikir_pemula_desc;

  /// No description provided for @ach_dzikir_pemula_title.
  ///
  /// In id, this message translates to:
  /// **'DZIKIR PEMULA'**
  String get ach_dzikir_pemula_title;

  /// No description provided for @ach_early_bird_desc.
  ///
  /// In id, this message translates to:
  /// **'20x sholat tepat waktu (±10m)'**
  String get ach_early_bird_desc;

  /// No description provided for @ach_early_bird_hint.
  ///
  /// In id, this message translates to:
  /// **'20× sholat tepat waktu (≤10 menit setelah adzan).'**
  String get ach_early_bird_hint;

  /// No description provided for @ach_early_bird_title.
  ///
  /// In id, this message translates to:
  /// **'EARLY BIRD'**
  String get ach_early_bird_title;

  /// No description provided for @ach_early_game_desc.
  ///
  /// In id, this message translates to:
  /// **'Sholat Subuh pertamamu tercatat'**
  String get ach_early_game_desc;

  /// No description provided for @ach_early_game_title.
  ///
  /// In id, this message translates to:
  /// **'EARLY GAME'**
  String get ach_early_game_title;

  /// No description provided for @ach_first_blood_desc.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan 5 sholat wajib dalam 1 hari (Hero Streak dimulai!)'**
  String get ach_first_blood_desc;

  /// No description provided for @ach_first_blood_hint.
  ///
  /// In id, this message translates to:
  /// **'Catat 5 sholat wajib dalam satu hari (Subuh, Dzuhur, Ashar, Maghrib, Isya).'**
  String get ach_first_blood_hint;

  /// No description provided for @ach_first_blood_title.
  ///
  /// In id, this message translates to:
  /// **'FIRST BLOOD!'**
  String get ach_first_blood_title;

  /// No description provided for @ach_first_clear_module_desc.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan modul Belajar pertamamu'**
  String get ach_first_clear_module_desc;

  /// No description provided for @ach_first_clear_module_title.
  ///
  /// In id, this message translates to:
  /// **'FIRST CLEAR'**
  String get ach_first_clear_module_title;

  /// No description provided for @ach_first_strike_desc.
  ///
  /// In id, this message translates to:
  /// **'Sholat Subuh ≤15 menit setelah adzan'**
  String get ach_first_strike_desc;

  /// No description provided for @ach_first_strike_hint.
  ///
  /// In id, this message translates to:
  /// **'Sholat Subuh dalam 15 menit setelah adzan.'**
  String get ach_first_strike_hint;

  /// No description provided for @ach_first_strike_title.
  ///
  /// In id, this message translates to:
  /// **'FIRST STRIKE'**
  String get ach_first_strike_title;

  /// No description provided for @ach_full_combo_desc.
  ///
  /// In id, this message translates to:
  /// **'Dalam 1 hari: 5 wajib + Tilawah + Dhuha'**
  String get ach_full_combo_desc;

  /// No description provided for @ach_full_combo_hint.
  ///
  /// In id, this message translates to:
  /// **'Dalam satu hari: catat 5 wajib + Tilawah + Dhuha.'**
  String get ach_full_combo_hint;

  /// No description provided for @ach_full_combo_title.
  ///
  /// In id, this message translates to:
  /// **'FULL COMBO'**
  String get ach_full_combo_title;

  /// No description provided for @ach_godlike_desc.
  ///
  /// In id, this message translates to:
  /// **'Hero Streak 30 hari beruntun'**
  String get ach_godlike_desc;

  /// No description provided for @ach_godlike_title.
  ///
  /// In id, this message translates to:
  /// **'GODLIKE!'**
  String get ach_godlike_title;

  /// No description provided for @ach_gold_buff_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali Qobliyah Ashar'**
  String get ach_gold_buff_desc;

  /// No description provided for @ach_gold_buff_title.
  ///
  /// In id, this message translates to:
  /// **'GOLD BUFF'**
  String get ach_gold_buff_title;

  /// No description provided for @ach_gold_lane_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali log sholat Ashar'**
  String get ach_gold_lane_desc;

  /// No description provided for @ach_gold_lane_title.
  ///
  /// In id, this message translates to:
  /// **'GOLD LANE'**
  String get ach_gold_lane_title;

  /// No description provided for @ach_hadis_champion_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 200 hadis'**
  String get ach_hadis_champion_desc;

  /// No description provided for @ach_hadis_champion_title.
  ///
  /// In id, this message translates to:
  /// **'HADIS CHAMPION'**
  String get ach_hadis_champion_title;

  /// No description provided for @ach_hadis_elite_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 50 hadis'**
  String get ach_hadis_elite_desc;

  /// No description provided for @ach_hadis_elite_title.
  ///
  /// In id, this message translates to:
  /// **'HADIS ELITE'**
  String get ach_hadis_elite_title;

  /// No description provided for @ach_hadis_grinder_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 10 hadis'**
  String get ach_hadis_grinder_desc;

  /// No description provided for @ach_hadis_grinder_title.
  ///
  /// In id, this message translates to:
  /// **'HADIS GRINDER'**
  String get ach_hadis_grinder_title;

  /// No description provided for @ach_hadis_hero_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 350 hadis'**
  String get ach_hadis_hero_desc;

  /// No description provided for @ach_hadis_hero_title.
  ///
  /// In id, this message translates to:
  /// **'HADIS HERO'**
  String get ach_hadis_hero_title;

  /// No description provided for @ach_hadis_legend_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 500 hadis'**
  String get ach_hadis_legend_desc;

  /// No description provided for @ach_hadis_legend_title.
  ///
  /// In id, this message translates to:
  /// **'HADIS LEGEND'**
  String get ach_hadis_legend_title;

  /// No description provided for @ach_hadis_rookie_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 5 hadis'**
  String get ach_hadis_rookie_desc;

  /// No description provided for @ach_hadis_rookie_title.
  ///
  /// In id, this message translates to:
  /// **'HADIS ROOKIE'**
  String get ach_hadis_rookie_title;

  /// No description provided for @ach_hadis_veteran_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 100 hadis'**
  String get ach_hadis_veteran_desc;

  /// No description provided for @ach_hadis_veteran_title.
  ///
  /// In id, this message translates to:
  /// **'HADIS VETERAN'**
  String get ach_hadis_veteran_title;

  /// No description provided for @ach_hadis_warrior_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 25 hadis'**
  String get ach_hadis_warrior_desc;

  /// No description provided for @ach_hadis_warrior_title.
  ///
  /// In id, this message translates to:
  /// **'HADIS WARRIOR'**
  String get ach_hadis_warrior_title;

  /// No description provided for @ach_hall_of_fame_desc.
  ///
  /// In id, this message translates to:
  /// **'Buka semua achievement lainnya 👑'**
  String get ach_hall_of_fame_desc;

  /// No description provided for @ach_hall_of_fame_hint.
  ///
  /// In id, this message translates to:
  /// **'Buka semua achievement lainnya satu per satu — terakhir dari 87 medali biasa.'**
  String get ach_hall_of_fame_hint;

  /// No description provided for @ach_hall_of_fame_title.
  ///
  /// In id, this message translates to:
  /// **'HALL OF FAME'**
  String get ach_hall_of_fame_title;

  /// No description provided for @ach_jamaah_champion_desc.
  ///
  /// In id, this message translates to:
  /// **'200x sholat berjamaah'**
  String get ach_jamaah_champion_desc;

  /// No description provided for @ach_jamaah_champion_title.
  ///
  /// In id, this message translates to:
  /// **'JAMAAH CHAMPION'**
  String get ach_jamaah_champion_title;

  /// No description provided for @ach_jamaah_elite_desc.
  ///
  /// In id, this message translates to:
  /// **'50x sholat berjamaah'**
  String get ach_jamaah_elite_desc;

  /// No description provided for @ach_jamaah_elite_title.
  ///
  /// In id, this message translates to:
  /// **'JAMAAH ELITE'**
  String get ach_jamaah_elite_title;

  /// No description provided for @ach_jamaah_grinder_desc.
  ///
  /// In id, this message translates to:
  /// **'10x sholat berjamaah'**
  String get ach_jamaah_grinder_desc;

  /// No description provided for @ach_jamaah_grinder_title.
  ///
  /// In id, this message translates to:
  /// **'JAMAAH GRINDER'**
  String get ach_jamaah_grinder_title;

  /// No description provided for @ach_jamaah_hero_desc.
  ///
  /// In id, this message translates to:
  /// **'350x sholat berjamaah'**
  String get ach_jamaah_hero_desc;

  /// No description provided for @ach_jamaah_hero_title.
  ///
  /// In id, this message translates to:
  /// **'JAMAAH HERO'**
  String get ach_jamaah_hero_title;

  /// No description provided for @ach_jamaah_legend_desc.
  ///
  /// In id, this message translates to:
  /// **'500x sholat berjamaah'**
  String get ach_jamaah_legend_desc;

  /// No description provided for @ach_jamaah_legend_title.
  ///
  /// In id, this message translates to:
  /// **'JAMAAH LEGEND'**
  String get ach_jamaah_legend_title;

  /// No description provided for @ach_jamaah_rookie_desc.
  ///
  /// In id, this message translates to:
  /// **'5x sholat berjamaah'**
  String get ach_jamaah_rookie_desc;

  /// No description provided for @ach_jamaah_rookie_title.
  ///
  /// In id, this message translates to:
  /// **'JAMAAH ROOKIE'**
  String get ach_jamaah_rookie_title;

  /// No description provided for @ach_jamaah_veteran_desc.
  ///
  /// In id, this message translates to:
  /// **'100x sholat berjamaah'**
  String get ach_jamaah_veteran_desc;

  /// No description provided for @ach_jamaah_veteran_title.
  ///
  /// In id, this message translates to:
  /// **'JAMAAH VETERAN'**
  String get ach_jamaah_veteran_title;

  /// No description provided for @ach_jamaah_warrior_desc.
  ///
  /// In id, this message translates to:
  /// **'25x sholat berjamaah'**
  String get ach_jamaah_warrior_desc;

  /// No description provided for @ach_jamaah_warrior_title.
  ///
  /// In id, this message translates to:
  /// **'JAMAAH WARRIOR'**
  String get ach_jamaah_warrior_title;

  /// No description provided for @ach_jungler_desc.
  ///
  /// In id, this message translates to:
  /// **'Streak Tilawah 7 hari beruntun'**
  String get ach_jungler_desc;

  /// No description provided for @ach_jungler_title.
  ///
  /// In id, this message translates to:
  /// **'JUNGLER'**
  String get ach_jungler_title;

  /// No description provided for @ach_langkah_pertama_desc.
  ///
  /// In id, this message translates to:
  /// **'Log sholat pertama kamu'**
  String get ach_langkah_pertama_desc;

  /// No description provided for @ach_langkah_pertama_title.
  ///
  /// In id, this message translates to:
  /// **'LANGKAH PERTAMA'**
  String get ach_langkah_pertama_title;

  /// No description provided for @ach_late_game_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali log sholat Isya'**
  String get ach_late_game_desc;

  /// No description provided for @ach_late_game_title.
  ///
  /// In id, this message translates to:
  /// **'LATE GAME'**
  String get ach_late_game_title;

  /// No description provided for @ach_legendary_desc.
  ///
  /// In id, this message translates to:
  /// **'Hero Streak 100 hari beruntun'**
  String get ach_legendary_desc;

  /// No description provided for @ach_legendary_title.
  ///
  /// In id, this message translates to:
  /// **'LEGENDARY!'**
  String get ach_legendary_title;

  /// No description provided for @ach_mana_regen_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali log Tilawah/Dzikir'**
  String get ach_mana_regen_desc;

  /// No description provided for @ach_mana_regen_title.
  ///
  /// In id, this message translates to:
  /// **'MANA REGEN'**
  String get ach_mana_regen_title;

  /// No description provided for @ach_maniac_desc.
  ///
  /// In id, this message translates to:
  /// **'Hero Streak 14 hari beruntun'**
  String get ach_maniac_desc;

  /// No description provided for @ach_maniac_title.
  ///
  /// In id, this message translates to:
  /// **'MANIAC!'**
  String get ach_maniac_title;

  /// No description provided for @ach_mid_buff_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali Qobliyah Dzuhur'**
  String get ach_mid_buff_desc;

  /// No description provided for @ach_mid_buff_title.
  ///
  /// In id, this message translates to:
  /// **'MID BUFF'**
  String get ach_mid_buff_title;

  /// No description provided for @ach_mid_finisher_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali Ba\\\'diyah Dzuhur'**
  String get ach_mid_finisher_desc;

  /// No description provided for @ach_mid_finisher_title.
  ///
  /// In id, this message translates to:
  /// **'MID FINISHER'**
  String get ach_mid_finisher_title;

  /// No description provided for @ach_mid_game_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali log sholat Dzuhur'**
  String get ach_mid_game_desc;

  /// No description provided for @ach_mid_game_title.
  ///
  /// In id, this message translates to:
  /// **'MID GAME'**
  String get ach_mid_game_title;

  /// No description provided for @ach_night_finisher_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali Ba\\\'diyah Isya'**
  String get ach_night_finisher_desc;

  /// No description provided for @ach_night_finisher_title.
  ///
  /// In id, this message translates to:
  /// **'NIGHT FINISHER'**
  String get ach_night_finisher_title;

  /// No description provided for @ach_phoenix_desc.
  ///
  /// In id, this message translates to:
  /// **'Bangkit 3× setelah streak putus — gak pernah nyerah'**
  String get ach_phoenix_desc;

  /// No description provided for @ach_phoenix_hint.
  ///
  /// In id, this message translates to:
  /// **'Setelah streak putus, mulai lagi sampai tercatat 3 kali bangkit.'**
  String get ach_phoenix_hint;

  /// No description provided for @ach_phoenix_title.
  ///
  /// In id, this message translates to:
  /// **'PHOENIX'**
  String get ach_phoenix_title;

  /// No description provided for @ach_quiz_mvp_desc.
  ///
  /// In id, this message translates to:
  /// **'Skor sempurna 100% di satu quiz'**
  String get ach_quiz_mvp_desc;

  /// No description provided for @ach_quiz_mvp_hint.
  ///
  /// In id, this message translates to:
  /// **'Kerjakan kuis di akhir modul Belajar dan jawab semua benar (100%).'**
  String get ach_quiz_mvp_hint;

  /// No description provided for @ach_quiz_mvp_title.
  ///
  /// In id, this message translates to:
  /// **'MVP'**
  String get ach_quiz_mvp_title;

  /// No description provided for @ach_quran_adept_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 100 ayat'**
  String get ach_quran_adept_desc;

  /// No description provided for @ach_quran_adept_title.
  ///
  /// In id, this message translates to:
  /// **'QURAN ADEPT'**
  String get ach_quran_adept_title;

  /// No description provided for @ach_quran_apprentice_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 50 ayat'**
  String get ach_quran_apprentice_desc;

  /// No description provided for @ach_quran_apprentice_title.
  ///
  /// In id, this message translates to:
  /// **'QURAN APPRENTICE'**
  String get ach_quran_apprentice_title;

  /// No description provided for @ach_quran_champion_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 4.000 ayat'**
  String get ach_quran_champion_desc;

  /// No description provided for @ach_quran_champion_title.
  ///
  /// In id, this message translates to:
  /// **'QURAN CHAMPION'**
  String get ach_quran_champion_title;

  /// No description provided for @ach_quran_guardian_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 2.000 ayat'**
  String get ach_quran_guardian_desc;

  /// No description provided for @ach_quran_guardian_title.
  ///
  /// In id, this message translates to:
  /// **'QURAN GUARDIAN'**
  String get ach_quran_guardian_title;

  /// No description provided for @ach_quran_hafizh_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 1.000 ayat'**
  String get ach_quran_hafizh_desc;

  /// No description provided for @ach_quran_hafizh_title.
  ///
  /// In id, this message translates to:
  /// **'HAFIZH MUDA'**
  String get ach_quran_hafizh_title;

  /// No description provided for @ach_quran_master_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 6.236 ayat (khatam)'**
  String get ach_quran_master_desc;

  /// No description provided for @ach_quran_master_hint.
  ///
  /// In id, this message translates to:
  /// **'Baca total 6.236 ayat (seluruh Al-Qur\\\'an) sejak pertama install.'**
  String get ach_quran_master_hint;

  /// No description provided for @ach_quran_master_title.
  ///
  /// In id, this message translates to:
  /// **'HAFIZH MASTER'**
  String get ach_quran_master_title;

  /// No description provided for @ach_quran_novice_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 10 ayat'**
  String get ach_quran_novice_desc;

  /// No description provided for @ach_quran_novice_title.
  ///
  /// In id, this message translates to:
  /// **'QURAN NOVICE'**
  String get ach_quran_novice_title;

  /// No description provided for @ach_quran_sage_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 500 ayat'**
  String get ach_quran_sage_desc;

  /// No description provided for @ach_quran_sage_title.
  ///
  /// In id, this message translates to:
  /// **'QURAN SAGE'**
  String get ach_quran_sage_title;

  /// No description provided for @ach_quran_scholar_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 200 ayat'**
  String get ach_quran_scholar_desc;

  /// No description provided for @ach_quran_scholar_title.
  ///
  /// In id, this message translates to:
  /// **'QURAN SCHOLAR'**
  String get ach_quran_scholar_title;

  /// No description provided for @ach_rank_elite_desc.
  ///
  /// In id, this message translates to:
  /// **'Capai Level 25'**
  String get ach_rank_elite_desc;

  /// No description provided for @ach_rank_elite_title.
  ///
  /// In id, this message translates to:
  /// **'ELITE'**
  String get ach_rank_elite_title;

  /// No description provided for @ach_rank_epic_desc.
  ///
  /// In id, this message translates to:
  /// **'Capai Level 60'**
  String get ach_rank_epic_desc;

  /// No description provided for @ach_rank_epic_title.
  ///
  /// In id, this message translates to:
  /// **'EPIC'**
  String get ach_rank_epic_title;

  /// No description provided for @ach_rank_master_desc.
  ///
  /// In id, this message translates to:
  /// **'Capai Level 40'**
  String get ach_rank_master_desc;

  /// No description provided for @ach_rank_master_title.
  ///
  /// In id, this message translates to:
  /// **'MASTER'**
  String get ach_rank_master_title;

  /// No description provided for @ach_rank_mythic_desc.
  ///
  /// In id, this message translates to:
  /// **'Capai Level 80 — Muslim Mythic!'**
  String get ach_rank_mythic_desc;

  /// No description provided for @ach_rank_mythic_hint.
  ///
  /// In id, this message translates to:
  /// **'Naik level lewat XP dari ibadah harian — naik level 80 butuh waktu.'**
  String get ach_rank_mythic_hint;

  /// No description provided for @ach_rank_mythic_title.
  ///
  /// In id, this message translates to:
  /// **'MYTHIC'**
  String get ach_rank_mythic_title;

  /// No description provided for @ach_rank_warrior_desc.
  ///
  /// In id, this message translates to:
  /// **'Capai Level 10'**
  String get ach_rank_warrior_desc;

  /// No description provided for @ach_rank_warrior_title.
  ///
  /// In id, this message translates to:
  /// **'WARRIOR'**
  String get ach_rank_warrior_title;

  /// No description provided for @ach_sage_desc.
  ///
  /// In id, this message translates to:
  /// **'Tamatkan semua 16 modul Belajar'**
  String get ach_sage_desc;

  /// No description provided for @ach_sage_hint.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan semua 16 modul Belajar (skor kuis terserah).'**
  String get ach_sage_hint;

  /// No description provided for @ach_sage_title.
  ///
  /// In id, this message translates to:
  /// **'SAGE'**
  String get ach_sage_title;

  /// No description provided for @ach_santri_scholar_desc.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan 40 modul Belajar'**
  String get ach_santri_scholar_desc;

  /// No description provided for @ach_santri_scholar_hint.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan 40 modul di tab Belajar (saat ini 16 modul, naik bertahap).'**
  String get ach_santri_scholar_hint;

  /// No description provided for @ach_santri_scholar_title.
  ///
  /// In id, this message translates to:
  /// **'SANTRI SCHOLAR'**
  String get ach_santri_scholar_title;

  /// No description provided for @ach_savage_desc.
  ///
  /// In id, this message translates to:
  /// **'Hero Streak 60 hari beruntun'**
  String get ach_savage_desc;

  /// No description provided for @ach_savage_title.
  ///
  /// In id, this message translates to:
  /// **'SAVAGE!'**
  String get ach_savage_title;

  /// No description provided for @ach_sharpshooter_desc.
  ///
  /// In id, this message translates to:
  /// **'10× sholat tepat waktu (≤10 menit)'**
  String get ach_sharpshooter_desc;

  /// No description provided for @ach_sharpshooter_hint.
  ///
  /// In id, this message translates to:
  /// **'10× sholat tepat waktu (≤10 menit setelah adzan).'**
  String get ach_sharpshooter_hint;

  /// No description provided for @ach_sharpshooter_title.
  ///
  /// In id, this message translates to:
  /// **'SHARPSHOOTER'**
  String get ach_sharpshooter_title;

  /// No description provided for @ach_subuh_legend_desc.
  ///
  /// In id, this message translates to:
  /// **'Streak Subuh 30 hari'**
  String get ach_subuh_legend_desc;

  /// No description provided for @ach_subuh_legend_title.
  ///
  /// In id, this message translates to:
  /// **'SUBUH LEGEND'**
  String get ach_subuh_legend_title;

  /// No description provided for @ach_subuh_solo_carry_desc.
  ///
  /// In id, this message translates to:
  /// **'Streak Subuh 7 hari beruntun — lane tersulit'**
  String get ach_subuh_solo_carry_desc;

  /// No description provided for @ach_subuh_solo_carry_title.
  ///
  /// In id, this message translates to:
  /// **'SUBUH SOLO CARRY'**
  String get ach_subuh_solo_carry_title;

  /// No description provided for @ach_sultan_sunnah_desc.
  ///
  /// In id, this message translates to:
  /// **'50 sholat sunnah total'**
  String get ach_sultan_sunnah_desc;

  /// No description provided for @ach_sultan_sunnah_title.
  ///
  /// In id, this message translates to:
  /// **'SULTAN SUNNAH'**
  String get ach_sultan_sunnah_title;

  /// No description provided for @ach_sunnah_master_desc.
  ///
  /// In id, this message translates to:
  /// **'200 sholat sunnah total'**
  String get ach_sunnah_master_desc;

  /// No description provided for @ach_sunnah_master_hint.
  ///
  /// In id, this message translates to:
  /// **'Total catatan 8 jenis sholat sunnah (Dhuha, Rawatib, Tahajjud, dll).'**
  String get ach_sunnah_master_hint;

  /// No description provided for @ach_sunnah_master_title.
  ///
  /// In id, this message translates to:
  /// **'SUNNAH MASTER'**
  String get ach_sunnah_master_title;

  /// No description provided for @ach_sunset_strike_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali log sholat Maghrib'**
  String get ach_sunset_strike_desc;

  /// No description provided for @ach_sunset_strike_title.
  ///
  /// In id, this message translates to:
  /// **'SUNSET STRIKE'**
  String get ach_sunset_strike_title;

  /// No description provided for @ach_tahajjud_secured_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertama kali log sholat Tahajjud'**
  String get ach_tahajjud_secured_desc;

  /// No description provided for @ach_tahajjud_secured_title.
  ///
  /// In id, this message translates to:
  /// **'TAHAJJUD SECURED'**
  String get ach_tahajjud_secured_title;

  /// No description provided for @ach_tilawah_streak_14_desc.
  ///
  /// In id, this message translates to:
  /// **'Streak Tilawah 14 hari'**
  String get ach_tilawah_streak_14_desc;

  /// No description provided for @ach_tilawah_streak_14_title.
  ///
  /// In id, this message translates to:
  /// **'TILAWAH STREAK'**
  String get ach_tilawah_streak_14_title;

  /// No description provided for @ach_triple_kill_desc.
  ///
  /// In id, this message translates to:
  /// **'Hero Streak 3 hari beruntun'**
  String get ach_triple_kill_desc;

  /// No description provided for @ach_triple_kill_title.
  ///
  /// In id, this message translates to:
  /// **'TRIPLE KILL'**
  String get ach_triple_kill_title;

  /// No description provided for @ach_unstoppable_desc.
  ///
  /// In id, this message translates to:
  /// **'Hero Streak 5 hari beruntun'**
  String get ach_unstoppable_desc;

  /// No description provided for @ach_unstoppable_title.
  ///
  /// In id, this message translates to:
  /// **'UNSTOPPABLE!'**
  String get ach_unstoppable_title;

  /// No description provided for @ach_wajib_champion_desc.
  ///
  /// In id, this message translates to:
  /// **'400x sholat wajib'**
  String get ach_wajib_champion_desc;

  /// No description provided for @ach_wajib_champion_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB CHAMPION'**
  String get ach_wajib_champion_title;

  /// No description provided for @ach_wajib_elite_desc.
  ///
  /// In id, this message translates to:
  /// **'100x sholat wajib'**
  String get ach_wajib_elite_desc;

  /// No description provided for @ach_wajib_elite_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB ELITE'**
  String get ach_wajib_elite_title;

  /// No description provided for @ach_wajib_grinder_desc.
  ///
  /// In id, this message translates to:
  /// **'25x sholat wajib'**
  String get ach_wajib_grinder_desc;

  /// No description provided for @ach_wajib_grinder_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB GRINDER'**
  String get ach_wajib_grinder_title;

  /// No description provided for @ach_wajib_hero_desc.
  ///
  /// In id, this message translates to:
  /// **'700x sholat wajib'**
  String get ach_wajib_hero_desc;

  /// No description provided for @ach_wajib_hero_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB HERO'**
  String get ach_wajib_hero_title;

  /// No description provided for @ach_wajib_immortal_desc.
  ///
  /// In id, this message translates to:
  /// **'2.000x sholat wajib'**
  String get ach_wajib_immortal_desc;

  /// No description provided for @ach_wajib_immortal_hint.
  ///
  /// In id, this message translates to:
  /// **'Total catatan sholat wajib kumulatif seumur hidup akun.'**
  String get ach_wajib_immortal_hint;

  /// No description provided for @ach_wajib_immortal_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB IMMORTAL'**
  String get ach_wajib_immortal_title;

  /// No description provided for @ach_wajib_master_desc.
  ///
  /// In id, this message translates to:
  /// **'1.000x sholat wajib'**
  String get ach_wajib_master_desc;

  /// No description provided for @ach_wajib_master_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB MASTER'**
  String get ach_wajib_master_title;

  /// No description provided for @ach_wajib_mythic_desc.
  ///
  /// In id, this message translates to:
  /// **'1.500x sholat wajib'**
  String get ach_wajib_mythic_desc;

  /// No description provided for @ach_wajib_mythic_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB MYTHIC'**
  String get ach_wajib_mythic_title;

  /// No description provided for @ach_wajib_rookie_desc.
  ///
  /// In id, this message translates to:
  /// **'10x sholat wajib'**
  String get ach_wajib_rookie_desc;

  /// No description provided for @ach_wajib_rookie_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB ROOKIE'**
  String get ach_wajib_rookie_title;

  /// No description provided for @ach_wajib_veteran_desc.
  ///
  /// In id, this message translates to:
  /// **'200x sholat wajib'**
  String get ach_wajib_veteran_desc;

  /// No description provided for @ach_wajib_veteran_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB VETERAN'**
  String get ach_wajib_veteran_title;

  /// No description provided for @ach_wajib_warrior_desc.
  ///
  /// In id, this message translates to:
  /// **'50x sholat wajib'**
  String get ach_wajib_warrior_desc;

  /// No description provided for @ach_wajib_warrior_title.
  ///
  /// In id, this message translates to:
  /// **'WAJIB WARRIOR'**
  String get ach_wajib_warrior_title;

  /// No description provided for @ach_wombo_combo_desc.
  ///
  /// In id, this message translates to:
  /// **'Tuntaskan Daily Zikir 100 pertama kali'**
  String get ach_wombo_combo_desc;

  /// No description provided for @ach_wombo_combo_title.
  ///
  /// In id, this message translates to:
  /// **'WOMBO COMBO'**
  String get ach_wombo_combo_title;

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'Muslim Leveling'**
  String get appTitle;

  /// No description provided for @localeEnglish.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get localeEnglish;

  /// No description provided for @localeIndonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get localeIndonesian;

  /// No description provided for @localePicked.
  ///
  /// In id, this message translates to:
  /// **'Bahasa dipilih'**
  String get localePicked;

  /// No description provided for @localeSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikut Sistem (HP)'**
  String get localeSystem;

  /// No description provided for @localeTitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa aplikasi'**
  String get localeTitle;

  /// No description provided for @settingLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingLanguage;

  /// No description provided for @shareBtnShareAgain.
  ///
  /// In id, this message translates to:
  /// **'Bagikan Lagi'**
  String get shareBtnShareAgain;

  /// No description provided for @shareCaption.
  ///
  /// In id, this message translates to:
  /// **'Aku unlock \"{title}\" di Muslim Leveling! 🎮🕌'**
  String shareCaption(String title);

  /// No description provided for @shareEarnedOn.
  ///
  /// In id, this message translates to:
  /// **'Diraih {date}'**
  String shareEarnedOn(String date);

  /// No description provided for @shareErrImage.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat gambar kartu. Coba lagi.'**
  String get shareErrImage;

  /// No description provided for @shareErrPrepare.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyiapkan kartu. Coba lagi.'**
  String get shareErrPrepare;

  /// No description provided for @shareErrShare.
  ///
  /// In id, this message translates to:
  /// **'Gagal membagikan kartu. Coba lagi.'**
  String get shareErrShare;

  /// No description provided for @shareStatAllModules.
  ///
  /// In id, this message translates to:
  /// **'📚 Semua 16 modul selesai!'**
  String get shareStatAllModules;

  /// No description provided for @shareStatCollector.
  ///
  /// In id, this message translates to:
  /// **'👑 Kolektor sejati!'**
  String get shareStatCollector;

  /// No description provided for @shareStatComeback.
  ///
  /// In id, this message translates to:
  /// **'Total comeback: {count} kali 💪'**
  String shareStatComeback(int count);

  /// No description provided for @shareStatDhikr.
  ///
  /// In id, this message translates to:
  /// **'📿 Target zikir tercapai!'**
  String get shareStatDhikr;

  /// No description provided for @shareStatFajr15.
  ///
  /// In id, this message translates to:
  /// **'🎯 Subuh sebelum 15 menit'**
  String get shareStatFajr15;

  /// No description provided for @shareStatFajrStreak.
  ///
  /// In id, this message translates to:
  /// **'hari Subuh beruntun 🔥'**
  String get shareStatFajrStreak;

  /// No description provided for @shareStatFullCombo.
  ///
  /// In id, this message translates to:
  /// **'🔥 5 wajib + Tilawah + Dhuha'**
  String get shareStatFullCombo;

  /// No description provided for @shareStatHeroStreak.
  ///
  /// In id, this message translates to:
  /// **'hari Hero Streak 🔥'**
  String get shareStatHeroStreak;

  /// No description provided for @shareStatLearning.
  ///
  /// In id, this message translates to:
  /// **'📖 Mulai belajar — teruskan!'**
  String get shareStatLearning;

  /// No description provided for @shareStatLevel.
  ///
  /// In id, this message translates to:
  /// **'Level {level} — {rank}'**
  String shareStatLevel(int level, String rank);

  /// No description provided for @shareStatOnTime10.
  ///
  /// In id, this message translates to:
  /// **'🎯 10× sholat tepat waktu'**
  String get shareStatOnTime10;

  /// No description provided for @shareStatOnTimeFirst.
  ///
  /// In id, this message translates to:
  /// **'⚡ Tepat waktu sejak pertama'**
  String get shareStatOnTimeFirst;

  /// No description provided for @shareStatQuizPerfect.
  ///
  /// In id, this message translates to:
  /// **'⭐ Skor sempurna!'**
  String get shareStatQuizPerfect;

  /// No description provided for @shareStatSunnah.
  ///
  /// In id, this message translates to:
  /// **'🏛️ Semua 8 sunnah terkumpul'**
  String get shareStatSunnah;

  /// No description provided for @shareStatTilawahStreak.
  ///
  /// In id, this message translates to:
  /// **'hari Tilawah beruntun 🔥'**
  String get shareStatTilawahStreak;

  /// No description provided for @tabHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get tabHome;

  /// No description provided for @tabJadwal.
  ///
  /// In id, this message translates to:
  /// **'Jadwal'**
  String get tabJadwal;

  /// No description provided for @tabQuran.
  ///
  /// In id, this message translates to:
  /// **'Al-Quran'**
  String get tabQuran;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'id':
      return AppL10nId();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

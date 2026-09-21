import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_tr.dart';

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
    Locale('ms'),
    Locale('tr'),
  ];

  /// No description provided for @achBtnAwesome.
  ///
  /// In id, this message translates to:
  /// **'MANTAP!'**
  String get achBtnAwesome;

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

  /// No description provided for @commonCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get commonCancel;

  /// No description provided for @cityPickerEmptyKab.
  ///
  /// In id, this message translates to:
  /// **'Kabupaten/kota tidak ditemukan'**
  String get cityPickerEmptyKab;

  /// No description provided for @cityPickerEmptyProv.
  ///
  /// In id, this message translates to:
  /// **'Provinsi tidak ditemukan'**
  String get cityPickerEmptyProv;

  /// No description provided for @cityPickerHintKab.
  ///
  /// In id, this message translates to:
  /// **'Ketik nama kabupaten/kota...'**
  String get cityPickerHintKab;

  /// No description provided for @cityPickerHintProv.
  ///
  /// In id, this message translates to:
  /// **'Ketik nama provinsi...'**
  String get cityPickerHintProv;

  /// No description provided for @cityPickerNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kabupaten/kota tidak ditemukan. Coba pilih provinsi lain.'**
  String get cityPickerNotFound;

  /// No description provided for @cityPickerLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar kabupaten/kota. Periksa koneksi lalu coba lagi.'**
  String get cityPickerLoadFailed;

  /// No description provided for @cityPickerRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get cityPickerRetry;

  /// No description provided for @cityPickerTitleKab.
  ///
  /// In id, this message translates to:
  /// **'Pilih Kabupaten/Kota'**
  String get cityPickerTitleKab;

  /// No description provided for @cityPickerTitleProv.
  ///
  /// In id, this message translates to:
  /// **'Pilih Provinsi'**
  String get cityPickerTitleProv;

  /// No description provided for @commonClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get commonClose;

  /// No description provided for @commonLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get commonLogout;

  /// No description provided for @commonOk.
  ///
  /// In id, this message translates to:
  /// **'Oke'**
  String get commonOk;

  /// No description provided for @commonSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get commonSave;

  /// No description provided for @homeAskWajibBody.
  ///
  /// In id, this message translates to:
  /// **'Pilih kondisi sholatmu untuk bonus XP'**
  String get homeAskWajibBody;

  /// No description provided for @homeAskWajibTitle.
  ///
  /// In id, this message translates to:
  /// **'Sudah Sholat ({prayer})?'**
  String homeAskWajibTitle(String prayer);

  /// No description provided for @homeBonusJamaah.
  ///
  /// In id, this message translates to:
  /// **'Berjamaah'**
  String get homeBonusJamaah;

  /// No description provided for @homeBonusJamaahSub.
  ///
  /// In id, this message translates to:
  /// **'sholat berjamaah'**
  String get homeBonusJamaahSub;

  /// No description provided for @homeBonusOnTime.
  ///
  /// In id, this message translates to:
  /// **'Tepat waktu'**
  String get homeBonusOnTime;

  /// No description provided for @homeBonusOnTimeSub.
  ///
  /// In id, this message translates to:
  /// **'di bawah 30 menit setelah adzan'**
  String get homeBonusOnTimeSub;

  /// No description provided for @homeBonusPlain.
  ///
  /// In id, this message translates to:
  /// **'Sudah'**
  String get homeBonusPlain;

  /// No description provided for @homeBonusPlainSub.
  ///
  /// In id, this message translates to:
  /// **'tanpa bonus XP'**
  String get homeBonusPlainSub;

  /// No description provided for @homeBonusQuestSunnah.
  ///
  /// In id, this message translates to:
  /// **'BONUS QUEST · SUNNAH'**
  String get homeBonusQuestSunnah;

  /// No description provided for @homeChestLocked.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan 5 wajib'**
  String get homeChestLocked;

  /// No description provided for @homeChestMetaOpened.
  ///
  /// In id, this message translates to:
  /// **'DIBUKA'**
  String get homeChestMetaOpened;

  /// No description provided for @homeChestMetaProgress.
  ///
  /// In id, this message translates to:
  /// **'{done}/{total} WAJIB'**
  String homeChestMetaProgress(int done, int total);

  /// No description provided for @homeChestOpenedLabel.
  ///
  /// In id, this message translates to:
  /// **'CHEST DIBUKA'**
  String get homeChestOpenedLabel;

  /// No description provided for @homeChestOpenedSub.
  ///
  /// In id, this message translates to:
  /// **'Besok lagi ya kak! 🌙'**
  String get homeChestOpenedSub;

  /// No description provided for @homeChestReadyLabel.
  ///
  /// In id, this message translates to:
  /// **'REWARD SIAP!'**
  String get homeChestReadyLabel;

  /// No description provided for @homeChestReadySub.
  ///
  /// In id, this message translates to:
  /// **'Klik untuk klaim 🎉'**
  String get homeChestReadySub;

  /// No description provided for @homeChestTitle.
  ///
  /// In id, this message translates to:
  /// **'DAILY CHEST'**
  String get homeChestTitle;

  /// No description provided for @homeDefaultCity.
  ///
  /// In id, this message translates to:
  /// **'Jakarta'**
  String get homeDefaultCity;

  /// No description provided for @homeLevelUpSource.
  ///
  /// In id, this message translates to:
  /// **'Sholat {prayer}'**
  String homeLevelUpSource(String prayer);

  /// No description provided for @homeLockAfterTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu {prayer} sudah lewat.'**
  String homeLockAfterTime(String prayer);

  /// No description provided for @homeLockBeforeTime.
  ///
  /// In id, this message translates to:
  /// **'Belum masuk waktu {prayer} (adzan {time}).'**
  String homeLockBeforeTime(String prayer, String time);

  /// No description provided for @homeLockSubuh.
  ///
  /// In id, this message translates to:
  /// **'Quest Subuh terkunci {hours} jam setelah adzan (sampai {until}). Besok jangan kelewat ya! 💪'**
  String homeLockSubuh(int hours, String until);

  /// No description provided for @homeLogDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Sholat ini udah dicatat hari ini!'**
  String get homeLogDuplicate;

  /// No description provided for @homeNext.
  ///
  /// In id, this message translates to:
  /// **'BERIKUTNYA'**
  String get homeNext;

  /// No description provided for @homeQuestClaimable.
  ///
  /// In id, this message translates to:
  /// **'{n} SIAP KLAIM'**
  String homeQuestClaimable(int n);

  /// No description provided for @homeQuestDaily.
  ///
  /// In id, this message translates to:
  /// **'QUEST HARIAN'**
  String get homeQuestDaily;

  /// No description provided for @homeQuickActions.
  ///
  /// In id, this message translates to:
  /// **'AKSES CEPAT'**
  String get homeQuickActions;

  /// No description provided for @homeQuickActionsMeta.
  ///
  /// In id, this message translates to:
  /// **'RENUNGAN {done}/{total}'**
  String homeQuickActionsMeta(int done, int total);

  /// No description provided for @homeQuickDoa.
  ///
  /// In id, this message translates to:
  /// **'Doa'**
  String get homeQuickDoa;

  /// No description provided for @homeQuickDzikir.
  ///
  /// In id, this message translates to:
  /// **'Dzikir'**
  String get homeQuickDzikir;

  /// No description provided for @homeQuickHadis.
  ///
  /// In id, this message translates to:
  /// **'Hadis'**
  String get homeQuickHadis;

  /// No description provided for @homeQuickKiblat.
  ///
  /// In id, this message translates to:
  /// **'Kiblat'**
  String get homeQuickKiblat;

  /// No description provided for @homeQuickRenungan.
  ///
  /// In id, this message translates to:
  /// **'Renungan'**
  String get homeQuickRenungan;

  /// No description provided for @homeRevealBtn.
  ///
  /// In id, this message translates to:
  /// **'Alhamdulillah! 🤲'**
  String get homeRevealBtn;

  /// No description provided for @homeRevealCosmetic.
  ///
  /// In id, this message translates to:
  /// **'KOSMETIK BARU!'**
  String get homeRevealCosmetic;

  /// No description provided for @homeRevealDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Item duplikat — koleksi tetap tersimpan 📦'**
  String get homeRevealDuplicate;

  /// No description provided for @homeRevealLevelUp.
  ///
  /// In id, this message translates to:
  /// **'⬆️ Level Up!{suffix}'**
  String homeRevealLevelUp(String suffix);

  /// No description provided for @homeRevealReward.
  ///
  /// In id, this message translates to:
  /// **'REWARD DIDAPAT!'**
  String get homeRevealReward;

  /// No description provided for @homeRevealShield.
  ///
  /// In id, this message translates to:
  /// **'FREEZE SHIELD!'**
  String get homeRevealShield;

  /// No description provided for @homeRevealShieldBody.
  ///
  /// In id, this message translates to:
  /// **'Streak aman 1 hari saat lupa sholat. Total: {count} ❄️'**
  String homeRevealShieldBody(int count);

  /// No description provided for @homeRingWajib.
  ///
  /// In id, this message translates to:
  /// **'WAJIB'**
  String get homeRingWajib;

  /// No description provided for @homeRitualToday.
  ///
  /// In id, this message translates to:
  /// **'RITUAL HARI INI'**
  String get homeRitualToday;

  /// No description provided for @homeSideDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai hari ini ✓'**
  String get homeSideDone;

  /// No description provided for @homeSideDzikir.
  ///
  /// In id, this message translates to:
  /// **'Dzikir 100x'**
  String get homeSideDzikir;

  /// No description provided for @homeSideDzikirSub.
  ///
  /// In id, this message translates to:
  /// **'{count}/{target} dzikir'**
  String homeSideDzikirSub(int count, int target);

  /// No description provided for @homeSideHadis.
  ///
  /// In id, this message translates to:
  /// **'Belajar Hadis'**
  String get homeSideHadis;

  /// No description provided for @homeSideHadisSub.
  ///
  /// In id, this message translates to:
  /// **'{count}/{target} hadis dibaca'**
  String homeSideHadisSub(int count, int target);

  /// No description provided for @homeSideQuestTitle.
  ///
  /// In id, this message translates to:
  /// **'SIDE QUEST'**
  String get homeSideQuestTitle;

  /// No description provided for @homeSideQuran.
  ///
  /// In id, this message translates to:
  /// **'Baca Quran'**
  String get homeSideQuran;

  /// No description provided for @homeSideQuranSub.
  ///
  /// In id, this message translates to:
  /// **'{done}/{target} ayat hari ini'**
  String homeSideQuranSub(int done, int target);

  /// No description provided for @homeSideSedekah.
  ///
  /// In id, this message translates to:
  /// **'Sedekah'**
  String get homeSideSedekah;

  /// No description provided for @homeSideSedekahSub.
  ///
  /// In id, this message translates to:
  /// **'Bersedekah hari ini'**
  String get homeSideSedekahSub;

  /// No description provided for @homeSunnahHintBadiyahDzuhur.
  ///
  /// In id, this message translates to:
  /// **'Ba\'diyah Dzuhur waktunya setelah Dzuhur sampai sebelum Ashar.'**
  String get homeSunnahHintBadiyahDzuhur;

  /// No description provided for @homeSunnahHintBadiyahIsya.
  ///
  /// In id, this message translates to:
  /// **'Ba\'diyah Isya waktunya setelah Isya sampai tengah malam.'**
  String get homeSunnahHintBadiyahIsya;

  /// No description provided for @homeSunnahHintBadiyahMaghrib.
  ///
  /// In id, this message translates to:
  /// **'Ba\'diyah Maghrib waktunya setelah Maghrib sampai sebelum Isya.'**
  String get homeSunnahHintBadiyahMaghrib;

  /// No description provided for @homeSunnahHintDhuha.
  ///
  /// In id, this message translates to:
  /// **'Dhuha bisa setelah matahari naik (±15 min setelah terbit) sampai sebelum Dzuhur.'**
  String get homeSunnahHintDhuha;

  /// No description provided for @homeSunnahHintFallback.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi nanti ya.'**
  String get homeSunnahHintFallback;

  /// No description provided for @homeSunnahHintQobliyahAshar.
  ///
  /// In id, this message translates to:
  /// **'Qobliyah Ashar waktunya dari Ashar sampai sebelum Maghrib.'**
  String get homeSunnahHintQobliyahAshar;

  /// No description provided for @homeSunnahHintQobliyahDzuhur.
  ///
  /// In id, this message translates to:
  /// **'Qobliyah Dzuhur waktunya dari Dzuhur sampai sebelum Ashar.'**
  String get homeSunnahHintQobliyahDzuhur;

  /// No description provided for @homeSunnahHintQobliyahSubuh.
  ///
  /// In id, this message translates to:
  /// **'Qobliyah Subuh waktunya sama dengan sholat Subuh (dari Subuh sampai Terbit).'**
  String get homeSunnahHintQobliyahSubuh;

  /// No description provided for @homeSunnahHintTahajjud.
  ///
  /// In id, this message translates to:
  /// **'Tahajjud waktu setelah Isya sampai sebelum Imsak.'**
  String get homeSunnahHintTahajjud;

  /// No description provided for @homeUnitDays.
  ///
  /// In id, this message translates to:
  /// **'hari'**
  String get homeUnitDays;

  /// No description provided for @homeWajibQuest.
  ///
  /// In id, this message translates to:
  /// **'WAJIB QUEST'**
  String get homeWajibQuest;

  /// No description provided for @homeXpToNextRank.
  ///
  /// In id, this message translates to:
  /// **'XP TO NEXT RANK'**
  String get homeXpToNextRank;

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

  /// No description provided for @localeMalay.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Melayu'**
  String get localeMalay;

  /// No description provided for @localeTurkish.
  ///
  /// In id, this message translates to:
  /// **'Türkçe'**
  String get localeTurkish;

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

  /// No description provided for @onbContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get onbContinue;

  /// No description provided for @onbDefaultNickname.
  ///
  /// In id, this message translates to:
  /// **'Pejuang'**
  String get onbDefaultNickname;

  /// No description provided for @onbGenderAkhwat.
  ///
  /// In id, this message translates to:
  /// **'AKHWAT'**
  String get onbGenderAkhwat;

  /// No description provided for @onbGenderIkhwan.
  ///
  /// In id, this message translates to:
  /// **'IKHWAN'**
  String get onbGenderIkhwan;

  /// No description provided for @onbGenderMeaning.
  ///
  /// In id, this message translates to:
  /// **'Ikhwan artinya laki-laki, akhwat artinya perempuan.'**
  String get onbGenderMeaning;

  /// No description provided for @onbGenderPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Jawabanmu cuma dipakai untuk menyembunyikan menu. Kamu bisa ubah kapan saja di Profil.'**
  String get onbGenderPrivacy;

  /// No description provided for @onbGenderSkip.
  ///
  /// In id, this message translates to:
  /// **'Tidak perlu'**
  String get onbGenderSkip;

  /// No description provided for @onbGenderTitle.
  ///
  /// In id, this message translates to:
  /// **'Kamu Ikhwan atau Akhwat?'**
  String get onbGenderTitle;

  /// No description provided for @onbGenderWhy.
  ///
  /// In id, this message translates to:
  /// **'Akhwat punya fitur Periode Haid: saat datang bulan, streak sholat otomatis di-freeze supaya tidak ada penalti. Fitur itu kami sembunyikan dari tampilan Ikhwan supaya menunya bersih.'**
  String get onbGenderWhy;

  /// No description provided for @onbHowAchBody.
  ///
  /// In id, this message translates to:
  /// **'Buka medali dari streak, tilawah, dan dzikir.'**
  String get onbHowAchBody;

  /// No description provided for @onbHowAchTitle.
  ///
  /// In id, this message translates to:
  /// **'Achievements'**
  String get onbHowAchTitle;

  /// No description provided for @onbHowBody.
  ///
  /// In id, this message translates to:
  /// **'Tiga hal ini yang bikin ibadah harianmu terasa seperti naik level.'**
  String get onbHowBody;

  /// No description provided for @onbHowDemoHint.
  ///
  /// In id, this message translates to:
  /// **'Coba ketuk kartunya'**
  String get onbHowDemoHint;

  /// No description provided for @onbHowQuestBody.
  ///
  /// In id, this message translates to:
  /// **'Tandai sholat wajib & sunnah tiap hari.'**
  String get onbHowQuestBody;

  /// No description provided for @onbHowQuestTitle.
  ///
  /// In id, this message translates to:
  /// **'Quest Harian'**
  String get onbHowQuestTitle;

  /// No description provided for @onbHowTitle.
  ///
  /// In id, this message translates to:
  /// **'Cara Main'**
  String get onbHowTitle;

  /// No description provided for @onbHowXpBody.
  ///
  /// In id, this message translates to:
  /// **'Tiap quest selesai dapat XP. Naik level, naik pangkat.'**
  String get onbHowXpBody;

  /// No description provided for @onbHowXpTitle.
  ///
  /// In id, this message translates to:
  /// **'XP & Level'**
  String get onbHowXpTitle;

  /// No description provided for @onbLangBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa ubah kapan saja di Profil.'**
  String get onbLangBody;

  /// No description provided for @onbLangTitle.
  ///
  /// In id, this message translates to:
  /// **'Mau pakai bahasa apa?'**
  String get onbLangTitle;

  /// No description provided for @onbLocationAllow.
  ///
  /// In id, this message translates to:
  /// **'Izinkan Lokasi'**
  String get onbLocationAllow;

  /// No description provided for @onbLocationBody.
  ///
  /// In id, this message translates to:
  /// **'Untuk menghitung jadwal sholat & arah qiblat yang akurat, kami perlu akses lokasi. Lokasi tidak dibagikan ke siapa pun — semua perhitungan terjadi di HP-mu.'**
  String get onbLocationBody;

  /// No description provided for @onbLocationLoading.
  ///
  /// In id, this message translates to:
  /// **'MENGAMBIL LOKASI...'**
  String get onbLocationLoading;

  /// No description provided for @onbLocationLater.
  ///
  /// In id, this message translates to:
  /// **'Pakai kota default dulu'**
  String get onbLocationLater;

  /// No description provided for @onbLocationLaterHint.
  ///
  /// In id, this message translates to:
  /// **'Belum ada lokasi? Jadwal memakai kota default dulu — bisa diubah kapan saja di Profil.'**
  String get onbLocationLaterHint;

  /// No description provided for @onbLocationPickManual.
  ///
  /// In id, this message translates to:
  /// **'Pilih kota manual'**
  String get onbLocationPickManual;

  /// No description provided for @onbLocationRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get onbLocationRetry;

  /// No description provided for @onbLocationTitle.
  ///
  /// In id, this message translates to:
  /// **'Butuh Lokasimu'**
  String get onbLocationTitle;

  /// No description provided for @onbNameBody.
  ///
  /// In id, this message translates to:
  /// **'Nama ini muncul di Beranda dan kartu medali. Boleh dikosongkan.'**
  String get onbNameBody;

  /// No description provided for @onbNameTitle.
  ///
  /// In id, this message translates to:
  /// **'Siapa nama pejuangmu?'**
  String get onbNameTitle;

  /// No description provided for @onbNicknameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama pejuang (opsional — kosong: Pejuang)'**
  String get onbNicknameHint;

  /// No description provided for @onbNotifAllow.
  ///
  /// In id, this message translates to:
  /// **'Izinkan Notifikasi'**
  String get onbNotifAllow;

  /// No description provided for @onbNotifBody.
  ///
  /// In id, this message translates to:
  /// **'Biar tidak kelewat, kami kirim pengingat saat waktu sholat tiba. Kami minta izin notifikasi + pengecualian baterai — tanpa itu ponsel bisa mematikan pengingat diam-diam saat app ditutup.'**
  String get onbNotifBody;

  /// No description provided for @onbNotifDenied.
  ///
  /// In id, this message translates to:
  /// **'Pengingat tidak aktif. Bisa dinyalakan kapan saja di Profil.'**
  String get onbNotifDenied;

  /// No description provided for @onbNotifLoading.
  ///
  /// In id, this message translates to:
  /// **'MENYALA...'**
  String get onbNotifLoading;

  /// No description provided for @onbNotifSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati, nanti saja'**
  String get onbNotifSkip;

  /// No description provided for @onbNotifTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Adzan'**
  String get onbNotifTitle;

  /// No description provided for @onbProgressLabel.
  ///
  /// In id, this message translates to:
  /// **'Persiapan'**
  String get onbProgressLabel;

  /// No description provided for @onbStepOf.
  ///
  /// In id, this message translates to:
  /// **'Langkah {step} dari {total}'**
  String onbStepOf(String step, String total);

  /// No description provided for @onbXpDemoSemantics.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Subuh selesai, ditambah 50 XP'**
  String get onbXpDemoSemantics;

  /// No description provided for @prayerAshar.
  ///
  /// In id, this message translates to:
  /// **'Ashar'**
  String get prayerAshar;

  /// No description provided for @prayerDzuhur.
  ///
  /// In id, this message translates to:
  /// **'Dzuhur'**
  String get prayerDzuhur;

  /// No description provided for @prayerIsya.
  ///
  /// In id, this message translates to:
  /// **'Isya'**
  String get prayerIsya;

  /// No description provided for @prayerJumat.
  ///
  /// In id, this message translates to:
  /// **'Jumat'**
  String get prayerJumat;

  /// No description provided for @prayerMaghrib.
  ///
  /// In id, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerSubuh.
  ///
  /// In id, this message translates to:
  /// **'Subuh'**
  String get prayerSubuh;

  /// No description provided for @profilAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get profilAbout;

  /// No description provided for @profilAboutBody.
  ///
  /// In id, this message translates to:
  /// **'Ibadah itu konsisten, bukan sempurna. Muslim Leveling membantu kamu membangun kebiasaan sholat lima waktu dan membaca Quran dengan cara yang seru — setiap sholat yang dicatat memberi XP, setiap hari tanpa putus menambah streak, dan setiap pencapaian membuka skin avatar baru.'**
  String get profilAboutBody;

  /// No description provided for @profilAboutFooter.
  ///
  /// In id, this message translates to:
  /// **'Dibuat dengan penuh doa untuk setiap pejuang akhirat.'**
  String get profilAboutFooter;

  /// No description provided for @profilAboutOffline.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada server, tidak ada iklan, tidak ada langganan. Semua datamu tinggal di perangkat — milikmu sepenuhnya.'**
  String get profilAboutOffline;

  /// No description provided for @profilAccountSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Akun'**
  String get profilAccountSettings;

  /// No description provided for @profilAlreadyPrayedToday.
  ///
  /// In id, this message translates to:
  /// **', sudah shalat hari ini'**
  String get profilAlreadyPrayedToday;

  /// No description provided for @profilAndroidNotifSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Notifikasi Android'**
  String get profilAndroidNotifSettings;

  /// No description provided for @profilBackupActive.
  ///
  /// In id, this message translates to:
  /// **'Backup aktif'**
  String get profilBackupActive;

  /// No description provided for @profilBatteryPerm.
  ///
  /// In id, this message translates to:
  /// **'Izinkan \"Tanpa batasan baterai\" supaya pengingat tetap bunyi saat app ditutup.'**
  String get profilBatteryPerm;

  /// No description provided for @profilCalendarHeader.
  ///
  /// In id, this message translates to:
  /// **'KALENDER SHOLAT'**
  String get profilCalendarHeader;

  /// No description provided for @profilChangePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ganti Foto'**
  String get profilChangePhoto;

  /// No description provided for @profilCloudVerifyFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal verifikasi cloud. Coba lagi.'**
  String get profilCloudVerifyFailed;

  /// No description provided for @profilConnecting.
  ///
  /// In id, this message translates to:
  /// **'MENGHUBUNGKAN...'**
  String get profilConnecting;

  /// No description provided for @profilContinueGoogle.
  ///
  /// In id, this message translates to:
  /// **'Lanjut dengan Google'**
  String get profilContinueGoogle;

  /// No description provided for @profilCycleExplain.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan saat haid agar streak sholat tetap aman tanpa penalti.'**
  String get profilCycleExplain;

  /// No description provided for @profilCycleFrozenMeta.
  ///
  /// In id, this message translates to:
  /// **'mode haid · streak di-freeze'**
  String get profilCycleFrozenMeta;

  /// No description provided for @profilCycleFrozenSemantics.
  ///
  /// In id, this message translates to:
  /// **'Mode haid aktif, streak di-freeze'**
  String get profilCycleFrozenSemantics;

  /// No description provided for @profilCycleModeShort.
  ///
  /// In id, this message translates to:
  /// **'mode haid'**
  String get profilCycleModeShort;

  /// No description provided for @profilCyclePeriod.
  ///
  /// In id, this message translates to:
  /// **'Periode Haid'**
  String get profilCyclePeriod;

  /// No description provided for @profilEditName.
  ///
  /// In id, this message translates to:
  /// **'Edit Nama'**
  String get profilEditName;

  /// No description provided for @profilEditProfile.
  ///
  /// In id, this message translates to:
  /// **'Edit profil'**
  String get profilEditProfile;

  /// No description provided for @profilEnableReminders.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan pengingat'**
  String get profilEnableReminders;

  /// No description provided for @profilExactAlarmPerm.
  ///
  /// In id, this message translates to:
  /// **'Izin \"Alarm & pengingat\" belum aktif — pengingat bisa telat beberapa menit.'**
  String get profilExactAlarmPerm;

  /// No description provided for @profilFriday.
  ///
  /// In id, this message translates to:
  /// **'Jumat'**
  String get profilFriday;

  /// No description provided for @profilFromCamera.
  ///
  /// In id, this message translates to:
  /// **'Ambil dari Kamera'**
  String get profilFromCamera;

  /// No description provided for @profilFromGallery.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari Galeri'**
  String get profilFromGallery;

  /// No description provided for @profilGender.
  ///
  /// In id, this message translates to:
  /// **'Jenis Kelamin'**
  String get profilGender;

  /// No description provided for @profilGenderAkhwat.
  ///
  /// In id, this message translates to:
  /// **'Akhwat'**
  String get profilGenderAkhwat;

  /// No description provided for @profilGenderExplain.
  ///
  /// In id, this message translates to:
  /// **'Ikhwan = laki-laki, akhwat = perempuan. Dipakai untuk menyembunyikan atau menampilkan menu Periode Haid. Tidak ikut sinkron ke cloud.'**
  String get profilGenderExplain;

  /// No description provided for @profilGenderIkhwan.
  ///
  /// In id, this message translates to:
  /// **'Ikhwan'**
  String get profilGenderIkhwan;

  /// No description provided for @profilGenderUnset.
  ///
  /// In id, this message translates to:
  /// **'Belum dipilih'**
  String get profilGenderUnset;

  /// No description provided for @profilHeatmapBody.
  ///
  /// In id, this message translates to:
  /// **'Makin hijau makin lengkap — 5 shade = 5 sholat wajib.'**
  String get profilHeatmapBody;

  /// No description provided for @profilHeatmapHeader.
  ///
  /// In id, this message translates to:
  /// **'KALENDER SHOLAT WAJIB'**
  String get profilHeatmapHeader;

  /// No description provided for @profilHeatmapRow.
  ///
  /// In id, this message translates to:
  /// **'Heatmap sholat wajib per bulan'**
  String get profilHeatmapRow;

  /// No description provided for @profilHeatmapSemantics.
  ///
  /// In id, this message translates to:
  /// **'Buka kalender sholat wajib'**
  String get profilHeatmapSemantics;

  /// No description provided for @profilHeroSemantics.
  ///
  /// In id, this message translates to:
  /// **'Profile hero — {tier}'**
  String profilHeroSemantics(String tier);

  /// No description provided for @profilLevelBadge.
  ///
  /// In id, this message translates to:
  /// **'LVL {level}'**
  String profilLevelBadge(int level);

  /// No description provided for @profilLockerRow.
  ///
  /// In id, this message translates to:
  /// **'Atur aura dan gelar aktif'**
  String get profilLockerRow;

  /// No description provided for @profilLockerSemantics.
  ///
  /// In id, this message translates to:
  /// **'Buka loker skin'**
  String get profilLockerSemantics;

  /// No description provided for @profilLockerSkin.
  ///
  /// In id, this message translates to:
  /// **'LOKER SKIN'**
  String get profilLockerSkin;

  /// No description provided for @profilLoginCancelled.
  ///
  /// In id, this message translates to:
  /// **'Login dibatalkan.'**
  String get profilLoginCancelled;

  /// No description provided for @profilLoginFailed.
  ///
  /// In id, this message translates to:
  /// **'❌ Login gagal: {msg}'**
  String profilLoginFailed(String msg);

  /// No description provided for @profilLoginMerged.
  ///
  /// In id, this message translates to:
  /// **'☁️ Login OK — progress digabung.'**
  String get profilLoginMerged;

  /// No description provided for @profilLoginNotSaved.
  ///
  /// In id, this message translates to:
  /// **'⚠️ Login OK, tapi backup belum tersimpan.'**
  String get profilLoginNotSaved;

  /// No description provided for @profilLoginOffline.
  ///
  /// In id, this message translates to:
  /// **'⚠️ Login OK, tapi backup belum aktif (offline).'**
  String get profilLoginOffline;

  /// No description provided for @profilLogoutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus data lokal dan kembali ke layar awal?'**
  String get profilLogoutConfirm;

  /// No description provided for @profilLogoutSuccess.
  ///
  /// In id, this message translates to:
  /// **'Logout berhasil.'**
  String get profilLogoutSuccess;

  /// No description provided for @profilMiniLevel.
  ///
  /// In id, this message translates to:
  /// **'Level'**
  String get profilMiniLevel;

  /// No description provided for @profilMiniStreak.
  ///
  /// In id, this message translates to:
  /// **'Streak'**
  String get profilMiniStreak;

  /// No description provided for @profilMiniXp.
  ///
  /// In id, this message translates to:
  /// **'XP'**
  String get profilMiniXp;

  /// No description provided for @profilModeBalanced.
  ///
  /// In id, this message translates to:
  /// **'⚖️ Seimbang'**
  String get profilModeBalanced;

  /// No description provided for @profilModeBalancedDesc.
  ///
  /// In id, this message translates to:
  /// **'Diingetin 15 menit sebelum & saat adzan'**
  String get profilModeBalancedDesc;

  /// No description provided for @profilModeFocus.
  ///
  /// In id, this message translates to:
  /// **'🎯 Fokus'**
  String get profilModeFocus;

  /// No description provided for @profilModeFocusDesc.
  ///
  /// In id, this message translates to:
  /// **'Hanya pengingat utama di waktu adzan'**
  String get profilModeFocusDesc;

  /// No description provided for @profilModeIntense.
  ///
  /// In id, this message translates to:
  /// **'🔥 Intensif'**
  String get profilModeIntense;

  /// No description provided for @profilModeIntenseDesc.
  ///
  /// In id, this message translates to:
  /// **'30 menit, 5 menit sebelum & saat adzan'**
  String get profilModeIntenseDesc;

  /// No description provided for @profilNicknameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama panggilan'**
  String get profilNicknameHint;

  /// No description provided for @profilNotifPermAction.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi belum aktif. Buka Pengaturan Notifikasi Android lalu izinkan.'**
  String get profilNotifPermAction;

  /// No description provided for @profilNotifPermBody.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi belum aktif. Aktifkan untuk menerima pengingat adzan.'**
  String get profilNotifPermBody;

  /// No description provided for @profilNotifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get profilNotifications;

  /// No description provided for @profilOemBody.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan \"Autostart\" & \"Tanpa batasan baterai\" di pengaturan HP agar alarm tetap bunyi saat app ditutup, dan notif muncul di lock screen.'**
  String get profilOemBody;

  /// No description provided for @profilOemManual.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan > Aplikasi > Muslim Leveling > Baterai & Autostart manual.'**
  String get profilOemManual;

  /// No description provided for @profilOemTitle.
  ///
  /// In id, this message translates to:
  /// **'Adzan tak muncul di Xiaomi/Oppo/Vivo?'**
  String get profilOemTitle;

  /// No description provided for @profilOpenAutostart.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan Auto-start'**
  String get profilOpenAutostart;

  /// No description provided for @profilPhotoFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengambil foto: {msg}'**
  String profilPhotoFailed(String msg);

  /// No description provided for @profilPhotoSection.
  ///
  /// In id, this message translates to:
  /// **'FOTO PROFIL'**
  String get profilPhotoSection;

  /// No description provided for @profilPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Privasi & Data'**
  String get profilPrivacy;

  /// No description provided for @profilPrivacyDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Masuk Profil → Keluar untuk menghapus semua data lokal sekaligus. Tidak ada yang tersisa di perangkat.'**
  String get profilPrivacyDeleteBody;

  /// No description provided for @profilPrivacyDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus kapan saja'**
  String get profilPrivacyDeleteTitle;

  /// No description provided for @profilPrivacyLocalBody.
  ///
  /// In id, this message translates to:
  /// **'Semua data — sholat, bacaan Quran, statistik, dan preferensi — hanya tinggal di HP kamu. Tidak ada server, tidak ada cloud.'**
  String get profilPrivacyLocalBody;

  /// No description provided for @profilPrivacyLocalTitle.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan di perangkat'**
  String get profilPrivacyLocalTitle;

  /// No description provided for @profilPrivacyLocationBody.
  ///
  /// In id, this message translates to:
  /// **'Lokasi hanya dipakai sekali untuk menentukan jadwal sholat daerahmu. Lokasi tidak disimpan atau dibagikan.'**
  String get profilPrivacyLocationBody;

  /// No description provided for @profilPrivacyLocationTitle.
  ///
  /// In id, this message translates to:
  /// **'Lokasi privat'**
  String get profilPrivacyLocationTitle;

  /// No description provided for @profilPrivacyTraceBody.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi tidak mengirim aktivitas kamu ke pihak ketiga dan tidak memantau perilaku.'**
  String get profilPrivacyTraceBody;

  /// No description provided for @profilPrivacyTraceTitle.
  ///
  /// In id, this message translates to:
  /// **'Tanpa jejak online'**
  String get profilPrivacyTraceTitle;

  /// No description provided for @profilReminderMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Pengingat'**
  String get profilReminderMode;

  /// No description provided for @profilReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Adzan'**
  String get profilReminderTitle;

  /// No description provided for @profilRemindersChangeFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengubah pengingat: {msg}'**
  String profilRemindersChangeFailed(String msg);

  /// No description provided for @profilRemindersFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menjadwalkan pengingat — cek izin notifikasi & alarm di pengaturan HP.'**
  String get profilRemindersFailed;

  /// No description provided for @profilRemindersNone.
  ///
  /// In id, this message translates to:
  /// **'Mode tersimpan, tapi belum ada pengingat terjadwal — cek izin notifikasi & alarm di pengaturan HP.'**
  String get profilRemindersNone;

  /// No description provided for @profilRemindersOff.
  ///
  /// In id, this message translates to:
  /// **'Pengingat adzan dimatikan'**
  String get profilRemindersOff;

  /// No description provided for @profilRemindersScheduled.
  ///
  /// In id, this message translates to:
  /// **'Pengingat adzan aktif: mode {mode} — {n} pengingat terjadwal'**
  String profilRemindersScheduled(String mode, int n);

  /// No description provided for @profilRemindersScheduledCount.
  ///
  /// In id, this message translates to:
  /// **'{n} pengingat adzan terjadwal 🔔'**
  String profilRemindersScheduledCount(int n);

  /// No description provided for @profilRemovePhoto.
  ///
  /// In id, this message translates to:
  /// **'Hapus Foto'**
  String get profilRemovePhoto;

  /// No description provided for @profilSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan: {msg}'**
  String profilSaveFailed(String msg);

  /// No description provided for @profilSettingsHeader.
  ///
  /// In id, this message translates to:
  /// **'PENGATURAN'**
  String get profilSettingsHeader;

  /// No description provided for @profilSettingsOpenFailed.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan notifikasi gagal dibuka: {msg}'**
  String profilSettingsOpenFailed(String msg);

  /// No description provided for @profilSoundAdzan.
  ///
  /// In id, this message translates to:
  /// **'🕌 Adzan'**
  String get profilSoundAdzan;

  /// No description provided for @profilSoundAdzanDesc.
  ///
  /// In id, this message translates to:
  /// **'Suara adzan penuh saat masuk waktu sholat'**
  String get profilSoundAdzanDesc;

  /// No description provided for @profilSoundMode.
  ///
  /// In id, this message translates to:
  /// **'Suara Notifikasi'**
  String get profilSoundMode;

  /// No description provided for @profilSoundNormal.
  ///
  /// In id, this message translates to:
  /// **'🔔 Suara'**
  String get profilSoundNormal;

  /// No description provided for @profilSoundNormalDesc.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi dengan suara standar HP'**
  String get profilSoundNormalDesc;

  /// No description provided for @profilSoundSilent.
  ///
  /// In id, this message translates to:
  /// **'🔕 Senyap'**
  String get profilSoundSilent;

  /// No description provided for @profilSoundSilentDesc.
  ///
  /// In id, this message translates to:
  /// **'Hanya muncul notifikasi, tanpa suara'**
  String get profilSoundSilentDesc;

  /// No description provided for @profilStatsDailyAvg.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata Harian'**
  String get profilStatsDailyAvg;

  /// No description provided for @profilStatsEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Centang sholat pertamamu — statistik mulai terisi di sini.'**
  String get profilStatsEmptyBody;

  /// No description provided for @profilStatsEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan.'**
  String get profilStatsEmptyTitle;

  /// No description provided for @profilStatsHeader.
  ///
  /// In id, this message translates to:
  /// **'STATISTIK'**
  String get profilStatsHeader;

  /// No description provided for @profilStatsQuranStreak.
  ///
  /// In id, this message translates to:
  /// **'Streak Baca Quran'**
  String get profilStatsQuranStreak;

  /// No description provided for @profilStatsSince.
  ///
  /// In id, this message translates to:
  /// **'Sejak {date}'**
  String profilStatsSince(String date);

  /// No description provided for @profilStatsVerses.
  ///
  /// In id, this message translates to:
  /// **'Ayat Quran Terbaca'**
  String get profilStatsVerses;

  /// No description provided for @profilStatsWajib.
  ///
  /// In id, this message translates to:
  /// **'Sholat wajib'**
  String get profilStatsWajib;

  /// No description provided for @profilStreakBest.
  ///
  /// In id, this message translates to:
  /// **'best {count}'**
  String profilStreakBest(int count);

  /// No description provided for @profilStreakFreeze.
  ///
  /// In id, this message translates to:
  /// **'freeze'**
  String get profilStreakFreeze;

  /// No description provided for @profilStreakPerPrayer.
  ///
  /// In id, this message translates to:
  /// **'STREAK PER SHOLAT'**
  String get profilStreakPerPrayer;

  /// No description provided for @profilStreakSemanticsItem.
  ///
  /// In id, this message translates to:
  /// **'{prayer} {days} hari'**
  String profilStreakSemanticsItem(String prayer, int days);

  /// No description provided for @profilStreakSemanticsTitle.
  ///
  /// In id, this message translates to:
  /// **'Streak per salat'**
  String get profilStreakSemanticsTitle;

  /// No description provided for @profilTestAdzan.
  ///
  /// In id, this message translates to:
  /// **'Tes Adzan'**
  String get profilTestAdzan;

  /// No description provided for @profilTestNotif.
  ///
  /// In id, this message translates to:
  /// **'Tes Notifikasi'**
  String get profilTestNotif;

  /// No description provided for @profilTestNotifFailed.
  ///
  /// In id, this message translates to:
  /// **'Tes notifikasi gagal: {msg}'**
  String profilTestNotifFailed(String msg);

  /// No description provided for @profilTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema aplikasi'**
  String get profilTheme;

  /// No description provided for @profilUnitDays.
  ///
  /// In id, this message translates to:
  /// **'hari'**
  String get profilUnitDays;

  /// No description provided for @profilUnitVerses.
  ///
  /// In id, this message translates to:
  /// **'ayat'**
  String get profilUnitVerses;

  /// No description provided for @profilUnitWeeks.
  ///
  /// In id, this message translates to:
  /// **'minggu'**
  String get profilUnitWeeks;

  /// No description provided for @profilVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi {version}'**
  String profilVersion(String version);

  /// No description provided for @profilXpToNext.
  ///
  /// In id, this message translates to:
  /// **'{xp} XP lagi → LVL {level}'**
  String profilXpToNext(int xp, int level);

  /// No description provided for @profilXpWithinLevel.
  ///
  /// In id, this message translates to:
  /// **'{current}/{needed} XP'**
  String profilXpWithinLevel(int current, int needed);

  /// No description provided for @settingLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingLanguage;

  /// No description provided for @sunnahBadiyahDzuhurDesc.
  ///
  /// In id, this message translates to:
  /// **'Sunnah sesudah Dzuhur'**
  String get sunnahBadiyahDzuhurDesc;

  /// No description provided for @sunnahBadiyahDzuhurName.
  ///
  /// In id, this message translates to:
  /// **'Ba\'diyah Dzuhur'**
  String get sunnahBadiyahDzuhurName;

  /// No description provided for @sunnahBadiyahIsyaDesc.
  ///
  /// In id, this message translates to:
  /// **'Sunnah sesudah Isya'**
  String get sunnahBadiyahIsyaDesc;

  /// No description provided for @sunnahBadiyahIsyaName.
  ///
  /// In id, this message translates to:
  /// **'Ba\'diyah Isya'**
  String get sunnahBadiyahIsyaName;

  /// No description provided for @sunnahBadiyahMaghribDesc.
  ///
  /// In id, this message translates to:
  /// **'Sunnah sesudah Maghrib'**
  String get sunnahBadiyahMaghribDesc;

  /// No description provided for @sunnahBadiyahMaghribName.
  ///
  /// In id, this message translates to:
  /// **'Ba\'diyah Maghrib'**
  String get sunnahBadiyahMaghribName;

  /// No description provided for @sunnahDhuhaDesc.
  ///
  /// In id, this message translates to:
  /// **'Sunnah mutlak di pagi hari'**
  String get sunnahDhuhaDesc;

  /// No description provided for @sunnahDhuhaName.
  ///
  /// In id, this message translates to:
  /// **'Dhuha'**
  String get sunnahDhuhaName;

  /// No description provided for @sunnahQobliyahAsharDesc.
  ///
  /// In id, this message translates to:
  /// **'Sunnah sebelum Ashar'**
  String get sunnahQobliyahAsharDesc;

  /// No description provided for @sunnahQobliyahAsharName.
  ///
  /// In id, this message translates to:
  /// **'Qobliyah Ashar'**
  String get sunnahQobliyahAsharName;

  /// No description provided for @sunnahQobliyahDzuhurDesc.
  ///
  /// In id, this message translates to:
  /// **'Sunnah sebelum Dzuhur'**
  String get sunnahQobliyahDzuhurDesc;

  /// No description provided for @sunnahQobliyahDzuhurName.
  ///
  /// In id, this message translates to:
  /// **'Qobliyah Dzuhur'**
  String get sunnahQobliyahDzuhurName;

  /// No description provided for @sunnahQobliyahSubuhDesc.
  ///
  /// In id, this message translates to:
  /// **'Sunnah sebelum Subuh'**
  String get sunnahQobliyahSubuhDesc;

  /// No description provided for @sunnahQobliyahSubuhName.
  ///
  /// In id, this message translates to:
  /// **'Qobliyah Subuh'**
  String get sunnahQobliyahSubuhName;

  /// No description provided for @sunnahTahajjudDesc.
  ///
  /// In id, this message translates to:
  /// **'Sunnah malam (qiyamul lail)'**
  String get sunnahTahajjudDesc;

  /// No description provided for @sunnahTahajjudName.
  ///
  /// In id, this message translates to:
  /// **'Tahajjud'**
  String get sunnahTahajjudName;

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

  /// No description provided for @tabBelajar.
  ///
  /// In id, this message translates to:
  /// **'Belajar'**
  String get tabBelajar;

  /// No description provided for @tabProfil.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get tabProfil;

  /// No description provided for @dlTitle.
  ///
  /// In id, this message translates to:
  /// **'Renungan Hari Ini'**
  String get dlTitle;

  /// No description provided for @dlBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get dlBack;

  /// No description provided for @dlCiteSurah.
  ///
  /// In id, this message translates to:
  /// **'QS. {surah} : {ayah}'**
  String dlCiteSurah(String surah, int ayah);

  /// No description provided for @dlCiteHadis.
  ///
  /// In id, this message translates to:
  /// **'HADIS HARI INI'**
  String get dlCiteHadis;

  /// No description provided for @dlCiteDoa.
  ///
  /// In id, this message translates to:
  /// **'DOA · {name}'**
  String dlCiteDoa(String name);

  /// No description provided for @dlCiteUlama.
  ///
  /// In id, this message translates to:
  /// **'KATA ULAMA · {name}'**
  String dlCiteUlama(String name);

  /// No description provided for @dlActListen.
  ///
  /// In id, this message translates to:
  /// **'Dengar'**
  String get dlActListen;

  /// No description provided for @dlActPause.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get dlActPause;

  /// No description provided for @dlActSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get dlActSave;

  /// No description provided for @dlActSaved.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan'**
  String get dlActSaved;

  /// No description provided for @dlActTafsir.
  ///
  /// In id, this message translates to:
  /// **'Tafsir'**
  String get dlActTafsir;

  /// No description provided for @dlErrLoad.
  ///
  /// In id, this message translates to:
  /// **'Renungan hari ini belum bisa dimuat.\nSambungkan internet lalu coba lagi.'**
  String get dlErrLoad;

  /// No description provided for @dlErrTafsir.
  ///
  /// In id, this message translates to:
  /// **'Tafsir tidak bisa dimuat. Coba lagi.'**
  String get dlErrTafsir;

  /// No description provided for @dlDone.
  ///
  /// In id, this message translates to:
  /// **'Renungan hari ini tuntas'**
  String get dlDone;

  /// No description provided for @dlProgress.
  ///
  /// In id, this message translates to:
  /// **'{done} dari {count} renungan dibaca · swipe untuk lanjut'**
  String dlProgress(int done, int count);

  /// No description provided for @qsTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagikan Ayat'**
  String get qsTitle;

  /// No description provided for @qsShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get qsShare;

  /// No description provided for @qsPreparing.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan…'**
  String get qsPreparing;

  /// No description provided for @qsErr.
  ///
  /// In id, this message translates to:
  /// **'Gagal membagikan ayat. Coba lagi.'**
  String get qsErr;

  /// No description provided for @qsModeSolid.
  ///
  /// In id, this message translates to:
  /// **'Solid'**
  String get qsModeSolid;

  /// No description provided for @qsModeGradient.
  ///
  /// In id, this message translates to:
  /// **'Gradasi'**
  String get qsModeGradient;

  /// No description provided for @qsModeEsthetic.
  ///
  /// In id, this message translates to:
  /// **'Estetik'**
  String get qsModeEsthetic;

  /// No description provided for @qsContentArabic.
  ///
  /// In id, this message translates to:
  /// **'Arab'**
  String get qsContentArabic;

  /// No description provided for @qsContentTranslation.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan'**
  String get qsContentTranslation;

  /// No description provided for @quest_subuh_tepat_desc.
  ///
  /// In id, this message translates to:
  /// **'Sholat Subuh tepat waktu (≤30 menit setelah adzan)'**
  String get quest_subuh_tepat_desc;

  /// No description provided for @quest_five_rings_desc.
  ///
  /// In id, this message translates to:
  /// **'Lengkapin 5/5 sholat hari ini'**
  String get quest_five_rings_desc;

  /// No description provided for @quest_timely_prayers_desc.
  ///
  /// In id, this message translates to:
  /// **'Sholat tepat waktu (≤10 menit), 3x hari ini'**
  String get quest_timely_prayers_desc;

  /// No description provided for @quest_dhuha_before_dzuhur_desc.
  ///
  /// In id, this message translates to:
  /// **'Sholat Dhuha sebelum Dzuhur'**
  String get quest_dhuha_before_dzuhur_desc;

  /// No description provided for @quest_rawatib_two_desc.
  ///
  /// In id, this message translates to:
  /// **'Rawatib 2x hari ini'**
  String get quest_rawatib_two_desc;

  /// No description provided for @quest_dzuhur_tepat_desc.
  ///
  /// In id, this message translates to:
  /// **'Sholat Dzuhur tepat waktu (≤30 menit setelah adzan)'**
  String get quest_dzuhur_tepat_desc;

  /// No description provided for @quest_maghrib_tepat_desc.
  ///
  /// In id, this message translates to:
  /// **'Sholat Maghrib tepat waktu (≤30 menit setelah adzan)'**
  String get quest_maghrib_tepat_desc;

  /// No description provided for @quest_isya_hadir_desc.
  ///
  /// In id, this message translates to:
  /// **'Jangan lewatkan sholat Isya malam ini'**
  String get quest_isya_hadir_desc;

  /// No description provided for @quest_any_three_desc.
  ///
  /// In id, this message translates to:
  /// **'Kerjakan 3 sholat wajib hari ini (bebas yang mana)'**
  String get quest_any_three_desc;

  /// No description provided for @quest_subuh_isya_desc.
  ///
  /// In id, this message translates to:
  /// **'Kunci dua ujung hari: Subuh + Isya'**
  String get quest_subuh_isya_desc;

  /// No description provided for @quest_one_sunnah_desc.
  ///
  /// In id, this message translates to:
  /// **'Kerjakan 1 sholat sunnah apa saja hari ini'**
  String get quest_one_sunnah_desc;

  /// No description provided for @quest_rawatib_one_desc.
  ///
  /// In id, this message translates to:
  /// **'Rawatib 1x hari ini (qobliyah/ba\'diyah bebas)'**
  String get quest_rawatib_one_desc;

  /// No description provided for @quest_zikir_33_desc.
  ///
  /// In id, this message translates to:
  /// **'Zikir 33x lewat tombol Daily Zikir'**
  String get quest_zikir_33_desc;

  /// No description provided for @quest_zikir_goal_desc.
  ///
  /// In id, this message translates to:
  /// **'Tuntaskan Daily Zikir sampai {goal}'**
  String quest_zikir_goal_desc(Object goal);

  /// No description provided for @quest_quran_10ayat_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca Quran 10 ayat hari ini'**
  String get quest_quran_10ayat_desc;

  /// No description provided for @quest_hadis_3_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 3 hadis hari ini (≥5 dtk tiap hadis)'**
  String get quest_hadis_3_desc;

  /// No description provided for @quest_dzikir_33_subuh_desc.
  ///
  /// In id, this message translates to:
  /// **'Dzikir Subhanallah 33x (tasbih setelah sholat)'**
  String get quest_dzikir_33_subuh_desc;

  /// No description provided for @quest_quran_1halaman_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca Quran 20 ayat (≈1 halaman mushaf)'**
  String get quest_quran_1halaman_desc;

  /// No description provided for @quest_hadis_5_desc.
  ///
  /// In id, this message translates to:
  /// **'Baca 5 hadis hari ini (≥5 dtk tiap hadis)'**
  String get quest_hadis_5_desc;

  /// No description provided for @quest_berjamaah_1_desc.
  ///
  /// In id, this message translates to:
  /// **'Sholat berjamaah 1x hari ini (pilih bonus berjamaah saat claim)'**
  String get quest_berjamaah_1_desc;

  /// No description provided for @quest_hero_streak_7_desc.
  ///
  /// In id, this message translates to:
  /// **'Pertahanin Hero Streak 7 hari! 🔥'**
  String get quest_hero_streak_7_desc;

  /// No description provided for @questCopy_sholat_1.
  ///
  /// In id, this message translates to:
  /// **'Kamu mungkin lagi sibuk, tapi tetap nyempetin. Good job.'**
  String get questCopy_sholat_1;

  /// No description provided for @questCopy_sholat_2.
  ///
  /// In id, this message translates to:
  /// **'Adzan selesai, kamu langsung jalan. Mantap.'**
  String get questCopy_sholat_2;

  /// No description provided for @questCopy_sholat_3.
  ///
  /// In id, this message translates to:
  /// **'Tepat waktu hari ini. Satu hal baik yang kamu jaga.'**
  String get questCopy_sholat_3;

  /// No description provided for @questCopy_sholat_4.
  ///
  /// In id, this message translates to:
  /// **'Capek tetap capek. Tapi kamu tetap datang. 🤍'**
  String get questCopy_sholat_4;

  /// No description provided for @questCopy_sunnah_1.
  ///
  /// In id, this message translates to:
  /// **'Nggak wajib, tapi kamu tetap memilih untuk melakukannya.'**
  String get questCopy_sunnah_1;

  /// No description provided for @questCopy_sunnah_2.
  ///
  /// In id, this message translates to:
  /// **'Nggak ada yang maksa. Kamu sendiri yang memilih untuk datang.'**
  String get questCopy_sunnah_2;

  /// No description provided for @questCopy_sunnah_3.
  ///
  /// In id, this message translates to:
  /// **'Dua rakaat hari ini. Kecil, tapi berarti.'**
  String get questCopy_sunnah_3;

  /// No description provided for @questCopy_sunnah_4.
  ///
  /// In id, this message translates to:
  /// **'Pelan-pelan, kebiasaan baik seperti ini yang kamu bangun.'**
  String get questCopy_sunnah_4;

  /// No description provided for @questCopy_zikir_1.
  ///
  /// In id, this message translates to:
  /// **'Di tengah ramainya hari, kamu masih menyempatkan ingat Allah.'**
  String get questCopy_zikir_1;

  /// No description provided for @questCopy_zikir_2.
  ///
  /// In id, this message translates to:
  /// **'Berhenti sebentar. Tarik napas. Ingat Allah.'**
  String get questCopy_zikir_2;

  /// No description provided for @questCopy_zikir_3.
  ///
  /// In id, this message translates to:
  /// **'Apa pun yang lagi kamu pikirin, kamu tetap meluangkan waktu untuk zikir.'**
  String get questCopy_zikir_3;

  /// No description provided for @questCopy_zikir_4.
  ///
  /// In id, this message translates to:
  /// **'Selesai zikir. Semoga hati terasa sedikit lebih ringan. 🤍'**
  String get questCopy_zikir_4;

  /// No description provided for @questCopy_quran_1.
  ///
  /// In id, this message translates to:
  /// **'Satu ayat hari ini. Pelan-pelan, yang penting terus.'**
  String get questCopy_quran_1;

  /// No description provided for @questCopy_quran_2.
  ///
  /// In id, this message translates to:
  /// **'Hari ini kamu kembali membuka Al-Quran. Senang lihatnya.'**
  String get questCopy_quran_2;

  /// No description provided for @questCopy_quran_3.
  ///
  /// In id, this message translates to:
  /// **'Nggak harus banyak. Satu halaman pun tetap sebuah langkah.'**
  String get questCopy_quran_3;

  /// No description provided for @questCopy_quran_4.
  ///
  /// In id, this message translates to:
  /// **'Satu halaman selesai. Besok lanjut lagi, ya.'**
  String get questCopy_quran_4;

  /// No description provided for @questCopy_hadis_1.
  ///
  /// In id, this message translates to:
  /// **'Hari ini kamu meluangkan waktu untuk belajar dari sabda Nabi.'**
  String get questCopy_hadis_1;

  /// No description provided for @questCopy_hadis_2.
  ///
  /// In id, this message translates to:
  /// **'Satu hadis kamu baca hari ini. Semoga ada yang bisa kamu bawa ke harimu.'**
  String get questCopy_hadis_2;

  /// No description provided for @questCopy_hadis_3.
  ///
  /// In id, this message translates to:
  /// **'Nemu hadis yang ngena? Simpan. Siapa tahu kamu butuh mengingatnya lagi.'**
  String get questCopy_hadis_3;

  /// No description provided for @questCopy_hadis_4.
  ///
  /// In id, this message translates to:
  /// **'Sedikit belajar hari ini, semoga jadi bekal untuk besok.'**
  String get questCopy_hadis_4;

  /// No description provided for @questCopy_fiveRings_1.
  ///
  /// In id, this message translates to:
  /// **'Subuh, Dzuhur, Ashar, Maghrib, Isya. Kamu hadir di semuanya hari ini.'**
  String get questCopy_fiveRings_1;

  /// No description provided for @questCopy_fiveRings_2.
  ///
  /// In id, this message translates to:
  /// **'Lima waktu selesai. Alhamdulillah, hari ini kamu berhasil menjaganya.'**
  String get questCopy_fiveRings_2;

  /// No description provided for @questCopy_fiveRings_3.
  ///
  /// In id, this message translates to:
  /// **'Satu hari, lima waktu. Lengkap. 🤍'**
  String get questCopy_fiveRings_3;

  /// No description provided for @questCopy_fiveRings_4.
  ///
  /// In id, this message translates to:
  /// **'Hari ini selesai dengan baik. Besok kita mulai lagi.'**
  String get questCopy_fiveRings_4;

  /// No description provided for @questCopy_subuhIsya_1.
  ///
  /// In id, this message translates to:
  /// **'Subuh kamu jaga, Isya kamu jaga. Alhamdulillah.'**
  String get questCopy_subuhIsya_1;

  /// No description provided for @questCopy_subuhIsya_2.
  ///
  /// In id, this message translates to:
  /// **'Dari awal sampai akhir hari, kamu tetap menyempatkan diri.'**
  String get questCopy_subuhIsya_2;

  /// No description provided for @questCopy_subuhIsya_3.
  ///
  /// In id, this message translates to:
  /// **'Dua waktu ini kamu jaga hari ini. Good job.'**
  String get questCopy_subuhIsya_3;

  /// No description provided for @questCopy_subuhIsya_4.
  ///
  /// In id, this message translates to:
  /// **'Hari ini kamu berhasil menjaga Subuh dan Isya. Besok lanjut lagi.'**
  String get questCopy_subuhIsya_4;

  /// No description provided for @questHaid_1.
  ///
  /// In id, this message translates to:
  /// **'Hari ini waktunya istirahat. Tetap semangat, ya. 🤍'**
  String get questHaid_1;

  /// No description provided for @questHaid_2.
  ///
  /// In id, this message translates to:
  /// **'Nggak apa-apa berhenti sebentar. Kamu tetap bagian dari perjalanan ini.'**
  String get questHaid_2;

  /// No description provided for @questHaid_3.
  ///
  /// In id, this message translates to:
  /// **'Hari ini kamu nggak perlu mengejar quest ini. Jaga diri dan tetap dekat dengan Allah.'**
  String get questHaid_3;

  /// No description provided for @questHaid_4.
  ///
  /// In id, this message translates to:
  /// **'Quest boleh berhenti sebentar. Perjalananmu tetap lanjut.'**
  String get questHaid_4;

  /// No description provided for @questClaimAlhamdulillah.
  ///
  /// In id, this message translates to:
  /// **'Alhamdulillah'**
  String get questClaimAlhamdulillah;

  /// No description provided for @questClaimContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get questClaimContinue;

  /// No description provided for @sqCombinedTitle.
  ///
  /// In id, this message translates to:
  /// **'Alhamdulillah, {count} Quest Tuntas!'**
  String sqCombinedTitle(Object count);

  /// No description provided for @sqCombinedDesc.
  ///
  /// In id, this message translates to:
  /// **'Semua quest harian selesai hari ini. Semoga istiqomah!'**
  String get sqCombinedDesc;

  /// No description provided for @sqZikirTitle.
  ///
  /// In id, this message translates to:
  /// **'Dzikir 100x Selesai!'**
  String get sqZikirTitle;

  /// No description provided for @sqZikirDesc.
  ///
  /// In id, this message translates to:
  /// **'Konsisten berdzikir hari ini. Istiqomah!'**
  String get sqZikirDesc;

  /// No description provided for @sqTilawahTitle.
  ///
  /// In id, this message translates to:
  /// **'Baca Quran 10 Ayat Selesai!'**
  String get sqTilawahTitle;

  /// No description provided for @sqTilawahDesc.
  ///
  /// In id, this message translates to:
  /// **'Tilawah hari ini tuntas. Lanjutkan besok!'**
  String get sqTilawahDesc;

  /// No description provided for @sqHadisTitle.
  ///
  /// In id, this message translates to:
  /// **'Belajar 5 Hadis Selesai!'**
  String get sqHadisTitle;

  /// No description provided for @sqHadisDesc.
  ///
  /// In id, this message translates to:
  /// **'Lima hadis baru terbaca hari ini. Terus belajar!'**
  String get sqHadisDesc;

  /// No description provided for @sqBadgeCombined.
  ///
  /// In id, this message translates to:
  /// **'QUEST HARIAN TUNTAS'**
  String get sqBadgeCombined;

  /// No description provided for @sqBadgeSingle.
  ///
  /// In id, this message translates to:
  /// **'QUEST SELESAI'**
  String get sqBadgeSingle;

  /// No description provided for @sqButton.
  ///
  /// In id, this message translates to:
  /// **'MANTAP!'**
  String get sqButton;

  /// No description provided for @sqBarrierLabel.
  ///
  /// In id, this message translates to:
  /// **'side quest selesai'**
  String get sqBarrierLabel;

  /// No description provided for @sqSemantics.
  ///
  /// In id, this message translates to:
  /// **'{title}. {desc}. Bonus {xp} XP.'**
  String sqSemantics(Object desc, Object title, Object xp);

  /// No description provided for @sqSourceZikir.
  ///
  /// In id, this message translates to:
  /// **'Dzikir 100x'**
  String get sqSourceZikir;

  /// No description provided for @sqSourceTilawah.
  ///
  /// In id, this message translates to:
  /// **'Baca Quran'**
  String get sqSourceTilawah;

  /// No description provided for @sqSourceHadis.
  ///
  /// In id, this message translates to:
  /// **'Belajar Hadis'**
  String get sqSourceHadis;

  /// No description provided for @naikTitle.
  ///
  /// In id, this message translates to:
  /// **'NAIK LEVEL!'**
  String get naikTitle;

  /// No description provided for @naikBadgeSemantics.
  ///
  /// In id, this message translates to:
  /// **'Bulan sabit emas, lambang naik level'**
  String get naikBadgeSemantics;

  /// No description provided for @naikReached.
  ///
  /// In id, this message translates to:
  /// **'Masha Allah, kamu mencapai {rank} — Level {level}'**
  String naikReached(Object level, Object rank);

  /// No description provided for @naikFrom.
  ///
  /// In id, this message translates to:
  /// **'dari {source}'**
  String naikFrom(Object source);

  /// No description provided for @naikBack.
  ///
  /// In id, this message translates to:
  /// **'KEMBALI'**
  String get naikBack;

  /// No description provided for @naikRewardSemanticsFull.
  ///
  /// In id, this message translates to:
  /// **'Hadiah: tambah {xp} XP, level {level}, gelar baru {rank}'**
  String naikRewardSemanticsFull(Object level, Object rank, Object xp);

  /// No description provided for @naikRewardSemanticsLevel.
  ///
  /// In id, this message translates to:
  /// **'Hadiah: level {level}, gelar baru {rank}'**
  String naikRewardSemanticsLevel(Object level, Object rank);

  /// No description provided for @naikChipLevelJumps.
  ///
  /// In id, this message translates to:
  /// **'Lonjakan'**
  String get naikChipLevelJumps;

  /// No description provided for @naikChipLevel.
  ///
  /// In id, this message translates to:
  /// **'Level'**
  String get naikChipLevel;

  /// No description provided for @naikChipRank.
  ///
  /// In id, this message translates to:
  /// **'GELAR BARU'**
  String get naikChipRank;

  /// No description provided for @naikProgressSemantics.
  ///
  /// In id, this message translates to:
  /// **'Menuju level {next}: {have} dari {need} XP'**
  String naikProgressSemantics(Object have, Object need, Object next);

  /// No description provided for @naikClosing.
  ///
  /// In id, this message translates to:
  /// **'Barakallah — terus istiqomah, level berikutnya menantimu ✨'**
  String get naikClosing;

  /// No description provided for @naikLevelLabel.
  ///
  /// In id, this message translates to:
  /// **'Level {level}'**
  String naikLevelLabel(Object level);

  /// No description provided for @uq_ulama_ilmu_itu_lebih_baik_daripada_harta_ilmu.
  ///
  /// In id, this message translates to:
  /// **'Ilmu itu lebih baik daripada harta. Ilmu menjaga kamu, sedangkan harta justru kamu yang menjaganya.'**
  String get uq_ulama_ilmu_itu_lebih_baik_daripada_harta_ilmu;

  /// No description provided for @uq_ulama_orang_berilmu_itu_hidup_walau_sudah_wafa.
  ///
  /// In id, this message translates to:
  /// **'Orang berilmu itu hidup walau sudah wafat, sedangkan orang bodoh itu mati walau masih hidup.'**
  String get uq_ulama_orang_berilmu_itu_hidup_walau_sudah_wafa;

  /// No description provided for @uq_ulama_jangan_melihat_siapa_yang_berbicara_tapi.
  ///
  /// In id, this message translates to:
  /// **'Jangan melihat siapa yang berbicara, tapi lihatlah apa yang dia katakan.'**
  String get uq_ulama_jangan_melihat_siapa_yang_berbicara_tapi;

  /// No description provided for @uq_ulama_nilai_seseorang_diukur_dari_apa_yang_dia.
  ///
  /// In id, this message translates to:
  /// **'Nilai seseorang diukur dari apa yang dia tekuni dengan sungguh-sungguh.'**
  String get uq_ulama_nilai_seseorang_diukur_dari_apa_yang_dia;

  /// No description provided for @uq_ulama_hisablah_dirimu_sendiri_sebelum_kamu_dih.
  ///
  /// In id, this message translates to:
  /// **'Hisablah dirimu sendiri sebelum kamu dihisab, dan timbanglah amalmu sebelum ditimbang.'**
  String get uq_ulama_hisablah_dirimu_sendiri_sebelum_kamu_dih;

  /// No description provided for @uq_ulama_aku_tidak_pernah_menyesal_karena_diam_ta.
  ///
  /// In id, this message translates to:
  /// **'Aku tidak pernah menyesal karena diam, tapi aku sering menyesal karena berbicara.'**
  String get uq_ulama_aku_tidak_pernah_menyesal_karena_diam_ta;

  /// No description provided for @uq_ulama_kehormatanmu_adalah_agamamu_dan_harga_di.
  ///
  /// In id, this message translates to:
  /// **'Kehormatanmu adalah agamamu, dan harga dirimu adalah akhlakmu.'**
  String get uq_ulama_kehormatanmu_adalah_agamamu_dan_harga_di;

  /// No description provided for @uq_ulama_waktu_itu_seperti_pedang_kalau_kamu_tida.
  ///
  /// In id, this message translates to:
  /// **'Waktu itu seperti pedang — kalau kamu tidak memotongnya, dia yang memotongmu.'**
  String get uq_ulama_waktu_itu_seperti_pedang_kalau_kamu_tida;

  /// No description provided for @uq_ulama_ilmu_bukanlah_yang_dihafal_tetapi_ilmu_a.
  ///
  /// In id, this message translates to:
  /// **'Ilmu bukanlah yang dihafal, tetapi ilmu adalah yang memberi manfaat.'**
  String get uq_ulama_ilmu_bukanlah_yang_dihafal_tetapi_ilmu_a;

  /// No description provided for @uq_ulama_ilmu_itu_cahaya_dan_cahaya_allah_tidak_a.
  ///
  /// In id, this message translates to:
  /// **'Ilmu itu cahaya, dan cahaya Allah tidak akan masuk ke dalam hati orang yang bermaksiat.'**
  String get uq_ulama_ilmu_itu_cahaya_dan_cahaya_allah_tidak_a;

  /// No description provided for @uq_ulama_barangsiapa_tidak_tahan_lelahnya_belajar.
  ///
  /// In id, this message translates to:
  /// **'Barangsiapa tidak tahan lelahnya belajar, dia harus tahan perihnya kebodohan.'**
  String get uq_ulama_barangsiapa_tidak_tahan_lelahnya_belajar;

  /// No description provided for @uq_ulama_aku_tidak_berhenti_belajar_sejak_aku_men.
  ///
  /// In id, this message translates to:
  /// **'Aku tidak berhenti belajar sejak aku menyadari bahwa aku masih bodoh.'**
  String get uq_ulama_aku_tidak_berhenti_belajar_sejak_aku_men;

  /// No description provided for @uq_ulama_aku_tidak_memberi_fatwa_sampai_aku_berta.
  ///
  /// In id, this message translates to:
  /// **'Aku tidak memberi fatwa sampai aku bertanya kepada orang yang lebih berilmu dariku.'**
  String get uq_ulama_aku_tidak_memberi_fatwa_sampai_aku_berta;

  /// No description provided for @uq_ulama_manusia_lebih_membutuhkan_ilmu_daripada.
  ///
  /// In id, this message translates to:
  /// **'Manusia lebih membutuhkan ilmu daripada makanan dan minuman.'**
  String get uq_ulama_manusia_lebih_membutuhkan_ilmu_daripada;

  /// No description provided for @uq_ulama_aku_tidak_menulis_satu_hadis_pun_melaink.
  ///
  /// In id, this message translates to:
  /// **'Aku tidak menulis satu hadis pun melainkan aku amalkan dulu isinya.'**
  String get uq_ulama_aku_tidak_menulis_satu_hadis_pun_melaink;

  /// No description provided for @uq_ulama_ilmu_tanpa_amal_seperti_pohon_tanpa_buah.
  ///
  /// In id, this message translates to:
  /// **'Ilmu tanpa amal seperti pohon tanpa buah.'**
  String get uq_ulama_ilmu_tanpa_amal_seperti_pohon_tanpa_buah;

  /// No description provided for @uq_ulama_anak_adam_hanyalah_kumpulan_hari_hari_se.
  ///
  /// In id, this message translates to:
  /// **'Anak Adam hanyalah kumpulan hari-hari. Setiap satu hari berlalu, sebagian dari dirinya ikut pergi.'**
  String get uq_ulama_anak_adam_hanyalah_kumpulan_hari_hari_se;

  /// No description provided for @uq_ulama_barangsiapa_mengenal_allah_dia_akan_menc.
  ///
  /// In id, this message translates to:
  /// **'Barangsiapa mengenal Allah, dia akan mencintai-Nya; dan yang mencintai-Nya akan sibuk dengan-Nya.'**
  String get uq_ulama_barangsiapa_mengenal_allah_dia_akan_menc;

  /// No description provided for @uq_ulama_sesungguhnya_dunia_ini_hanya_sebentar_ja.
  ///
  /// In id, this message translates to:
  /// **'Sesungguhnya dunia ini hanya sebentar, jangan sampai kita bekerja untuknya seolah selamanya.'**
  String get uq_ulama_sesungguhnya_dunia_ini_hanya_sebentar_ja;

  /// No description provided for @uq_ulama_jadikan_dunia_ini_cukup_berada_di_tangan.
  ///
  /// In id, this message translates to:
  /// **'Jadikan dunia ini cukup berada di tanganmu, jangan sampai masuk ke dalam hatimu.'**
  String get uq_ulama_jadikan_dunia_ini_cukup_berada_di_tangan;

  /// No description provided for @uq_ulama_perbanyaklah_mengingat_mati_karena_itu_m.
  ///
  /// In id, this message translates to:
  /// **'Perbanyaklah mengingat mati, karena itu menghapus cinta kepada dunia.'**
  String get uq_ulama_perbanyaklah_mengingat_mati_karena_itu_m;

  /// No description provided for @uq_ulama_aku_tidak_mengobati_sesuatu_yang_lebih_b.
  ///
  /// In id, this message translates to:
  /// **'Aku tidak mengobati sesuatu yang lebih berat daripada niatku sendiri.'**
  String get uq_ulama_aku_tidak_mengobati_sesuatu_yang_lebih_b;

  /// No description provided for @uq_ulama_ilmu_itu_untuk_diamalkan_kalau_tidak_dia.
  ///
  /// In id, this message translates to:
  /// **'Ilmu itu untuk diamalkan; kalau tidak diamalkan, dia akan pergi.'**
  String get uq_ulama_ilmu_itu_untuk_diamalkan_kalau_tidak_dia;

  /// No description provided for @uq_ulama_diam_adalah_hikmah_tapi_sedikit_orang_ya.
  ///
  /// In id, this message translates to:
  /// **'Diam adalah hikmah, tapi sedikit orang yang mau mengamalkannya.'**
  String get uq_ulama_diam_adalah_hikmah_tapi_sedikit_orang_ya;

  /// No description provided for @uq_ulama_sebaik_baik_hati_adalah_yang_dipenuhi_ra.
  ///
  /// In id, this message translates to:
  /// **'Sebaik-baik hati adalah yang dipenuhi rasa takut dan harap kepada Allah.'**
  String get uq_ulama_sebaik_baik_hati_adalah_yang_dipenuhi_ra;

  /// No description provided for @uq_ulama_tidak_ada_yang_lebih_bermanfaat_bagi_hat.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada yang lebih bermanfaat bagi hati daripada membaca Al-Qur\'an dengan tadabbur.'**
  String get uq_ulama_tidak_ada_yang_lebih_bermanfaat_bagi_hat;

  /// No description provided for @uq_ulama_hati_bisa_sakit_seperti_badan_sakit_dan.
  ///
  /// In id, this message translates to:
  /// **'Hati bisa sakit seperti badan sakit, dan obatnya adalah istigfar.'**
  String get uq_ulama_hati_bisa_sakit_seperti_badan_sakit_dan;

  /// No description provided for @uq_ulama_kesabaran_itu_cahaya_dengannya_jalan_yan.
  ///
  /// In id, this message translates to:
  /// **'Kesabaran itu cahaya — dengannya jalan yang sempit terasa lapang.'**
  String get uq_ulama_kesabaran_itu_cahaya_dengannya_jalan_yan;

  /// No description provided for @uq_ulama_ilmu_tanpa_amal_adalah_sia_sia_dan_amal.
  ///
  /// In id, this message translates to:
  /// **'Ilmu tanpa amal adalah sia-sia, dan amal tanpa ilmu tidak akan sempurna.'**
  String get uq_ulama_ilmu_tanpa_amal_adalah_sia_sia_dan_amal;

  /// No description provided for @uq_ulama_kebahagiaan_bukan_pada_banyaknya_harta_t.
  ///
  /// In id, this message translates to:
  /// **'Kebahagiaan bukan pada banyaknya harta, tetapi pada lapangnya hati.'**
  String get uq_ulama_kebahagiaan_bukan_pada_banyaknya_harta_t;

  /// No description provided for @uq_ulama_siapa_yang_menuntut_ilmu_semata_untuk_me.
  ///
  /// In id, this message translates to:
  /// **'Siapa yang menuntut ilmu semata untuk membanggakan diri, ilmunya akan menjadi hujjah atas dirinya.'**
  String get uq_ulama_siapa_yang_menuntut_ilmu_semata_untuk_me;

  /// No description provided for @uq_ulama_jaga_hatimu_karena_allah_melihat_bukan_h.
  ///
  /// In id, this message translates to:
  /// **'Jaga hatimu, karena Allah melihat bukan hanya amalmu, tapi juga apa yang ada di dalamnya.'**
  String get uq_ulama_jaga_hatimu_karena_allah_melihat_bukan_h;

  /// No description provided for @uq_month_1.
  ///
  /// In id, this message translates to:
  /// **'Muharam'**
  String get uq_month_1;

  /// No description provided for @uq_month_2.
  ///
  /// In id, this message translates to:
  /// **'Safar'**
  String get uq_month_2;

  /// No description provided for @uq_month_3.
  ///
  /// In id, this message translates to:
  /// **'Rabiulawal'**
  String get uq_month_3;

  /// No description provided for @uq_month_4.
  ///
  /// In id, this message translates to:
  /// **'Rabiulakhir'**
  String get uq_month_4;

  /// No description provided for @uq_month_5.
  ///
  /// In id, this message translates to:
  /// **'Jumadilawal'**
  String get uq_month_5;

  /// No description provided for @uq_month_6.
  ///
  /// In id, this message translates to:
  /// **'Jumadilakhir'**
  String get uq_month_6;

  /// No description provided for @uq_month_7.
  ///
  /// In id, this message translates to:
  /// **'Rajab'**
  String get uq_month_7;

  /// No description provided for @uq_month_8.
  ///
  /// In id, this message translates to:
  /// **'Syaban'**
  String get uq_month_8;

  /// No description provided for @uq_month_9.
  ///
  /// In id, this message translates to:
  /// **'Ramadan'**
  String get uq_month_9;

  /// No description provided for @uq_month_10.
  ///
  /// In id, this message translates to:
  /// **'Syawal'**
  String get uq_month_10;

  /// No description provided for @uq_month_11.
  ///
  /// In id, this message translates to:
  /// **'Zulkaidah'**
  String get uq_month_11;

  /// No description provided for @uq_month_12.
  ///
  /// In id, this message translates to:
  /// **'Zulhijah'**
  String get uq_month_12;

  /// No description provided for @uq_ev_1_1.
  ///
  /// In id, this message translates to:
  /// **'Tahun Baru Hijriah'**
  String get uq_ev_1_1;

  /// No description provided for @uq_ev_1_10.
  ///
  /// In id, this message translates to:
  /// **'Hari Asyura'**
  String get uq_ev_1_10;

  /// No description provided for @uq_ev_3_12.
  ///
  /// In id, this message translates to:
  /// **'Maulid Nabi'**
  String get uq_ev_3_12;

  /// No description provided for @uq_ev_7_27.
  ///
  /// In id, this message translates to:
  /// **'Isra Mikraj'**
  String get uq_ev_7_27;

  /// No description provided for @uq_ev_8_15.
  ///
  /// In id, this message translates to:
  /// **'Nisfu Syaban'**
  String get uq_ev_8_15;

  /// No description provided for @uq_ev_9_1.
  ///
  /// In id, this message translates to:
  /// **'Awal Ramadan'**
  String get uq_ev_9_1;

  /// No description provided for @uq_ev_9_17.
  ///
  /// In id, this message translates to:
  /// **'Nuzulul Quran'**
  String get uq_ev_9_17;

  /// No description provided for @uq_ev_10_1.
  ///
  /// In id, this message translates to:
  /// **'Idulfitri'**
  String get uq_ev_10_1;

  /// No description provided for @uq_ev_12_9.
  ///
  /// In id, this message translates to:
  /// **'Hari Arafah'**
  String get uq_ev_12_9;

  /// No description provided for @uq_ev_12_10.
  ///
  /// In id, this message translates to:
  /// **'Iduladha'**
  String get uq_ev_12_10;

  /// No description provided for @hjHariPentingTitle.
  ///
  /// In id, this message translates to:
  /// **'Hari Penting Islam'**
  String get hjHariPentingTitle;

  /// No description provided for @hjHariPentingEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa memuat tanggal penting.'**
  String get hjHariPentingEmpty;

  /// No description provided for @hjHariPentingSemantics.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Hijriah, buka Hari Penting Islam'**
  String get hjHariPentingSemantics;

  /// No description provided for @hjToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini!'**
  String get hjToday;

  /// No description provided for @hjPassed.
  ///
  /// In id, this message translates to:
  /// **'Sudah lewat'**
  String get hjPassed;

  /// No description provided for @hjDaysLeft.
  ///
  /// In id, this message translates to:
  /// **'{days} hari lagi'**
  String hjDaysLeft(Object days);

  /// No description provided for @hjHijriSuffix.
  ///
  /// In id, this message translates to:
  /// **'H'**
  String get hjHijriSuffix;

  /// No description provided for @qiblaCalibrationHint.
  ///
  /// In id, this message translates to:
  /// **'💡 Kalibrasi kompas: putar perangkat membentuk angka 8 beberapa kali untuk akurasi terbaik.'**
  String get qiblaCalibrationHint;

  /// No description provided for @qiblaCompassLabel.
  ///
  /// In id, this message translates to:
  /// **'KOMPAS KIBLAT'**
  String get qiblaCompassLabel;

  /// No description provided for @qiblaTitle.
  ///
  /// In id, this message translates to:
  /// **'Arah Kiblat'**
  String get qiblaTitle;

  /// No description provided for @qiblaAligned.
  ///
  /// In id, this message translates to:
  /// **'🎯 Pas! Tahan posisi ini'**
  String get qiblaAligned;

  /// No description provided for @qiblaTurnRight.
  ///
  /// In id, this message translates to:
  /// **'Putar {degrees}° ke kanan →'**
  String qiblaTurnRight(String degrees);

  /// No description provided for @qiblaTurnLeft.
  ///
  /// In id, this message translates to:
  /// **'← Putar {degrees}° ke kiri'**
  String qiblaTurnLeft(String degrees);

  /// No description provided for @qiblaNoSensorTitle.
  ///
  /// In id, this message translates to:
  /// **'Sensor Kompas Tidak Tersedia'**
  String get qiblaNoSensorTitle;

  /// No description provided for @qiblaNoSensorBody.
  ///
  /// In id, this message translates to:
  /// **'Perangkat ini tidak memiliki sensor magnetometer. Gunakan panduan arah di bawah ini sebagai alternatif.'**
  String get qiblaNoSensorBody;

  /// No description provided for @qiblaAlignedTitle.
  ///
  /// In id, this message translates to:
  /// **'Sudah Menghadap Kiblat!'**
  String get qiblaAlignedTitle;

  /// No description provided for @qiblaAimTitle.
  ///
  /// In id, this message translates to:
  /// **'Arahkan Perangkat ke Kiblat'**
  String get qiblaAimTitle;

  /// No description provided for @qiblaStatTitle.
  ///
  /// In id, this message translates to:
  /// **'ARAH KIBLAT'**
  String get qiblaStatTitle;

  /// No description provided for @qiblaDistanceTitle.
  ///
  /// In id, this message translates to:
  /// **'JARAK KA\'BAH'**
  String get qiblaDistanceTitle;

  /// No description provided for @qiblaCityDistance.
  ///
  /// In id, this message translates to:
  /// **'📍 {city} • {km} km ke Ka\'bah'**
  String qiblaCityDistance(String city, String km);

  /// No description provided for @qiblaCityBearing.
  ///
  /// In id, this message translates to:
  /// **'Arah Kiblat dari {city}:'**
  String qiblaCityBearing(String city);

  /// No description provided for @qiblaNorthDegrees.
  ///
  /// In id, this message translates to:
  /// **'{degrees}° dari Utara'**
  String qiblaNorthDegrees(String degrees);

  /// No description provided for @qiblaTurnInstruction.
  ///
  /// In id, this message translates to:
  /// **'Putar perangkat {degrees}° searah jarum jam dari utara untuk menghadap kiblat.'**
  String qiblaTurnInstruction(String degrees);

  /// No description provided for @qiblaOffset.
  ///
  /// In id, this message translates to:
  /// **'Selisih {degrees}° dari kiblat'**
  String qiblaOffset(String degrees);

  /// No description provided for @dzResetTitle.
  ///
  /// In id, this message translates to:
  /// **'Reset counter?'**
  String get dzResetTitle;

  /// No description provided for @dzResetBody.
  ///
  /// In id, this message translates to:
  /// **'Counter \"{item}\" akan di-nolkan dari 0.\\nTotal dzikir hari ini TETAP dihitung.'**
  String dzResetBody(String item);

  /// No description provided for @dzResetCancel.
  ///
  /// In id, this message translates to:
  /// **'BATAL'**
  String get dzResetCancel;

  /// No description provided for @dzResetConfirm.
  ///
  /// In id, this message translates to:
  /// **'RESET'**
  String get dzResetConfirm;

  /// No description provided for @dzTapHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk di mana saja untuk berdzikir'**
  String get dzTapHint;

  /// No description provided for @dzToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini: {total}'**
  String dzToday(String total);

  /// No description provided for @dzVibrateOff.
  ///
  /// In id, this message translates to:
  /// **'Matikan getar'**
  String get dzVibrateOff;

  /// No description provided for @dzVibrateOn.
  ///
  /// In id, this message translates to:
  /// **'Nyalakan getar'**
  String get dzVibrateOn;

  /// No description provided for @dzResetThis.
  ///
  /// In id, this message translates to:
  /// **'Reset counter ini'**
  String get dzResetThis;

  /// No description provided for @dzTargetDone.
  ///
  /// In id, this message translates to:
  /// **'TARGET TERCAPAI'**
  String get dzTargetDone;

  /// No description provided for @hdEmptyPage.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hadis di halaman ini.'**
  String get hdEmptyPage;

  /// No description provided for @hdLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat hadis.'**
  String get hdLoadFailed;

  /// No description provided for @hdLoadFailedRetry.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat hadis. Coba lagi.'**
  String get hdLoadFailedRetry;

  /// No description provided for @hdSearchFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mencari hadis.'**
  String get hdSearchFailed;

  /// No description provided for @hdRandomFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengambil hadis acak. Coba lagi.'**
  String get hdRandomFailed;

  /// No description provided for @hdSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari hadis…'**
  String get hdSearchHint;

  /// No description provided for @hdSearchFound.
  ///
  /// In id, this message translates to:
  /// **'{total} hadis ditemukan'**
  String hdSearchFound(String total);

  /// No description provided for @hdSearchEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hadis ditemukan.'**
  String get hdSearchEmpty;

  /// No description provided for @hdBackToList.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke daftar'**
  String get hdBackToList;

  /// No description provided for @hdLoadMore.
  ///
  /// In id, this message translates to:
  /// **'Muat Lagi'**
  String get hdLoadMore;

  /// No description provided for @hdNumber.
  ///
  /// In id, this message translates to:
  /// **'no. {id}'**
  String hdNumber(String id);

  /// No description provided for @hdDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Hadis no. {id}'**
  String hdDetailTitle(String id);

  /// No description provided for @dzTransSubhanallah.
  ///
  /// In id, this message translates to:
  /// **'Maha Suci Allah'**
  String get dzTransSubhanallah;

  /// No description provided for @dzTransAlhamdulillah.
  ///
  /// In id, this message translates to:
  /// **'Segala puji bagi Allah'**
  String get dzTransAlhamdulillah;

  /// No description provided for @dzTransAllahuakbar.
  ///
  /// In id, this message translates to:
  /// **'Allah Maha Besar'**
  String get dzTransAllahuakbar;

  /// No description provided for @dzTransAstaghfirullah.
  ///
  /// In id, this message translates to:
  /// **'Aku memohon ampun kepada Allah'**
  String get dzTransAstaghfirullah;

  /// No description provided for @dzTransHawla.
  ///
  /// In id, this message translates to:
  /// **'Tiada daya & kekuatan kecuali dengan Allah'**
  String get dzTransHawla;

  /// No description provided for @blModulNotFound.
  ///
  /// In id, this message translates to:
  /// **'Modul tidak ditemukan'**
  String get blModulNotFound;

  /// No description provided for @blModulDone.
  ///
  /// In id, this message translates to:
  /// **'Modul Selesai!'**
  String get blModulDone;

  /// No description provided for @blKnowledgeUp.
  ///
  /// In id, this message translates to:
  /// **'Pengetahuanmu semakin bertambah.'**
  String get blKnowledgeUp;

  /// No description provided for @blMinScore70.
  ///
  /// In id, this message translates to:
  /// **'Minimal 70% untuk lulus. Coba lagi ya!'**
  String get blMinScore70;

  /// No description provided for @blReadAgain.
  ///
  /// In id, this message translates to:
  /// **'Baca lagi artikelnya, lalu coba quiz lagi. Kamu pasti bisa!'**
  String get blReadAgain;

  /// No description provided for @blBackToHub.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Hub'**
  String get blBackToHub;

  /// No description provided for @qdArabicSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran teks Arab'**
  String get qdArabicSize;

  /// No description provided for @qdTransSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran terjemahan'**
  String get qdTransSize;

  /// No description provided for @qdLatinHint.
  ///
  /// In id, this message translates to:
  /// **'Bacaan latin untuk membantu membaca Arab'**
  String get qdLatinHint;

  /// No description provided for @qdTajwidColors.
  ///
  /// In id, this message translates to:
  /// **'Warna Tajwid'**
  String get qdTajwidColors;

  /// No description provided for @qdTafsirMuyassar.
  ///
  /// In id, this message translates to:
  /// **'Tafsir Muyassar (ringkas, mudah dicerna)'**
  String get qdTafsirMuyassar;

  /// No description provided for @qdTafsirKemenag.
  ///
  /// In id, this message translates to:
  /// **'Tafsir Kemenag (lengkap)'**
  String get qdTafsirKemenag;

  /// No description provided for @ppUnlockSkins.
  ///
  /// In id, this message translates to:
  /// **'Buka semua skin premium'**
  String get ppUnlockSkins;

  /// No description provided for @ppActivateDev.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Pro (dev)'**
  String get ppActivateDev;

  /// No description provided for @deExpTitle.
  ///
  /// In id, this message translates to:
  /// **'DAPET EXP!'**
  String get deExpTitle;

  /// No description provided for @bqModulNotFound.
  ///
  /// In id, this message translates to:
  /// **'Modul tidak ditemukan'**
  String get bqModulNotFound;

  /// No description provided for @bqQuizUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Quiz belum tersedia'**
  String get bqQuizUnavailable;

  /// No description provided for @bqNotYetRight.
  ///
  /// In id, this message translates to:
  /// **'Belum tepat'**
  String get bqNotYetRight;

  /// No description provided for @qpPrevAyah.
  ///
  /// In id, this message translates to:
  /// **'Ayat sebelumnya'**
  String get qpPrevAyah;

  /// No description provided for @qpNextAyah.
  ///
  /// In id, this message translates to:
  /// **'Ayat berikutnya'**
  String get qpNextAyah;

  /// No description provided for @qpMurrotalSettings.
  ///
  /// In id, this message translates to:
  /// **'Setelan murrotal'**
  String get qpMurrotalSettings;

  /// No description provided for @qpbRepeatRange.
  ///
  /// In id, this message translates to:
  /// **'Ulangi rentang'**
  String get qpbRepeatRange;

  /// No description provided for @qpbSleepTimer.
  ///
  /// In id, this message translates to:
  /// **'Tidur otomatis'**
  String get qpbSleepTimer;

  /// No description provided for @qpbEndOfSurah.
  ///
  /// In id, this message translates to:
  /// **'Akhir surat'**
  String get qpbEndOfSurah;

  /// No description provided for @qbNoBookmark.
  ///
  /// In id, this message translates to:
  /// **'Belum ada bookmark'**
  String get qbNoBookmark;

  /// No description provided for @qbDeleteBookmark.
  ///
  /// In id, this message translates to:
  /// **'Hapus bookmark'**
  String get qbDeleteBookmark;

  /// No description provided for @qacDeleteBookmark.
  ///
  /// In id, this message translates to:
  /// **'Hapus bookmark'**
  String get qacDeleteBookmark;

  /// No description provided for @phPrevMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan sebelumnya'**
  String get phPrevMonth;

  /// No description provided for @phNextMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan berikutnya'**
  String get phNextMonth;

  /// No description provided for @clProLocked.
  ///
  /// In id, this message translates to:
  /// **'Pro terkunci'**
  String get clProLocked;

  /// No description provided for @clCompleteQuest.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan quest harian untuk membuka skin dari Daily Chest.'**
  String get clCompleteQuest;

  /// No description provided for @qdTajwidLegend.
  ///
  /// In id, this message translates to:
  /// **'Merah=Ghunnah, Biru=Qalqalah/Idgham, Hijau=Mad'**
  String get qdTajwidLegend;

  /// No description provided for @ppProPitch.
  ///
  /// In id, this message translates to:
  /// **'Perisai, aura, dan gelar eksklusif. Gaya baru untuk avatarmu — tanpa memengaruhi XP, streak, atau peringkatmu.'**
  String get ppProPitch;

  /// No description provided for @deQuizDone.
  ///
  /// In id, this message translates to:
  /// **'Kamu menyelesaikan quiz {moduleTitle}!'**
  String deQuizDone(String moduleTitle);

  /// No description provided for @deLevelShort.
  ///
  /// In id, this message translates to:
  /// **'Lv {level}'**
  String deLevelShort(int level);

  /// No description provided for @deLevel.
  ///
  /// In id, this message translates to:
  /// **'Level {level}'**
  String deLevel(int level);

  /// No description provided for @bqQuestionOf.
  ///
  /// In id, this message translates to:
  /// **'PERTANYAAN {current}/{total}'**
  String bqQuestionOf(int current, int total);

  /// No description provided for @qbSurahName.
  ///
  /// In id, this message translates to:
  /// **'Surat {number}'**
  String qbSurahName(int number);

  /// No description provided for @qacAyahNumber.
  ///
  /// In id, this message translates to:
  /// **'Ayat {number}'**
  String qacAyahNumber(int number);

  /// No description provided for @jdLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat jadwal. Periksa koneksi.'**
  String get jdLoadFailed;

  /// No description provided for @jdAlreadyLogged.
  ///
  /// In id, this message translates to:
  /// **'✓ SUDAH DILOG'**
  String get jdAlreadyLogged;

  /// No description provided for @jdTesSuara.
  ///
  /// In id, this message translates to:
  /// **'Tes suara'**
  String get jdTesSuara;

  /// No description provided for @jdAdzanDownloadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengunduh suara adzan. Periksa koneksi lalu coba lagi.'**
  String get jdAdzanDownloadFailed;

  /// No description provided for @qtLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data Quran'**
  String get qtLoadFailed;

  /// No description provided for @qtSurahNotFound.
  ///
  /// In id, this message translates to:
  /// **'Surat tidak ditemukan'**
  String get qtSurahNotFound;

  /// No description provided for @qtContinueReading.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan membaca'**
  String get qtContinueReading;

  /// No description provided for @spTagline.
  ///
  /// In id, this message translates to:
  /// **'Level Up iman, Level Up Kehidupanmu'**
  String get spTagline;

  /// No description provided for @spLoading.
  ///
  /// In id, this message translates to:
  /// **'MEMUAT DATA PEJUANG...'**
  String get spLoading;

  /// No description provided for @btSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tingkatkan ilmu, raih lebih banyak XP.'**
  String get btSubtitle;

  /// No description provided for @doaLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat doa.'**
  String get doaLoadFailed;

  /// No description provided for @taProSignature.
  ///
  /// In id, this message translates to:
  /// **'Pro signature finish'**
  String get taProSignature;

  /// No description provided for @tpSelected.
  ///
  /// In id, this message translates to:
  /// **'Tema dipilih'**
  String get tpSelected;

  /// No description provided for @qrDisplaySettings.
  ///
  /// In id, this message translates to:
  /// **'Setelan tampilan'**
  String get qrDisplaySettings;

  /// No description provided for @jdSoundFollowGlobal.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti global'**
  String get jdSoundFollowGlobal;

  /// No description provided for @jdNotifFor.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi {prayer}'**
  String jdNotifFor(String prayer);

  /// No description provided for @jdSoundSilent.
  ///
  /// In id, this message translates to:
  /// **'Senyap — tanpa suara'**
  String get jdSoundSilent;

  /// No description provided for @jdSoundNormal.
  ///
  /// In id, this message translates to:
  /// **'Suara — notifikasi standar HP'**
  String get jdSoundNormal;

  /// No description provided for @jdSoundAdzan.
  ///
  /// In id, this message translates to:
  /// **'Adzan — suara adzan penuh'**
  String get jdSoundAdzan;

  /// No description provided for @jdSoundGlobalOption.
  ///
  /// In id, this message translates to:
  /// **'Ikuti pengaturan global'**
  String get jdSoundGlobalOption;

  /// No description provided for @jdFootnote.
  ///
  /// In id, this message translates to:
  /// **'Jadwal dari data KEMENAG RI via api.myquran.com untuk {city}. Ter-update otomatis saat tab dibuka; tap nama kota di atas untuk ganti lokasi.'**
  String jdFootnote(String city);

  /// No description provided for @qtSearchEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan. Coba kata lain di terjemahan, atau tulis nama surat + nomor ayat — mis. {example}.'**
  String qtSearchEmpty(String example);

  /// No description provided for @qtOpenSurah.
  ///
  /// In id, this message translates to:
  /// **'Buka surat {surah}'**
  String qtOpenSurah(String surah);

  /// No description provided for @qtAyahOf.
  ///
  /// In id, this message translates to:
  /// **'Ayat {ayah} dari {total}'**
  String qtAyahOf(int ayah, int total);

  /// No description provided for @qtSurahAyah.
  ///
  /// In id, this message translates to:
  /// **'Surat {surah} · Ayat {ayah}'**
  String qtSurahAyah(String surah, int ayah);

  /// No description provided for @btQuizScore.
  ///
  /// In id, this message translates to:
  /// **'Quiz: {score}%'**
  String btQuizScore(int score);

  /// No description provided for @nlLevelShort.
  ///
  /// In id, this message translates to:
  /// **'Lv {level}'**
  String nlLevelShort(int level);

  /// No description provided for @homeLevelShort.
  ///
  /// In id, this message translates to:
  /// **'LV {level}'**
  String homeLevelShort(int level);

  /// No description provided for @qtsTafsirAyah.
  ///
  /// In id, this message translates to:
  /// **'Tafsir Ayat {ayah}'**
  String qtsTafsirAyah(int ayah);

  /// No description provided for @locFailureDisabled.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan layanan lokasi perangkat, lalu coba lagi.'**
  String get locFailureDisabled;

  /// No description provided for @locFailureDenied.
  ///
  /// In id, this message translates to:
  /// **'Izinkan akses lokasi untuk menggunakan lokasi saat ini.'**
  String get locFailureDenied;

  /// No description provided for @locFailureDeniedForever.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi diblokir. Buka Pengaturan untuk mengizinkannya.'**
  String get locFailureDeniedForever;

  /// No description provided for @locFailureTimeout.
  ///
  /// In id, this message translates to:
  /// **'Lokasi terlalu lama ditemukan. Coba lagi di area terbuka.'**
  String get locFailureTimeout;

  /// No description provided for @locFailureLookup.
  ///
  /// In id, this message translates to:
  /// **'Kota tidak dapat ditemukan. Periksa koneksi atau pilih kota manual.'**
  String get locFailureLookup;

  /// No description provided for @authNoIdToken.
  ///
  /// In id, this message translates to:
  /// **'Google tidak kirim idToken. Cek SHA-1 di Firebase Console.'**
  String get authNoIdToken;

  /// No description provided for @authEmptyUser.
  ///
  /// In id, this message translates to:
  /// **'Firebase Auth gagal — user kosong.'**
  String get authEmptyUser;

  /// No description provided for @authDevError10.
  ///
  /// In id, this message translates to:
  /// **'Google DEVELOPER_ERROR (10): SHA-1 belum terdaftar di Firebase Console.'**
  String get authDevError10;

  /// No description provided for @authMisconfigured.
  ///
  /// In id, this message translates to:
  /// **'Google Sign-In misconfigured. Cek OAuth consent + SHA-1.'**
  String get authMisconfigured;

  /// No description provided for @authNetworkError.
  ///
  /// In id, this message translates to:
  /// **'Jaringan error saat login Google.'**
  String get authNetworkError;

  /// No description provided for @authCredInvalid.
  ///
  /// In id, this message translates to:
  /// **'Firebase Auth gagal validasi credential.'**
  String get authCredInvalid;

  /// No description provided for @authNotEnabled.
  ///
  /// In id, this message translates to:
  /// **'Google Sign-In belum diaktifkan di Firebase Console.'**
  String get authNotEnabled;

  /// No description provided for @authEmailInUse.
  ///
  /// In id, this message translates to:
  /// **'Email sudah terdaftar dengan metode lain.'**
  String get authEmailInUse;

  /// No description provided for @notifModeFokus.
  ///
  /// In id, this message translates to:
  /// **'Mode Fokus aktif! Pengingat hanya saat masuk waktu adzan.'**
  String get notifModeFokus;

  /// No description provided for @notifModeSeimbang.
  ///
  /// In id, this message translates to:
  /// **'Mode Seimbang aktif! Pengingat semua sholat wajib 15 menit sebelum adzan.'**
  String get notifModeSeimbang;

  /// No description provided for @notifModeIntensif.
  ///
  /// In id, this message translates to:
  /// **'Mode Intensif aktif! Diingetin 30 menit & 5 menit sebelum sholat. Pertahanin streak! 🔥'**
  String get notifModeIntensif;

  /// No description provided for @notifReady.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Muslim Leveling siap! 🔔'**
  String get notifReady;

  /// No description provided for @notifTestBody.
  ///
  /// In id, this message translates to:
  /// **'Kalau adzan terdengar, notifikasi kamu siap! Kalau tidak, cek volume alarm HP.'**
  String get notifTestBody;

  /// No description provided for @notifTestTitle.
  ///
  /// In id, this message translates to:
  /// **'🕌 Tes Suara Adzan'**
  String get notifTestTitle;

  /// No description provided for @notifChannelReminder.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi pengingat waktu sholat'**
  String get notifChannelReminder;

  /// No description provided for @notifModeTitle.
  ///
  /// In id, this message translates to:
  /// **'Muslim Leveling Mode: {mode}'**
  String notifModeTitle(String mode);

  /// No description provided for @notifTitleMarker.
  ///
  /// In id, this message translates to:
  /// **'🕌 {prayer}'**
  String notifTitleMarker(String prayer);

  /// No description provided for @notifTitlePrayer.
  ///
  /// In id, this message translates to:
  /// **'🕌 Waktunya Sholat {prayer}'**
  String notifTitlePrayer(String prayer);

  /// No description provided for @notifBodyImsak.
  ///
  /// In id, this message translates to:
  /// **'Sudah masuk imsak{loc}. Berhenti makan & minum ya. 🌙'**
  String notifBodyImsak(String loc);

  /// No description provided for @notifBodyTerbit.
  ///
  /// In id, this message translates to:
  /// **'Matahari terbit{loc}. Waktu Subuh berakhir, Dhuha sudah masuk. ☀️'**
  String notifBodyTerbit(String loc);

  /// No description provided for @notifBody30min.
  ///
  /// In id, this message translates to:
  /// **'30 menit lagi masuk waktu {prayer}{loc}. Persiapan ya! 🔥'**
  String notifBody30min(String prayer, String loc);

  /// No description provided for @notifBody5min.
  ///
  /// In id, this message translates to:
  /// **'5 menit lagi masuk waktu {prayer}{loc}. Segera siap! ⚡'**
  String notifBody5min(String prayer, String loc);

  /// No description provided for @notifBody15min.
  ///
  /// In id, this message translates to:
  /// **'15 menit lagi masuk waktu {prayer}{loc}. Persiapan ya! 🌙'**
  String notifBody15min(String prayer, String loc);

  /// No description provided for @notifBodyNow.
  ///
  /// In id, this message translates to:
  /// **'Sudah masuk waktu sholat {prayer}{loc}. Yuk jaga streak! 🔥'**
  String notifBodyNow(String prayer, String loc);

  /// No description provided for @prayerImsak.
  ///
  /// In id, this message translates to:
  /// **'Imsak'**
  String get prayerImsak;

  /// No description provided for @prayerTerbit.
  ///
  /// In id, this message translates to:
  /// **'Terbit'**
  String get prayerTerbit;

  /// No description provided for @notifLocSuffix.
  ///
  /// In id, this message translates to:
  /// **' di {city}'**
  String notifLocSuffix(String city);

  /// No description provided for @blClaimXp.
  ///
  /// In id, this message translates to:
  /// **'KLAIM +{xp} XP'**
  String blClaimXp(int xp);

  /// No description provided for @blNotPassed.
  ///
  /// In id, this message translates to:
  /// **'Belum Lulus'**
  String get blNotPassed;

  /// No description provided for @jdPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktu Sholat'**
  String get jdPageTitle;

  /// No description provided for @jdSearchCity.
  ///
  /// In id, this message translates to:
  /// **'Cari Kota'**
  String get jdSearchCity;

  /// No description provided for @jdNextPrayer.
  ///
  /// In id, this message translates to:
  /// **'SHOLAT BERIKUTNYA'**
  String get jdNextPrayer;

  /// No description provided for @jdTodaySchedule.
  ///
  /// In id, this message translates to:
  /// **'JADWAL HARI INI'**
  String get jdTodaySchedule;

  /// No description provided for @jdAdzanSoundTitle.
  ///
  /// In id, this message translates to:
  /// **'SUARA ADZAN'**
  String get jdAdzanSoundTitle;

  /// No description provided for @jdLoadingShort.
  ///
  /// In id, this message translates to:
  /// **'memuat...'**
  String get jdLoadingShort;

  /// No description provided for @jdCountdownHm.
  ///
  /// In id, this message translates to:
  /// **'{hours}j {minutes}m lagi'**
  String jdCountdownHm(int hours, int minutes);

  /// No description provided for @jdCountdownM.
  ///
  /// In id, this message translates to:
  /// **'{minutes}m lagi'**
  String jdCountdownM(int minutes);

  /// No description provided for @jdCountdownTomorrow.
  ///
  /// In id, this message translates to:
  /// **'besok'**
  String get jdCountdownTomorrow;

  /// No description provided for @jdRegionTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Wilayah'**
  String get jdRegionTitle;

  /// No description provided for @jdRegionIndonesia.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get jdRegionIndonesia;

  /// No description provided for @jdRegionAbroad.
  ///
  /// In id, this message translates to:
  /// **'Luar Negeri'**
  String get jdRegionAbroad;

  /// No description provided for @jdAbroadSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Ketik nama kota di luar negeri...'**
  String get jdAbroadSearchHint;

  /// No description provided for @jdAbroadEmpty.
  ///
  /// In id, this message translates to:
  /// **'Kota tidak ditemukan. Tulis namanya dalam bahasa Inggris — mis. London.'**
  String get jdAbroadEmpty;

  /// No description provided for @jdFootnoteAbroad.
  ///
  /// In id, this message translates to:
  /// **'Jadwal dari Aladhan untuk {city}. Metode perhitungan mengikuti negara kota ini. Ter-update otomatis saat tab dibuka; tap nama kota di atas untuk ganti lokasi.'**
  String jdFootnoteAbroad(String city);

  /// No description provided for @commonRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get commonRetry;

  /// No description provided for @qtSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari surat atau ayat'**
  String get qtSearchHint;

  /// No description provided for @qtSearchHelper.
  ///
  /// In id, this message translates to:
  /// **'mis. {example}'**
  String qtSearchHelper(String example);

  /// No description provided for @qtVerseHits.
  ///
  /// In id, this message translates to:
  /// **'{count} ayat ditemukan di terjemahan'**
  String qtVerseHits(int count);

  /// No description provided for @qtVerseHitsTruncated.
  ///
  /// In id, this message translates to:
  /// **'{count}+ ayat ditemukan — persempit kata kunci'**
  String qtVerseHitsTruncated(int count);

  /// No description provided for @qtBookmarkTooltip.
  ///
  /// In id, this message translates to:
  /// **'Bookmark ayat'**
  String get qtBookmarkTooltip;

  /// No description provided for @qtSubtitle.
  ///
  /// In id, this message translates to:
  /// **'114 surat · 30 juz'**
  String get qtSubtitle;

  /// No description provided for @qbTitle.
  ///
  /// In id, this message translates to:
  /// **'Bookmark'**
  String get qbTitle;

  /// No description provided for @qbEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Tap ikon bookmark di ayat yang mau disimpan.'**
  String get qbEmptyHint;

  /// No description provided for @qacPlayFromHere.
  ///
  /// In id, this message translates to:
  /// **'Putar dari ayat ini'**
  String get qacPlayFromHere;

  /// No description provided for @qrBasmalah.
  ///
  /// In id, this message translates to:
  /// **'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang'**
  String get qrBasmalah;

  /// No description provided for @qs_meaning_1.
  ///
  /// In id, this message translates to:
  /// **'Pembukaan'**
  String get qs_meaning_1;

  /// No description provided for @qs_meaning_2.
  ///
  /// In id, this message translates to:
  /// **'Sapi'**
  String get qs_meaning_2;

  /// No description provided for @qs_meaning_3.
  ///
  /// In id, this message translates to:
  /// **'Keluarga Imran'**
  String get qs_meaning_3;

  /// No description provided for @qs_meaning_4.
  ///
  /// In id, this message translates to:
  /// **'Wanita'**
  String get qs_meaning_4;

  /// No description provided for @qs_meaning_5.
  ///
  /// In id, this message translates to:
  /// **'Hidangan'**
  String get qs_meaning_5;

  /// No description provided for @qs_meaning_6.
  ///
  /// In id, this message translates to:
  /// **'Binatang Ternak'**
  String get qs_meaning_6;

  /// No description provided for @qs_meaning_7.
  ///
  /// In id, this message translates to:
  /// **'Tempat Tertinggi'**
  String get qs_meaning_7;

  /// No description provided for @qs_meaning_8.
  ///
  /// In id, this message translates to:
  /// **'Rampasan Perang'**
  String get qs_meaning_8;

  /// No description provided for @qs_meaning_9.
  ///
  /// In id, this message translates to:
  /// **'Pengampunan'**
  String get qs_meaning_9;

  /// No description provided for @qs_meaning_10.
  ///
  /// In id, this message translates to:
  /// **'Yunus'**
  String get qs_meaning_10;

  /// No description provided for @qs_meaning_11.
  ///
  /// In id, this message translates to:
  /// **'Hud'**
  String get qs_meaning_11;

  /// No description provided for @qs_meaning_12.
  ///
  /// In id, this message translates to:
  /// **'Yusuf'**
  String get qs_meaning_12;

  /// No description provided for @qs_meaning_13.
  ///
  /// In id, this message translates to:
  /// **'Guruh'**
  String get qs_meaning_13;

  /// No description provided for @qs_meaning_14.
  ///
  /// In id, this message translates to:
  /// **'Ibrahim'**
  String get qs_meaning_14;

  /// No description provided for @qs_meaning_15.
  ///
  /// In id, this message translates to:
  /// **'Hijr'**
  String get qs_meaning_15;

  /// No description provided for @qs_meaning_16.
  ///
  /// In id, this message translates to:
  /// **'Lebah'**
  String get qs_meaning_16;

  /// No description provided for @qs_meaning_17.
  ///
  /// In id, this message translates to:
  /// **'Memperjalankan Malam Hari'**
  String get qs_meaning_17;

  /// No description provided for @qs_meaning_18.
  ///
  /// In id, this message translates to:
  /// **'Goa'**
  String get qs_meaning_18;

  /// No description provided for @qs_meaning_19.
  ///
  /// In id, this message translates to:
  /// **'Maryam'**
  String get qs_meaning_19;

  /// No description provided for @qs_meaning_20.
  ///
  /// In id, this message translates to:
  /// **'Taha'**
  String get qs_meaning_20;

  /// No description provided for @qs_meaning_21.
  ///
  /// In id, this message translates to:
  /// **'Para Nabi'**
  String get qs_meaning_21;

  /// No description provided for @qs_meaning_22.
  ///
  /// In id, this message translates to:
  /// **'Haji'**
  String get qs_meaning_22;

  /// No description provided for @qs_meaning_23.
  ///
  /// In id, this message translates to:
  /// **'Orang-Orang Mukmin'**
  String get qs_meaning_23;

  /// No description provided for @qs_meaning_24.
  ///
  /// In id, this message translates to:
  /// **'Cahaya'**
  String get qs_meaning_24;

  /// No description provided for @qs_meaning_25.
  ///
  /// In id, this message translates to:
  /// **'Pembeda'**
  String get qs_meaning_25;

  /// No description provided for @qs_meaning_26.
  ///
  /// In id, this message translates to:
  /// **'Para Penyair'**
  String get qs_meaning_26;

  /// No description provided for @qs_meaning_27.
  ///
  /// In id, this message translates to:
  /// **'Semut-semut'**
  String get qs_meaning_27;

  /// No description provided for @qs_meaning_28.
  ///
  /// In id, this message translates to:
  /// **'Kisah-Kisah'**
  String get qs_meaning_28;

  /// No description provided for @qs_meaning_29.
  ///
  /// In id, this message translates to:
  /// **'Laba-Laba'**
  String get qs_meaning_29;

  /// No description provided for @qs_meaning_30.
  ///
  /// In id, this message translates to:
  /// **'Romawi'**
  String get qs_meaning_30;

  /// No description provided for @qs_meaning_31.
  ///
  /// In id, this message translates to:
  /// **'Luqman'**
  String get qs_meaning_31;

  /// No description provided for @qs_meaning_32.
  ///
  /// In id, this message translates to:
  /// **'Sajdah'**
  String get qs_meaning_32;

  /// No description provided for @qs_meaning_33.
  ///
  /// In id, this message translates to:
  /// **'Golongan Yang Bersekutu'**
  String get qs_meaning_33;

  /// No description provided for @qs_meaning_34.
  ///
  /// In id, this message translates to:
  /// **'Saba\''**
  String get qs_meaning_34;

  /// No description provided for @qs_meaning_35.
  ///
  /// In id, this message translates to:
  /// **'Maha Pencipta'**
  String get qs_meaning_35;

  /// No description provided for @qs_meaning_36.
  ///
  /// In id, this message translates to:
  /// **'Yasin'**
  String get qs_meaning_36;

  /// No description provided for @qs_meaning_37.
  ///
  /// In id, this message translates to:
  /// **'Barisan-Barisan'**
  String get qs_meaning_37;

  /// No description provided for @qs_meaning_38.
  ///
  /// In id, this message translates to:
  /// **'Sad'**
  String get qs_meaning_38;

  /// No description provided for @qs_meaning_39.
  ///
  /// In id, this message translates to:
  /// **'Rombongan'**
  String get qs_meaning_39;

  /// No description provided for @qs_meaning_40.
  ///
  /// In id, this message translates to:
  /// **'Maha Pengampun'**
  String get qs_meaning_40;

  /// No description provided for @qs_meaning_41.
  ///
  /// In id, this message translates to:
  /// **'Yang Dijelaskan'**
  String get qs_meaning_41;

  /// No description provided for @qs_meaning_42.
  ///
  /// In id, this message translates to:
  /// **'Musyawarah'**
  String get qs_meaning_42;

  /// No description provided for @qs_meaning_43.
  ///
  /// In id, this message translates to:
  /// **'Perhiasan'**
  String get qs_meaning_43;

  /// No description provided for @qs_meaning_44.
  ///
  /// In id, this message translates to:
  /// **'Kabut'**
  String get qs_meaning_44;

  /// No description provided for @qs_meaning_45.
  ///
  /// In id, this message translates to:
  /// **'Berlutut'**
  String get qs_meaning_45;

  /// No description provided for @qs_meaning_46.
  ///
  /// In id, this message translates to:
  /// **'Bukit Pasir'**
  String get qs_meaning_46;

  /// No description provided for @qs_meaning_47.
  ///
  /// In id, this message translates to:
  /// **'Muhammad'**
  String get qs_meaning_47;

  /// No description provided for @qs_meaning_48.
  ///
  /// In id, this message translates to:
  /// **'Kemenangan'**
  String get qs_meaning_48;

  /// No description provided for @qs_meaning_49.
  ///
  /// In id, this message translates to:
  /// **'Kamar-Kamar'**
  String get qs_meaning_49;

  /// No description provided for @qs_meaning_50.
  ///
  /// In id, this message translates to:
  /// **'Qaf'**
  String get qs_meaning_50;

  /// No description provided for @qs_meaning_51.
  ///
  /// In id, this message translates to:
  /// **'Angin yang Menerbangkan'**
  String get qs_meaning_51;

  /// No description provided for @qs_meaning_52.
  ///
  /// In id, this message translates to:
  /// **'Bukit Tursina'**
  String get qs_meaning_52;

  /// No description provided for @qs_meaning_53.
  ///
  /// In id, this message translates to:
  /// **'Bintang'**
  String get qs_meaning_53;

  /// No description provided for @qs_meaning_54.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get qs_meaning_54;

  /// No description provided for @qs_meaning_55.
  ///
  /// In id, this message translates to:
  /// **'Maha Pengasih'**
  String get qs_meaning_55;

  /// No description provided for @qs_meaning_56.
  ///
  /// In id, this message translates to:
  /// **'Hari Kiamat'**
  String get qs_meaning_56;

  /// No description provided for @qs_meaning_57.
  ///
  /// In id, this message translates to:
  /// **'Besi'**
  String get qs_meaning_57;

  /// No description provided for @qs_meaning_58.
  ///
  /// In id, this message translates to:
  /// **'Gugatan'**
  String get qs_meaning_58;

  /// No description provided for @qs_meaning_59.
  ///
  /// In id, this message translates to:
  /// **'Pengusiran'**
  String get qs_meaning_59;

  /// No description provided for @qs_meaning_60.
  ///
  /// In id, this message translates to:
  /// **'Wanita Yang Diuji'**
  String get qs_meaning_60;

  /// No description provided for @qs_meaning_61.
  ///
  /// In id, this message translates to:
  /// **'Barisan'**
  String get qs_meaning_61;

  /// No description provided for @qs_meaning_62.
  ///
  /// In id, this message translates to:
  /// **'Jumat'**
  String get qs_meaning_62;

  /// No description provided for @qs_meaning_63.
  ///
  /// In id, this message translates to:
  /// **'Orang-Orang Munafik'**
  String get qs_meaning_63;

  /// No description provided for @qs_meaning_64.
  ///
  /// In id, this message translates to:
  /// **'Pengungkapan Kesalahan'**
  String get qs_meaning_64;

  /// No description provided for @qs_meaning_65.
  ///
  /// In id, this message translates to:
  /// **'Talak'**
  String get qs_meaning_65;

  /// No description provided for @qs_meaning_66.
  ///
  /// In id, this message translates to:
  /// **'Pengharaman'**
  String get qs_meaning_66;

  /// No description provided for @qs_meaning_67.
  ///
  /// In id, this message translates to:
  /// **'Kerajaan'**
  String get qs_meaning_67;

  /// No description provided for @qs_meaning_68.
  ///
  /// In id, this message translates to:
  /// **'Pena'**
  String get qs_meaning_68;

  /// No description provided for @qs_meaning_69.
  ///
  /// In id, this message translates to:
  /// **'Hari Kiamat'**
  String get qs_meaning_69;

  /// No description provided for @qs_meaning_70.
  ///
  /// In id, this message translates to:
  /// **'Tempat Naik'**
  String get qs_meaning_70;

  /// No description provided for @qs_meaning_71.
  ///
  /// In id, this message translates to:
  /// **'Nuh'**
  String get qs_meaning_71;

  /// No description provided for @qs_meaning_72.
  ///
  /// In id, this message translates to:
  /// **'Jin'**
  String get qs_meaning_72;

  /// No description provided for @qs_meaning_73.
  ///
  /// In id, this message translates to:
  /// **'Orang Yang Berselimut'**
  String get qs_meaning_73;

  /// No description provided for @qs_meaning_74.
  ///
  /// In id, this message translates to:
  /// **'Orang Yang Berkemul'**
  String get qs_meaning_74;

  /// No description provided for @qs_meaning_75.
  ///
  /// In id, this message translates to:
  /// **'Hari Kiamat'**
  String get qs_meaning_75;

  /// No description provided for @qs_meaning_76.
  ///
  /// In id, this message translates to:
  /// **'Manusia'**
  String get qs_meaning_76;

  /// No description provided for @qs_meaning_77.
  ///
  /// In id, this message translates to:
  /// **'Malaikat Yang Diutus'**
  String get qs_meaning_77;

  /// No description provided for @qs_meaning_78.
  ///
  /// In id, this message translates to:
  /// **'Berita Besar'**
  String get qs_meaning_78;

  /// No description provided for @qs_meaning_79.
  ///
  /// In id, this message translates to:
  /// **'Malaikat Yang Mencabut'**
  String get qs_meaning_79;

  /// No description provided for @qs_meaning_80.
  ///
  /// In id, this message translates to:
  /// **'Bermuka Masam'**
  String get qs_meaning_80;

  /// No description provided for @qs_meaning_81.
  ///
  /// In id, this message translates to:
  /// **'Penggulungan'**
  String get qs_meaning_81;

  /// No description provided for @qs_meaning_82.
  ///
  /// In id, this message translates to:
  /// **'Terbelah'**
  String get qs_meaning_82;

  /// No description provided for @qs_meaning_83.
  ///
  /// In id, this message translates to:
  /// **'Orang-Orang Curang'**
  String get qs_meaning_83;

  /// No description provided for @qs_meaning_84.
  ///
  /// In id, this message translates to:
  /// **'Terbelah'**
  String get qs_meaning_84;

  /// No description provided for @qs_meaning_85.
  ///
  /// In id, this message translates to:
  /// **'Gugusan Bintang'**
  String get qs_meaning_85;

  /// No description provided for @qs_meaning_86.
  ///
  /// In id, this message translates to:
  /// **'Yang Datang Di Malam Hari'**
  String get qs_meaning_86;

  /// No description provided for @qs_meaning_87.
  ///
  /// In id, this message translates to:
  /// **'Maha Tinggi'**
  String get qs_meaning_87;

  /// No description provided for @qs_meaning_88.
  ///
  /// In id, this message translates to:
  /// **'Hari Kiamat'**
  String get qs_meaning_88;

  /// No description provided for @qs_meaning_89.
  ///
  /// In id, this message translates to:
  /// **'Fajar'**
  String get qs_meaning_89;

  /// No description provided for @qs_meaning_90.
  ///
  /// In id, this message translates to:
  /// **'Negeri'**
  String get qs_meaning_90;

  /// No description provided for @qs_meaning_91.
  ///
  /// In id, this message translates to:
  /// **'Matahari'**
  String get qs_meaning_91;

  /// No description provided for @qs_meaning_92.
  ///
  /// In id, this message translates to:
  /// **'Malam'**
  String get qs_meaning_92;

  /// No description provided for @qs_meaning_93.
  ///
  /// In id, this message translates to:
  /// **'Duha'**
  String get qs_meaning_93;

  /// No description provided for @qs_meaning_94.
  ///
  /// In id, this message translates to:
  /// **'Lapang'**
  String get qs_meaning_94;

  /// No description provided for @qs_meaning_95.
  ///
  /// In id, this message translates to:
  /// **'Buah Tin'**
  String get qs_meaning_95;

  /// No description provided for @qs_meaning_96.
  ///
  /// In id, this message translates to:
  /// **'Segumpal Darah'**
  String get qs_meaning_96;

  /// No description provided for @qs_meaning_97.
  ///
  /// In id, this message translates to:
  /// **'Kemuliaan'**
  String get qs_meaning_97;

  /// No description provided for @qs_meaning_98.
  ///
  /// In id, this message translates to:
  /// **'Bukti Nyata'**
  String get qs_meaning_98;

  /// No description provided for @qs_meaning_99.
  ///
  /// In id, this message translates to:
  /// **'Guncangan'**
  String get qs_meaning_99;

  /// No description provided for @qs_meaning_100.
  ///
  /// In id, this message translates to:
  /// **'Kuda Yang Berlari Kencang'**
  String get qs_meaning_100;

  /// No description provided for @qs_meaning_101.
  ///
  /// In id, this message translates to:
  /// **'Hari Kiamat'**
  String get qs_meaning_101;

  /// No description provided for @qs_meaning_102.
  ///
  /// In id, this message translates to:
  /// **'Bermegah-Megahan'**
  String get qs_meaning_102;

  /// No description provided for @qs_meaning_103.
  ///
  /// In id, this message translates to:
  /// **'Masa'**
  String get qs_meaning_103;

  /// No description provided for @qs_meaning_104.
  ///
  /// In id, this message translates to:
  /// **'Pengumpat'**
  String get qs_meaning_104;

  /// No description provided for @qs_meaning_105.
  ///
  /// In id, this message translates to:
  /// **'Gajah'**
  String get qs_meaning_105;

  /// No description provided for @qs_meaning_106.
  ///
  /// In id, this message translates to:
  /// **'Quraisy'**
  String get qs_meaning_106;

  /// No description provided for @qs_meaning_107.
  ///
  /// In id, this message translates to:
  /// **'Barang Yang Berguna'**
  String get qs_meaning_107;

  /// No description provided for @qs_meaning_108.
  ///
  /// In id, this message translates to:
  /// **'Pemberian Yang Banyak'**
  String get qs_meaning_108;

  /// No description provided for @qs_meaning_109.
  ///
  /// In id, this message translates to:
  /// **'Orang-Orang kafir'**
  String get qs_meaning_109;

  /// No description provided for @qs_meaning_110.
  ///
  /// In id, this message translates to:
  /// **'Pertolongan'**
  String get qs_meaning_110;

  /// No description provided for @qs_meaning_111.
  ///
  /// In id, this message translates to:
  /// **'Api Yang Bergejolak'**
  String get qs_meaning_111;

  /// No description provided for @qs_meaning_112.
  ///
  /// In id, this message translates to:
  /// **'Ikhlas'**
  String get qs_meaning_112;

  /// No description provided for @qs_meaning_113.
  ///
  /// In id, this message translates to:
  /// **'Subuh'**
  String get qs_meaning_113;

  /// No description provided for @qs_meaning_114.
  ///
  /// In id, this message translates to:
  /// **'Manusia'**
  String get qs_meaning_114;

  /// No description provided for @qsRevelationMeccan.
  ///
  /// In id, this message translates to:
  /// **'Makkiyah'**
  String get qsRevelationMeccan;

  /// No description provided for @qsRevelationMedinan.
  ///
  /// In id, this message translates to:
  /// **'Madaniyah'**
  String get qsRevelationMedinan;

  /// No description provided for @qtContinueReadingDetail.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan membaca {surah} ayat {ayah}'**
  String qtContinueReadingDetail(String surah, int ayah);

  /// No description provided for @qtOpenSurahAyah.
  ///
  /// In id, this message translates to:
  /// **'Buka {surah} ayat {ayah}'**
  String qtOpenSurahAyah(String surah, int ayah);

  /// No description provided for @qpbAyahRange.
  ///
  /// In id, this message translates to:
  /// **'Rentang ayat'**
  String get qpbAyahRange;

  /// No description provided for @qpbFrom.
  ///
  /// In id, this message translates to:
  /// **'Dari'**
  String get qpbFrom;

  /// No description provided for @qpbTo.
  ///
  /// In id, this message translates to:
  /// **'Sampai'**
  String get qpbTo;

  /// No description provided for @qpbRepeatRangeDetail.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke ayat {from} setelah ayat {to} selesai'**
  String qpbRepeatRangeDetail(int from, int to);

  /// No description provided for @qpbSpeed.
  ///
  /// In id, this message translates to:
  /// **'Kecepatan'**
  String get qpbSpeed;

  /// No description provided for @qpbQari.
  ///
  /// In id, this message translates to:
  /// **'Qari'**
  String get qpbQari;

  /// No description provided for @qpbOff.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get qpbOff;

  /// No description provided for @qpbMinutes.
  ///
  /// In id, this message translates to:
  /// **'{m} mnt'**
  String qpbMinutes(int m);

  /// No description provided for @qdTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Tampilan'**
  String get qdTitle;

  /// No description provided for @qdTranslationLabel.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan Indonesia'**
  String get qdTranslationLabel;

  /// No description provided for @qdTransliteration.
  ///
  /// In id, this message translates to:
  /// **'Transliterasi Latin'**
  String get qdTransliteration;

  /// No description provided for @qdTafsirBrief.
  ///
  /// In id, this message translates to:
  /// **'Tafsir Ringkas'**
  String get qdTafsirBrief;

  /// No description provided for @qdBasmalahLatin.
  ///
  /// In id, this message translates to:
  /// **'Bismillaahir Rahmaanir Raheem'**
  String get qdBasmalahLatin;

  /// No description provided for @qdBasmalahTranslation.
  ///
  /// In id, this message translates to:
  /// **'Dengan menyebut nama Allah Yang Maha Pemurah lagi Maha Penyayang.'**
  String get qdBasmalahTranslation;

  /// No description provided for @qpPlay.
  ///
  /// In id, this message translates to:
  /// **'Putar'**
  String get qpPlay;

  /// No description provided for @qpNowPlaying.
  ///
  /// In id, this message translates to:
  /// **'QS {surah} : {ayah}'**
  String qpNowPlaying(String surah, int ayah);
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id', 'ms', 'tr'].contains(locale.languageCode);

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
    case 'ms':
      return AppL10nMs();
    case 'tr':
      return AppL10nTr();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

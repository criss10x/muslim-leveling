// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppL10nId extends AppL10n {
  AppL10nId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Muslim Leveling';

  @override
  String get tabHome => 'Beranda';

  @override
  String get tabJadwal => 'Jadwal';

  @override
  String get tabQuran => 'Al-Quran';

  @override
  String get localeSystem => 'Ikut Sistem (HP)';

  @override
  String get localeTitle => 'Bahasa aplikasi';

  @override
  String get localeIndonesian => 'Bahasa Indonesia';

  @override
  String get localeEnglish => 'English';

  @override
  String get localePicked => 'Bahasa dipilih';

  @override
  String get settingLanguage => 'Bahasa';
}

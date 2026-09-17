// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Muslim Leveling';

  @override
  String get tabHome => 'Home';

  @override
  String get tabJadwal => 'Schedule';

  @override
  String get tabQuran => 'Quran';

  @override
  String get localeSystem => 'Follow System (Phone)';
}

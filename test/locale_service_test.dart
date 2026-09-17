import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/main.dart';
import 'package:muslim_leveling/services/locale_service.dart';

import 'helpers/app_wrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('default ikut HP: override null saat prefs kosong', () async {
    await localeNotifier.load();
    expect(localeNotifier.override, isNull);
  });

  test('setLocale menyimpan pilihan, load berikutnya memulihkannya', () async {
    await localeNotifier.setLocale(const Locale('en'));
    expect(localeNotifier.override, const Locale('en'));

    await localeNotifier.load();
    expect(localeNotifier.override, const Locale('en'));
  });

  test('kembali ke "ikut HP" menghapus prefs, bukan menyimpan sentinel', () async {
    await localeNotifier.setLocale(const Locale('id'));
    await localeNotifier.setLocale(null);
    expect(localeNotifier.override, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), isNull);
  });

  test('kode bahasa tak dikenal → ikut HP, bukan crash', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'zz'});
    await localeNotifier.load();
    expect(localeNotifier.override, isNull);
  });

  test('en lebih dulu di supported: HP Jepang dapat English, bukan Indonesia',
      () {
    expect(LocaleNotifier.supported.first, const Locale('en'));
  });

  testWidgets('MaterialApp app punya delegate l10n dan locale null (ikut HP)',
      (tester) async {
    await tester.pumpWidget(const MuslimLevelingApp());
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.localizationsDelegates, contains(AppL10n.delegate));
    expect(app.supportedLocales, LocaleNotifier.supported);
    // null = ikut bahasa HP. Kalau ini jadi non-null, default "ikut HP" rusak.
    expect(app.locale, isNull);
  });

  testWidgets('appWrap default id, dan bisa dipaksa en', (tester) async {
    await tester.pumpWidget(appWrap(const SizedBox()));
    expect(
      AppL10n.of(tester.element(find.byType(SizedBox))).localeName,
      'id',
    );

    await tester.pumpWidget(
      appWrap(const SizedBox(), locale: const Locale('en')),
    );
    expect(
      AppL10n.of(tester.element(find.byType(SizedBox))).localeName,
      'en',
    );
  });
}

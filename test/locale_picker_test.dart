import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/services/locale_service.dart';
import 'package:muslim_leveling/widgets/locale_picker.dart';

import 'helpers/app_wrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await localeNotifier.setLocale(null);
  });

  testWidgets('sheet menawarkan ikut HP + SETIAP bahasa di supported',
      (tester) async {
    await tester.pumpWidget(
      appWrap(const LocalePicker(), locale: const Locale('id')),
    );

    expect(find.text('Ikut Sistem (HP)'), findsOneWidget);
    // Daftar dibaca dari LocaleNotifier.supported, bukan disalin ke tes —
    // menambah bahasa tidak boleh membuat tes ini merah.
    for (final locale in LocaleNotifier.supported) {
      expect(
        find.text(LocaleNotifier.labelFor(
            lookupAppL10n(const Locale('id')), locale)),
        findsOneWidget,
        reason: 'baris ${locale.languageCode} hilang dari picker',
      );
    }
  });

  testWidgets('label bahasa ikut bahasa aktif (tr → Türkçe juga)', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWrap(const LocalePicker(), locale: const Locale('tr')),
    );
    expect(find.text('Türkçe'), findsOneWidget);
    expect(find.text('Bahasa Melayu'), findsOneWidget);
  });

  testWidgets('tap English → override en dan prefs tersimpan', (tester) async {
    await tester.pumpWidget(
      appWrap(const LocalePicker(), locale: const Locale('id')),
    );

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(localeNotifier.override, const Locale('en'));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'en');
  });

  testWidgets('label ikut bahasa aktif: locale en → "Follow System (Phone)"',
      (tester) async {
    await tester.pumpWidget(
      appWrap(const LocalePicker(), locale: const Locale('en')),
    );

    expect(find.text('Follow System (Phone)'), findsOneWidget);
    expect(find.text('Ikut Sistem (HP)'), findsNothing);
  });
}

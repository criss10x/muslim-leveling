import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/services/locale_service.dart';
import 'package:muslim_leveling/widgets/locale_picker.dart';

import 'helpers/app_wrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await localeNotifier.setLocale(null);
  });

  testWidgets('sheet menawarkan 3 pilihan: ikut HP, Indonesia, English',
      (tester) async {
    await tester.pumpWidget(
      appWrap(const LocalePicker(), locale: const Locale('id')),
    );

    expect(find.text('Ikut Sistem (HP)'), findsOneWidget);
    expect(find.text('Bahasa Indonesia'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
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

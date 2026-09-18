import 'package:flutter/material.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

/// Guard dual bahasa untuk tab Home.
///
/// Alasan tes ini ada: 282 tes lain memakai `appWrap` dengan locale default
/// `id`, jadi mereka SEMUA hijau walaupun teks English salah atau lupa
/// dipasang. Tanpa tes ini, "Home sudah dual bahasa" cuma klaim.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
  });

  Future<void> pumpHome(WidgetTester t, Locale locale) async {
    await t.pumpWidget(appWrap(Scaffold(body: HomeTab()), locale: locale));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Home render Indonesia saat locale id', (t) async {
    await pumpHome(t, const Locale('id'));

    expect(find.text('RITUAL HARI INI'), findsOneWidget);
    await t.scrollUntilVisible(find.text('AKSES CEPAT'), 200);
    expect(find.text('AKSES CEPAT'), findsOneWidget);
  });

  testWidgets('Home render English saat locale en', (t) async {
    await pumpHome(t, const Locale('en'));

    expect(find.text("TODAY'S RITUALS"), findsOneWidget);
    await t.scrollUntilVisible(find.text('QUICK ACCESS'), 200);
    expect(find.text('QUICK ACCESS'), findsOneWidget);
    expect(find.text('Reflection'), findsWidgets);
    // Bahasa Indonesia tidak boleh bocor ke layar English.
    expect(find.text('AKSES CEPAT'), findsNothing);
    expect(find.text('Renungan'), findsNothing);
  });

  testWidgets('nama & keterangan bonus quest ikut bahasa', (t) async {
    await pumpHome(t, const Locale('en'));
    await t.scrollUntilVisible(find.textContaining('BONUS QUEST'), 200);
    await t.ensureVisible(find.byIcon(AppIcons.expandMore));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(AppIcons.expandMore));
    await t.pumpAndSettle();

    expect(find.text('Sunnah encouraged in the morning'), findsOneWidget);
    expect(find.text('Sunnah malam (qiyamul lail)'), findsNothing);
  });

  testWidgets('hint terkunci juga ikut bahasa', (t) async {
    // Subuh belum masuk waktu (default timings 04:42, jam tes 00:00).
    final en = GameService.wajibLockHint(
      'subuh',
      GameService.current.timings,
      lookupAppL10n(const Locale('en')),
    );
    final id = GameService.wajibLockHint(
      'subuh',
      GameService.current.timings,
      lookupAppL10n(const Locale('id')),
    );

    expect(en, isNot(id));
    expect(en.toLowerCase(), isNot(contains('belum')));
  });
}

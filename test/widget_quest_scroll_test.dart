import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/widget_link.dart';
import 'helpers/app_wrap.dart';

/// Tap widget home screen harus benar-benar membawa user ke daftar quest.
///
/// Ini bukan formalitas: percobaan pertama dengan `Scrollable.ensureVisible`
/// hijau tanpa error tapi offset tetap 0.0, karena `ListView` belum membangun
/// section quest yang ada jauh di bawah. Tes ini mengukur offset, jadi versi
/// yang "tidak crash tapi juga tidak menggulir" akan gagal di sini.
void main() {
  setUp(() {
    WidgetLink.reset();
  });

  testWidgets('permintaan widget menggulir ke daftar quest', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await GameService.load();
    await GameService.runDailyCheck(); // isi quest supaya sectionnya ada

    await tester.pumpWidget(appWrap(const HomeTab()));
    await tester.pump(const Duration(milliseconds: 100));

    final ctl = tester.widget<ListView>(find.byType(ListView)).controller!;
    expect(ctl.offset, 0.0, reason: 'posisi awal harus di atas');

    WidgetLink.requestQuests();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(ctl.offset, greaterThan(0.0), reason: 'harus menggulir ke bawah');
    expect(WidgetLink.pending, 0, reason: 'permintaan harus dikonsumsi');
    expect(tester.takeException(), isNull);
  });

  testWidgets('permintaan kedua tetap dilayani (bukan sekali seumur app)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await GameService.load();
    await GameService.runDailyCheck();
    await tester.pumpWidget(appWrap(const HomeTab()));
    await tester.pump(const Duration(milliseconds: 100));

    final ctl = tester.widget<ListView>(find.byType(ListView)).controller!;

    WidgetLink.requestQuests();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final pertama = ctl.offset;
    expect(pertama, greaterThan(0.0));

    // User menggulir balik ke atas, lalu menekan widget lagi.
    ctl.jumpTo(0);
    await tester.pump();
    WidgetLink.requestQuests();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(ctl.offset, greaterThan(0.0), reason: 'permintaan kedua harus jalan');
    expect(WidgetLink.pending, 0);
  });

  testWidgets('tanpa permintaan, Home tidak menggulir sendiri', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await GameService.load();
    await GameService.runDailyCheck();
    await tester.pumpWidget(appWrap(const HomeTab()));
    await tester.pump(const Duration(milliseconds: 500));

    final ctl = tester.widget<ListView>(find.byType(ListView)).controller!;
    expect(ctl.offset, 0.0);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/screens/naik_level_screen.dart';
import 'package:muslim_leveling/services/game_service.dart';

import 'helpers/app_wrap.dart';

/// Bukti end-to-end: locale `en` benar-benar merender teks English di UI,
/// bukan cuma di jembatan ARB. Tes jembatan (l10n_arb_parity_test) bisa hijau
/// sementara layarnya masih Indonesia kalau ada call site yang lupa diubah —
/// itulah yang dijaga di sini.
///
/// CATATAN pump: kedua layar ini punya Entrance (Future.delayed, itu TIMER) dan
/// ConfettiBurst (AnimationController finite). Kalau tes berakhir sebelum
/// keduanya kelar, `flutter_test` gagal dengan `!timersPending` — bukan karena
/// logikanya salah. Karena itu dipakai [drain], bukan `pumpAndSettle`:
/// DashboardShell punya animasi fireflies yang tak pernah berhenti, jadi
/// pumpAndSettle bisa timeout.
Future<void> drain(WidgetTester t) async {
  for (var i = 0; i < 12; i++) {
    await t.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
    GameService.setTestNow('11:00');
    await GameService.load();
  });
  tearDown(() => GameService.setTestNow(null));

  testWidgets('locale en: daftar quest di Home pakai English', (t) async {
    await t.pumpWidget(
      appWrap(Scaffold(body: HomeTab()), locale: const Locale('en')),
    );
    await t.pump();

    // Header DAILY QUEST ada di bawah viewport → harus di-scroll dulu,
    // sama seperti home_bonus_quest_collapse_test.
    await t.scrollUntilVisible(find.text('DAILY QUEST'), 200);

    // Judul section sudah lama dari ARB; ini kontrol bahwa locale-nya aktif.
    expect(find.text('DAILY QUEST'), findsOneWidget);
    expect(find.text('QUEST HARIAN'), findsNothing);
    expect(find.text('OBLIGATORY QUEST'), findsWidgets);

    // Desc quest = yang baru dilokalisasi. Kalau salah satu call site lupa
    // diubah, teks Indonesia aslinya masih muncul di tree.
    final l10nEn = lookupAppL10n(const Locale('en'));
    for (final q in GameService.generateQuestPool()) {
      final en = q.localizedDesc(l10nEn);
      if (en == q.desc) continue; // teksnya memang sama (nama diri)
      expect(
        find.text(q.desc),
        findsNothing,
        reason: 'desc Indonesia "${q.desc}" masih tampil di locale en',
      );
    }

    await drain(t);
  });

  testWidgets('locale en: layar Naik Level pakai English', (t) async {
    await t.pumpWidget(
      appWrap(
        const NaikLevelScreen(
          xpGained: 50,
          levelsGained: 1,
          source: 'Read Quran',
        ),
        locale: const Locale('en'),
      ),
    );
    await t.pump();

    expect(find.text('LEVEL UP!'), findsOneWidget);
    expect(find.text('NAIK LEVEL!'), findsNothing);
    expect(find.text('BACK'), findsOneWidget);
    expect(find.text('KEMBALI'), findsNothing);
    expect(find.text('NEW TITLE'), findsOneWidget);
    expect(find.text('GELAR BARU'), findsNothing);
    expect(find.textContaining('from Read Quran'), findsOneWidget);

    await drain(t);
  });

  testWidgets('locale id: layar Naik Level tetap Indonesia (tak ada regresi)', (
    t,
  ) async {
    await t.pumpWidget(
      appWrap(
        const NaikLevelScreen(
          xpGained: 50,
          levelsGained: 1,
          source: 'Baca Quran',
        ),
      ),
    );
    await t.pump();

    expect(find.text('NAIK LEVEL!'), findsOneWidget);
    expect(find.text('KEMBALI'), findsOneWidget);
    expect(find.text('GELAR BARU'), findsOneWidget);

    await drain(t);
  });
}

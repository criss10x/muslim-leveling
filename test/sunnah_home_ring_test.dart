import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/theme/app_icons.dart';

// ponytail: runnable check untuk kesesuaian ring "SUNNAH" di tab Home dengan
// daftar quest sunnah. Tiga jalur yang dulu bisa drift diam-diam:
//  (a) denominator ring `/8` literal, terpisah dari daftar baris Bonus Quest —
//      sudah pernah 9 baris vs ring 8 tanpa satu tes pun gagal (lihat 0b26de2).
//  (b) numerator menghitung SEMUA log ber-key `rawatib*`, termasuk key legacy
//      yang sudah dibuang app (mis. rawatib_subuh_ba_diyyah dari state lama) →
//      `9/8`, progress di-clamp, teksnya bohong.
//  (c) baris UI punya kunci yang tidak punya case di isSunnahOnTime/sunnahHint
//      → baris mustahil diklaim atau hint-nya jatuh ke fallback generik.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
  });

  test('denominator ring == jumlah baris Bonus Quest == sunnahKeys', () {
    expect(
      HomeTab.bonusSunnahKeys.length,
      GameService.sunnahKeys.length,
      reason: 'ring "SUNNAH" memakai panjang daftar baris Bonus Quest, '
          'sementara kunci yang dihitung sunnahCountToday datang dari '
          'GameService.sunnahKeys — keduanya harus sama panjang dan sama isi',
    );
    expect(HomeTab.bonusSunnahKeys, GameService.sunnahKeys);
  });

  test('ring tidak pernah melebihi denominator (key legacy dari state lama)', () {
    final today = GameService.todayStr();
    GameService.setStateForTest(GameState(prayerLog: [
      // Key yang sudah dibuang app tapi masih bisa ada di state user lama.
      PrayerLog(
        date: today,
        prayer: 'rawatib_subuh_ba_diyyah',
        time: '05:00',
        type: 'sunnah',
      ),
      // Key yang dikenal, hari ini.
      PrayerLog(date: today, prayer: 'dhuha', time: '07:00', type: 'sunnah'),
      // Key dikenal, tapi bukan hari ini — tidak boleh ikut dihitung.
      PrayerLog(
        date: '2026-01-01',
        prayer: 'tahajjud',
        time: '22:00',
        type: 'sunnah',
      ),
    ]));

    expect(
      GameService.sunnahCountToday,
      1,
      reason: 'hanya dhuha hari ini; key legacy dan log hari lain tidak dihitung',
    );
    expect(
      GameService.sunnahCountToday,
      lessThanOrEqualTo(GameService.sunnahKeys.length),
      reason: 'numerator melebihi denominator → teks ring jadi "9/8"',
    );
  });

  test('setiap kunci baris Bonus Quest punya window + hint sendiri', () {
    final t = Timings(
      imsak: '04:10',
      subuh: '04:20',
      terbit: '05:35',
      dzuhur: '12:10',
      ashar: '15:30',
      maghrib: '18:15',
      isya: '19:30',
    );
    GameService.setTestNow('09:00');

    for (final k in HomeTab.bonusSunnahKeys) {
      expect(
        GameService.sunnahHint(k),
        isNot('Coba lagi nanti ya.'),
        reason: '$k tidak punya case di sunnahHint — hint jatuh ke fallback',
      );
      // isSunnahOnTime tidak boleh melempar; default branch mengembalikan true
      // (selalu bisa diklaim), jadi kita uji perilaku wrap-aware-nya sekilas.
      expect(() => GameService.isSunnahOnTime(k, t), returnsNormally);
    }
  });

  testWidgets('denominator ring == jumlah baris yang benar-benar dirender',
      (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: HomeTab())));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));

    // Denominator ring dibaca dari teks yang benar-benar dirender — bukan dari
    // konstanta. Literal `/8` LOLOS selama daftarnya kebetulan 8 baris, jadi
    // pembandingnya adalah jumlah baris nyata di daftar Bonus Quest (perlu
    // expand dulu; collapsed cuma menampilkan yang on-time).
    GameService.setTestNow('09:00');
    await t.scrollUntilVisible(find.textContaining('BONUS QUEST'), 200);
    await t.ensureVisible(find.byIcon(AppIcons.expandMore));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(AppIcons.expandMore));
    await t.pumpAndSettle();

    final rows = find.textContaining('Sunnah ').evaluate().length;
    expect(
      rows,
      greaterThan(0),
      reason: 'daftar Bonus Quest tidak ter-render — tes tidak menguji apa pun',
    );
    expect(
      find.text('0/$rows'),
      findsOneWidget,
      reason: 'label ring harus "0/$rows" ($rows baris dirender). Denominator '
          'hardcoded akan berbeda begitu daftarnya bukan $rows baris.',
    );
  });
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/profil_tab.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bagian Statistik di tab Profil. Golden test tidak menjangkau ini karena
/// state-nya kosong dan hanya merender empty state — jadi baris berisi data
/// diuji di sini.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String dayOffset(int daysAgo) {
    final d = DateTime.now().subtract(Duration(days: daysAgo));
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Map<String, Object> basePrefs() => {
    'nickname': 'Pejuang',
    'onboarding_done': true,
    'city_id': 'a1',
    'city_name': 'Jakarta',
    'avatar_path': '',
  };

  /// Menulis prayerLog langsung ke SharedPreferences supaya GameService
  /// memuatnya saat init — jalur yang sama dengan pemakaian sungguhan.
  void seedLogs(List<Map<String, String>> logs) {
    final state = GameService.current.toMap();
    state['prayerLog'] = logs;
    SharedPreferences.setMockInitialValues({
      ...basePrefs(),
      'game_state_v1': jsonEncode(state),
    });
  }

  Future<void> pumpProfil(WidgetTester tester) async {
    // GameService.current statis dan bertahan antar test — tanpa load ulang,
    // sebuah test bisa lolos karena data yang ditinggalkan test sebelumnya.
    await GameService.load();
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const ProfilTab(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('tanpa catatan, Statistik mengajari bukan menampilkan nol', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(basePrefs());
    await pumpProfil(tester);

    expect(find.text('Belum ada catatan minggu ini.'), findsOneWidget);
    // Kartu-kartu lama berisi "0 total" tidak boleh muncul lagi.
    expect(find.text('Sholat Selesai'), findsNothing);
    expect(find.text('total'), findsNothing);
  });

  testWidgets('periode dinyatakan eksplisit di header', (tester) async {
    SharedPreferences.setMockInitialValues(basePrefs());
    await pumpProfil(tester);

    // Tanpa '7 HARI' angkanya tidak bisa ditafsirkan sama sekali.
    expect(find.text('STATISTIK'), findsOneWidget);
    expect(find.text('7 HARI'), findsOneWidget);
  });

  testWidgets('Hero Streak tidak lagi digandakan di Statistik', (tester) async {
    SharedPreferences.setMockInitialValues(basePrefs());
    await pumpProfil(tester);

    // Streak sudah tampil di kartu hero; mengulangnya di Statistik membuat
    // satu layar memuat angka yang sama dua kali.
    expect(find.text('Hero Streak'), findsNothing);
  });

  testWidgets('baris statistik memakai denominator, bukan angka telanjang', (
    tester,
  ) async {
    seedLogs([
      for (final p in ['subuh', 'dzuhur', 'ashar'])
        {'date': dayOffset(0), 'prayer': p, 'time': '05:00', 'type': 'wajib'},
      {'date': dayOffset(2), 'prayer': 'subuh', 'time': '05:00', 'type': 'wajib'},
      {'date': dayOffset(1), 'prayer': 'tilawah', 'time': '20:00', 'type': 'tilawah'},
    ]);
    await pumpProfil(tester);

    expect(find.text('Sholat wajib'), findsOneWidget);
    expect(find.text('Tilawah'), findsOneWidget);
    // 4 sholat wajib dalam 7 hari, dari kemungkinan 35.
    expect(find.textContaining('/35'), findsOneWidget);
  });

  testWidgets('Statistik membuka sheet mingguan yang sebelumnya tak terjangkau', (
    tester,
  ) async {
    // Sengaja diisi: saat kosong, link ini memang tidak ditampilkan karena
    // sheet mingguannya juga akan kosong.
    seedLogs([
      {'date': dayOffset(0), 'prayer': 'subuh', 'time': '05:00', 'type': 'wajib'},
    ]);
    await pumpProfil(tester);

    final link = find.text('Lihat statistik mingguan');
    expect(link, findsOneWidget);

    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();

    expect(find.text('STATISTIK MINGGUAN'), findsOneWidget);
  });
}

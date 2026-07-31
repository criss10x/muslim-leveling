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

    expect(find.text('Belum ada catatan.'), findsOneWidget);
    // Kartu-kartu lama berisi "0 total" tidak boleh muncul lagi.
    expect(find.text('Sholat Selesai'), findsNothing);
    expect(find.text('total'), findsNothing);
  });

  testWidgets('angka lifetime, bukan jendela mingguan', (tester) async {
    // Catatan jauh di luar 7 hari terakhir harus tetap terhitung — inilah
    // pembeda total seumur pakai dari jendela mingguan.
    seedLogs([
      {'date': dayOffset(200), 'prayer': 'subuh', 'time': '05:00', 'type': 'wajib'},
      {'date': dayOffset(120), 'prayer': 'dzuhur', 'time': '12:00', 'type': 'wajib'},
      {'date': dayOffset(0), 'prayer': 'ashar', 'time': '15:00', 'type': 'wajib'},
    ]);
    await pumpProfil(tester);

    expect(find.text('3'), findsWidgets);
    // Header tidak lagi mengklaim periode 7 hari.
    expect(find.text('STATISTIK'), findsOneWidget);
    expect(find.text('7 HARI'), findsNothing);
  });

  testWidgets('total lifetime diberi keterangan sejak kapan', (tester) async {
    seedLogs([
      {'date': '2026-03-12', 'prayer': 'subuh', 'time': '05:00', 'type': 'wajib'},
      {'date': dayOffset(0), 'prayer': 'dzuhur', 'time': '12:00', 'type': 'wajib'},
    ]);
    await pumpProfil(tester);

    // "Total" tanpa titik mulai tidak bisa ditafsirkan.
    expect(find.text('Sejak 12 Maret 2026'), findsOneWidget);
  });

  testWidgets('Hero Streak tidak lagi digandakan di Statistik', (tester) async {
    SharedPreferences.setMockInitialValues(basePrefs());
    await pumpProfil(tester);

    // Streak sudah tampil di kartu hero; mengulangnya di Statistik membuat
    // satu layar memuat angka yang sama dua kali.
    expect(find.text('Hero Streak'), findsNothing);
  });

  testWidgets('angka besar diberi pemisah ribuan', (tester) async {
    seedLogs([
      for (var i = 0; i < 1247; i++)
        {
          'date': dayOffset(i % 300),
          'prayer': 'subuh',
          'time': '05:00',
          'type': 'wajib',
        },
    ]);
    await pumpProfil(tester);

    expect(find.text('Sholat wajib'), findsOneWidget);
    // "1247" jauh lebih lambat dibaca daripada "1.247".
    expect(find.text('1.247'), findsOneWidget);
  });

  testWidgets('golden: Statistik dengan total lifetime', (tester) async {
    // Sebaran panjang, bukan seminggu: totalnya harus terlihat seperti
    // akumulasi berbulan-bulan, termasuk angka empat digit.
    final logs = <Map<String, String>>[];
    for (var i = 0; i < 1247; i++) {
      logs.add({
        'date': dayOffset(i % 280),
        'prayer': GameService.wajibList[i % 5],
        'time': '05:00',
        'type': 'wajib',
      });
    }
    for (var i = 0; i < 386; i++) {
      logs.add({
        'date': dayOffset(i % 280),
        'prayer': 'rawatib_subuh',
        'time': '05:10',
        'type': 'sunnah',
      });
    }
    for (var i = 0; i < 92; i++) {
      logs.add({
        'date': dayOffset(i % 280),
        'prayer': 'tilawah',
        'time': '20:00',
        'type': 'tilawah',
      });
    }

    seedLogs(logs);
    await pumpProfil(tester);

    await expectLater(
      find.byKey(const Key('profil-stats-card')),
      matchesGoldenFile('goldens/profil_stats_populated.png'),
    );
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

    final link = find.text('Mingguan');
    expect(link, findsOneWidget);

    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();

    expect(find.text('STATISTIK MINGGUAN'), findsOneWidget);
  });
}

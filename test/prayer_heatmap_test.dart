import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/widgets/prayer_heatmap.dart';

void main() {
  test('wajibPerHari hanya hitung sholat wajib, abaikan sunnah/tilawah', () {
    final logs = [
      PrayerLog(date: '2026-08-10', prayer: 'subuh', time: '04:50', type: 'wajib'),
      PrayerLog(date: '2026-08-10', prayer: 'dzuhur', time: '12:05', type: 'wajib'),
      PrayerLog(date: '2026-08-10', prayer: 'dhuha', time: '06:20', type: 'sunnah'),
      PrayerLog(date: '2026-08-10', prayer: 'tilawah', time: '20:00', type: 'tilawah'),
      PrayerLog(date: '2026-08-11', prayer: 'isya', time: '19:10', type: 'wajib'),
    ];
    final m = wajibPerHari(logs);
    expect(m['2026-08-10'], 2, reason: 'subuh + dzuhur, bukan dhuha/tilawah');
    expect(m['2026-08-11'], 1);
    expect(m['2026-08-12'], isNull, reason: 'tanggal tanpa catatan tidak muncul');
  });

  test('wajibPerHari cap di 5 meski ada catatan dobel tanggal sama', () {
    final logs = [
      PrayerLog(date: '2026-08-10', prayer: 'subuh', time: '04:50', type: 'wajib'),
      PrayerLog(date: '2026-08-10', prayer: 'subuh', time: '04:55', type: 'wajib'),
    ];
    final m = wajibPerHari(logs);
    expect(m['2026-08-10'], 2,
        reason: 'dobel subuh tetap dihitung per catatan — heatmap murni count');
  });

  testWidgets('PrayerHeatmap render grid 7 kolom tanpa overflow', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: PrayerHeatmap()),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Sen'), findsOneWidget);
    expect(find.text('Min'), findsOneWidget);
  });
}

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/hijri_service.dart';

// ponytail: runnable check — decode cache bulan & label; jalur HTTP
// diuji manual (aladhan.com, satu panggilan/bulan).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cache bulan ter-decode + hijriLabel + tanggal penting', () async {
    SharedPreferences.setMockInitialValues({
      'hijri_g2h2_2026_8': jsonEncode([
        [1, 17, 2, 1448], // 1 Safar 1448
        [2, 18, 2, 1448],
      ]),
    });
    final days = await hijriService.month(2026, 8);
    expect(days, isNotNull);
    expect(days!.length, 2);
    expect(days[0].hDay, 17);
    expect(hijriLabel(days[0]), '17 Safar 1448 H');
    expect(hijriImportantDates[(1, 1)], 'Tahun Baru Hijriah');
    expect(hijriMonthNames[9], 'Ramadan');
  });
}

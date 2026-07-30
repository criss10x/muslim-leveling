import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/jadwal_tab.dart';
import 'package:muslim_leveling/services/prayer_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    activeThemePreset = AppThemePreset.darkEmerald;
  });

  test('location failure messages identify the blocked step', () {
    expect(
      CurrentLocationFailure.permissionDenied.message,
      'Izinkan akses lokasi untuk menggunakan lokasi saat ini.',
    );
    expect(
      CurrentLocationFailure.serviceDisabled.message,
      'Aktifkan layanan lokasi perangkat, lalu coba lagi.',
    );
  });

  testWidgets('Jadwal header keeps location compact without calendar', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const JadwalTab()),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.my_location), findsOneWidget);
    expect(find.text('Lokasi Saat Ini'), findsNothing);
    expect(find.text('Cari Kota'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month), findsNothing);
    expect(find.text('Kalender'), findsNothing);
  });

  testWidgets('next-prayer name uses light-theme foreground', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    activeThemePreset = AppThemePreset.lightEmerald;
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    SharedPreferences.setMockInitialValues({
      'city_id': '1301',
      'city_name': 'Jakarta',
      'prayer_cache_v2': jsonEncode({
        'cityId': '1301',
        'date': date,
        'timings': {
          'imsak': '04:30',
          'subuh': '04:42',
          'terbit': '05:55',
          'dhuha': '06:20',
          'dzuhur': '12:01',
          'ashar': '15:20',
          'maghrib': '17:55',
          'isya': '19:08',
          'lokasi': 'Jakarta',
        },
      }),
    });

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const JadwalTab()),
    );
    await tester.pumpAndSettle();

    final nextPrayerName = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.style?.fontSize == 32 &&
          const {
            'Subuh',
            'Dzuhur',
            'Ashar',
            'Maghrib',
            'Isya',
          }.contains(widget.data),
    );
    expect(nextPrayerName, findsOneWidget);
    expect(
      tester.widget<Text>(nextPrayerName).style?.color,
      AppColors.onSurface,
    );
  });
}

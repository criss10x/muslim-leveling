import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/jadwal_tab.dart';
import 'package:muslim_leveling/services/prayer_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';

import 'helpers/app_wrap.dart';

void main() {
  /// Fixture kartu jadwal: cache prefs + locale apa pun. Dipakai ulang supaya
  /// tes EN benar-benar merender jalur yang sama dengan tes ID.
  Future<void> pumpJadwal(WidgetTester tester, Locale locale, ThemeData theme) async {
    GoogleFonts.config.allowRuntimeFetching = false;
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
      appWrap(const JadwalTab(), locale: locale, theme: theme),
    );
    await tester.pumpAndSettle();
  }


  tearDown(() {
    activeThemePreset = AppThemePreset.darkEmerald;
  });

  test('location failure messages identify the blocked step', () async {
    // message() sekarang butuh l10n (service tanpa BuildContext), jadi load
    // delegate-nya sungguhan — bukan cek getter statis.
    final l10n = await AppL10n.delegate.load(const Locale('id'));
    expect(
      CurrentLocationFailure.permissionDenied.message(l10n),
      'Izinkan akses lokasi untuk menggunakan lokasi saat ini.',
    );
    expect(
      CurrentLocationFailure.serviceDisabled.message(l10n),
      'Aktifkan layanan lokasi perangkat, lalu coba lagi.',
    );
  });

  testWidgets('Jadwal header keeps location compact, calendar always shown', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      appWrap(const JadwalTab(), theme: AppTheme.dark()),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(AppIcons.myLocation), findsOneWidget);
    expect(find.text('Lokasi Saat Ini'), findsNothing);
    expect(find.text('Cari Kota'), findsOneWidget);
    // Tombol Hari Penting Islam selalu render (fix P1a: tidak di-gate API).
    // Kalau API hijriah gagal, label fallback 'Hari Penting Islam' muncul.
    expect(find.byIcon(AppIcons.calendarMonth), findsOneWidget);
    expect(find.text('Hari Penting Islam'), findsOneWidget);
  });

  testWidgets('next-prayer name uses light-theme foreground', (tester) async {
    activeThemePreset = AppThemePreset.lightEmerald;
    await pumpJadwal(tester, const Locale('id'), AppTheme.light());

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

  testWidgets('tab Jadwal ikut bahasa aktif (locale en)', (tester) async {
    // Keluhan asli: "di tab jadwal masih default bahasa indonesia". Label
    // hardcode dulu membuat tab ini tetap Indonesia walau app sudah EN.
    await pumpJadwal(tester, const Locale('en'), AppTheme.dark());

    expect(find.text('Prayer Times'), findsOneWidget);
    expect(find.text('Search City'), findsOneWidget);
    expect(find.text("TODAY'S SCHEDULE"), findsOneWidget);
    expect(find.text('NEXT PRAYER'), findsOneWidget);
    // Nama sholat juga harus Inggris, bukan sisa literal.
    expect(find.text('Subuh'), findsNothing);
    expect(find.text('Dzuhur'), findsNothing);
    expect(find.text('Fajr'), findsWidgets);
  });

  testWidgets('tab Jadwal tetap Indonesia untuk locale id', (tester) async {
    await pumpJadwal(tester, const Locale('id'), AppTheme.dark());

    expect(find.text('Waktu Sholat'), findsOneWidget);
    expect(find.text('Cari Kota'), findsOneWidget);
    expect(find.text('JADWAL HARI INI'), findsOneWidget);
    expect(find.text('Subuh'), findsWidgets);
  });

  testWidgets('nama bulan di header ikut locale', (tester) async {
    // Dulu 12 nama bulan + 7 nama hari ditulis manual dalam Indonesia.
    await pumpJadwal(tester, const Locale('en'), AppTheme.dark());
    final now = DateTime.now();
    const enMonths = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    expect(find.textContaining(enMonths[now.month - 1]), findsOneWidget);
    expect(find.textContaining('Januari'), findsNothing);
  });
}

// Regresi halaman 5 (lokasi): user yang menolak/mati GPS tidak boleh terjebak.
//
// Dulu: `_allowLocation` cuma menampilkan SnackBar yang hilang sendiri, tombol
// tetap "Izinkan Lokasi", dan setelah permanent-deny Android tidak memunculkan
// dialog lagi → dinding mati di langkah 5 dari 6.
//
// Sekarang: alasan ditahan di layar, jalur manual naik jadi aksi utama, dan
// ada tombol keluar yang jujur ("pakai kota default dulu").
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/screens/onboarding_screen.dart';

import 'helpers/app_wrap.dart';

const _geoChannel = MethodChannel('flutter.baseflow.com/geolocator');

/// Matikan layanan lokasi → getCurrentLocation() balik serviceDisabled.
void _mockLocationOff(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(_geoChannel,
      (call) async {
    if (call.method == 'isLocationServiceEnabled') return false;
    return null;
  });
}

Future<void> _toPage5(WidgetTester tester) async {
  final pv = tester.widget<PageView>(find.byType(PageView));
  pv.controller!.jumpToPage(4);
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('GPS mati: alasan tampil di layar, jalur manual jadi utama',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    _mockLocationOff(tester);
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(_geoChannel, null));

    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await _toPage5(tester);

    // Sebelum gagal: CTA utama minta izin, jalur manual jadi sekunder.
    expect(find.text('Izinkan Lokasi'), findsOneWidget);
    expect(find.text('PILIH KOTA MANUAL'), findsOneWidget);

    await tester.tap(find.text('Izinkan Lokasi'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Sesudah gagal: alasan ditahan di layar (bukan SnackBar), CTA utama
    // berpindah ke jalur yang pasti berhasil, "Coba lagi" jadi sekunder.
    expect(find.text('Izinkan Lokasi'), findsNothing,
        reason: 'tombol yang dialognya sudah tidak muncul lagi harus diganti');
    // Jalur manual naik jadi HeroButton (label apa adanya, tidak uppercase);
    // "Coba lagi" turun jadi GhostButton (uppercase).
    expect(find.text('Pilih kota manual'), findsOneWidget);
    expect(find.text('COBA LAGI'), findsOneWidget);
    expect(
      find.textContaining('lokasi', findRichText: true),
      findsWidgets,
      reason: 'alasan gagal harus terbaca di layar',
    );
    // Jalan keluar jujur selalu tersedia.
    expect(find.text('PAKAI KOTA DEFAULT DULU'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tombol keluar lokasi benar-benar maju ke halaman 6',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    _mockLocationOff(tester);
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(_geoChannel, null));

    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await _toPage5(tester);

    await tester.tap(find.text('PAKAI KOTA DEFAULT DULU'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Pengingat Adzan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

// Regresi dua bug halaman 5 onboarding:
//
// 1. Buntu setelah pilih kota manual. Urutan "GPS gagal → pilih kota manual"
//    dulu berakhir tanpa jalan maju: `_pickCity` tidak membersihkan `_locError`,
//    dan cabang CTA digerakkan `_locError != null` → tombol tetap "Pilih kota
//    manual", "Lanjut" tak pernah muncul. User terjebak di langkah 5 dari 6
//    justru setelah melakukan hal yang benar.
//
// 2. Offline disalahartikan "kota tidak ditemukan". `citiesForProvince`
//    mengembalikan [] untuk kegagalan koneksi DAN untuk provinsi kosong, jadi
//    user offline disuruh "coba pilih provinsi lain" selamanya.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:muslim_leveling/services/prayer_service.dart';
import 'package:muslim_leveling/widgets/city_picker.dart';

import 'helpers/app_wrap.dart';
import 'helpers/mock_equran.dart';

const _geoChannel = MethodChannel('flutter.baseflow.com/geolocator');

/// Layanan lokasi mati → `getCurrentLocation()` balik serviceDisabled.
void _mockLocationOff(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(_geoChannel,
      (call) async {
    if (call.method == 'isLocationServiceEnabled') return false;
    return null;
  });
}

Future<void> _settle(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _toPage5(WidgetTester tester) async {
  final pv = tester.widget<PageView>(find.byType(PageView));
  pv.controller!.jumpToPage(4);
  await _settle(tester, 700);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    // Sekali saja: PrayerService._discoveryClient adalah static final, jadi ia
    // mengunci HttpOverrides yang aktif saat pertama diakses.
    installMockEquran();
  });

  testWidgets('GPS gagal → pilih kota manual → "Lanjut" muncul dan maju',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    _mockLocationOff(tester);
    mockEquranCities({
      'Bali': ['Kab. Badung', 'Kota Denpasar'],
    });
    addTearDown(() =>
        tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(_geoChannel, null));

    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await _settle(tester, 900);
    await _toPage5(tester);

    // 1) GPS gagal → alasan tampil, jalur manual jadi CTA utama.
    await tester.tap(find.text('Izinkan Lokasi'));
    await _settle(tester, 1000);
    expect(find.text('Pilih kota manual'), findsOneWidget,
        reason: 'setelah gagal, jalur manual harus jadi aksi utama');
    expect(find.text('Lanjut'), findsNothing);

    // 2) Pilih kota manual yang BERHASIL (network hidup via mock).
    await tester.tap(find.text('Pilih kota manual'));
    await _settle(tester, 500);
    await tester.enterText(find.byType(TextField), 'bali');
    await _settle(tester, 300);
    await tester.tap(find.text('Bali'));
    await _settle(tester, 500);
    await tester.tap(find.text('Kota Denpasar'));
    await _settle(tester, 700);

    // 3) INTI BUG: kota sudah terisi → "Lanjut" wajib muncul.
    expect(find.text('Kota Denpasar'), findsOneWidget,
        reason: 'kota terpilih harus tampil sebagai konfirmasi');
    expect(find.text('Lanjut'), findsOneWidget,
        reason: 'setelah kota terpilih, CTA maju wajib ada — ini bug buntu');
    expect(find.text('Pilih kota manual'), findsNothing,
        reason: 'jalur manual tidak relevan lagi setelah kota terisi');

    // 4) Benar-benar maju ke halaman 6.
    await tester.tap(find.text('Lanjut'));
    await _settle(tester, 900);
    expect(find.text('Pengingat Adzan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('offline vs provinsi kosong: hasilnya harus bisa dibedakan', () async {
    mockEquranOffline();
    SharedPreferences.setMockInitialValues({});
    final offline = await PrayerService.citiesForProvince('Jawa Barat');
    expect(offline, isNull,
        reason: 'kegagalan koneksi harus null, bukan [] — '
            '[] berarti "provinsi ini memang kosong"');

    mockEquranCities({'Bali': ['Kota Denpasar']});
    final kosong = await PrayerService.citiesForProvince('Provinsi Antah');
    expect(kosong, isEmpty,
        reason: 'provinsi tanpa kota menjawab [], bukan null');
  });

  testWidgets('pemilih kota membedakan pesan offline dari provinsi kosong',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    mockEquranOffline();

    await tester.pumpWidget(appWrap(
      Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => CityPicker.show(ctx),
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('buka'));
    await _settle(tester, 500);
    await tester.enterText(find.byType(TextField), 'bali');
    await _settle(tester, 300);
    await tester.tap(find.text('Bali'));
    await _settle(tester, 900);

    expect(find.textContaining('Periksa koneksi'), findsOneWidget,
        reason: 'offline harus menyebut koneksi, bukan menyalahkan provinsi');
    expect(find.textContaining('Coba pilih provinsi lain'), findsNothing,
        reason: 'menyarankan ganti provinsi saat offline = menyesatkan');
    expect(find.text('Coba lagi'), findsOneWidget,
        reason: 'harus ada jalan pulang tanpa menutup dialog');

    // "Coba lagi" benar-benar memuat ulang, bukan tombol mati.
    mockEquranCities({'Bali': ['Kab. Badung', 'Kota Denpasar']});
    await tester.tap(find.text('Coba lagi'));
    await _settle(tester, 900);
    expect(find.text('Kab. Badung'), findsOneWidget,
        reason: 'setelah koneksi pulih, daftar kota harus muncul');
    expect(tester.takeException(), isNull);
  });
}

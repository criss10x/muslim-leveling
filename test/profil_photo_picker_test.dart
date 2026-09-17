// ponytail: penjaga untuk "ganti foto profil".
// 1) Foto non-persegi TIDAK boleh dipaksa jadi kotak oleh decode. Kalau
//    cacheWidth DAN cacheHeight diisi, ResizeImage (policy exact) meraster
//    ulang sumber ke kotak → aspek hilang sebelum BoxFit.cover kebagian,
//    foto terlihat "penyet". Diukur dari piksel PNG hasil render.
// 2) Tap avatar sendiri = ubah foto (pola Strava), badge kamera sebagai
//    affordance, dan emoji tidak lagi dipakai di chrome.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/profil_tab.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:muslim_leveling/widgets/tier_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/app_wrap.dart';

/// 400x300 (4:3) dengan lingkaran putih di tengah. Rasio sumber != 1
/// supaya stretch terdeteksi sebagai elips.
const _photoB64 =
    'iVBORw0KGgoAAAANSUhEUgAAAZAAAAEsCAIAAABi1XKVAAAEl0lEQVR42u3csbGzOhCAUcvjOhRR'
    'lSIqoBJFVEBhFOMKTCCwkdbn5C/Rrj7hO/+8lGt5AIzg6QgAwQIQLECwAAQLQLAAwQIQLADBAgQL'
    'QLAABAsQLADBAhAsQLAABAtAsADBAhAsAMECBAtAsAAECxAsAMECECxAsAAECxAsAMECECxAsAAE'
    'C0CwAMECECwAwQIEC0CwAAQLECwAwQIQLECwAAQLQLAAwQIQLIBPXo6AZvuytf2H0zo7PRqkXItT'
    '4EthEjIEiziF0i8Ei4EjJV4IFqN2SrkQLMbrlHIhWDoVgXIJFlIlWwgWOqVcCBZSJVuChVTJFoKF'
    'VMkWgiVVyJZgIVWyxc3872XUyonhCwsXz6cWgoVUyZafhKiV80SwcLucKn4SulT4eegLC7VyzggW'
    'bpHTxk9Clwc/D31hoVbOH8HCbTEFBMs9wSwECzfERBAs3A1zQbDcCkxHsHAfzAjBchMwKQTLHcC8'
    'BAvbb2oIlr3H7BAsG48JChZ23RwRLFuOaSJY9hszFSwAwfIUY7IIlp3GfAUL22zKCBYgWI7Aw4tZ'
    'CxY22MQRLLuLuQsWgGB5ZjF9BAsQLDyw2AHBsqnYBAQLECw8qtgHwQIQLM8ptkKwAATLQ4rdQLAA'
    'wcITig0RLADB8nhiTwQLQLAABMt3PrZFsAAEy4OJnUGwAMECECzf9tgcBAsQLADB8lWP/REsAMEC'
    'ECzf89giwQIQLADBAgSLQ/70gF0SLADBAgQLQLAABOsK/kqKjRIsAMECBAtAsAAECxAsAMECEKwT'
    '/JMZ7JVgAQgWIFgAggUgWIBgAQgWgGABggUgWACCBQgWgGABCBYgWACCBQgWgGABCNYNpnV2CNgr'
    'wQIQLECwAAQLQLAAwQIQLADBOsc/mcFGCRaAYAGCBSBYAIJ1HX8lxS4JFoBgAYIFIFgD8KcHbJFg'
    'AQgWIFi+58H+CBaAYAGC5asebI5gAQgWIFi+7cHOCBaAYHkwsS2CBSBYgGDhOx97IlgAguXxxIYI'
    'FoBgeUKxGwgWIFh4SLEVggUgWJ5T7INgAQiWRxWbgGDZVOyAYAEIlgcW00ewAMHCM4u5C5bdxcQR'
    'LBuMWQsWgGB5eDFlBMs2Y76ChZ02WQQLQLA8xZipYGG/TRPBsuWYI4Jl1zFBwcLGmx2CZe8xNcHC'
    '9mNegoU7YFIIlpuAGQkW7gOmI1i4FeaCYLkbmIhg4YaYhVkIFu6JKSBYbgvOP7aUa3EKPduXzSFI'
    'Fb6w3B+ctmDhFjln/CTEz0Op8oWFe+VUESzcLueJn4T4eShVgoVsSRV+EuLuOTF8YeFTS6oEC9mS'
    'KgQL2ZIqBAvZkirBQrakCsFCuXQKweIPsyVVgoVy6RSChXLpFIJF7HLpFIJF1/ESKQSLfvulUAgW'
    '3YVMmBAsIDj/exlAsAAECxAsAMECECxAsAAEC0CwAMECECwAwQIEC0CwAAQLECwAwQIQLECwAAQL'
    'QLAAwQIQLADBAgQLQLAABAsQLADBAgTLEQCCBSBYgGABCBaAYAGCBSBYAIIFCBaAYAEIFiBYAIIF'
    'IFiAYAEIFoBgAYIF8HtvpEqL1nwhxRIAAAAASUVORK5CYII=';

/// Tulis file uji. WAJIB sync: async I/O di dalam body testWidgets tidak
/// pernah selesai (zona fake-async) → file kosong → "Invalid image data".
File _photo() {
  final f = File('/tmp/avatar_aspect_400x300.png');
  if (!f.existsSync()) {
    f.writeAsBytesSync(base64Decode(_photoB64));
  }
  return f;
}

/// Parameter decode nyata yang dipakai avatar (dari ResizeImage provider).
/// Inilah objek yang menentukan raster sebelum BoxFit.cover kebagian.
({int? width, int? height}) _decodeParams(WidgetTester tester) {
  final widget = tester.widget<Image>(
    find.descendant(
      of: find.byType(TierProfileAvatar),
      matching: find.byType(Image),
    ),
  );
  final provider = widget.image;
  if (provider is ResizeImage) {
    return (width: provider.width, height: provider.height);
  }
  return (width: null, height: null);
}

/// Decode ulang byte foto dengan PERSIS parameter yang dipakai widget, lalu
/// balikan dimensi hasilnya. Inilah yang menentukan raster sebelum
/// BoxFit.cover — mengukur widget-nya langsung, bukan menebak.
Future<(int, int)> _decodedSize(
  WidgetTester tester,
  String path,
  int? cacheWidth,
  int? cacheHeight,
) async {
  final bytes = File(path).readAsBytesSync();
  final res = await tester.runAsync<(int, int)>(() async {
    final buf = await ui.ImmutableBuffer.fromUint8List(bytes);
    // Teruskan null apa adanya — Flutter juga begitu. Mengganti null dengan
    // dimensi intrinsik akan MEMAKSA kotak dan merusak aspek palsu.
    final codec = await ui.instantiateImageCodecWithSize(
      buf,
      getTargetSize: (iw, ih) =>
          ui.TargetImageSize(width: cacheWidth, height: cacheHeight),
    );
    final frame = await codec.getNextFrame();
    return (frame.image.width, frame.image.height);
  });
  return res!;
}

void main() {
  testWidgets('foto non-persegi tidak dipaksa jadi kotak saat decode', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1.0;
    final f = _photo();

    await tester.pumpWidget(
      appWrap(Center(
          child: TierProfileAvatar(
            profileImagePath: f.path,
            displayName: 'Pejuang',
            tierName: 'Warrior',
            sizeDp: 88,
          ),
        ), theme: AppTheme.dark()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final params = _decodeParams(tester);
    final (w, h) = await _decodedSize(
      tester,
      f.path,
      params.width,
      params.height,
    );

    // Sumber 400x300 (4:3). Yang benar: rasio tetap 4:3 setelah decode.
    // Kalau cacheHeight ikut diisi (policy exact), hasilnya kotak 1:1.
    expect(
      w / h,
      closeTo(400 / 300, 0.02),
      reason: 'decode merusak aspek: $w x $h dari sumber 400x300',
    );
  });

  testWidgets('badge kamera, bukan emoji, di avatar', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      appWrap(const Center(
          child: TierProfileAvatar(
            displayName: 'Pejuang',
            tierName: 'Warrior',
            sizeDp: 88,
            showEditBadge: true,
          ),
        ), theme: AppTheme.dark()),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('\u{1F4F7}'), findsNothing);
    expect(find.byIcon(AppIcons.camera), findsOneWidget);
  });

  testWidgets('tap avatar membuka sheet foto', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'nickname': 'Pejuang',
      'onboarding_done': true,
      'avatar_path': '',
    });
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      appWrap(const Scaffold(body: ProfilTab()), theme: AppTheme.dark()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byType(TierProfileAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Ambil dari Kamera'), findsOneWidget);
    expect(find.text('Pilih dari Galeri'), findsOneWidget);
    expect(find.text('Edit Nama'), findsNothing);
  });
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/widgets/quran_share_sheet.dart';
import 'package:muslim_leveling/widgets/share_card_kit.dart';

import 'helpers/app_wrap.dart';

/// Rasio tinggi ARTWORK terhadap tinggi BERKAS, diukur dari berkas PNG-nya
/// sendiri — BUKAN dari konstanta produksi.
///
/// Ini penting: versi pertama tes memakai `gpArtworkHeightRatio()` yang sama
/// dengan produksi, sehingga saat fungsinya dibuat salah (satu angka untuk
/// semua berkas) ekspektasi tes ikut salah dan tesnya tetap hijau. Mengukur
/// dari berkas membuat tes ini punya sumber kebenaran sendiri.
Future<double> artworkRatioFromAsset(String asset) async {
  final data = await rootBundle.load(asset);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final h = image.height;
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final px = bytes!.buffer.asUint8List();
  final w = image.width;
  var top = -1, bottom = -1;
  for (var y = 0; y < h; y++) {
    var ink = false;
    for (var x = 0; x < w; x += 5) {
      if (px[(y * w + x) * 4 + 3] > 0) {
        ink = true;
        break;
      }
    }
    if (ink) {
      if (top < 0) top = y;
      bottom = y;
    }
  }
  return (bottom - top + 1) / h;
}

/// Kepatuhan badge "Dapatkan di Google Play".
///
/// Badge lama digambar sendiri dengan Icons.play_arrow + dua baris teks. Itu
/// melanggar aturan badge Google ("jangan ubah warna, proporsi, spasi, atau
/// aspek apa pun") dan bentuknya memang beda: rasio 5,4:1 sementara aset resmi
/// 3,365:1, tinggi artwork turun sampai 15,7dp di kartu 1:1 (ambang Google
/// 28px), dan clear space-nya nol padahal wajib seperempat tinggi badge.
///
/// Yang diuji di sini hanya syarat yang benar-benar bisa diperiksa mesin.
void main() {
  const surah = QuranSurah(
    number: 2,
    nameArabic: 'البقرة',
    nameLatin: 'Al-Baqarah',
    meaning: 'Sapi Betina',
    ayahCount: 286,
    revelation: 'Madaniyah',
  );
  const ayah = QuranAyah(
    ayah: 255,
    arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    translation: 'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup.',
  );

  test('aset resmi ada untuk tiap locale yang didukung app', () async {
    // en/id/tr punya berkasnya sendiri; ms memakai berkas Indonesia (Google
    // tidak menerbitkan badge Melayu, dan byte-nya identik).
    for (final code in ['en', 'id', 'ms', 'tr']) {
      final asset = GooglePlayBadge.assetFor(code);
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(1000),
          reason: 'aset $asset kosong atau tidak terdaftar di pubspec');
    }
    // ms wajib menunjuk berkas yang sama dengan id, bukan berkas yang hilang.
    expect(GooglePlayBadge.assetFor('ms'), GooglePlayBadge.assetFor('id'));
  });

  testWidgets('aset resmi tidak dimodifikasi (ukuran + padding terjaga)',
      (tester) async {
    // Seluruh badan lewat runAsync: instantiateImageCodec dan toByteData
    // menunggu kerja nyata dari engine, dan zona async palsu milik widget test
    // tidak memompanya (test menggantung ~5 menit lalu dibunuh harness).
    for (final asset in ['en', 'id', 'tr']) {
      await tester.runAsync(() async {
        final data = await rootBundle.load('assets/images/gp_badge/$asset.png');
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        final image = frame.image;
        final w = image.width;
        final h = image.height;

      // Ukuran asli aset Google: 646x250 dengan artwork 646x192 (29px
      // transparan atas+bawah). Kalau berkasnya diganti dengan versi yang
      // di-crop atau di-resize, koreksi tinggi di kit jadi salah.
        expect(w, 646, reason: '$asset: lebar aset bukan 646');
        expect(h, 250, reason: '$asset: tinggi aset bukan 250');

        // Artwork (piksel tidak transparan) harus mengisi seluruh lebar dan
        // hanya menyisakan padding vertikal: bukti asetnya tidak dipotong.
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final px = bytes!.buffer.asUint8List();
        var topInk = -1, bottomInk = -1;
        for (var y = 0; y < h; y++) {
          var anyInk = false;
          for (var x = 0; x < w; x += 7) {
            if (px[(y * w + x) * 4 + 3] > 0) {
              anyInk = true;
              break;
            }
          }
          if (anyInk) {
            if (topInk < 0) topInk = y;
            bottomInk = y;
          }
        }
        // Padding berkas diukur dari berkasnya sendiri: en 41px, id/tr 29px.
        final expectedTop = asset == 'en' ? 41 : 29;
        expect(topInk, closeTo(expectedTop, 3),
            reason: '$asset: padding atas aset bukan ~$expectedTop px');
        expect(bottomInk, closeTo(250 - expectedTop - 1, 3),
            reason: '$asset: padding bawah aset tidak simetris');
      });
    }
  });

  testWidgets('artwork minimal 28dp dan ada clear space seperempat tinggi', (
    tester,
  ) async {
    // WAJIB menguji ketiga locale: tiap berkas badge punya padding transparan
    // berbeda (en 41px di semua sisi, id/tr 29px atas-bawah), dan rasio
    // produksi dihitung per berkas. Versi pertama tes ini hanya merender
    // locale default 'id', sehingga bug "en memakai rasio id" tidak pernah
    // tersentuh — terbukti saat kontrol negatifnya lolos.
    for (final (loc, aspect) in [
      ('id', 9 / 16),
      ('id', 1.0),
      ('en', 9 / 16),
      ('en', 1.0),
      ('tr', 9 / 16),
    ]) {
      final name = '$loc/${aspect == 1.0 ? '1x1' : '9x16'}';
      await tester.pumpWidget(
        appWrap(
          Scaffold(
            body: Center(
              child: QSharePreviewCard(
                surah: surah,
                ayah: ayah,
                aspect: aspect,
              ),
            ),
          ),
          locale: Locale(loc),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final badge = tester.getRect(find.byType(GooglePlayBadge));
      final footer = tester.getRect(find.byType(ShareCardFooter));

      // Rasio diukur dari BERKAS yang benar-benar dipakai locale ini, bukan
      // dari konstanta produksi — kalau tidak, tesnya tautologis.
      final ratio = await tester.runAsync(
        () => artworkRatioFromAsset(GooglePlayBadge.assetFor(loc)),
      );
      final artwork = badge.height * ratio!;
      expect(
        artwork,
        greaterThanOrEqualTo(27.5),
        reason:
            '$name: artwork ${artwork.toStringAsFixed(1)}dp di bawah ambang '
            'Google (28px)',
      );

      expect(
        badge.top - footer.top,
        greaterThanOrEqualTo(kPlayBadgeClearSpace - 0.5),
        reason: '$name: badge menempel terlalu dekat ke konten di atasnya',
      );

      // Badge harus tetap proporsional (tidak diregangkan).
      expect(
        badge.width / badge.height,
        closeTo(kPlayBadgeBoxRatio, 0.01),
        reason: '$name: proporsi badge diubah',
      );
    }
  });
}

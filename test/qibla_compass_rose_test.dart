// Penjaga arah mawar kompas kiblat.
//
// Regresi yang terjadi: huruf N/E/S/W dan tick derajat TIDAK ikut berputar
// (tidak memakai `azimuth` sama sekali di `_paintCardinals`/`_paintTicks`).
// Akibatnya, saat HP tidak menghadap utara, huruf "N" tetap menempel di atas
// layar dan jarum kiblat tampak menunjuk ke ATAS — dibaca user sebagai
// "kiblat ada di utara", padahal Ka'bah di barat laut dari Indonesia.
//
// Referensi: mawar kompas pada kompas sejati berputar melawan arah putaran
// perangkat; saat menghadap timur (azimuth 90), utara ada di sisi KIRI.
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/qibla_screen.dart';

void main() {
  test('utara ada di atas hanya saat perangkat menghadap utara', () {
    expect(roseScreenAngle(0, 0), closeTo(0, 0.001));
  });

  test('menghadap timur -> utara di KIRI layar (270)', () {
    // Inti bug: sebelumnya selalu 0 (atas layar).
    expect(roseScreenAngle(0, 90), closeTo(270, 0.001));
  });

  test('menghadap selatan -> utara di BAWAH layar (180)', () {
    expect(roseScreenAngle(0, 180), closeTo(180, 0.001));
  });

  test('menghadap barat -> utara di KANAN layar (90)', () {
    expect(roseScreenAngle(0, 270), closeTo(90, 0.001));
  });

  test('timur selalu 90 derajat searah jarum jam dari utara', () {
    // Sifat mawar: jarak sudut antar kardinal tetap, hanya bergeser.
    for (final az in [0.0, 37.0, 90.0, 214.0, 359.0]) {
      final n = roseScreenAngle(0, az);
      final e = roseScreenAngle(90, az);
      final s = roseScreenAngle(180, az);
      final w = roseScreenAngle(270, az);

      expect((e - n + 360) % 360, closeTo(90, 0.001),
          reason: 'timur harus 90° searah jarum jam dari utara (az=$az)');
      expect((s - n + 360) % 360, closeTo(180, 0.001),
          reason: 'selatan harus berseberangan dengan utara (az=$az)');
      expect((w - n + 360) % 360, closeTo(270, 0.001),
          reason: 'barat harus 270° dari utara (az=$az)');
    }
  });

  test('hasil selalu 0..360 tanpa nilai negatif', () {
    for (final az in [0.0, 90.0, 180.0, 270.0, 359.9, 360.0]) {
      for (final base in [0.0, 90.0, 180.0, 270.0]) {
        final a = roseScreenAngle(base, az);
        expect(a, greaterThanOrEqualTo(0));
        expect(a, lessThan(360));
      }
    }
  });

  test('menghadap timur: kiblat dari Jakarta (295°) tampak di kiri-atas', () {
    // Sisi kanan jarum = (qiblaBearing - azimuth); azimuth 90, bearing 295
    // -> 205°, yaitu kiri-bawah layar. Mawar harus konsisten dengan itu:
    // utara(270) dan barat laut(295-90=205) berada di sisi kiri.
    final needle = (295 - 90 + 360) % 360;
    expect(needle, closeTo(205, 0.001));
    expect(roseScreenAngle(0, 90), closeTo(270, 0.001));
    // 205 tidak sama dengan 0: jarum TIDAK menunjuk ke atas saat menghadap timur.
    expect(needle, isNot(closeTo(0, 30)));
  });
}

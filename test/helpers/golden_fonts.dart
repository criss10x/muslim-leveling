import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Muat font yang dibundel app supaya golden test menampilkan glyph asli.
///
/// flutter_test TIDAK memuat font aplikasi secara otomatis. Tanpa langkah ini
/// setiap karakter ter-render sebagai kotak `.notdef`, dan itu tidak terlihat
/// seperti kegagalan — ukuran teks, pembungkusan, dan posisi tetap benar, jadi
/// golden "lulus" sambil menampilkan kartu yang tidak bisa dibaca. Golden kartu
/// share sempat begini sejak awal (Arab berupa kotak) dan baru ketahuan saat
/// diperiksa piksel demi piksel: 7 pola baris unik, sementara glyph Arab asli
/// menghasilkan 57.
///
/// Kenapa `FontLoader` langsung, bukan `GoogleFonts.pendingFonts()`: pendingFonts
/// memetakan per-berat file (`PlusJakartaSans-Bold.ttf`), dan yang dibundel cuma
/// Regular + SemiBold — meminta w700 melempar dan meninggalkan sebagian teks
/// tanpa font. FontLoader memuat per-keluarga, jadi tidak bergantung pada nama
/// file per-berat.
///
/// Panggil dari `setUpAll`, dan pakai [expectGlyphsRendered] sebagai penjaga:
/// kalau font gagal dimuat, tesnya gagal alih-alih menghasilkan golden kotak.
Future<void> loadGoldenFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Beri kesempatan binding menyelesaikan inisialisasi sebelum runAsync.
  await Future<void>.delayed(Duration.zero);
  await TestWidgetsFlutterBinding.instance.runAsync(() async {
    for (final (family, path) in goldenFontFiles) {
      final loader = FontLoader(family);
      loader.addFont(rootBundle.load(path));
      await loader.load();
    }
  });

  // Gagal keras kalau font Arab tidak benar-benar terpasang — lebih baik tes
  // merah daripada golden hijau yang menampilkan kotak.
  expectArabicFontLoaded();
}

/// Keluarga font yang dipakai kartu share + ikon Phosphor.
/// Hanya file yang benar-benar ada di `assets/`.
const List<(String, String)> goldenFontFiles = [
  ('Phosphor', 'assets/fonts/Phosphor-Regular.ttf'),
  ('PhosphorFill', 'assets/fonts/Phosphor-Fill.ttf'),
  ('PlusJakartaSans', 'assets/google_fonts/PlusJakartaSans-Regular.ttf'),
  ('AmiriQuran', 'assets/google_fonts/AmiriQuran-Regular.ttf'),
  ('JetBrainsMono', 'assets/google_fonts/JetBrainsMono-Bold.ttf'),
  ('Sora', 'assets/google_fonts/Sora-Bold.ttf'),
];

/// Penjaga: pastikan font Arab benar-benar TERPASANG, bukan sekadar diminta.
///
/// Kenapa perlu: kalau font tidak termuat, flutter_test menggambar setiap
/// karakter sebagai kotak `.notdef` dengan lebar seragam — dan golden tetap
/// "lulus" karena ukuran teks, pembungkusan, dan posisi tidak berubah. Golden
/// kartu share sempat begini sejak awal rilis: Arab berupa kotak, ketahuan
/// hanya setelah pikselnya diperiksa (7 pola baris unik, sementara glyph asli
/// menghasilkan 57).
///
/// Caranya: ukur lebar dua huruf Arab yang bentuknya jelas berbeda dengan
/// TextPainter. Kalau font terpasang, lebarnya beda. Kalau jatuh ke `.notdef`,
/// keduanya jadi kotak dengan lebar identik. TextPainter dipakai langsung
/// (tanpa pipeline widget) supaya tidak menggantung di dalam testWidgets.
void expectArabicFontLoaded() {
  double widthOf(String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 48),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    return tp.width;
  }

  // 'ا' (alif, sempit) vs 'م' (mim, bulat lebar) — jelas beda di font Arab.
  final alif = widthOf('ا');
  final mim = widthOf('م');
  expect(
    (alif - mim).abs(),
    greaterThan(0.5),
    reason:
        'lebar ا dan م identik ($alif vs $mim) — font Arab tidak terpasang, '
        'teks ter-render sebagai kotak .notdef seragam. Pastikan '
        'loadGoldenFonts() berhasil memuat assets/google_fonts/AmiriQuran-*.ttf.',
  );
}

import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/gender_picker.dart';

/// Progres onboarding yang bisa dilanjutkan — supaya app yang mati di tengah
/// jalan (dibunuh OS, di-background lalu ditutup, HP restart) tidak mengulang
/// dari halaman pertama.
///
/// Dulu semua jawaban baru ditulis di halaman terakhir, jadi user yang sudah
/// melewati empat halaman lalu keluar sebentar kembali ke halaman 1.
///
/// ponytail: yang disimpan halaman terakhir + gender, bukan seluruh jawaban.
/// Nama singgah di TextEditingController dan kota butuh panggilan API, jadi
/// keduanya tidak dipulihkan di sini — dan tidak perlu: user mendarat kembali
/// di halaman terakhirnya, jadi paling banyak satu field yang diisi ulang.
/// Menyimpan tiap jawaban = empat key + restore async di enam halaman, untuk
/// keuntungan yang tidak sebanding.
///
/// ponytail: penulisan tidak di-await pemanggil (fire-and-forget). Kalau
/// proses mati tepat di antara dua penulisan, user mundur satu halaman —
/// masih jauh lebih baik daripada mengulang lima.
class OnboardingProgress {
  const OnboardingProgress._();

  static const _pageKey = 'onboarding_page';

  /// Halaman terakhir yang dibuka user + gender yang sudah dipilih.
  /// page = 0 berarti tidak ada progres (mulai dari halaman pertama).
  static Future<({int page, String gender})> resume() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getInt(_pageKey) ?? 0;
    return (
      // ponytail: nilai negatif tidak mungkin datang dari app ini, tapi disk
      // bisa berisi apa saja — lebih baik mulai dari halaman pertama daripada
      // mempercayai angka dari build lain.
      page: v < 0 ? 0 : v,
      // kGenderPrefKey sama dengan yang dibaca Profil — satu sumber kebenaran,
      // bukan key kedua untuk data yang sama.
      gender: p.getString(kGenderPrefKey) ?? '',
    );
  }

  /// User sedang berada di halaman [page] (0-based).
  static Future<void> savePage(int page, String gender) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_pageKey, page);
    await p.setString(kGenderPrefKey, gender);
  }

  /// Onboarding selesai — tidak ada lagi yang perlu dilanjutkan.
  /// Gender sengaja TIDAK dihapus: Profil masih membacanya.
  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_pageKey);
  }
}

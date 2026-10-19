import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Niat yang datang dari tap widget home screen.
///
/// Sengaja hanya *niat membuka daftar quest*, bukan aksi claim: claim punya
/// konsekuensi XP, toast, medali, dan sinkron cloud yang wajib terlihat user.
/// Widget yang meng-claim sendiri akan melewati semua itu.
class WidgetLink {
  /// Host deep link yang dipasang di AndroidManifest
  /// (`id.muslimleveling.muslim_leveling://quests`).
  static const deepLinkHost = 'quests';

  /// Kunci prefs. Ditulis Kotlin sebagai `flutter.widget_open_quests`
  /// (SharedPreferences menambahkan prefix `flutter.` untuk Dart), jadi dari
  /// sisi Dart namanya tanpa prefix.
  static const prefKey = 'widget_open_quests';

  /// Kounter permintaan, bukan bool.
  ///
  /// Bool tidak bisa dipakai: listener yang meng-consume akan men-set nilainya
  /// kembali ke `false` di dalam panggilan yang sama, dan `ValueNotifier` tidak
  /// memberi tahu saat nilai yang sama di-set ulang — jadi permintaan kedua dan
  /// seterusnya hilang tanpa jejak. Kounter selalu naik, jadi setiap permintaan
  /// pasti terdeteksi.
  static final requestCount = ValueNotifier<int>(0);

  /// Jumlah permintaan yang belum dilayani.
  static int get pending => _pending;
  static int _pending = 0;

  static void requestQuests() {
    _pending++;
    requestCount.value++;
  }

  /// Tandai satu permintaan sudah dilayani.
  static void consume() {
    if (_pending > 0) _pending--;
  }

  /// Baca penanda yang ditulis [MainActivity], lalu hapus.
  ///
  /// Dipanggil saat app dibuka dan saat kembali ke depan. Sekali pakai: kalau
  /// penanda dibiarkan, app akan terus melompat ke quest setiap resume.
  static Future<bool> takePending() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getBool(prefKey) != true) return false;
      await p.remove(prefKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  @visibleForTesting
  static void reset() {
    _pending = 0;
    requestCount.value = 0;
  }
}

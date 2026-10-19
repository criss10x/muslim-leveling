import 'package:shared_preferences/shared_preferences.dart';

/// Orkestrasi snapshot widget.
///
/// Dipisah dari `WidgetSnapshot` supaya aturan "fetch sekali sehari" bisa diuji
/// tanpa Android dan tanpa jaringan.
class WidgetSync {
  /// Tanggal (yyyy-MM-dd) terakhir jadwal 7 hari berhasil diambil.
  static const weekStampKey = 'widget_week_fetched_on';

  /// Panggil [fetch] hanya kalau [today] berbeda dari hari terakhir yang
  /// berhasil.
  ///
  /// [fetch] mengembalikan jumlah hari yang didapat. Nol dianggap gagal:
  /// jadwal kosong tidak boleh menandai hari selesai, supaya dicoba lagi di
  /// kesempatan berikutnya (mis. saat app dibuka lagi dengan jaringan).
  ///
  /// Tidak pernah melempar: kegagalan jadwal widget tidak boleh mengganggu app.
  static Future<void> ensureWeek({
    required Future<int> Function() fetch,
    required String today,
  }) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getString(weekStampKey) == today) return;
      final days = await fetch();
      if (days <= 0) return;
      await p.setString(weekStampKey, today);
    } catch (_) {
      // diam: snapshot tetap memakai jadwal hari ini yang sudah tersimpan
    }
  }
}

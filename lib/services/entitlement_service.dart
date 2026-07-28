import 'package:flutter/foundation.dart';

/// Semua fitur gratis — Pro selalu aktif.
/// ponytail: dev toggle & paywall dihapus. Billing nanti kalau monetisasi.
class EntitlementService {
  static final ValueNotifier<bool> proStatus = ValueNotifier(true);

  static bool get isPro => true;

  static Future<void> load() async {}

  /// DEV ONLY — semua gratis, jadi nggak perlu ini.
  @Deprecated('Semua gratis. Jangan panggil.')
  static Future<void> setProDev(bool value) async {}
}

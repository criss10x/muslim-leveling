import 'package:flutter/foundation.dart';

/// Gerbang bersama antar-announcer (medali & side quest): hanya satu popup
/// selebrasi tampil dalam satu waktu. logPrayerAsync bisa mengisi kedua
/// notifier sekaligus dalam satu call — tanpa gerbang, dua dialog race.
/// Tiap overlay menunggu gerbang bebas (listener memicu drain ulang).
class AnnouncerGate {
  static final ValueNotifier<bool> busy = ValueNotifier(false);
}

import 'package:flutter/material.dart';

import '../services/game_service.dart';
import 'xp_toast.dart';

/// Satu-satunya jalur reward share (ayat, hadis, asma, doa).
///
/// Dua hal yang bentuk implementasinya ditentukan oleh kode, bukan selera:
///
/// 1. **Share menaruh app ke background.** `ShareUtil.java` memanggil
///    `startActivity(chooser)` lalu langsung `result.success`, tanpa menunggu
///    hasil. Jadi kalau notif ditampilkan saat itu juga, user tidak ada di app:
///    animasinya habis (1,8 detik) sebelum dia kembali. Reveal-nya karena itu
///    DITUNDA sampai app aktif lagi.
/// 2. **XP diberikan saat chooser terbuka.** Itu yang bisa dibuktikan app ini
///    (tidak ada callback "benar-benar terkirim" dari Android), dan dibatasi
///    cap 3/hari. Jadi menekan Bagikan lalu membatalkan chooser tetap dapat XP,
///    maksimum 30 XP sehari.
///
/// Tidak pernah melempar, dan tidak pernah menampilkan reward yang tidak
/// benar-benar diberikan.
abstract final class ShareReward {
  static BuildContext? _pendingContext;
  static final _ResumeWatcher _watcher = _ResumeWatcher();
  static bool _watcherInstalled = false;

  /// Dipanggil SETELAH share berhasil (channel resolve tanpa error).
  static Future<void> onShared(BuildContext context) async {
    int gained;
    try {
      gained = await GameService.awardShareXp();
    } catch (_) {
      return; // XP gagal disimpan, tapi share tetap sukses dari sisi user.
    }
    if (gained <= 0) return; // cap harian habis: diam, jangan pura-pura.
    if (!context.mounted) return;
    if (!_watcherInstalled) {
      WidgetsBinding.instance.addObserver(_watcher);
      _watcherInstalled = true;
    }
    _pendingContext = context;
  }

  /// Dipanggil saat app kembali aktif. Menampilkan reveal yang tertunda,
  /// sekali saja, dan membuang konteks basi (screen sudah ditutup).
  static void onResumed() {
    final ctx = _pendingContext;
    _pendingContext = null;
    if (ctx == null || !ctx.mounted) return;
    // 64 dp = tepi atas tombol Bagikan (52 dp) + jarak 12 dp, jadi pill
    // tidak pernah menutupi tombol yang baru ditekan.
    showXpToast(ctx, GameService.shareXpPerCard, bottomOffset: 64);
  }

  /// Dipakai tes supaya reveal tidak bocor dari satu tes ke tes lain.
  @visibleForTesting
  static void resetForTest() => _pendingContext = null;

  @visibleForTesting
  static bool get hasPending => _pendingContext != null;
}

/// Pengamat lifecycle tingkat app: cukup satu, jadi tidak ada layar share yang
/// perlu diapa-apakan. Dipasang sekali saat share pertama memberi XP.
class _ResumeWatcher with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ShareReward.onResumed();
  }
}

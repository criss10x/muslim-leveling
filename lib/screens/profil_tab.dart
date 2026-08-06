import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/prayer_service.dart';
import '../../services/game_service.dart';
import '../../services/notification_service.dart';
import '../../services/achievement_service.dart';
import '../../services/learning_content.dart';
import '../../services/supabase_sync.dart';
import '../../services/backup_merge.dart';
import '../../services/auth_service.dart';
import '../../widgets/achievement_medal.dart';
import '../../widgets/tier_avatar.dart';
import '../../widgets/cosmetic_locker.dart';
import '../../widgets/theme_preset_picker.dart';
import '../../services/cosmetic_service.dart';
import '../../services/cosmetic_catalog.dart';
import 'achievements_screen.dart';
import 'welcome_pejuang.dart';

/// Profil Pejuang — hero header, stats grid, achievements, settings rows.
class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key});

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  String _nickname = 'Muslim Warrior';
  String? _avatarPath;
  bool _haidMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Rebuild avatar/title live when cosmetics equip changes.
    GameService.stateVersion.addListener(_onGameOrEntitlementChanged);
  }

  @override
  void dispose() {
    GameService.stateVersion.removeListener(_onGameOrEntitlementChanged);
    super.dispose();
  }

  void _onGameOrEntitlementChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    await GameService.load();
    await AchievementService.refresh(); // sinkron medali dengan state terkini
    final p = await SharedPreferences.getInstance();
    final state = GameService.current;
    if (!mounted) return;
    setState(() {
      _nickname = p.getString('nickname') ?? 'Muslim Warrior';
      _avatarPath = p.getString('avatar_path');
      _haidMode = state.haidMode;
    });
  }

  Future<void> _refresh() async {
    await _loadProfile();
  }

  Future<void> _editNickname() async {
    final ctrl = TextEditingController(text: _nickname);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Edit Nama', style: AppText.titleLg()),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: AppText.bodyLg(),
          decoration: InputDecoration(
            hintText: 'Nama panggilan',
            hintStyle: AppText.bodyMd().copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppText.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(
              'Simpan',
              style: AppText.bodyMd().copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    await p.setString('nickname', result);
    setState(() => _nickname = result);
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/avatar.jpg');
    await file.writeAsBytes(bytes);
    final p = await SharedPreferences.getInstance();
    await p.setString('avatar_path', file.path);
    setState(() => _avatarPath = file.path);
  }

  Future<void> _removeAvatar() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('avatar_path');
    if (_avatarPath != null) {
      try {
        await File(_avatarPath!).delete();
      } catch (_) {}
    }
    setState(() => _avatarPath = null);
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: AppColors.primary),
              title: Text('Edit Nama', style: AppText.bodyLg()),
              onTap: () {
                Navigator.pop(ctx);
                _editNickname();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('Ganti Foto', style: AppText.bodyLg()),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar();
              },
            ),
            if (_avatarPath != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text(
                  'Hapus Foto',
                  style: AppText.bodyLg().copyWith(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSettingSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  /// Ringkas exception buat snackbar diagnosa: tipe + potongan pesan.
  String _shortError(Object e) {
    final s = e.toString();
    return s.length > 110 ? '${s.substring(0, 110)}…' : s;
  }

  Future<void> _applyNotifSettings(
    bool enabled,
    String mode,
    String soundMode,
  ) async {
    try {
      if (enabled) {
        await NotificationService.applyNotifSettings(
          mode: mode,
          soundMode: soundMode,
        );
        final n = await NotificationService.pendingCount();
        if (!mounted) return;
        _showSettingSnackbar(
          n > 0
              ? 'Pengingat adzan aktif: mode ${mode[0].toUpperCase()}${mode.substring(1)} — $n pengingat terjadwal 🔔'
              : 'Mode tersimpan, tapi belum ada pengingat terjadwal — cek izin notifikasi & alarm di pengaturan HP.',
        );
      } else {
        _showSettingSnackbar('Pengingat adzan dimatikan');
      }
    } catch (e, st) {
      // Tampilkan error asli (dipendekkan) — sebelumnya disembunyikan dan
      // bikin debugging buta. Full stacktrace ke Sentry.
      debugPrint('[Profil] gagal simpan pengaturan notif: $e');
      await Sentry.captureException(e, stackTrace: st);
      if (!mounted) return;
      _showSettingSnackbar('Gagal menyimpan: ${_shortError(e)}');
    }
  }

  Future<void> _showNotifDialog() async {
    bool enabled = await NotificationService.isRemindersEnabled();
    String mode = await NotificationService.getNotifMode();
    String soundMode = await NotificationService.getSoundMode();
    final realEnabled = await NotificationService.areNotificationsEnabled();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Pengingat Adzan',
                  style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning kalau permission dicabut tapi prefs ON
                  if (!realEnabled)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Izin notifikasi dicabut. Buka Pengaturan HP untuk mengaktifkan.',
                              style: AppText.bodyMd().copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Toggle enable
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Aktifkan pengingat',
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Switch(
                        value: enabled,
                        onChanged: (v) async {
                          try {
                            if (v) {
                              // Request permission first
                              final granted =
                                  await NotificationService.requestPermission();
                              if (!granted) {
                                _showSettingSnackbar(
                                  'Izin notifikasi ditolak. Aktifkan manual di pengaturan HP.',
                                );
                                return;
                              }
                              // Tanpa izin "Alarm & pengingat" (Android 12+),
                              // penjadwalan exact gagal total — minta dulu.
                              final exactOk =
                                  await NotificationService.ensureExactAlarmPermission();
                              if (!exactOk) {
                                _showSettingSnackbar(
                                  'Izin "Alarm & pengingat" belum aktif — pengingat bisa telat beberapa menit.',
                                );
                              }
                              // Battery optimization = penyebab #1 notif
                              // terjadwal tak pernah muncul saat app ditutup.
                              final battOk =
                                  await NotificationService.ensureBatteryUnrestricted();
                              if (!battOk) {
                                _showSettingSnackbar(
                                  'Izinkan "Tanpa batasan baterai" supaya pengingat tetap bunyi saat app ditutup.',
                                );
                              }
                              await NotificationService.setRemindersEnabled(
                                true,
                              );
                              // Enable pertama kali belum punya timing tersimpan di
                              // prefs — jadwalkan langsung dari jadwal kota tersimpan.
                              final loc = await PrayerService.loadLocation();
                              if (loc != null) {
                                final j = await PrayerService.fetchSchedule(
                                  cityId: loc.id,
                                  cityName: loc.name,
                                );
                                if (j != null) {
                                  await NotificationService.scheduleAdhanReminders(
                                    loc.name,
                                    {
                                      'subuh': j['subuh'] ?? '',
                                      'dzuhur': j['dzuhur'] ?? '',
                                      'ashar': j['ashar'] ?? '',
                                      'maghrib': j['maghrib'] ?? '',
                                      'isya': j['isya'] ?? '',
                                    },
                                  );
                                }
                              }
                              // Verifikasi hasil nyata di sistem, bukan cuma
                              // status toggle.
                              final n =
                                  await NotificationService.pendingCount();
                              _showSettingSnackbar(
                                n > 0
                                    ? '$n pengingat adzan terjadwal 🔔'
                                    : 'Gagal menjadwalkan pengingat — cek izin notifikasi & alarm di pengaturan HP.',
                              );
                            } else {
                              await NotificationService.setRemindersEnabled(
                                false,
                              );
                            }
                            setSt(() => enabled = v);
                          } catch (e, st) {
                            // Jangan pernah diam — tampilkan error asli
                            // (dipendekkan), full stacktrace ke Sentry.
                            debugPrint('[Profil] gagal ubah pengingat: $e');
                            await Sentry.captureException(e, stackTrace: st);
                            _showSettingSnackbar(
                              'Gagal mengubah pengingat: ${_shortError(e)}',
                            );
                          }
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Mode selection
                  AnimatedOpacity(
                    opacity: enabled ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: AbsorbPointer(
                      absorbing: !enabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mode Pengingat',
                            style: AppText.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _notifModeOption(
                            'fokus',
                            '🎯 Fokus',
                            'Hanya pengingat utama di waktu adzan',
                            mode,
                            (m) => setSt(() => mode = m),
                          ),
                          _notifModeOption(
                            'seimbang',
                            '⚖️ Seimbang',
                            'Diingetin 15 menit sebelum & saat adzan',
                            mode,
                            (m) => setSt(() => mode = m),
                          ),
                          _notifModeOption(
                            'intensif',
                            '🔥 Intensif',
                            '30 menit, 5 menit sebelum & saat adzan',
                            mode,
                            (m) => setSt(() => mode = m),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Suara Notifikasi',
                            style: AppText.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _notifModeOption(
                            'senyap',
                            '🔕 Senyap',
                            'Hanya muncul notifikasi, tanpa suara',
                            soundMode,
                            (m) => setSt(() => soundMode = m),
                          ),
                          _notifModeOption(
                            'suara',
                            '🔔 Suara',
                            'Notifikasi dengan suara standar HP',
                            soundMode,
                            (m) => setSt(() => soundMode = m),
                          ),
                          _notifModeOption(
                            'adzan',
                            '🕌 Adzan',
                            'Suara adzan penuh saat masuk waktu sholat',
                            soundMode,
                            (m) => setSt(() => soundMode = m),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Test buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: enabled
                              ? () async {
                                  // Tes = preview murni; tidak menyimpan/
                                  // reschedule (itu tugas Simpan). Dulu tombol
                                  // ini mati diam-diam saat reschedule throw.
                                  try {
                                    await NotificationService.sendTestNotification(
                                      mode,
                                      soundModeOverride: soundMode,
                                    );
                                  } catch (e, st) {
                                    debugPrint('[Profil] tes notif gagal: $e');
                                    await Sentry.captureException(
                                      e,
                                      stackTrace: st,
                                    );
                                    _showSettingSnackbar(
                                      'Tes notifikasi gagal: ${_shortError(e)}',
                                    );
                                  }
                                }
                              : null,
                          icon: Icon(
                            Icons.send,
                            size: 16,
                            color: enabled
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                          label: Text(
                            'Tes Notifikasi',
                            style: AppText.bodyMd().copyWith(
                              color: enabled
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: enabled
                              ? () async {
                                  await NotificationService.sendTestAdzanSound();
                                }
                              : null,
                          icon: Icon(
                            Icons.volume_up,
                            size: 16,
                            color: enabled
                                ? AppColors.secondaryFixed
                                : AppColors.onSurfaceVariant,
                          ),
                          label: Text(
                            'Tes Adzan',
                            style: AppText.bodyMd().copyWith(
                              color: enabled
                                  ? AppColors.secondaryFixed
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Jalan pintas ke pengaturan channel notifikasi Android —
                  // suara channel cuma bisa diubah user lewat sistem.
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () =>
                          NotificationService.openChannelSettings(),
                      icon: Icon(
                        Icons.settings,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      label: Text(
                        'Pengaturan Notifikasi Android',
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Tutup',
                  style: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  // Tutup dialog dulu biar tombol terasa responsif; kerja
                  // async (reschedule bisa >1 detik) jalan setelahnya, dan
                  // exception apa pun berujung snackbar, bukan diam.
                  Navigator.pop(ctx);
                  _applyNotifSettings(enabled, mode, soundMode);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  'Simpan',
                  style: AppText.bodyMd().copyWith(color: AppColors.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _notifModeOption(
    String value,
    String label,
    String desc,
    String current,
    ValueChanged<String> onTap,
  ) {
    final selected = value == current;
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (isLightTheme
                    ? AppColors.primaryContainer
                    : AppColors.primaryContainer.withValues(alpha: 0.15))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurface,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    desc,
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Privasi & Data', style: AppText.titleLg()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _privacyItem(Icons.phone_android, 'Tersimpan di perangkat',
                  'Semua data — sholat, bacaan Quran, statistik, dan preferensi — '
                  'hanya tinggal di HP kamu. Tidak ada server, tidak ada cloud.'),
              const SizedBox(height: 12),
              _privacyItem(Icons.wifi_off, 'Tanpa jejak online',
                  'Aplikasi tidak mengirim aktivitas kamu ke pihak ketiga '
                  'dan tidak memantau perilaku.'),
              const SizedBox(height: 12),
              _privacyItem(Icons.location_off, 'Lokasi privat',
                  'Lokasi hanya dipakai sekali untuk menentukan jadwal sholat '
                  'daerahmu. Lokasi tidak disimpan atau dibagikan.'),
              const SizedBox(height: 12),
              _privacyItem(Icons.delete_outline, 'Hapus kapan saja',
                  'Masuk Profil → Keluar untuk menghapus semua data lokal '
                  'sekaligus. Tidak ada yang tersisa di perangkat.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Oke',
              style: AppText.bodyMd().copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Tentang Aplikasi', style: AppText.titleLg()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Muslim Leveling',
                style: AppText.headlineMd().copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'Versi 1.0.0',
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ibadah itu konsisten, bukan sempurna. '
                'Muslim Leveling membantu kamu membangun kebiasaan sholat lima waktu '
                'dan membaca Quran dengan cara yang seru — setiap sholat yang dicatat '
                'memberi XP, setiap hari tanpa putus menambah streak, dan setiap '
                'pencapaian membuka skin avatar baru.',
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada server, tidak ada iklan, tidak ada langganan. '
                'Semua datamu tinggal di perangkat — milikmu sepenuhnya.',
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 12),
              Text(
                'Dibuat dengan penuh doa untuk setiap pejuang akhirat.',
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: AppText.bodyMd().copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Keluar', style: AppText.titleLg()),
        content: Text(
          'Hapus data lokal dan kembali ke layar awal?',
          style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: AppText.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Keluar',
              style: AppText.bodyMd().copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final p = await SharedPreferences.getInstance();
    await p.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePejuangScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceContainerHigh,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ).copyWith(top: AppSpacing.md, bottom: 100),
            children: [
              _hero(context),
              const SizedBox(height: AppSpacing.md),
              _prayerStreaks(),
              const SizedBox(height: AppSpacing.md),
              _stats(),
              const SizedBox(height: AppSpacing.md),
              _cosmeticLocker(),
              const SizedBox(height: AppSpacing.md),
              _achievements(),
              const SizedBox(height: AppSpacing.md),
              _haidModeToggle(),
              const SizedBox(height: AppSpacing.lg),
              _accountBackup(),
              const SizedBox(height: AppSpacing.md),
              _settings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final state = GameService.current;
    final levelInfo = GameService.getLevelInfo(state.xp);
    final rankTitle = GameService.getRankTitle(state.level);

    // Equipped cosmetics — resolved fresh each build so they react to
    // Locker taps (this state listens to GameService.stateVersion
    // and calls setState on change).
    final auraId = CosmeticService.resolveSlot(
      state,
      CosmeticSlot.aura,
      isPro: true,
    );
    final titleId = CosmeticService.resolveSlot(
      state,
      CosmeticSlot.title,
      isPro: true,
    );
    final equippedTitle = CosmeticCatalog.byId(titleId)?.titleText ?? '';
    final tier = getTierVisualConfig(getTierName(state.level));

    // Solid raised hero (same language as Home) — GlassPanel alpha muddies on pure black.
    final light = isLightTheme;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Profile hero — ${tier.name}',
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: light
                  ? null
                  : [
                      BoxShadow(
                        color: tier.inkPrimary.withValues(alpha: 0.22),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                gradient: LinearGradient(
                  colors: [
                    tier.inkPrimary.withValues(alpha: light ? 0.08 : 0.14),
                    tier.inkSecondary.withValues(alpha: light ? 0.08 : 0.12),
                  ],
                ),
                border: Border.all(
                  color: tier.inkPrimary.withValues(alpha: light ? 0.30 : 0.40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(
                          alpha: light ? 0.5 : 0.35,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        TierProfileAvatar(
                          profileImagePath: _avatarPath,
                          displayName: _nickname,
                          tierName: tier.name,
                          sizeDp: 88,
                          isPro: true,
                          equippedFrameId: 'frame_default',
                          equippedAuraId: auraId,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _nickname,
                                      style: AppText.headlineMd().copyWith(
                                        fontSize: 22,
                                        color: AppColors.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  IconButton(
                                    onPressed: _showEditOptions,
                                    tooltip: 'Edit profil',
                                    constraints: const BoxConstraints(
                                      minWidth: 44,
                                      minHeight: 44,
                                    ),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.edit,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryFixed.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                  border: Border.all(
                                    color: AppColors.secondaryFixed.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  rankTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.labelCaps().copyWith(
                                    color: AppColors.secondaryFixed,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              if (equippedTitle.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  equippedTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.labelCaps().copyWith(
                                    color: AppColors.tertiary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'LVL ${state.level}',
                                  style: AppText.labelCapsSm().copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // XP Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'XP Progress',
                            style: AppText.labelCaps().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${levelInfo.xpInCurrentLevel}/${levelInfo.xpNeededForNextLevel} XP',
                            style: AppText.bodyMd().copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: levelInfo.progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [tier.inkPrimary, tier.inkSecondary],
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                boxShadow: light
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: tier.inkPrimary.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _miniStat(
                          'Level',
                          '${GameService.current.level}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _miniStat('XP', '${GameService.current.xp}'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _miniStat(
                          'Streak',
                          '${GameService.current.heroStreak.current}🔥',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _miniStat(
                          'Rank',
                          tier.name,
                          color: tier.inkPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (true) // ponytail: semua gratis. Selalu tampilkan border
            Positioned.fill(
              child: ExcludeSemantics(
                child: IgnorePointer(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: ProPresentation.antiqueGold.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// "Loker Skin" — cosmetic locker (frame/aura/title tabs) reusing the
  /// same HudHeader + FlatCard shell as the other Profil sections.
  void _showCosmeticLocker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.86,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HudHeader('LOKER SKIN'),
                SizedBox(height: AppSpacing.sm),
                CosmeticLocker(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cosmeticLocker() {
    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: 'Buka loker skin',
      onTap: _showCosmeticLocker,
      // Bentuknya sengaja sejajar dengan _achievements(): HudHeader + kartu
      // PressableScale ber-surfaceContainer, chevron kecil. Dua baris ini
      // duduk berdampingan di Profil, jadi vokabulernya harus satu.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HudHeader('LOKER SKIN'),
          PressableScale(
            onTap: _showCosmeticLocker,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Atur aura dan gelar aktif',
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, {Color? color}) {
    final accent = color ?? AppColors.primary;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.titleLg().copyWith(color: accent),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.labelCaps().copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  static const _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  /// Tanggal catatan paling awal, sebagai "sejak kapan" untuk total seumur
  /// pakai. Null kalau belum ada catatan sama sekali.
  static String? _mulaiSejak(List<PrayerLog> logs) {
    if (logs.isEmpty) return null;
    final terlama = logs
        .map((l) => l.date)
        .where((d) => d.isNotEmpty)
        .fold<String?>(null, (a, b) => a == null || b.compareTo(a) < 0 ? b : a);
    if (terlama == null) return null;

    final d = DateTime.tryParse(terlama);
    if (d == null) return null;
    return '${d.day} ${_namaBulan[d.month - 1]} ${d.year}';
  }

  Widget _stats() {
    final logs = GameService.current.prayerLog;

    int total(bool Function(PrayerLog) match) => logs.where(match).length;

    final wajib = total((l) => GameService.wajibList.contains(l.prayer));
    final sunnah = total(
      (l) => l.type == 'sunnah' || l.prayer.startsWith('rawatib'),
    );
    final tilawah = total((l) => l.prayer == 'tilawah');
    final sejak = _mulaiSejak(logs);
    final kosong = wajib == 0 && sunnah == 0 && tilawah == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total seumur pakai, bukan jendela mingguan: Profil adalah layar
        // identitas, dan angka yang hanya bisa naik terbaca sebagai piala.
        const HudHeader('STATISTIK'),
        FlatCard(
          key: const Key('profil-stats-card'),
          child: kosong
              ? _statsEmpty()
              : Column(
                  children: [
                    _statRow(label: 'Sholat wajib', value: _angka(wajib)),
                    _statRow(
                      label: 'Sunnah & rawatib',
                      value: _angka(sunnah),
                    ),
                    _statRow(
                      label: 'Tilawah',
                      value: _angka(tilawah),
                      denom: ' kali',
                      last: sejak == null,
                    ),
                    if (sejak != null) _statsFooter(sejak),
                  ],
                ),
        ),
      ],
    );
  }

  /// "Sejak kapan" untuk total seumur pakai. Bukan tombol — sekadar keterangan
  /// yang memberi konteks pada angka lifetime.
  Widget _statsFooter(String sejak) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sejak $sejak',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pemisah ribuan — total seumur pakai cepat menembus empat digit, dan
  /// "1247" jauh lebih lambat dibaca daripada "1.247".
  static String _angka(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Widget _statsEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Belum ada catatan.',
          style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Centang sholat pertamamu — statistik mulai terisi di sini.',
          style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _statRow({
    required String label,
    required String value,
    String? denom,
    bool last = false,
  }) {
    return Semantics(
      label: '$label: $value${denom ?? ''}',
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text.rich(
                  TextSpan(
                    text: value,
                    style: AppText.bodyLg().copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    children: denom == null
                        ? null
                        : [
                            TextSpan(
                              text: denom,
                              style: AppText.bodyMd().copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                  ),
                ),
              ],
            ),
            if (!last) ...[
              const SizedBox(height: AppSpacing.sm),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _prayerStreaks() {
    final prayers = [
      ('Subuh', 'subuh'),
      ('Dzuhur', 'dzuhur'),
      ('Ashar', 'ashar'),
      ('Maghrib', 'maghrib'),
      ('Isya', 'isya'),
    ];
    final streaks = GameService.current.perPrayerStreaks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HudHeader('STREAK PER SHOLAT'),
        FlatCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: prayers.map((entry) {
              final label = entry.$1;
              final count = streaks[entry.$2]?.current ?? 0;
              final active = count > 0;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppText.labelCaps().copyWith(
                      color: active
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 13,
                        color: active
                            ? AppColors.secondaryFixed
                            : AppColors.outlineVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$count',
                        style: AppText.titleLg().copyWith(
                          fontSize: 15,
                          color: active
                              ? AppColors.secondaryFixed
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        if (streaks['jumat']?.current != null &&
            streaks['jumat']!.current > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          FlatCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(Icons.mosque, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Jumat',
                  style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
                ),
                const Spacer(),
                Icon(
                  Icons.local_fire_department,
                  size: 14,
                  color: AppColors.secondaryFixed,
                ),
                const SizedBox(width: 3),
                Text(
                  '${streaks['jumat']!.current}',
                  style: AppText.titleLg().copyWith(
                    fontSize: 16,
                    color: AppColors.secondaryFixed,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'minggu',
                  style: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Ringkasan medali + pintu ke galeri.
  /// Dulu 43 medali digelar penuh di sini: tab Profil jadi panjang dan
  /// medalinya mengecil. Sekarang cukup cuplikan + progres; galeri lengkap
  /// (dikelompokkan per tier) ada di [AchievementsScreen].
  Widget _achievements() {
    final defs = AchievementService.defs;
    final unlockedCount = AchievementService.unlockedCount;

    // Cuplikan: yang sudah terbuka lebih dulu, sisanya ditambal yang terkunci
    // supaya barisnya tidak pernah kosong di akun baru.
    final preview = <AchievementDef>[
      ...defs.where((d) => AchievementService.isUnlocked(d.id)),
      ...defs.where((d) => !AchievementService.isUnlocked(d.id)),
    ].take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(
          'ACHIEVEMENTS',
          meta: '$unlockedCount/${defs.length}',
          accent: AppColors.secondaryFixed,
        ),
        PressableScale(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AchievementsScreen()),
            );
            // Medali bisa terbuka saat di galeri — segarkan hitungannya.
            if (mounted) setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                for (final d in preview)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: AchievementMedal(
                      def: d,
                      unlocked: AchievementService.isUnlocked(d.id),
                      size: 36,
                    ),
                  ),
                // Expanded menyerap sisa ruang: teks rapat ke kanan dan tidak
                // pernah overflow di layar sempit.
                Expanded(
                  child: Text(
                    'Lihat semua',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.secondaryFixed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _haidModeToggle() {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.bloodtype_outlined,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Haid',
                  style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
                ),
                Text(
                  _haidMode ? 'Streak dijaga — tidak ada penalti' : 'Nonaktif',
                  style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
                ),
              ],
            ),
          ),
          Switch(
            value: _haidMode,
            onChanged: (v) async {
              await GameService.setHaidMode(v);
              setState(() => _haidMode = v);
            },
            activeTrackColor: AppColors.error.withValues(alpha: 0.5),
            activeThumbColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  // ── Backup & Account ──
  Future<void> _handleGoogleLogin() async {
    final uid = await AuthService.signInWithGoogle();
    if (uid == null) {
      final err =
          AuthService.lastError ?? 'Login Google dibatalkan atau gagal.';
      _showSettingSnackbar('❌ $err');
      return;
    }
    SupabaseSync.initWithUser(uid);

    // Local first — never blind-overwrite with cloud (Critical #1).
    await GameService.load();
    await LearningService.load();
    await AchievementService.load(force: true);

    final localGame = GameService.current.toMap();
    final localLearning = LearningService.current.toMap();
    final p = await SharedPreferences.getInstance();
    Map<String, dynamic> localAch = {};
    final achRaw = p.getString('achievements_unlocked');
    if (achRaw != null && achRaw.isNotEmpty) {
      try {
        localAch = Map<String, dynamic>.from(jsonDecode(achRaw) as Map);
      } catch (_) {}
    }

    final remote = await SupabaseSync.load();
    final hasRemote = remote != null;
    final remoteGame = remote != null && remote['game'] is Map
        ? Map<String, dynamic>.from(remote['game'] as Map)
        : null;
    final remoteLearning = remote != null && remote['learning'] is Map
        ? Map<String, dynamic>.from(remote['learning'] as Map)
        : null;
    Map<String, dynamic> remoteAch = {};
    if (remote != null && remote['achievements'] is Map) {
      final ach = remote['achievements'] as Map;
      final unlocked = ach['unlocked'] is Map ? ach['unlocked'] : ach;
      if (unlocked is Map) {
        remoteAch = Map<String, dynamic>.from(unlocked);
      }
    }

    // ponytail: max-XP / union merge. Dialog Cloud|Device when users need control.
    final mergedGame = remoteGame == null
        ? localGame
        : pickRicherGame(localGame, remoteGame);
    final mergedLearning = remoteLearning == null
        ? localLearning
        : mergeLearning(localLearning, remoteLearning);
    final mergedAch = mergeAchievements(localAch, remoteAch);

    await p.setString('game_state_v1', jsonEncode(mergedGame));
    await p.setString('learning_state_v1', jsonEncode(mergedLearning));
    await p.setString('achievements_unlocked', jsonEncode(mergedAch));

    await GameService.load();
    await LearningService.load();
    await AchievementService.load(force: true);

    // Always push merged result so cloud catches up (signed-in only).
    final gameSaved = await SupabaseSync.saveGame(GameService.current.toMap());
    final learningSaved = await SupabaseSync.saveLearning(
      LearningService.current.toMap(),
    );
    final achievementsSaved = await SupabaseSync.saveAchievements({
      'unlocked': mergedAch,
      'ts': DateTime.now().toUtc().toIso8601String(),
    });
    final backupSaved = SupabaseSync.allSaved([
      gameSaved,
      learningSaved,
      achievementsSaved,
    ]);

    if (!mounted) return;
    setState(() {});
    await _loadProfile();
    if (!backupSaved) {
      _showSettingSnackbar(
        '⚠️ Login berhasil, tetapi backup belum tersimpan. Cek koneksi lalu coba login lagi.',
      );
      return;
    }
    _showSettingSnackbar(
      hasRemote
          ? '☁️ Login OK — progress digabung (XP tertinggi + achievement digabung).'
          : '☁️ Login OK — progress perangkat di-backup ke cloud.',
    );
  }

  Future<void> _handleLogout() async {
    await AuthService.signOut();
    // Stop cloud writes; local SharedPreferences stays intact.
    SupabaseSync.clearUser();
    if (!mounted) return;
    setState(() {});
    _showSettingSnackbar(
      'Logout berhasil. Progress tetap di perangkat; backup cloud berhenti.',
    );
  }

  Widget _accountBackup() {
    final signedIn = AuthService.isSignedIn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HudHeader('BACKUP & AKUN'),
        FlatCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    signedIn ? Icons.cloud_done : Icons.cloud_off,
                    color: signedIn
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      signedIn
                          ? 'Backup cloud aktif (akun Google)'
                          : 'Belum login — backup cloud mati (hanya di HP ini)',
                      style: AppText.bodyMd().copyWith(
                        color: signedIn
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (signedIn)
                OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Keluar dari Akun'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 22),
                  label: const Text('Lanjut dengan Google'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                signedIn
                    ? 'Ganti HP? Login akun sama → merge XP tertinggi + achievement.'
                    : 'Login Google wajib untuk backup cloud. Tanpa login, progress cuma di HP.',
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settings() {
    final rows = <_SettingRow>[
      _SettingRow(
        'Pengaturan Akun',
        Icons.person_outline,
        onTap: _editNickname,
      ),
      _SettingRow(
        'Notifikasi',
        Icons.notifications_outlined,
        onTap: _showNotifDialog,
      ),
      _SettingRow(
        'Tema aplikasi',
        Icons.palette_outlined,
        onTap: () => showThemePresetPicker(context),
      ),
      _SettingRow(
        'Privasi & Data',
        Icons.lock_outline,
        onTap: _showPrivacyDialog,
      ),
      _SettingRow(
        'Tentang Aplikasi',
        Icons.info_outline,
        onTap: _showAboutDialog,
      ),
      _SettingRow(
        'Keluar',
        Icons.logout,
        color: AppColors.error,
        onTap: _confirmLogout,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HudHeader('PENGATURAN'),
        FlatCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              final isLast = i == rows.length - 1;
              final color = r.color ?? AppColors.onSurface;
              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: r.onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2,
                        ),
                        child: Row(
                          children: [
                            Icon(r.icon, color: color, size: 20),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                r.title,
                                style: AppText.bodyLg().copyWith(color: color),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      height: 1,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingRow {
  final String title;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  _SettingRow(this.title, this.icon, {this.color, this.onTap});
}

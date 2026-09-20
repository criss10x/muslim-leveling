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
import '../../services/cloud_sync.dart';
import '../../services/backup_merge.dart';
import '../../services/auth_service.dart';
import '../../widgets/achievement_medal.dart';
import '../../widgets/tier_avatar.dart';
import '../../widgets/cosmetic_locker.dart';
import '../../widgets/theme_preset_picker.dart';
import '../widgets/gender_picker.dart';
import '../widgets/locale_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/prayer_heatmap.dart';
import '../../services/cosmetic_service.dart';
import '../../services/cosmetic_catalog.dart';
import 'achievements_screen.dart';
import 'onboarding_screen.dart';
import '../theme/app_icons.dart';

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
  String _gender = '';
  bool _googleLoginLoading = false;

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
    await AchievementService.refresh(silent: true); // sinkron medali, tanpa popup
    final p = await SharedPreferences.getInstance();
    final state = GameService.current;
    if (!mounted) return;
    setState(() {
      _nickname = p.getString('nickname') ?? 'Muslim Warrior';
      _avatarPath = p.getString('avatar_path');
      _haidMode = state.haidMode;
      _gender = p.getString(kGenderPrefKey) ?? '';
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
        title: Text(AppL10n.of(context).profilEditName, style: AppText.titleLg()),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: AppText.bodyLg(),
          decoration: InputDecoration(
            hintText: AppL10n.of(context).profilNicknameHint,
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
              AppL10n.of(context).commonCancel,
              style: AppText.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(
              AppL10n.of(context).commonSave,
              style: AppText.bodyMd().copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    await p.setString('nickname', result);
    // Sync ke GameState supaya ikut cloud backup.
    await GameService.updateNickname(result);
    setState(() => _nickname = result);
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        // ponytail: foto profil tidak pernah >256dp — tanpa batas ini kamera
        // menyimpan file multi-MB yang hanya dipakai untuk lingkaran 88dp.
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 88,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      // ponytail: rename tiap pick — nama sama membuat Flutter menyajikan
      // decode lama dari imageCache (foto baru terlihat "penyet" karena
      // decode pakai constraint cache lama).
      final file = File(
        '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(bytes);
      final p = await SharedPreferences.getInstance();
      final old = p.getString('avatar_path');
      await p.setString('avatar_path', file.path);
      if (old != null && old != file.path) {
        try {
          await File(old).delete();
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() => _avatarPath = file.path);
    } catch (e) {
      // Trust boundary: kamera absen / izin ditolak / file gagal dibaca.
      if (!mounted) return;
      _showSettingSnackbar(
        AppL10n.of(context).profilPhotoFailed(_shortError(e)),
      );
    }
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

  /// Sheet khusus foto: Kamera / Galeri / Hapus. Dipisah dari
  /// [_showEditOptions] karena aksi foto jauh lebih sering dipakai daripada
  /// ganti nama, dan tap langsung di avatar harus mendarat di sini.
  void _showPhotoOptions() {
    // Ditangkap sekali: builder-nya dipanggil setelah dialog dibuka.
    final l10n = AppL10n.of(context);
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    l10n.profilPhotoSection,
                    style: AppText.labelCaps().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(AppIcons.camera, color: AppColors.primary),
              title: Text(l10n.profilFromCamera, style: AppText.bodyLg()),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(AppIcons.photoLibrary, color: AppColors.primary),
              title: Text(l10n.profilFromGallery, style: AppText.bodyLg()),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            if (_avatarPath != null)
              ListTile(
                leading: Icon(AppIcons.delete, color: AppColors.error),
                title: Text(
                  l10n.profilRemovePhoto,
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

  void _showEditOptions() {
    final l10n = AppL10n.of(context);
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
              leading: Icon(AppIcons.person, color: AppColors.primary),
              title: Text(l10n.profilEditName, style: AppText.bodyLg()),
              onTap: () {
                Navigator.pop(ctx);
                _editNickname();
              },
            ),
            ListTile(
              leading: Icon(AppIcons.camera, color: AppColors.primary),
              title: Text(l10n.profilChangePhoto, style: AppText.bodyLg()),
              onTap: () {
                Navigator.pop(ctx);
                _showPhotoOptions();
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
        final l10n = AppL10n.of(context);
        _showSettingSnackbar(
          n > 0
              ? l10n.profilRemindersScheduled(
                  '${mode[0].toUpperCase()}${mode.substring(1)}',
                  n,
                )
              : l10n.profilRemindersNone,
        );
      } else {
        _showSettingSnackbar(AppL10n.of(context).profilRemindersOff);
      }
    } catch (e, st) {
      // Tampilkan error asli (dipendekkan) — sebelumnya disembunyikan dan
      // bikin debugging buta. Full stacktrace ke Sentry.
      debugPrint('[Profil] gagal simpan pengaturan notif: $e');
      await Sentry.captureException(e, stackTrace: st);
      if (!mounted) return;
      _showSettingSnackbar(
        AppL10n.of(context).profilSaveFailed(_shortError(e)),
      );
    }
  }

  Future<void> _showNotifDialog() async {
    late bool enabled;
    late String mode;
    late String soundMode;
    late bool realEnabled;
    try {
      await NotificationService.init();
      enabled = await NotificationService.isRemindersEnabled();
      mode = await NotificationService.getNotifMode();
      soundMode = await NotificationService.getSoundMode();
      realEnabled = await NotificationService.areNotificationsEnabled();
    } catch (e, st) {
      debugPrint('[Profil] gagal buka pengaturan notif: $e');
      await Sentry.captureException(e, stackTrace: st);
      if (!mounted) return;
      _showSettingSnackbar(
        // Sebelum await apa pun di fungsi ini: AppL10n.of(context) aman.
        AppL10n.of(context).profilSettingsOpenFailed(_shortError(e)),
      );
      return;
    }
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final l10n = AppL10n.of(ctx);
          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            title: Row(
              children: [
                Icon(
                  AppIcons.notificationsActive,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppL10n.of(context).profilReminderTitle,
                  style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status juga false pada first install sebelum prompt muncul.
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
                          Icon(AppIcons.warningAmber, color: AppColors.error, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              AppL10n.of(context).profilNotifPermBody,
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
                          AppL10n.of(context).profilEnableReminders,
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
                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                                _showSettingSnackbar(
                                  l10n.profilNotifPermAction,
                                );
                                return;
                              }
                              if (ctx.mounted) {
                                setSt(() => realEnabled = true);
                              }
                              // Tanpa izin "Alarm & pengingat" (Android 12+),
                              // penjadwalan exact gagal total — minta dulu.
                              final exactOk =
                                  await NotificationService.ensureExactAlarmPermission();
                              if (!exactOk) {
                                _showSettingSnackbar(
                                  l10n.profilExactAlarmPerm,
                                );
                              }
                              // Battery optimization = penyebab #1 notif
                              // terjadwal tak pernah muncul saat app ditutup.
                              final battOk =
                                  await NotificationService.ensureBatteryUnrestricted();
                              if (!battOk) {
                                _showSettingSnackbar(
                                  l10n.profilBatteryPerm,
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
                                      'imsak': j['imsak'] ?? '',
                                      'subuh': j['subuh'] ?? '',
                                      'terbit': j['terbit'] ?? '',
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
                                    ? l10n.profilRemindersScheduledCount(n)
                                    : l10n.profilRemindersFailed,
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
                              l10n.profilRemindersChangeFailed(_shortError(e)),
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
                            AppL10n.of(context).profilReminderMode,
                            style: AppText.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _notifModeOption(
                            'fokus',
                            l10n.profilModeFocus,
                            l10n.profilModeFocusDesc,
                            mode,
                            (m) => setSt(() => mode = m),
                          ),
                          _notifModeOption(
                            'seimbang',
                            l10n.profilModeBalanced,
                            l10n.profilModeBalancedDesc,
                            mode,
                            (m) => setSt(() => mode = m),
                          ),
                          _notifModeOption(
                            'intensif',
                            l10n.profilModeIntense,
                            l10n.profilModeIntenseDesc,
                            mode,
                            (m) => setSt(() => mode = m),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            AppL10n.of(context).profilSoundMode,
                            style: AppText.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _notifModeOption(
                            'senyap',
                            l10n.profilSoundSilent,
                            l10n.profilSoundSilentDesc,
                            soundMode,
                            (m) => setSt(() => soundMode = m),
                          ),
                          _notifModeOption(
                            'suara',
                            l10n.profilSoundNormal,
                            l10n.profilSoundNormalDesc,
                            soundMode,
                            (m) => setSt(() => soundMode = m),
                          ),
                          _notifModeOption(
                            'adzan',
                            l10n.profilSoundAdzan,
                            l10n.profilSoundAdzanDesc,
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
                                    await NotificationService.sendTestNotification(l10n, 
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
                                      l10n.profilTestNotifFailed(_shortError(e)),
                                    );
                                  }
                                }
                              : null,
                          icon: Icon(
                            AppIcons.send,
                            size: 16,
                            color: enabled
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                          label: Text(
                            AppL10n.of(context).profilTestNotif,
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
                                  await NotificationService.sendTestAdzanSound(l10n);
                                }
                              : null,
                          icon: Icon(
                            AppIcons.volumeUp,
                            size: 16,
                            color: enabled
                                ? AppColors.secondaryFixed
                                : AppColors.onSurfaceVariant,
                          ),
                          label: Text(
                            l10n.profilTestAdzan,
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
                        AppIcons.settings,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      label: Text(
                        AppL10n.of(context).profilAndroidNotifSettings,
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  // Jalan pintas Auto-start (Xiaomi/Oppo/Vivo) — tanpa ini
                  // alarm dibunuh OEM saat app ditutup → adzan tak pernah
                  // muncul di lock screen. Buka halaman sistem langsung.
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              AppIcons.batteryAlert,
                              size: 20,
                              color: AppColors.tertiary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                AppL10n.of(context).profilOemTitle,
                                style: AppText.bodyMd().copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppL10n.of(context).profilOemBody,
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final ok = await NotificationService
                                  .openOemAutoStartSettings();
                              if (!ok && ctx.mounted) {
                                Navigator.pop(ctx);
                                _showSettingSnackbar(l10n.profilOemManual);
                              }
                            },
                            icon: const Icon(AppIcons.powerSettingsNew, size: 16),
                            label: Text(
                              AppL10n.of(context).profilOpenAutostart,
                              style: AppText.bodyMd().copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  AppL10n.of(context).commonClose,
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
                  AppL10n.of(context).commonSave,
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
              selected ? AppIcons.radioButtonChecked : AppIcons.radioButtonOff,
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
    final l10n = AppL10n.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(AppL10n.of(context).profilPrivacy, style: AppText.titleLg()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _privacyItem(
                AppIcons.phoneAndroid,
                l10n.profilPrivacyLocalTitle,
                l10n.profilPrivacyLocalBody,
              ),
              const SizedBox(height: 12),
              _privacyItem(
                AppIcons.wifiOff,
                l10n.profilPrivacyTraceTitle,
                l10n.profilPrivacyTraceBody,
              ),
              const SizedBox(height: 12),
              _privacyItem(
                AppIcons.locationOff,
                l10n.profilPrivacyLocationTitle,
                l10n.profilPrivacyLocationBody,
              ),
              const SizedBox(height: 12),
              _privacyItem(
                AppIcons.deleteOutline,
                l10n.profilPrivacyDeleteTitle,
                l10n.profilPrivacyDeleteBody,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppL10n.of(context).commonOk,
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
    final l10n = AppL10n.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(AppL10n.of(context).profilAbout, style: AppText.titleLg()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppL10n.of(context).appTitle,
                style: AppText.headlineMd().copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                AppL10n.of(context).profilVersion('1.1.2'),
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.profilAboutBody,
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.profilAboutOffline,
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
                l10n.profilAboutFooter,
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
              AppL10n.of(context).commonClose,
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
        title: Text(AppL10n.of(context).commonLogout, style: AppText.titleLg()),
        content: Text(
          AppL10n.of(context).profilLogoutConfirm,
          style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppL10n.of(context).commonCancel,
              style: AppText.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppL10n.of(context).commonLogout,
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
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
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
              _heatmapButton(),
              const SizedBox(height: AppSpacing.md),
              _cosmeticLocker(),
              const SizedBox(height: AppSpacing.md),
              _achievements(),
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
    final heroStreak = state.heroStreak.current;
    final xpToNext =
        levelInfo.xpNeededForNextLevel - levelInfo.xpInCurrentLevel;

    // Solid raised hero (same language as Home) — GlassPanel alpha muddies on pure black.
    final light = isLightTheme;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: AppL10n.of(context).profilHeroSemantics(tier.name),
      child: Stack(
        children: [
          Container(
            key: const Key('profil-hero-card'),
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
                          // Strava: tap langsung di avatar = ganti foto,
                          // bukan buka menu edit. Badge kamera = affordance
                          // yang menyatakan itu tanpa perlu dijelaskan.
                          showEditBadge: true,
                          onTap: _showPhotoOptions,
                          equippedFrameId: CosmeticService.resolveSlot(
                            state,
                            CosmeticSlot.frame,
                            isPro: true,
                          ),
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
                                    tooltip: AppL10n.of(
                                      context,
                                    ).profilEditProfile,
                                    constraints: const BoxConstraints(
                                      minWidth: 44,
                                      minHeight: 44,
                                    ),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      AppIcons.edit,
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
                                  AppL10n.of(context).profilLevelBadge(state.level),
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
                          Flexible(
                            child: Text(
                              AppL10n.of(context).profilXpToNext(
                                xpToNext,
                                levelInfo.level + 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.labelCaps().copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Text(
                            AppL10n.of(context).profilXpWithinLevel(
                              levelInfo.xpInCurrentLevel,
                              levelInfo.xpNeededForNextLevel,
                            ),
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
                          AppL10n.of(context).profilMiniLevel,
                          '${GameService.current.level}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _miniStat(
                          AppL10n.of(context).profilMiniXp,
                          '${GameService.current.xp}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _miniStat(
                          AppL10n.of(context).profilMiniStreak,
                          // ponytail: streak 0 bukan "0🔥" — api tanpa hari
                          // terbaca sebagai pujian palsu. Dash = belum mulai.
                          heroStreak == 0 ? '—' : '$heroStreak',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _googleAuthButton(),
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

  // ── Google Auth ──
  Widget _googleAuthButton() {
    final signedIn = AuthService.isSignedIn;
    if (signedIn) {
      return Row(
        children: [
          Icon(AppIcons.cloudDone, color: AppColors.primary, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              AppL10n.of(context).profilBackupActive,
              style: AppText.labelCaps().copyWith(
                color: AppColors.primary,
                fontSize: 10,
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleLogout,
            child: Text(
              AppL10n.of(context).commonLogout,
              style: AppText.labelCaps().copyWith(
                color: AppColors.error,
                fontSize: 10,
              ),
            ),
          ),
        ],
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _googleLoginLoading ? null : _handleGoogleLogin,
        icon: _googleLoginLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(AppIcons.gMobiledata, size: 22),
        label: Text(
          _googleLoginLoading
              ? AppL10n.of(context).profilConnecting
              : AppL10n.of(context).profilContinueGoogle,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    // Ditangkap sebelum await: snackbar di bawah dipanggil setelah gap.
    final l10n = AppL10n.of(context);
    if (_googleLoginLoading) return;
    setState(() => _googleLoginLoading = true);
    try {
      final uid = await AuthService.signInWithGoogle(l10n);
      if (uid == null) {
        final err =
            AuthService.lastError ?? l10n.profilLoginCancelled;
        _showSettingSnackbar('❌ $err');
        return;
      }
      await _completeLogin(uid);
    } catch (e, st) {
      debugPrint('[Profil] login/sync gagal: $e');
      await Sentry.captureException(e, stackTrace: st);
      _showSettingSnackbar(l10n.profilLoginFailed(_shortError(e)));
    } finally {
      if (mounted) setState(() => _googleLoginLoading = false);
    }
  }

  Future<void> _completeLogin(String uid) async {
    final l10n = AppL10n.of(context);
    Map<String, dynamic>? remote;
    try {
      remote = await CloudSync.initWithUser(uid);
      if (remote == null) {
        // P0 fix: network down / verifikasi gagal → tetap lanjut login
        // (data lokal aman), tapi tanpa cloud backup.
        debugPrint('[Profil] cloud verify gagal/offline: sync nonaktif');
        await AuthService.saveEmail();
        await GameService.load();
        await LearningService.load();
        await AchievementService.load(force: true);
        if (mounted) {
          setState(() {});
          await _loadProfile();
          _showSettingSnackbar(l10n.profilLoginOffline);
        }
        return;
      }
    } catch (e, st) {
      debugPrint('[Profil] cloud verify gagal: $e');
      await AuthService.signOut();
      try {
        await Sentry.captureException(e, stackTrace: st);
      } catch (_) {}
      if (mounted) {
        _showSettingSnackbar(l10n.profilCloudVerifyFailed);
      }
      return;
    }

    await AuthService.saveEmail();
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

    // remote non-null di sini (null sudah di-early-return di atas).
    final remoteGame = remote['game'] is Map
        ? Map<String, dynamic>.from(remote['game'] as Map)
        : null;
    final remoteLearning = remote['learning'] is Map
        ? Map<String, dynamic>.from(remote['learning'] as Map)
        : null;
    Map<String, dynamic> remoteAch = {};
    if (remote['achievements'] is Map) {
      final ach = remote['achievements'] as Map;
      final unlocked = ach['unlocked'] is Map ? ach['unlocked'] : ach;
      if (unlocked is Map) {
        remoteAch = Map<String, dynamic>.from(unlocked);
      }
    }

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

    // Restore nickname + kota dari cloud (jika ada) ke SharedPreferences.
    final nick = mergedGame['nickname']?.toString();
    if (nick != null && nick.isNotEmpty) {
      await p.setString('nickname', nick);
    }
    final cid = mergedGame['cityId']?.toString();
    final cname = mergedGame['cityName']?.toString();
    if (cid != null && cid.isNotEmpty) {
      await p.setString('city_id', cid);
      await p.setString('city_name', cname ?? '');
    }

    await GameService.load();
    await LearningService.load();
    await AchievementService.load(force: true);

    final results = await Future.wait([
      CloudSync.saveGame(GameService.current.toMap()),
      CloudSync.saveLearning(LearningService.current.toMap()),
      CloudSync.saveAchievements({
        'unlocked': mergedAch,
        'ts': DateTime.now().toUtc().toIso8601String(),
      }),
    ]);
    final saved = CloudSync.allSaved(results);

    if (!mounted) return;
    setState(() {});
    await _loadProfile();
    if (!saved) {
      _showSettingSnackbar(l10n.profilLoginNotSaved);
      return;
    }
    _showSettingSnackbar(l10n.profilLoginMerged);
  }

  Future<void> _handleLogout() async {
    await AuthService.signOut();
    if (!mounted) return;
    setState(() {});
    _showSettingSnackbar(AppL10n.of(context).profilLogoutSuccess);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HudHeader(AppL10n.of(context).profilLockerSkin),
                const SizedBox(height: AppSpacing.sm),
                const CosmeticLocker(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Heatmap kalender sholat wajib per bulan — gaya GitHub contribution graph.
  void _showHeatmap() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HudHeader(AppL10n.of(context).profilHeatmapHeader),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppL10n.of(context).profilHeatmapBody,
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const PrayerHeatmap(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heatmapButton() {
    return Semantics(
      button: true,
      label: AppL10n.of(context).profilHeatmapSemantics,
      onTap: _showHeatmap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HudHeader(AppL10n.of(context).profilCalendarHeader),
          PressableScale(
            onTap: _showHeatmap,
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
                  Icon(AppIcons.calendarMonth, color: AppColors.primary, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      AppL10n.of(context).profilHeatmapRow,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Icon(
                    AppIcons.arrowForwardIos,
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

  Widget _cosmeticLocker() {
    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: AppL10n.of(context).profilLockerSemantics,
      onTap: _showCosmeticLocker,
      // Bentuknya sengaja sejajar dengan _achievements(): HudHeader + kartu
      // PressableScale ber-surfaceContainer, chevron kecil. Dua baris ini
      // duduk berdampingan di Profil, jadi vokabulernya harus satu.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HudHeader(AppL10n.of(context).profilLockerSkin),
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
                    AppIcons.inventory2Outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      AppL10n.of(context).profilLockerRow,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Icon(
                    AppIcons.arrowForwardIos,
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

  Widget _miniStat(String label, String value) {
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
              style: AppText.titleLg().copyWith(color: AppColors.primary),
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

  /// Tanggal paling awal antara tanggal instal dan log pertama — proxy
  /// terbaik untuk "sejak kapan", karena install date user lama baru
  /// tercatat saat update ini pertama jalan.
  static String? _mulaiSejak(List<PrayerLog> logs) {
    String? sejak;
    final install = GameService.firstInstallDate;
    if (install != null && install.isNotEmpty) sejak = install;
    for (final l in logs) {
      if (l.date.isEmpty) continue;
      if (sejak == null || l.date.compareTo(sejak) < 0) sejak = l.date;
    }
    if (sejak == null) return null;

    final d = DateTime.tryParse(sejak);
    if (d == null) return null;
    return '${d.day} ${_namaBulan[d.month - 1]} ${d.year}';
  }

  Widget _stats() {
    final logs = GameService.current.prayerLog;
    final state = GameService.current;

    int total(bool Function(PrayerLog) match) => logs.where(match).length;

    final wajib = total((l) => GameService.wajibList.contains(l.prayer));
    final quranAyatTotal = state.lifeTotals['quran_ayat'] ?? 0;
    final quranStreak = state.tilawahStreak.current;
    final tilawahDailyAvg = state.quranXp.readAyatTotal > 0
        ? '${state.quranXp.readAyatTotal.toInt()}'
        : '0';
    final sejak = _mulaiSejak(logs);
    final kosong = wajib == 0;

    Widget divider() => Column(
          children: [
            const SizedBox(height: AppSpacing.xs),
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total seumur pakai, bukan jendela mingguan: Profil adalah layar
        // identitas, dan angka yang hanya bisa naik terbaca sebagai piala.
        HudHeader(AppL10n.of(context).profilStatsHeader),
        FlatCard(
          key: const Key('profil-stats-card'),
          child: kosong
              ? _statsEmpty()
              : Column(
                  children: [
                    _statRow(
                      label: AppL10n.of(context).profilStatsWajib,
                      value: _angka(wajib),
                    ),
                    divider(),
                    _statRow(
                      label: AppL10n.of(context).profilStatsVerses,
                      value: _angka(quranAyatTotal),
                    ),
                    divider(),
                    _statRow(
                      label: AppL10n.of(context).profilStatsQuranStreak,
                      value: '$quranStreak',
                      denom: ' ${AppL10n.of(context).profilUnitDays}',
                    ),
                    divider(),
                    _statRow(
                      label: AppL10n.of(context).profilStatsDailyAvg,
                      value: tilawahDailyAvg,
                      denom: ' ${AppL10n.of(context).profilUnitVerses}',
                      last: sejak == null,
                    ),
                    if (sejak != null) _statsFooter(sejak),
                  ],
                ),
        ),
      ],
    );
  }

  /// Keterangan "Sejak" di bawah kartu statistik — konteks waktu untuk
  /// angka lifetime. Bukan tombol.
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
            child: Text(
              AppL10n.of(context).profilStatsSince(sejak),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
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
          AppL10n.of(context).profilStatsEmptyTitle,
          style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          AppL10n.of(context).profilStatsEmptyBody,
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
    final state = GameService.current;
    final streaks = state.perPrayerStreaks;
    final haidMode = state.haidMode;
    final todayKey = GameService.todayStr();
    final yestKey = _yesterdayKey();

    // Pakai wajibList dari game_service sebagai source of truth (sebelumnya
    // hardcoded di sini + 2× duplikat di game_service). tambah shalat = 1 file.
    final prayers = GameService.wajibList
        .map((k) => (_prayerLabel(k), k))
        .toList();

    // P1: sort by 'weakest link' — yang paling berisiko pecah duluan
    // (count==0 → belum mulai; lastDate older than today → at-risk).
    prayers.sort((a, b) {
      final sa = streaks[a.$2];
      final sb = streaks[b.$2];
      final aRisk = sa == null || sa.current == 0
          ? 0
          : (sa.lastDate == todayKey
              ? 2
              : (sa.lastDate == yestKey ? 1 : 0));
      final bRisk = sb == null || sb.current == 0
          ? 0
          : (sb.lastDate == todayKey
              ? 2
              : (sb.lastDate == yestKey ? 1 : 0));
      return aRisk.compareTo(bRisk);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(
          AppL10n.of(context).profilStreakPerPrayer,
          meta: haidMode
              ? AppL10n.of(context).profilCycleFrozenMeta
              : (GameService.freezeShields > 0
                  ? '❄️ ${GameService.freezeShields} shield'
                  : null),
        ),
        Semantics(
          container: true,
          label: _prayerStreaksSemanticsLabel(streaks, haidMode),
          child: FlatCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: prayers.map((entry) {
                final label = entry.$1;
                final key = entry.$2;
                final s = streaks[key];
                final count = s?.current ?? 0;
                final best = s?.best ?? 0;
                final freezeOk = s?.freezeAvailable ?? true;
                final active = count > 0;
                // P0: status 'hari ini' — lastDate == today = dot, == yest = at-risk.
                final loggedToday = s?.lastDate == todayKey;
                final atRisk =
                    !loggedToday && s?.lastDate == yestKey && count > 0;
                // haid: pakai snowflake bukan fire; suppress warning state.
                final iconData = haidMode
                    ? AppIcons.acUnit
                    : atRisk
                        ? AppIcons.warningAmberRounded
                        : AppIcons.localFireDepartment;
                final accent = haidMode
                    ? AppColors.tertiary
                    : atRisk
                        ? AppColors.error
                        : (active
                            ? AppColors.secondaryFixed
                            : AppColors.outlineVariant);
                final textColor = active || atRisk
                    ? (haidMode
                        ? AppColors.tertiary
                        : atRisk
                            ? AppColors.error
                            : AppColors.secondaryFixed)
                    : AppColors.onSurfaceVariant;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // label + status dot (P0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // P3
                          style: AppText.labelCaps().copyWith(
                            color: active
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        if (loggedToday) ...[
                          const SizedBox(width: 3),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(iconData, size: 13, color: accent),
                        const SizedBox(width: 2),
                        Text(
                          '$count',
                          maxLines: 1, // P3
                          overflow: TextOverflow.ellipsis,
                          style: AppText.titleLg().copyWith(
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    // P0: tampilkan best + freeze di micro-line
                    Text(
                      haidMode
                          ? AppL10n.of(context).profilStreakFreeze
                          : (best > 0
                              ? '${AppL10n.of(context).profilStreakBest(best)}'
                                    '${freezeOk ? ' · ❄' : ''}'
                              : ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 9,
                        height: 1.1,
                      ),
                    ),
                    // P2: unit 'hari' di belakang count, 10pt dim
                    Text(
                      AppL10n.of(context).profilUnitDays,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 9,
                        height: 1.1,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        // P2: Friday row selalu render (best/4 minggu) untuk discoverability.
        // Pakai best bukan current — Friday pecah weekly, current=1 kebanyakan.
        Builder(builder: (_) {
          final jumat = streaks['jumat'];
          final bestJumat = jumat?.best ?? 0;
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: FlatCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(haidMode ? AppIcons.acUnit : AppIcons.mosque,
                      size: 18,
                      color: haidMode
                          ? AppColors.tertiary
                          : AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    AppL10n.of(context).profilFriday,
                    style:
                        AppText.bodyLg().copyWith(color: AppColors.onSurface),
                  ),
                  const Spacer(),
                  if (haidMode) ...[
                    Text(
                      AppL10n.of(context).profilCycleModeShort,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.tertiary,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      AppIcons.localFireDepartment,
                      size: 14,
                      color: AppColors.secondaryFixed,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$bestJumat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.titleLg().copyWith(
                        fontSize: 16,
                        color: AppColors.secondaryFixed,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      AppL10n.of(context).profilUnitWeeks,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Nama sholat untuk UI — dari ARB, bukan label server, karena
  /// `arabicName` jadwal tidak berguna bagi pembaca non-Arab.
  String _prayerLabel(String key) {
    final l10n = AppL10n.of(context);
    return switch (key) {
      'subuh' => l10n.prayerSubuh,
      'dzuhur' => l10n.prayerDzuhur,
      'ashar' => l10n.prayerAshar,
      'maghrib' => l10n.prayerMaghrib,
      'isya' => l10n.prayerIsya,
      _ => key,
    };
  }

  /// YYYY-MM-DD untuk kemarin relatif ke hari ini.
  String _yesterdayKey() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Susun label untuk TalkBack: "Streak per salat. Subuh 7 hari. Dzuhur 0
  /// hari. … Mode haid aktif: streak di-freeze." (atau tanpa mode-haid).
  String _prayerStreaksSemanticsLabel(
    Map<String, StreakState> streaks,
    bool haidMode,
  ) {
    final todayKey = GameService.todayStr();
    final l10n = AppL10n.of(context);
    final parts = <String>[l10n.profilStreakSemanticsTitle];
    for (final key in GameService.wajibList) {
      final s = streaks[key];
      final c = s?.current ?? 0;
      final logged = s?.lastDate == todayKey;
      parts.add(
        l10n.profilStreakSemanticsItem(_prayerLabel(key), c) +
            (logged ? l10n.profilAlreadyPrayedToday : ''),
      );
    }
    if (haidMode) parts.add(l10n.profilCycleFrozenSemantics);
    return parts.join('. ');
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
          AppL10n.of(context).achSectionTitle,
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
                    AppL10n.of(context).achSeeAll,
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
                  AppIcons.arrowForwardIos,
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

  Widget _settings() {
    final rows = <_SettingRow>[
      // ponytail: genderHidesCycle — satu-satunya efek pilihan gender.
      // Kalau Lewati (''), baris ini tetap tampil.
      if (!genderHidesCycle(_gender))
      _SettingRow(
        AppL10n.of(context).profilCyclePeriod,
        AppIcons.bloodtypeOutlined,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_haidMode)
              Icon(
                AppIcons.shieldOutlined,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            Switch(
              value: _haidMode,
              onChanged: (v) async {
                await GameService.setHaidMode(v);
                if (!mounted) return;
                setState(() => _haidMode = v);
              },
              activeTrackColor: AppColors.error.withValues(alpha: 0.5),
              activeThumbColor: AppColors.error,
            ),
          ],
        ),
        onTap: () => _showSettingSnackbar(AppL10n.of(context).profilCycleExplain),
      ),
      _SettingRow(
        AppL10n.of(context).profilAccountSettings,
        AppIcons.personOutline,
        onTap: _editNickname,
      ),
      _SettingRow(
        AppL10n.of(context).profilNotifications,
        AppIcons.notificationsOutlined,
        onTap: _showNotifDialog,
      ),
      _SettingRow(
        AppL10n.of(context).profilTheme,
        AppIcons.paletteOutlined,
        onTap: () => showThemePresetPicker(context),
      ),
      _SettingRow(
        AppL10n.of(context).profilGender,
        AppIcons.personOutline,
        trailing: Text(
          switch (_gender) {
            'male' => AppL10n.of(context).profilGenderIkhwan,
            'female' => AppL10n.of(context).profilGenderAkhwat,
            _ => AppL10n.of(context).profilGenderUnset,
          },
          style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
        ),
        onTap: () async {
          final picked = await showGenderPicker(context);
          if (picked == null || !mounted) return;
          setState(() => _gender = picked);
          // Ikhwan = baris Periode Haid hilang. Kalau haidMode masih true,
          // streak-nya freeze diam-diam tanpa tombol untuk mematikan —
          // jadi matikan sekalian saat pindah ke Ikhwan.
          if (genderHidesCycle(picked) && _haidMode) {
            await GameService.setHaidMode(false);
            if (!mounted) return;
            setState(() => _haidMode = false);
          }
        },
      ),
      _SettingRow(
        AppL10n.of(context).settingLanguage,
        AppIcons.translate,
        onTap: () => showLocalePicker(context),
      ),
      _SettingRow(
        AppL10n.of(context).profilPrivacy,
        AppIcons.lockOutline,
        onTap: _showPrivacyDialog,
      ),
      _SettingRow(
        AppL10n.of(context).profilAbout,
        AppIcons.infoOutline,
        onTap: _showAboutDialog,
      ),
      _SettingRow(
        AppL10n.of(context).commonLogout,
        AppIcons.logout,
        color: AppColors.error,
        onTap: _confirmLogout,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(AppL10n.of(context).profilSettingsHeader),
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
                            if (r.trailing != null)
                              r.trailing!
                            else
                              Icon(
                                AppIcons.chevronRight,
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
  final Widget? trailing; // ponytail: replaces chevron when set (e.g. Switch)
  final VoidCallback? onTap;
  _SettingRow(this.title, this.icon, {this.color, this.trailing, this.onTap});
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Pilihan suara adzan: radio per varian + tombol tes + status unduh.
///
/// Satu sumber untuk tab Jadwal dan onboarding. Dulu logika ini hidup di
/// dalam JadwalTab, jadi onboarding hanya bisa menawarkannya dengan menyalin
/// seluruh alur unduh/tes — dan salinan itu pasti menyimpang dari aslinya.
/// Varian selain default (~1-2 MB) diunduh on-demand ke cache.
///
/// Modal "Notifikasi {sholat}" (senyap/suara/adzan) juga tinggal di sini:
/// tab Jadwal dan onboarding memakai [showOptions] yang sama, jadi aturan
/// penyimpanan override tidak bisa berbeda di antara keduanya.
class AdzanSoundPicker extends StatefulWidget {
  /// Judul "SUARA ADZAN" disembunyikan di onboarding: halaman itu sudah punya
  /// judul sendiri, jadi header kedua hanya mengulang hal yang sama.
  final bool showTitle;

  const AdzanSoundPicker({super.key, this.showTitle = true});

  /// Ikon mode suara di kanan tiap baris sholat.
  static const soundIcons = {
    'senyap': AppIcons.volumeOffRounded,
    'suara': AppIcons.notificationsRounded,
    'adzan': AppIcons.volumeUpRounded,
  };

  /// Label sholat untuk id internal ('subuh' → 'Subuh'/'Fajr').
  static String prayerLabel(AppL10n l10n, String id) => switch (id) {
    'subuh' => l10n.prayerSubuh,
    'dzuhur' => l10n.prayerDzuhur,
    'ashar' => l10n.prayerAshar,
    'maghrib' => l10n.prayerMaghrib,
    'isya' => l10n.prayerIsya,
    _ => id,
  };

  /// Modal "Notifikasi {sholat}": Senyap / Suara / Adzan, opsional ditambah
  /// baris "Ikut pengaturan global" yang menghapus override.
  ///
  /// [globalOption] berisi nilai mode global saat baris itu mau ditampilkan;
  /// null = sembunyikan. Tab Jadwal mengirim nilai global (opsinya 3 + 1,
  /// seperti sebelumnya). Onboarding mengirim null: nilai globalnya baru
  /// diatur di tab Profil, halaman yang belum pernah dilihat user, jadi
  /// "ikuti global" belum bermakna di sana. Menyembunyikannya lewat parameter
  /// lebih jujur daripada menyalin callback-nya dengan aturan berbeda.
  static Future<void> showOptions(
    BuildContext context, {
    required String prayerId,
    required String current,
    required bool isOverride,
    String? globalOption,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        final l10n = AppL10n.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.jdNotifFor(AdzanSoundPicker.prayerLabel(l10n, prayerId)),
                  style: AppText.titleLg().copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final (value, icon, label) in [
                  ('senyap', AppIcons.volumeOffRounded, l10n.jdSoundSilent),
                  ('suara', AppIcons.notificationsRounded, l10n.jdSoundNormal),
                  ('adzan', AppIcons.volumeUpRounded, l10n.jdSoundAdzan),
                ])
                  _soundOption(
                    ctx,
                    prayerId: prayerId,
                    // Override tidak pernah menyimpan mode global, jadi
                    // pilihannya cuma bisa cocok kalau override memang ada.
                    selected: isOverride && current == value,
                    value: value,
                    globalOption: globalOption,
                    icon: icon,
                    label: label,
                  ),
                if (globalOption != null)
                  _soundOption(
                    ctx,
                    prayerId: prayerId,
                    selected: !isOverride,
                    value: globalOption,
                    globalOption: globalOption,
                    icon: AppIcons.notificationsNoneRounded,
                    label: l10n.jdSoundGlobalOption,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _soundOption(
    BuildContext ctx, {
    required String prayerId,
    required bool selected,
    required String value,
    required String? globalOption,
    required IconData icon,
    required String label,
  }) {
    return InkWell(
      onTap: () async {
        Navigator.pop(ctx);
        if (value == globalOption) {
          await NotificationService.clearPerPrayerSound(prayerId);
        } else {
          await NotificationService.setPerPrayerSound(prayerId, value);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppText.bodyMd().copyWith(
                  color: selected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(
                AppIcons.checkCircleRounded,
                size: 18,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  @override
  State<AdzanSoundPicker> createState() => _AdzanSoundPickerState();
}

class _AdzanSoundPickerState extends State<AdzanSoundPicker> {
  String _variant = 'adzan';

  /// Varian yang sedang diunduh (null = tidak ada).
  String? _downloading;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await NotificationService.getAdzanVariant();
    if (mounted) setState(() => _variant = v);
  }

  Future<void> _pick(String id) async {
    if (id == _variant) return;
    final wasDownloaded = await NotificationService.isVariantDownloaded(id);
    if (!wasDownloaded && mounted) setState(() => _downloading = id);
    try {
      await NotificationService.setAdzanVariant(id);
      if (mounted) setState(() => _variant = id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppL10n.of(context).jdAdzanDownloadFailed,
              style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
            ),
            backgroundColor: AppColors.surfaceContainerLowest,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          HudHeader(l10n.jdAdzanSoundTitle),
        ],
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              for (final (id, _, label) in NotificationService.adzanVariants)
                _variantRow(id, label),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  // Tes dulu sebelum dipakai: varian dinilai dari suaranya,
                  // bukan dari namanya.
                  onPressed: _downloading == null
                      ? () => NotificationService.sendTestAdzanSound(l10n)
                      : null,
                  icon: const Icon(AppIcons.playCircleOutline, size: 18),
                  label: Text(l10n.jdTesSuara),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _variantRow(String id, String label) {
    final selected = id == _variant;
    final downloading = _downloading == id;
    return InkWell(
      onTap: downloading ? null : () => _pick(id),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? AppIcons.radioButtonCheckedRounded
                  : AppIcons.radioButtonOffRounded,
              size: 20,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppText.bodyMd().copyWith(
                  color: selected
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            // Status unduh: varian default selalu siap (bundled di APK).
            if (downloading)
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else if (id != 'adzan')
              FutureBuilder<bool>(
                future: NotificationService.isVariantDownloaded(id),
                builder: (context, snap) => Icon(
                  snap.data == true
                      ? AppIcons.checkCircleRounded
                      : AppIcons.downloadRounded,
                  size: 18,
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

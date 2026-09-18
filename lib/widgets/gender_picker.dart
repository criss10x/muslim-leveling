import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Prefs key gender — SATU sumber, dipakai onboarding (halaman 3) dan Profil.
/// Nilai: 'male' | 'female' | '' (belum dipilih / Lewati).
const kGenderPrefKey = 'gender';

/// Baris "Periode Haid" hanya disembunyikan kalau user menyatakan dirinya
/// Ikhwan. `''` (Lewati) sengaja TIDAK menyembunyikan — kalau Lewati ikut
/// menyembunyikan, satu tap ceroboh di onboarding menghapus akses fitur haid
/// permanen tanpa jalan pulang.
bool genderHidesCycle(String gender) => gender == 'male';

/// Sheet pilih jenis kelamin — jalan pulang buat user yang salah tekan di
/// onboarding. Mengembalikan nilai terpilih (null = sheet ditutup tanpa
/// memilih), dan nilai itu juga langsung disimpan ke prefs.
///
/// Tanpa ikon: Phosphor yang di-vendor tidak punya glyph gender, dan dua glyph
/// identik lebih membingungkan daripada tanpa ikon. Pola sama dengan
/// showLocalePicker: bottom sheet, tanpa state lokal.
Future<String?> showGenderPicker(BuildContext context) async {
  final picked = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => const _GenderPicker(),
  );
  if (picked == null) return null;
  final p = await SharedPreferences.getInstance();
  await p.setString(kGenderPrefKey, picked);
  return picked;
}

class _GenderPicker extends StatelessWidget {
  const _GenderPicker();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.profilGender,
              style: AppText.titleLg().copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.profilGenderExplain,
              style: AppText.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final (label, value) in [
              (l10n.profilGenderIkhwan, 'male'),
              (l10n.profilGenderAkhwat, 'female'),
              (l10n.profilGenderUnset, ''),
            ])
              ListTile(
                title: Text(
                  label,
                  style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
                ),
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/quran_settings.dart';

/// Setelan tampilan — diatur saat membaca, terpisah dari setelan murrotal
/// yang diatur saat menghafal.
Future<void> showQuranDisplaySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => const _DisplaySheet(),
  );
}

class _DisplaySheet extends StatelessWidget {
  const _DisplaySheet();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quranSettings,
      builder: (context, _) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Pengaturan Tampilan',
                      style: AppText.headlineMd()
                          .copyWith(color: AppColors.onSurface)),
                  const SizedBox(height: 16),
                  _preview(),
                  const SizedBox(height: 20),
                  _label('Ukuran teks Arab'),
                  Slider(
                    value: quranSettings.arabicFontSize,
                    min: kArabicFontMin,
                    max: kArabicFontMax,
                    divisions: (kArabicFontMax - kArabicFontMin).round(),
                    label: quranSettings.arabicFontSize.round().toString(),
                    onChanged: (v) => quranSettings.setArabicFontSize(v),
                  ),
                  _label('Ukuran terjemahan'),
                  Slider(
                    value: quranSettings.translationFontSize,
                    min: kTranslationFontMin,
                    max: kTranslationFontMax,
                    divisions:
                        (kTranslationFontMax - kTranslationFontMin).round(),
                    label: quranSettings.translationFontSize.round().toString(),
                    onChanged: (v) => quranSettings.setTranslationFontSize(v),
                  ),
                  const Divider(height: 24),
                  _switchTile(
                    value: quranSettings.showTranslation,
                    onChanged: (v) => quranSettings.setShowTranslation(v),
                    title: 'Terjemahan Indonesia',
                  ),
                  _switchTile(
                    value: quranSettings.showLatin,
                    onChanged: (v) => quranSettings.setShowLatin(v),
                    title: 'Transliterasi Latin',
                    subtitle: 'Bacaan latin untuk membantu membaca Arab',
                  ),
                  _switchTile(
                    value: quranSettings.showTajweed,
                    onChanged: (v) => quranSettings.setShowTajweed(v),
                    title: 'Warna Tajwid',
                    subtitle: 'Merah=Ghunnah, Biru=Qalqalah/Idgham, '
                        'Hijau=Mad',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(t,
            style: AppText.labelCaps()
                .copyWith(color: AppColors.onSurfaceVariant)),
      );

  Widget _switchTile({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    String? subtitle,
  }) =>
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: Text(title,
            style: AppText.bodyLg().copyWith(color: AppColors.onSurface)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle,
                style: AppText.bodyMd().copyWith(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant)),
      );

  Widget _preview() {
    final s = quranSettings;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiriQuran(
              fontSize: s.arabicFontSize,
              height: 2.0,
              color: AppColors.onSurface,
            ),
          ),
          if (s.showLatin) ...[
            const SizedBox(height: 4),
            Text(
              'Bismillaahir Rahmaanir Raheem',
              style: AppText.bodyMd().copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (s.showTranslation) ...[
            const SizedBox(height: 8),
            Text(
              'Dengan menyebut nama Allah Yang Maha Pemurah lagi '
              'Maha Penyayang.',
              style: AppText.bodyMd().copyWith(
                fontSize: s.translationFontSize,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

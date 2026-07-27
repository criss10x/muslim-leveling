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
                  Text('Tampilan',
                      style: AppText.headlineMd()
                          .copyWith(color: AppColors.onSurface)),
                  const SizedBox(height: 16),

                  // Pratinjau ikut berubah saat slider digeser.
                  Container(
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
                            fontSize: quranSettings.arabicFontSize,
                            height: 2.0,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (quranSettings.showTranslation) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Dengan menyebut nama Allah Yang Maha Pemurah lagi '
                            'Maha Penyayang.',
                            style: AppText.bodyMd().copyWith(
                              fontSize: quranSettings.translationFontSize,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Ukuran teks Arab',
                      style: AppText.labelCaps()
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  Slider(
                    value: quranSettings.arabicFontSize,
                    min: kArabicFontMin,
                    max: kArabicFontMax,
                    divisions: (kArabicFontMax - kArabicFontMin).round(),
                    label: quranSettings.arabicFontSize.round().toString(),
                    onChanged: (v) => quranSettings.setArabicFontSize(v),
                  ),

                  Text('Ukuran terjemahan',
                      style: AppText.labelCaps()
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  Slider(
                    value: quranSettings.translationFontSize,
                    min: kTranslationFontMin,
                    max: kTranslationFontMax,
                    divisions:
                        (kTranslationFontMax - kTranslationFontMin).round(),
                    label: quranSettings.translationFontSize.round().toString(),
                    onChanged: (v) => quranSettings.setTranslationFontSize(v),
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: quranSettings.showTranslation,
                    onChanged: (v) => quranSettings.setShowTranslation(v),
                    title: Text('Tampilkan terjemahan',
                        style: AppText.bodyLg()
                            .copyWith(color: AppColors.onSurface)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

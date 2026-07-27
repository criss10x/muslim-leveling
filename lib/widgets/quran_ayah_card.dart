import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_settings.dart';

class QuranAyahCard extends StatelessWidget {
  final QuranAyah ayah;
  final bool active;
  final VoidCallback onPlay;

  const QuranAyahCard({
    super.key,
    required this.ayah,
    required this.active,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quranSettings,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.10)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: active
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.45))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Ayat ${ayah.ayah}',
                      style: AppText.labelCapsSm()
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_arrow),
                    color: AppColors.primary,
                    tooltip: 'Putar dari ayat ini',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Font mushaf wajib di-bundle: font sistem Android salah
              // merender harakat Uthmani.
              Text(
                ayah.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiriQuran(
                  fontSize: quranSettings.arabicFontSize,
                  height: 2.0,
                  color: AppColors.onSurface,
                ),
              ),
              if (quranSettings.showTranslation) ...[
                const SizedBox(height: 12),
                Text(
                  ayah.translation,
                  style: AppText.bodyMd().copyWith(
                    fontSize: quranSettings.translationFontSize,
                    height: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

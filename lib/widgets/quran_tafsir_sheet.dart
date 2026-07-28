import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';

/// Sheet tafsir untuk satu ayat.
Future<void> showTafsirSheet(BuildContext context, QuranTafsir tafsir) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tafsir Ayat ${tafsir.ayah}',
                    style: AppText.headlineMd()
                        .copyWith(color: AppColors.onSurface),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  tafsir.text,
                  style: AppText.bodyMd().copyWith(
                    height: 1.7,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
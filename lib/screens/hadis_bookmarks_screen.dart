import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/hadis_api.dart';
import '../services/hadis_bookmark.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'hadis_screen.dart';

/// Daftar hadis tersimpan. Mengikuti pola [QuranBookmarksScreen]:
/// snapshot teks sudah tersimpan lokal, jadi layar ini tidak memanggil API.
class HadisBookmarksScreen extends StatefulWidget {
  const HadisBookmarksScreen({super.key});

  @override
  State<HadisBookmarksScreen> createState() => _HadisBookmarksScreenState();
}

class _HadisBookmarksScreenState extends State<HadisBookmarksScreen> {
  @override
  void initState() {
    super.initState();
    // Lokal sumber kebenaran; load() di sini supaya membuka layar ini selalu
    // menampilkan isi prefs terbaru (pola sama dgn QuranBookmarksScreen).
    hadisBookmarks.load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          l.hbTitle,
          style: AppText.titleLg().copyWith(color: AppColors.onBackground),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: hadisBookmarks,
          builder: (context, _) {
            final items = hadisBookmarks.items;
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 44,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l.hbNoBookmark,
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l.hbEmptyHint,
                        textAlign: TextAlign.center,
                        style: AppText.bodyMd().copyWith(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                100,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final b = items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: PressableScale(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HadisDetailScreen(
                          item: HadisItem(
                            id: b.id,
                            ar: b.arabic,
                            idn: b.translation,
                            grade: b.grade,
                            takhrij: b.takhrij,
                            hikmah: b.hikmah,
                          ),
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l.hdNumber('${b.id}'),
                                style: AppText.labelCaps().copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                              const Spacer(),
                              // Ikon 48dp penuh: ambang sentuh Android.
                              IconButton(
                                onPressed: () => hadisBookmarks.toggle(b),
                                icon: const Icon(Icons.bookmark),
                                color: AppColors.secondaryFixed,
                                tooltip: l.hbDelete,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          if (b.arabic.isNotEmpty) ...[
                            Text(
                              b.arabic,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: AppText.arabic(16, height: 1.6),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          Text(
                            b.translation,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodyMd().copyWith(
                              color: AppColors.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

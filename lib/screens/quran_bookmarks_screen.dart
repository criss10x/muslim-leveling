import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../services/quran_data.dart';
import '../services/quran_bookmark.dart';
import '../services/quran_settings.dart';
import 'quran_reader.dart';

/// Daftar ayat yang di-bookmark — tap buka reader di ayat itu.
class QuranBookmarksScreen extends StatefulWidget {
  const QuranBookmarksScreen({super.key});
  @override
  State<QuranBookmarksScreen> createState() => _QuranBookmarksScreenState();
}

class _QuranBookmarksScreenState extends State<QuranBookmarksScreen> {
  Map<int, QuranSurah> _surahByNumber = const {};
  bool _loadingSurahs = true;

  @override
  void initState() {
    super.initState();
    quranBookmarks.load();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final list = await quranData.surahs();
      if (!mounted) return;
      setState(() {
        _surahByNumber = {for (final s in list) s.number: s};
        _loadingSurahs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSurahs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text('Bookmark',
            style: AppText.headlineMd().copyWith(color: AppColors.onSurface)),
      ),
      body: ListenableBuilder(
        listenable: quranBookmarks,
        builder: (context, _) {
          final items = quranBookmarks.items;
          if (_loadingSurahs) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border,
                        size: 48, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text('Belum ada bookmark',
                        style: AppText.bodyLg()
                            .copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('Tap ikon bookmark di ayat yang mau disimpan.',
                        textAlign: TextAlign.center,
                        style: AppText.bodyMd()
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md).copyWith(bottom: 100),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final b = items[i];
              final surah = _surahByNumber[b.surah];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: PressableScale(
                  onTap: surah == null
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => QuranReader(
                                surah: surah, initialAyah: b.ayah),
                          )),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                surah == null
                                    ? 'Surat ${b.surah}'
                                    : '${surah.nameLatin} : ${b.ayah}',
                                style: AppText.labelCaps().copyWith(
                                    color: AppColors.primary, fontSize: 11),
                              ),
                            ),
                            IconButton(
                              onPressed: () => quranBookmarks.toggle(
                                  b.surah, b.ayah, b.arabic, b.translation),
                              icon: Icon(Icons.bookmark,
                                  size: 18, color: AppColors.secondaryFixed),
                              tooltip: 'Hapus bookmark',
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.arabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiriQuran(
                            fontSize: quranSettings.arabicFontSize,
                            height: 1.8,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.translation,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodyMd().copyWith(
                            fontSize: quranSettings.translationFontSize,
                            color: AppColors.onSurfaceVariant,
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
    );
  }
}

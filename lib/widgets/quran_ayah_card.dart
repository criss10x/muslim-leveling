import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_settings.dart';
import '../services/quran_bookmark.dart';

class QuranAyahCard extends StatelessWidget {
  final QuranAyah ayah;
  final int surahNumber;
  final bool active;
  final VoidCallback onPlay;
  final VoidCallback? onTafsir;
  final VoidCallback? onShare;

  const QuranAyahCard({
    super.key,
    required this.ayah,
    required this.surahNumber,
    required this.active,
    required this.onPlay,
    this.onTafsir,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([quranSettings, quranBookmarks]),
      builder: (context, _) {
        final showTr = quranSettings.showTranslation;
        final showLatin = quranSettings.showLatin;
        final showTajweed = quranSettings.showTajweed;
        final bookmarked =
            quranBookmarks.isBookmarked(surahNumber, ayah.ayah);
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
                    onPressed: () => quranBookmarks.toggle(
                        surahNumber, ayah.ayah, ayah.arabic, ayah.translation),
                    icon: Icon(
                      bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    color: bookmarked
                        ? AppColors.secondaryFixed
                        : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    tooltip: bookmarked ? 'Hapus bookmark' : 'Bookmark ayat',
                    visualDensity: VisualDensity.compact,
                  ),
                  if (onTafsir != null)
                    IconButton(
                      onPressed: onTafsir,
                      icon: const Icon(Icons.book_outlined),
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      tooltip: 'Tafsir',
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onShare != null)
                    IconButton(
                      onPressed: onShare,
                      icon: const Icon(Icons.share_outlined),
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      tooltip: 'Bagikan ayat',
                      visualDensity: VisualDensity.compact,
                    ),
                  IconButton(
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_arrow),
                    color: AppColors.primary,
                    tooltip: 'Putar dari ayat ini',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Teks Arab (dengan pewarnaan tajwid jika diaktifkan)
              if (showTajweed)
                _tajweedText(ayah.arabic)
              else
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
              // Transliterasi Latin
              if (showLatin && ayah.latin != null) ...[
                const SizedBox(height: 6),
                Text(
                  ayah.latin!,
                  style: AppText.bodyMd().copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
              // Terjemahan
              if (showTr) ...[
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

  /// Render teks Arab dengan warna tajwid dasar.
  /// ponytail: aturan regex sederhana, bukan parser morfologi lengkap.
  Widget _tajweedText(String arabic) {
    final base = GoogleFonts.amiriQuran(
      fontSize: quranSettings.arabicFontSize,
      height: 2.0,
    );

    final rules = _parseTajweed(arabic)
      ..sort((a, b) {
        int c = a.start.compareTo(b.start);
        if (c != 0) return c;
        return b.length.compareTo(a.length);
      });

    final spans = <TextSpan>[];
    int cursor = 0;

    for (final r in rules) {
      if (r.start > cursor) {
        spans.add(TextSpan(
          text: arabic.substring(cursor, r.start),
          style: base.copyWith(color: AppColors.onSurface),
        ));
      }
      spans.add(TextSpan(
        text: arabic.substring(r.start, r.start + r.length),
        style: base.copyWith(color: r.color),
      ));
      cursor = r.start + r.length;
    }
    if (cursor < arabic.length) {
      spans.add(TextSpan(
        text: arabic.substring(cursor),
        style: base.copyWith(color: AppColors.onSurface),
      ));
    }

    return RichText(
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }

  // Warna tajwid langsung di-parse dari teks per-ayat.
  static List<_TajweedRule> _parseTajweed(String text) {
    final rules = <_TajweedRule>[];
    final red = const Color(0xFFD32F2F);   // Ghunnah (نّ مّ)
    final blue = const Color(0xFF1565C0);   // Qalqalah (ق ط ب ج د sukun)
    final green = const Color(0xFF2E7D32);  // Mad (ا و ي after harakat)

    // Ghunnah: نّ atau مّ (nun/mim bertasydid)
    for (final m in RegExp(r'[نم]\u0651').allMatches(text)) {
      rules.add(_TajweedRule(m.start, m.end - m.start, red));
    }

    // Qalqalah: ق ط ب ج د dengan sukun (ْ)
    for (final m in RegExp(r'[ق طبجد]\u0652').allMatches(text)) {
      rules.add(_TajweedRule(m.start, m.end - m.start, blue));
    }

    // Mad wajib: ا + (ء|همزة) — mad far'i indicators
    for (final m in RegExp(r'[ا]\u064E[\u0621\u0623\u0625\u0622]').allMatches(text)) {
      rules.add(_TajweedRule(m.start, m.end - m.start, green));
    }

    // Mad thabi'i: alif after fatha, waw sukun after dhamma, ya sukun after kasra
    for (final m in RegExp(r'[َ][ا]').allMatches(text)) {
      rules.add(_TajweedRule(m.start, m.end - m.start, green));
    }
    for (final m in RegExp(r'[ُ][و\u0652]').allMatches(text)) {
      rules.add(_TajweedRule(m.start, m.end - m.start, green));
    }
    for (final m in RegExp(r'[ِ][ي\u0652]').allMatches(text)) {
      rules.add(_TajweedRule(m.start, m.end - m.start, green));
    }

    // Ghunnah ikhfa: ن sukun + huruf ikhfa
    for (final m in RegExp(r'نْ[ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك]').allMatches(text)) {
      rules.add(_TajweedRule(m.start, m.end - m.start, red));
    }

    // Idgham: ن sukun + (ي و م ن ل ر)
    for (final m in RegExp(r'نْ[ي ولمر]').allMatches(text)) {
      rules.add(_TajweedRule(m.start, m.end - m.start, blue.withValues(alpha: 0.7)));
    }

    return rules;
  }
}

class _TajweedRule {
  final int start;
  final int length;
  final Color color;
  const _TajweedRule(this.start, this.length, this.color);
}

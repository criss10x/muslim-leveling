import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';
import '../../widgets/xp_toast.dart';
import '../../services/game_service.dart';
import '../../services/daily_highlight.dart';
import '../../services/quran_data.dart';
import 'quran_reader.dart';

/// Daily Highlight — halaman penuh (dulu kartu PageView di tab Home).
/// Isi: ayat + hadis + doa harian, seed per tanggal. +1 XP per halaman
/// yang dilihat, tap ayat buka Quran, tombol bagikan teks.
class DailyHighlightScreen extends StatefulWidget {
  const DailyHighlightScreen({super.key});

  @override
  State<DailyHighlightScreen> createState() => _DailyHighlightScreenState();
}

class _DailyHighlightScreenState extends State<DailyHighlightScreen> {
  DailyHighlight? _h;
  final _ctrl = PageController();
  int _page = 0;
  bool _sharing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final h = await dailyHighlightService.forToday(GameService.todayStr());
      if (!mounted) return;
      setState(() {
        _h = h;
        _loading = false;
      });
      // Halaman pertama langsung dihitung: membuka halaman ini = membaca
      // halaman 1, jadi XP-nya tidak bergantung pada swipe.
      await _claim(0);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _claim(int i) async {
    final got = await GameService.claimHighlightSwipeXp(i);
    if (got && mounted) showXpToast(context, GameService.highlightSwipeXpPerPage);
  }

  List<({String title, String arabic, String text, bool isArabic})> _pages(
    DailyHighlight h,
  ) => [
    (
      title: 'QS. ${h.surahLatin}: ${h.ayahNumber}',
      arabic: h.ayahArabic,
      text: h.ayahIdn,
      isArabic: true,
    ),
    if (h.hadisIdn.isNotEmpty)
      (title: 'HADIS HARI INI', arabic: '', text: h.hadisIdn, isArabic: false),
    (title: 'DOA · ${h.doaNama}', arabic: '', text: h.doaIdn, isArabic: false),
  ];

  /// Teks untuk dibagikan — hanya bagian yang benar-benar ada.
  String _shareText(DailyHighlight h) {
    final b = StringBuffer('📖 Daily Highlight Muslim Leveling\n\n');
    b.writeln('QS. ${h.surahLatin}: ${h.ayahNumber}');
    if (h.ayahIdn.isNotEmpty) b.writeln(h.ayahIdn);
    if (h.hadisIdn.isNotEmpty) b.writeln('\nHadis:\n${h.hadisIdn}');
    if (h.doaIdn.isNotEmpty) {
      b.writeln('\nDoa ${h.doaNama}:\n${h.doaIdn}');
    }
    return b.toString().trim();
  }

  Future<void> _share() async {
    final h = _h;
    if (h == null || _sharing) return;
    setState(() => _sharing = true);
    try {
      await const MethodChannel('muslim_leveling/share').invokeMethod(
        'shareText',
        {'text': _shareText(h)},
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membagikan. Coba lagi.',
              style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
            ),
            backgroundColor: AppColors.surfaceContainerLowest,
          ),
        );
      }
    }
    if (mounted) setState(() => _sharing = false);
  }

  /// Tap ayat → Quran reader di ayat persis. Surah di-resolve ulang
  /// deterministik (quranData in-memory setelah load pertama → murah).
  Future<void> _openAyah(DailyHighlight h) async {
    final surahs = await quranData.surahs();
    final surah = surahs[highlightIndex(h.date, surahs.length)];
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranReader(surah: surah, initialAyah: h.ayahNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = _h;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : h == null
                  ? _empty()
                  : _body(h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(AppIcons.arrowBack, color: AppColors.onSurface),
            tooltip: 'Kembali',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY HIGHLIGHT',
                  style: AppText.labelCaps().copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Renungan Hari Ini',
                  style: AppText.headlineLg().copyWith(
                    fontSize: 22,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _h == null || _sharing ? null : _share,
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(AppIcons.share, color: AppColors.primary),
            tooltip: 'Bagikan',
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Renungan hari ini belum bisa dimuat.\n'
          'Sambungkan internet lalu coba lagi.',
          textAlign: TextAlign.center,
          style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _body(DailyHighlight h) {
    final pages = _pages(h);
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _ctrl,
            itemCount: pages.length,
            onPageChanged: (i) {
              setState(() => _page = i);
              _claim(i);
            },
            itemBuilder: (_, i) => GestureDetector(
              onTap: i == 0 ? () => _openAyah(h) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: SingleChildScrollView(child: _tile(pages[i])),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < pages.length; i++)
              Container(
                margin: const EdgeInsets.all(3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),
        if (_page == 0)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'Tap ayat untuk membuka di Quran',
              style: AppText.bodyMd().copyWith(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _tile(({String title, String arabic, String text, bool isArabic}) p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.title,
          style: AppText.labelCaps().copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (p.isArabic)
          Text(
            p.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiriQuran(
              fontSize: 26,
              height: 1.8,
              color: AppColors.onSurface,
            ),
          ),
        if (p.isArabic) const SizedBox(height: AppSpacing.md),
        Text(
          p.text,
          style: AppText.bodyMd().copyWith(
            color: AppColors.onSurface,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

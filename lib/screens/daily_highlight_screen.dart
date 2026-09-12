import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/xp_toast.dart';
import '../../widgets/quran_share_sheet.dart';
import '../../widgets/quran_tafsir_sheet.dart';
import '../../services/game_service.dart';
import '../../services/daily_highlight.dart';
import '../../services/quran_data.dart';
import '../../services/quran_audio_service.dart';
import '../../services/quran_playlist.dart';
import '../../services/quran_bookmark.dart';
import '../../services/quran_api.dart';
import '../../services/hijri_service.dart';
import 'quran_reader.dart';

/// Daily Highlight — halaman penuh (dulu kartu PageView di tab Home).
///
/// Susunan 3 lembar: **ayat jadi bintang** (Arab besar di tengah + 4 aksi
/// yang menempel padanya), hadis & doa jadi pendukung yang lebih tenang.
/// Ditutup penanda "tuntas" supaya terasa ritual harian, bukan teks lepas.
/// ponytail: semua isi dari service yang sudah ada (tafsir, audio, bookmark,
/// kartu share Quran, kalender hijriah) — nol dependensi & nol API baru.
class DailyHighlightScreen extends StatefulWidget {
  const DailyHighlightScreen({super.key});

  @override
  State<DailyHighlightScreen> createState() => _DailyHighlightScreenState();
}

class _DailyHighlightScreenState extends State<DailyHighlightScreen> {
  DailyHighlight? _h;
  final _ctrl = PageController();
  int _page = 0;
  bool _loading = true;

  /// Halaman yang XP-nya sudah diklaim hari ini. Sumber kebenaran tetap
  /// bitmask di GameService — ini cuma salinan untuk menggambar penutup.
  late int _claimed = GameService.highlightSwipeClaimedToday;

  String _hijri = '';

  /// Tafsir untuk ayat hari ini, dimuat malas (baru saat tombol ditekan).
  QuranTafsir? _tafsir;
  bool _tafsirLoading = false;

  /// Hasil resolve surah+ayat — dipakai tombol Quran, bagikan, dan simpan.
  ({QuranSurah surah, QuranAyah ayah})? _ref;

  @override
  void initState() {
    super.initState();
    _load();
    quranBookmarks.addListener(_onBookmarkChanged);
  }

  @override
  void dispose() {
    quranBookmarks.removeListener(_onBookmarkChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onBookmarkChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    // Kalender hijriah & bookmark bukan hal kritis — gagal pun halaman jalan.
    hijriService.today().then((d) {
      if (mounted && d != null) setState(() => _hijri = hijriLabel(d));
    }).catchError((_) {});
    quranBookmarks.load();

    try {
      final h = await dailyHighlightService.forToday(GameService.todayStr());
      if (!mounted) return;
      setState(() {
        _h = h;
        _loading = false;
      });
      _resolve(h);
      // Halaman pertama langsung dihitung: membuka halaman ini = membaca
      // halaman 1, jadi XP-nya tidak bergantung pada swipe.
      await _claim(0);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Resolve surah+ayat hari ini sekali saja (dipakai 4 aksi).
  Future<void> _resolve(DailyHighlight h) async {
    try {
      final surahs = await quranData.surahs();
      final surah = surahs[highlightIndex(h.date, surahs.length)];
      final ayahs = await quranData.ayahs(surah.number);
      if (!mounted) return;
      setState(() {
        _ref = (surah: surah, ayah: ayahs[h.ayahNumber - 1]);
      });
    } catch (_) {
      // ponytail: resolve gagal → tombol aksi disembunyikan, teks tetap tampil.
    }
  }

  Future<void> _claim(int i) async {
    final got = await GameService.claimHighlightSwipeXp(i);
    if (!mounted) return;
    if (got) {
      showXpToast(context, GameService.highlightSwipeXpPerPage);
      setState(() => _claimed |= 1 << i);
    }
  }

  bool get _tuntas => _claimed == (1 << GameService.highlightSwipeMaxPages) - 1;

  /// Ayat hari ini di Quran, mulai & berhenti di ayat itu.
  void _toggleAudio() {
    final r = _ref;
    if (r == null) return;
    if (quranAudio.isPlaying) {
      quranAudio.toggle();
      return;
    }
    quranAudio.start(
      range: PlaybackRange.full(
        surah: r.surah.number,
        ayahCount: r.surah.ayahCount,
      ).withFrom(r.ayah.ayah).withTo(r.ayah.ayah),
      startAyah: r.ayah.ayah,
    );
    setState(() {});
  }

  Future<void> _toggleBookmark() async {
    final r = _ref;
    if (r == null) return;
    await quranBookmarks.toggle(
      r.surah.number,
      r.ayah.ayah,
      r.ayah.arabic,
      r.ayah.translation,
    );
  }

  Future<void> _openTafsir() async {
    final r = _ref;
    if (r == null || _tafsirLoading) return;
    // Sudah pernah diambil → langsung tampilkan tanpa fetch ulang.
    if (_tafsir != null) {
      await showTafsirSheet(context, _tafsir!);
      return;
    }
    setState(() => _tafsirLoading = true);
    try {
      final list = await quranApi.tafsir(r.surah.number);
      if (!mounted) return;
      final t = list.firstWhere(
        (x) => x.ayah == r.ayah.ayah,
        orElse: () => const QuranTafsir(ayah: 0, shortText: '', longText: ''),
      );
      setState(() {
        _tafsir = t;
        _tafsirLoading = false;
      });
      if (t.longText.isNotEmpty || t.shortText.isNotEmpty) {
        await showTafsirSheet(context, t);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _tafsirLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tafsir tidak bisa dimuat. Coba lagi.',
            style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
          ),
          backgroundColor: AppColors.surfaceContainerLowest,
        ),
      );
    }
  }

  void _openAyah() {
    final r = _ref;
    if (r == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranReader(surah: r.surah, initialAyah: r.ayah.ayah),
      ),
    );
  }

  List<({String title, String arabic, String text, bool isArabic})> _pages(
    DailyHighlight h,
  ) => [
    (
      title: 'QS. ${h.surahLatin} : ${h.ayahNumber}',
      arabic: h.ayahArabic,
      text: h.ayahIdn,
      isArabic: true,
    ),
    if (h.hadisIdn.isNotEmpty)
      (title: 'HADIS HARI INI', arabic: '', text: h.hadisIdn, isArabic: false),
    (title: 'DOA · ${h.doaNama}', arabic: '', text: h.doaIdn, isArabic: false),
  ];

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
        AppSpacing.base,
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
                  style: AppText.labelCaps().copyWith(color: AppColors.primary),
                ),
                Text(
                  'Renungan Hari Ini',
                  style: AppText.headlineLg().copyWith(
                    fontSize: 22,
                    color: AppColors.onSurface,
                  ),
                ),
                // Tanggal hijriah: bikin header terasa "hari ini", bukan template.
                if (_hijri.isNotEmpty)
                  Text(
                    _hijri,
                    style: AppText.labelCapsSm().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
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
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.base,
              ),
              child: SingleChildScrollView(
                child: i == 0 ? _ayatPage(pages[0]) : _supportPage(pages[i]),
              ),
            ),
          ),
        ),
        _dots(pages.length),
        _footer(pages.length),
      ],
    );
  }

  // ── Lembar 1: AYAT — bintang halaman ini ──────────────────────────
  Widget _ayatPage(({String title, String arabic, String text, bool isArabic}) p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cite(p.title),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: _ref == null ? null : _openAyah,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Text(
                p.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: AppText.arabic(28),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 2,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                p.text,
                textAlign: TextAlign.center,
                style: AppText.bodyLg().copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
        if (_ref != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _actions(),
        ],
      ],
    );
  }

  /// 4 aksi ayat — semuanya dari service yang sudah ada di app.
  Widget _actions() {
    final r = _ref!;
    final saved = quranBookmarks.isBookmarked(r.surah.number, r.ayah.ayah);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _action(
          icon: quranAudio.isPlaying ? AppIcons.pause : AppIcons.play,
          label: quranAudio.isPlaying ? 'Jeda' : 'Dengar',
          onTap: _toggleAudio,
        ),
        _action(
          icon: AppIcons.bookmarkSimple,
          label: saved ? 'Tersimpan' : 'Simpan',
          onTap: _toggleBookmark,
          active: saved,
        ),
        _action(
          icon: AppIcons.translate,
          label: 'Tafsir',
          onTap: _openTafsir,
          busy: _tafsirLoading,
        ),
        _action(
          icon: AppIcons.share,
          label: 'Bagikan',
          // ponytail: pakai kartu share Quran yang sudah ada (9:16, siap
          // IG Story) — bukan teks polos; mutunya jauh lebih baik.
          onTap: () => showQuranShareSheet(
            context,
            surah: r.surah,
            ayah: r.ayah,
          ),
        ),
      ],
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    bool busy = false,
  }) {
    final ink = active ? AppColors.secondaryFixed : AppColors.primary;
    return PressableScale(
      pressedScale: 0.92,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            busy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: ink),
                  )
                : Icon(icon, size: 22, color: ink),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppText.labelCapsSm().copyWith(color: ink),
            ),
          ],
        ),
      ),
    );
  }

  // ── Lembar 2 & 3: HADIS / DOA — pendukung, lebih tenang ───────────
  Widget _supportPage(({String title, String arabic, String text, bool isArabic}) p) {
    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cite(p.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            p.text,
            style: AppText.bodyMd().copyWith(
              color: AppColors.onSurface,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cite(String text) => Text(
    text,
    style: AppText.labelCaps().copyWith(color: AppColors.primary),
  );

  Widget _dots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.all(3),
            width: i == _page ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              color: i == _page
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
      ],
    );
  }

  /// Penutup: progres hari ini. Tuntas = ritual selesai, bukan sekadar teks.
  Widget _footer(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_tuntas)
            Icon(AppIcons.checkCircle, size: 16, color: AppColors.secondaryFixed),
          if (_tuntas) const SizedBox(width: 6),
          Text(
            _tuntas
                ? 'Renungan hari ini tuntas'
                : '$_claimed dari $count renungan dibaca · swipe untuk lanjut',
            style: AppText.labelCapsSm().copyWith(
              color: _tuntas
                  ? AppColors.secondaryFixed
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

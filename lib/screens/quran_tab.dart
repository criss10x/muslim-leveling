import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_progress.dart';
import '../services/quran_bookmark.dart';
import 'quran_reader.dart';
import 'quran_bookmarks_screen.dart';
import '../widgets/rub_el_hizb_badge.dart';

class QuranTab extends StatefulWidget {
  const QuranTab({super.key});

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  List<QuranSurah> _all = const [];
  String _query = '';
  bool _loading = true;
  bool _failed = false;
  List<QuranSearchHit> _verseHits = const [];
  bool _searchingVerses = false;
  Timer? _debounce;
  // Urutan request pencarian: hasil lama dibuang kalau query sudah berubah
  // (stale-response race).
  int _searchSeq = 0;
  // Controller eksplisit: SliverPersistentHeader membangun ulang child-nya
  // saat scroll, dan TextField tanpa controller berisiko kehilangan isinya.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    quranProgress.addListener(_onProgressChanged);
    quranProgress.load();
    quranBookmarks.load();
  }

  @override
  void dispose() {
    quranProgress.removeListener(_onProgressChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Debounce 400ms lalu cari di terjemahan (lazy index, satu kali).
  void _onQueryChanged(String v) {
    _debounce?.cancel();
    _searchSeq++; // setiap ketikan invalidasi hasil yang sedang berjalan
    setState(() {
      _query = v;
      _verseHits = const [];
      _searchingVerses = false;
    });
    final q = v.trim();
    if (q.length < 3) return; // kata pendek → terlalu banyak hasil
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final seq = _searchSeq;
      // Nama surat sudah cocok → hasil ayat tidak relevan; jangan scan.
      if (quranData.search(_all, q).isNotEmpty) return;
      if (!mounted) return;
      setState(() => _searchingVerses = true);
      try {
        final hits = await quranData.searchVerses(q);
        // Hasil lama (query sudah berubah) → buang.
        if (!mounted || seq != _searchSeq) return;
        setState(() => _verseHits = hits);
      } finally {
        // Spinner mati walau searchVerses melempar (defensif).
        if (mounted && seq == _searchSeq) {
          setState(() => _searchingVerses = false);
        }
      }
    });
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final list = await quranData.surahs();
      if (!mounted) return;
      setState(() {
        _all = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Gagal memuat data Quran',
            style: AppText.bodyLg().copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    final list = quranData.search(_all, _query);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Al-Quran',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.headlineMd().copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Kaligrafi sebagai aksen, bukan informasi — karena itu
                      // diredupkan dan tidak diberi semantik. Flexible+FittedBox:
                      // menyusut saat layar sempit/teks besar, jangan overflow.
                      Flexible(
                        child: ExcludeSemantics(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'القرآن',
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              style: AppText.headlineMd().copyWith(
                                color:
                                    AppColors.goldInk.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        tooltip: 'Bookmark ayat',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const QuranBookmarksScreen(),
                          ),
                        ),
                        icon: Icon(
                          Icons.bookmark_border,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '114 surat · 30 juz',
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (_lastSurah case final surah?)
                    ...[
                      const SizedBox(height: AppSpacing.md),
                      _ResumeReadingCard(
                        surah: surah,
                        ayah: quranProgress.ayah!,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuranReader(
                              surah: surah,
                              initialAyah: quranProgress.ayah,
                            ),
                          ),
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchHeader(
              extent: _SearchHeader.extentFor(context),
              child: TextField(
                controller: _searchController,
                onChanged: _onQueryChanged,
                style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Cari surat, arti, nomor, atau kata',
                  hintStyle: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (list.isEmpty && _query.trim().length >= 3)
            _searchingVerses
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _verseHits.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'Tidak ditemukan di surat maupun terjemahan ayat',
                            style: AppText.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          top: AppSpacing.xs,
                          bottom: AppSpacing.xxl * 2,
                        ),
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 8,
                                ),
                                child: Text(
                                  '${_verseHits.length} ayat ditemukan di '
                                  'terjemahan',
                                  style: AppText.labelCaps().copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            SliverList.builder(
                              itemCount: _verseHits.length,
                              itemBuilder: (_, i) => _VerseHitRow(
                                hit: _verseHits[i],
                                query: _query.trim(),
                                surah: _surahOf(_verseHits[i].surahNumber),
                              ),
                            ),
                          ],
                        ),
                      )
          else if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Surat tidak ditemukan',
                  style: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.xs,
                bottom: AppSpacing.xxl * 2,
              ),
              sliver: SliverList.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => _SurahRow(surah: list[i]),
              ),
            ),
        ],
      ),
    );
  }

  /// Surat dari posisi baca terakhir, kalau masih ada di daftar.
  QuranSurah? get _lastSurah {
    final n = quranProgress.surahNumber;
    if (n == null || !quranProgress.hasProgress) return null;
    for (final s in _all) {
      if (s.number == n) return s;
    }
    return null;
  }

  QuranSurah? _surahOf(int n) {
    for (final s in _all) {
      if (s.number == n) return s;
    }
    return null;
  }
}

/// Kartu aksi "kembali ke bacaan terakhir". Menempel di atas daftar surat
/// selama ada posisi yang tersimpan.
class _ResumeReadingCard extends StatelessWidget {
  final QuranSurah surah;
  final int ayah;
  final VoidCallback onTap;

  const _ResumeReadingCard({
    required this.surah,
    required this.ayah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Lanjutkan membaca ${surah.nameLatin} ayat $ayah',
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lanjutkan membaca',
                        style: AppText.bodyLg().copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah.nameLatin} · Ayat $ayah',
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahRow extends StatelessWidget {
  final QuranSurah surah;
  const _SurahRow({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Semantics(
        button: true,
        label: 'Buka surat ${surah.nameLatin}',
        child: Material(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => QuranReader(surah: surah)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Proporsional, bukan angka mati: patokan 108px menyisakan
                  // terlalu sedikit untuk kolom arti di layar 360dp sehingga
                  // artinya membungkus dan tinggi baris berayun antar surat.
                  final arabicWidth = (constraints.maxWidth * 0.3).clamp(
                    0.0,
                    108.0,
                  );

                  return Row(
                    children: [
                      RubElHizbBadge(number: surah.number),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah.nameLatin,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.titleLg().copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              surah.meaning,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.bodyMd().copyWith(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RevelationChip(label: surah.revelation),
                                  const SizedBox(width: AppSpacing.sm),
                                  Icon(
                                    Icons.auto_stories,
                                    size: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${surah.ayahCount}',
                                    style: AppText.bodyMd().copyWith(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Diciutkan bila perlu, bukan dipotong: nama Arab
                      // terpanjang (mis. المنافقون) dulu kena ellipsis karena
                      // berebut ruang dengan chevron.
                      SizedBox(
                        width: arabicWidth,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              surah.nameArabic,
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              style: AppText.titleLg().copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip tempat turun surat. Madaniyah memakai pasangan warna sekunder (emas)
/// supaya asal turunnya bisa dipindai tanpa membaca teks. Pasangan
/// container/on-container dipakai, bukan goldInk, karena di preset Dark
/// goldInk di atas secondaryContainer praktis tidak terbaca.
class _RevelationChip extends StatelessWidget {
  final String label;
  const _RevelationChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isMakkiyah = label.toLowerCase() == 'makkiyah';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isMakkiyah
            ? AppColors.tertiaryContainer
            : AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppText.labelCapsSm().copyWith(
          color: isMakkiyah
              ? AppColors.onTertiaryContainer
              : AppColors.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// Search field yang menempel di atas saat daftar di-scroll. Tingginya dihitung
/// dari skala teks aktif, bukan angka mati: contentPadding TextField tidak ikut
/// membesar saat pengguna menaikkan ukuran teks sistem, tapi tinggi barisnya
/// iya — extent tetap akan menjepit field. Garis bawah hanya muncul ketika ada
/// konten yang lewat di belakangnya, supaya header tidak terlihat mengambang
/// saat daftar masih di puncak.
class _SearchHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double extent;

  const _SearchHeader({required this.child, required this.extent});

  /// Tinggi yang dibutuhkan header pada skala teks aktif: padding vertikal
  /// Container + contentPadding bawaan OutlineInputBorder (20 atas, 20 bawah)
  /// + tinggi satu baris bodyMd yang ikut diskalakan.
  static double extentFor(BuildContext context) {
    const containerPadding = AppSpacing.sm * 2;
    const contentPadding = 40.0;
    // Diturunkan dari bodyMd, bukan angka salinan: kalau gaya teksnya berubah,
    // extent ikut menyesuaikan dan field tidak diam-diam terjepit lagi.
    final base = AppText.bodyMd();
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(base.fontSize!) * base.height!;
    return containerPadding + contentPadding + lineHeight;
  }

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // overlapsContent hanya true kalau sliver lain menimpa header ini, bukan
    // saat header menimpa konten — untuk pinned header, shrinkOffset > 0 adalah
    // sinyal "sudah menempel di atas daftar" yang benar.
    final menempel = overlapsContent || shrinkOffset > 0;
    // SizedBox wajib: SliverPersistentHeader melayout anaknya dengan tinggi
    // maksimum, bukan tight. Kalau anaknya lebih pendek dari extent yang
    // dideklarasikan, paintExtent jadi lebih kecil dari layoutExtent dan
    // Flutter meng-assert. alignment memusatkan field supaya sisa ruangnya
    // terbagi rata, bukan menumpuk di bawah.
    return SizedBox(
      height: extent,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            bottom: menempel
                ? BorderSide(color: AppColors.outlineVariant)
                : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchHeader oldDelegate) =>
      oldDelegate.extent != extent || oldDelegate.child != child;
}

/// Satu baris hasil pencarian ayat dalam terjemahan. Tap → buka QuranReader
/// langsung ke ayat yang dimaksud.
class _VerseHitRow extends StatelessWidget {
  final QuranSearchHit hit;
  final String query;
  final QuranSurah? surah;

  const _VerseHitRow({
    required this.hit,
    required this.query,
    required this.surah,
  });

  /// Potong [text] jadi ~90 karakter di sekitar match [q], supaya kata yang
  /// dicari selalu terlihat (bukan terpotong ellipsis di akhir kalimat).
  /// Return null kalau q kosong/tidak ketemu → tampilkan teks apa adanya.
  String? _snippet(String text, String q) {
    final idx = text.toLowerCase().indexOf(q);
    if (idx < 0 || text.length <= 90) return null;
    var start = idx - 35;
    var end = idx + q.length + 50;
    if (start < 0) {
      start = 0;
      end = 90;
    }
    if (end > text.length) end = text.length;
    return (start > 0 ? '…' : '') +
        text.substring(start, end) +
        (end < text.length ? '…' : '');
  }

  /// RichText dengan kata kunci di-highlight (bold + warna primer).
  List<TextSpan> _highlight(String text, String q) {
    final spans = <TextSpan>[];
    if (q.isEmpty) {
      spans.add(TextSpan(text: text));
      return spans;
    }
    var rest = text;
    final lowerQ = q.toLowerCase();
    while (true) {
      final idx = rest.toLowerCase().indexOf(lowerQ);
      if (idx < 0) {
        spans.add(TextSpan(text: rest));
        break;
      }
      if (idx > 0) spans.add(TextSpan(text: rest.substring(0, idx)));
      final match = rest.substring(idx, idx + q.length);
      spans.add(TextSpan(
        text: match,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ));
      rest = rest.substring(idx + q.length);
      if (rest.isEmpty) break;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final snippet = _snippet(hit.translation, query);
    final shown = snippet ?? hit.translation;
    final baseStyle = AppText.bodyMd().copyWith(
      color: AppColors.onSurface,
      height: 1.4,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: () {
            if (surah == null) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuranReader(
                  surah: surah!,
                  initialAyah: hit.ayahNumber,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${hit.surahNumber}',
                      style: AppText.labelCaps().copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah == null
                            ? 'Surat ${hit.surahNumber} · Ayat ${hit.ayahNumber}'
                            : '${surah!.nameLatin} · Ayat ${hit.ayahNumber}',
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text.rich(
                        TextSpan(children: _highlight(shown, query)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: baseStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

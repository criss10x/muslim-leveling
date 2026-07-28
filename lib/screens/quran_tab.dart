import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import 'quran_reader.dart';
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
  // Controller eksplisit: SliverPersistentHeader membangun ulang child-nya
  // saat scroll, dan TextField tanpa controller berisiko kehilangan isinya.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                      Text(
                        'Al-Quran',
                        style: AppText.headlineMd().copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      // Kaligrafi sebagai aksen, bukan informasi — karena itu
                      // diredupkan dan tidak diberi semantik.
                      ExcludeSemantics(
                        child: Text(
                          'القرآن',
                          textDirection: TextDirection.rtl,
                          style: AppText.headlineMd().copyWith(
                            color: AppColors.goldInk.withValues(alpha: 0.75),
                          ),
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
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchHeader(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Cari surat, arti, atau nomor',
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
          if (list.isEmpty)
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
              child: Row(
                children: [
                  RubElHizbBadge(number: surah.number),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.nameLatin,
                          style: AppText.titleLg().copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          '${surah.meaning} · ${surah.ayahCount} ayat',
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Jumlah ayat digabung ke baris arti, bukan di sini:
                        // chip + jumlah ayat berdampingan melebihi lebar yang
                        // tersedia di layar 360dp dan memicu RenderFlex overflow.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _RevelationChip(label: surah.revelation),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Lebar dikunci lalu diciutkan bila perlu: nama Arab terpanjang
                  // (mis. المنافقون) sebelumnya kena ellipsis karena berebut
                  // ruang dengan chevron.
                  SizedBox(
                    width: 108,
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
    final madaniyah = label.toLowerCase() == 'madaniyah';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: madaniyah
            ? AppColors.secondaryContainer
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppText.labelCapsSm().copyWith(
          color: madaniyah
              ? AppColors.onSecondaryContainer
              : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Search field yang menempel di atas saat daftar di-scroll. minExtent sama
/// dengan maxExtent karena tingginya tetap; garis bawah hanya muncul ketika
/// ada konten yang lewat di belakangnya, supaya header tidak terlihat
/// mengambang saat daftar masih di puncak.
class _SearchHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _SearchHeader({required this.child});

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent
                ? AppColors.outlineVariant
                : Colors.transparent,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SearchHeader oldDelegate) => true;
}

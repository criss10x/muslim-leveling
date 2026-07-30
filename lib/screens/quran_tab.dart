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
                      // diredupkan dan tidak diberi semantik.
                      ExcludeSemantics(
                        child: Text(
                          'القرآن',
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
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
              extent: _SearchHeader.extentFor(context),
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

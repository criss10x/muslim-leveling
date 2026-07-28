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

  @override
  void initState() {
    super.initState();
    _load();
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Al-Quran',
                  style: AppText.headlineMd().copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '114 surat',
                  style: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Text(
                      'Pilih surat',
                      style: AppText.labelCaps().copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${list.length}',
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
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
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'Surat tidak ditemukan',
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.xs,
                      bottom: AppSpacing.xxl * 2,
                    ),
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
                          surah.meaning,
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            _RevelationChip(label: surah.revelation),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${surah.ayahCount} ayat',
                              style: AppText.labelCapsSm().copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
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

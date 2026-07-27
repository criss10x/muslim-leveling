import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import 'quran_reader.dart';

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
          padding: const EdgeInsets.all(24),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Cari surat, arti, atau nomor',
                hintStyle:
                    AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'Surat tidak ditemukan',
                      style: AppText.bodyMd()
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
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
    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QuranReader(surah: surah)),
      ),
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          '${surah.number}',
          style: AppText.labelCapsSm().copyWith(color: AppColors.primary),
        ),
      ),
      title: Text(
        surah.nameLatin,
        style: AppText.titleLg().copyWith(color: AppColors.onSurface),
      ),
      subtitle: Text(
        '${surah.meaning} · ${surah.revelation} · ${surah.ayahCount} ayat',
        style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
      ),
      trailing: Text(
        surah.nameArabic,
        style: AppText.titleLg().copyWith(color: AppColors.primary),
      ),
    );
  }
}

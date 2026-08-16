import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/hadis_api.dart';
import '../../services/game_service.dart';

/// Hadis — explore list (5/page) + search + hadis acak. API myquran v3.
class HadisScreen extends StatefulWidget {
  const HadisScreen({super.key});
  @override
  State<HadisScreen> createState() => _HadisScreenState();
}

class _HadisScreenState extends State<HadisScreen> {
  final _searchCtrl = TextEditingController();
  final List<HadisItem> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  bool _isSearch = false;
  int _searchTotal = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await hadisApi.explore(1);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _page = 1;
        _hasMore = items.length == 5;
        _isSearch = false;
        _searchTotal = 0;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_items.isEmpty) _error = 'Gagal memuat hadis.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || _isSearch) return;
    setState(() => _loading = true);
    try {
      final items = await hadisApi.explore(_page + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(items);
        _page++;
        _hasMore = items.length == 5;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_items.isEmpty) _error = 'Gagal memuat hadis.';
      });
    }
  }

  Future<void> _search(String keyword) async {
    final q = keyword.trim();
    if (q.isEmpty) {
      _searchCtrl.clear();
      return _load();
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final (items, total) = await hadisApi.search(q);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _isSearch = true;
        _searchTotal = total;
        _hasMore = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_items.isEmpty) _error = 'Gagal mencari hadis.';
      });
    }
  }

  Future<void> _random() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final item = await hadisApi.random();
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HadisDetailScreen(item: item),
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_items.isEmpty) _error = 'Gagal memuat hadis.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  style: AppText.bodyMd().copyWith(color: AppColors.onBackground),
                  decoration: InputDecoration(
                    hintText: 'Cari hadis…',
                    hintStyle: AppText.bodyMd()
                        .copyWith(color: AppColors.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search,
                        size: 20, color: AppColors.onSurfaceVariant),
                    suffixIcon: _isSearch || _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close,
                                size: 18, color: AppColors.onSurfaceVariant),
                            onPressed: () {
                              _searchCtrl.clear();
                              _load();
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _randomButton(),
            ],
          ),
        ),
        if (_isSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: Text('$_searchTotal hadis ditemukan',
                style: AppText.labelCaps()
                    .copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
          ),
        Expanded(child: _body()),
      ],
    );
  }

  Widget _randomButton() {
    return PressableScale(
      onTap: _loading ? null : _random,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            Icon(Icons.casino, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Acak',
                style: AppText.labelCaps()
                    .copyWith(color: AppColors.primary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_error != null && _items.isEmpty) {
      return ErrorRetry(message: _error!, onRetry: _load);
    }
    if (_loading && _items.isEmpty) {
      return Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, 100),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == _items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Center(
                child: _loading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      )
                    : TextButton.icon(
                        onPressed: _loadMore,
                        icon: const Icon(Icons.expand_more, size: 18),
                        label: const Text('Muat Lagi'),
                      ),
              ),
            );
          }
          final item = _items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PressableScale(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HadisDetailScreen(item: item),
              )),
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
                        if (item.grade.isNotEmpty) _gradeChip(item.grade),
                        const Spacer(),
                        Text('no. ${item.id}',
                            style: AppText.labelCaps().copyWith(
                                color: AppColors.onSurfaceVariant, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (item.ar.isNotEmpty) ...[
                      Text(item.ar,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 16, height: 1.6)),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Text(item.idn,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyMd()
                            .copyWith(color: AppColors.onBackground)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _gradeChip(String grade) {
    final sahih = grade.toLowerCase().contains('sahih');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (sahih ? AppColors.primary : AppColors.tertiary)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(grade,
          style: AppText.labelCaps().copyWith(
              color: sahih ? AppColors.primary : AppColors.tertiary,
              fontSize: 9)),
    );
  }
}

/// Hadis — detail: arab + terjemah + grade + takhrij + hikmah.
/// Baca ≥5 dtk → +1 XP (sekali per hadis per hari, cap 10/hari).
class HadisDetailScreen extends StatefulWidget {
  final HadisItem item;
  const HadisDetailScreen({super.key, required this.item});

  @override
  State<HadisDetailScreen> createState() => _HadisDetailScreenState();
}

class _HadisDetailScreenState extends State<HadisDetailScreen> {
  Timer? _xpTimer;

  @override
  void initState() {
    super.initState();
    // ponytail: dwell 5 dtk — timer polos cukup; keluar sebelum itu = tidak baca.
    _xpTimer = Timer(const Duration(seconds: 5), () {
      unawaited(GameService.noteHadisRead(widget.item.id));
    });
  }

  @override
  void dispose() {
    _xpTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final sahih = item.grade.toLowerCase().contains('sahih');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.onBackground),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text('Hadis no. ${item.id}',
                        style: AppText.titleLg().copyWith(
                            fontSize: 16, color: AppColors.primary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (item.grade.isNotEmpty) _gradeChip(item.grade, sahih),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md)
                    .copyWith(bottom: 100),
                children: [
                  if (item.takhrij.isNotEmpty)
                    Text(item.takhrij,
                        style: AppText.labelCaps()
                            .copyWith(color: AppColors.tertiary)),
                  const SizedBox(height: AppSpacing.md),
                  if (item.ar.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                      ),
                      child: Text(item.ar,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 24, height: 1.9)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  HudHeader('TERJEMAHAN', meta: null),
                  Text(item.idn,
                      style: AppText.bodyMd()
                          .copyWith(color: AppColors.onBackground, height: 1.5)),
                  if (item.hikmah != null && item.hikmah!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    HudHeader('HIKMAH', meta: null),
                    Text(item.hikmah!,
                        style: AppText.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant, height: 1.5)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradeChip(String grade, bool sahih) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (sahih ? AppColors.primary : AppColors.tertiary)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(grade,
          style: AppText.labelCaps().copyWith(
              color: sahih ? AppColors.primary : AppColors.tertiary,
              fontSize: 9)),
    );
  }
}

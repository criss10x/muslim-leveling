import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/doa_api.dart';

/// Doa — level 1: daftar grup doa (dari API equran.id).
class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});
  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> {
  List<(String, int)>? _groups;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final groups = await doaApi.fetchGroups();
      if (mounted) setState(() => _groups = groups);
    } catch (_) {
      if (mounted) setState(() => _error = 'Gagal memuat doa.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    if (_error != null && groups == null) {
      return ErrorRetry(message: _error!, onRetry: _load);
    }
    if (groups == null) {
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
        itemCount: groups.length,
        itemBuilder: (_, i) {
          final (grup, count) = groups[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PressableScale(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DoaListScreen(grup: grup),
              )),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Row(
                  children: [
                    Icon(Icons.volunteer_activism,
                        size: 22, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(grup,
                          style: AppText.bodyLg()
                              .copyWith(color: AppColors.onBackground)),
                    ),
                    Text('$count',
                        style: AppText.labelCaps()
                            .copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Doa — level 2: daftar doa dalam satu grup.
class DoaListScreen extends StatelessWidget {
  final String grup;
  const DoaListScreen({super.key, required this.grup});

  @override
  Widget build(BuildContext context) {
    final items = doaApi.byGrup(grup);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(context, grup, '${items.length} doa'),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Kosong'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md)
                          .copyWith(bottom: 100),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final d = items[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: PressableScale(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => DoaDetailScreen(doa: d),
                            )),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xxl),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.nama,
                                      style: AppText.bodyLg().copyWith(
                                          color: AppColors.onBackground)),
                                  const SizedBox(height: 4),
                                  Text(d.ar,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 16, height: 1.6)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context, String title, String meta) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.onBackground),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppText.titleLg().copyWith(
                        fontSize: 16, color: AppColors.primary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(meta,
                    style: AppText.labelCaps().copyWith(
                        color: AppColors.onSurfaceVariant, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Doa — detail: arab + transliterasi + terjemah + sumber.
class DoaDetailScreen extends StatelessWidget {
  final DoaItem doa;
  const DoaDetailScreen({super.key, required this.doa});

  @override
  Widget build(BuildContext context) {
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
                    child: Text(doa.nama,
                        style: AppText.titleLg().copyWith(
                            fontSize: 16, color: AppColors.primary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md)
                    .copyWith(bottom: 100),
                children: [
                  Text(doa.grup,
                      style: AppText.labelCaps()
                          .copyWith(color: AppColors.tertiary)),
                  const SizedBox(height: AppSpacing.md),
                  // Arab — text align center, natural font fallback.
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    child: Text(doa.ar,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26, height: 1.9)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _section('Transliterasi', doa.tr,
                      style: AppText.bodyMd().copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.md),
                  _section('Artinya', doa.idn),
                  if (doa.tentang.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _section('Sumber', doa.tentang),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String label, String text,
      {TextStyle? style}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(label.toUpperCase(), meta: null),
        Text(text,
            style: style ?? AppText.bodyMd().copyWith(color: AppColors.onBackground)),
      ],
    );
  }
}

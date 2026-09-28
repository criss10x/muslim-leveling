import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/doa_api.dart';
import '../theme/app_icons.dart';
import '../l10n/app_localizations.dart';

/// Doa — level 1: daftar grup doa (dari API equran.id).
///
/// Layout: setiap grup = baris FlatCard. Squint test menuntut hierarki:
/// nama grup (bodyLg, tinta penuh) → jumlah doa (labelCaps mono, readout
/// HUD) → chevron. Ikon disatukan dalam chip wash seperti quick action
/// Home supaya bahasa visualnya identik; isinya satu glyph doa karena
/// tidak ada data tematik per grup di API.
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
      if (mounted) setState(() => _error = AppL10n.of(context).doaLoadFailed);
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
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 100),
        itemCount: groups.length,
        itemBuilder: (_, i) {
          final (grup, count) = groups[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PressableScale(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DoaListScreen(grup: grup),
              )),
              child: FlatCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // Chip ikon wash: bahasa visual quick action Home
                    // (kedalaman dari tangga kecerahan, bukan bayangan).
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(AppIcons.volunteerActivism,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(grup,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodyLg()
                              .copyWith(color: AppColors.onBackground)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Readout HUD: jumlah doa mono kapital — angka sebagai
                    // sinyal, bukan dekorasi.
                    Text('$count',
                        style: AppText.labelCapsSm()
                            .copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: AppSpacing.base),
                    Icon(AppIcons.arrowForwardIos,
                        size: 14, color: AppColors.outlineVariant),
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
///
/// Perubahan layout vs versi lama: (1) preview Arab 2 baris, bukan ellipsis
/// satu baris — Arab adalah konten utama, potongan satu blok tidak bisa
/// dikenali; (2) nomor urut mono di kiri tiap kartu (urutan baca doa itu
/// bermakna); (3) app bar memakai judul tinta penuh + meta mono, konsisten
/// dengan HudHeader, bukan judul berwarna primary.
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ContentLangNote(
                  locale: Localizations.localeOf(context),
                  contentIsEnglish: false,
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text(AppL10n.of(context).doaEmpty))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md, AppSpacing.sm, AppSpacing.md, 100),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final d = items[i];
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: PressableScale(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => DoaDetailScreen(doa: d),
                            )),
                            child: FlatCard(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nomor urut baca — readout mono, bukan
                                  // dekorasi.
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text('${i + 1}',
                                        style: AppText.labelCapsSm().copyWith(
                                            color:
                                                AppColors.onSurfaceVariant)),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(d.nama,
                                            style: AppText.bodyLg().copyWith(
                                                color:
                                                    AppColors.onBackground)),
                                        const SizedBox(height: AppSpacing.base),
                                        // Preview Arab: 2 baris + ellipsis.
                                        // Amiri via AppText.arabic, tinggi 2.0.
                                        Text(
                                          d.ar,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                          textDirection:
                                              TextDirection.rtl,
                                          style: AppText.arabic(16, height: 1.9)
                                              .copyWith(
                                                  color: AppColors
                                                      .onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
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
            icon: Icon(AppIcons.arrowBack, color: AppColors.onBackground),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppText.titleLg().copyWith(
                        color: AppColors.onBackground, fontSize: 18),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(meta,
                    style: AppText.labelCapsSm()
                        .copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Doa — detail: arab + transliterasi + terjemah + sumber.
///
/// Hierarki: label grup (HudHeader readout) → kartu Arab besar (elemen
/// utama, Amiri 26/height 2.0 via token) → Transliterasi → Arti → Sumber,
/// semuanya lewat _section ber-HudHeader. Arab memakai AppText.arabic agar
/// tidak jatuh ke font fallback sistem.
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
                    icon: Icon(AppIcons.arrowBack, color: AppColors.onBackground),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(doa.nama,
                        style: AppText.titleLg().copyWith(
                            color: AppColors.onBackground, fontSize: 18),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.share,
                        size: 20, color: AppColors.onSurfaceVariant),
                    onPressed: () => _share(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md)
                    .copyWith(bottom: 100),
                children: [
                  // Nama grup = konten (ID), bukan chrome UI → tampil langsung
                  // lewat HudHeader sebagai readout pembuka.
                  HudHeader(doa.grup, meta: null),
                  // Arab — elemen utama, centered, tinggi 2.0, Amiri Quran.
                  FlatCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(doa.ar,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: AppText.arabic(26, height: 2.0)
                            .copyWith(color: AppColors.onBackground)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _section(AppL10n.of(context).doaSectionTranslit, doa.tr,
                      style: AppText.bodyMd().copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.lg),
                  _section(AppL10n.of(context).doaSectionMeaning, doa.idn),
                  if (doa.tentang.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _section(AppL10n.of(context).doaSectionSource, doa.tentang),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Share teks doa lewat channel ShareUtil (method shareText): Arab +
  /// terjemahan + sumber + watermark, tanpa perlu file gambar.
  Future<void> _share(BuildContext context) async {
    final buf = StringBuffer()
      ..writeln(doa.ar)
      ..writeln()
      ..writeln('"${doa.idn}"')
      ..writeln()
      ..writeln(doa.tentang)
      ..writeln()
      ..write('Muslim Leveling');
    try {
      const channel = MethodChannel('muslim_leveling/share');
      await channel.invokeMethod('shareText', {'text': buf.toString()});
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).qsErr)),
        );
      }
    }
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

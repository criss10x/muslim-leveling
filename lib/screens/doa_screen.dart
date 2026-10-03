import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/doa_api.dart';
import '../theme/app_icons.dart';
import '../l10n/app_localizations.dart';

/// Doa — level 1: daftar grup doa (dari API equran.id).
///
/// Layout: setiap grup = baris FlatCard. Hierarki: ikon tematik (identitas
/// kategori) → nama grup (bodyLg w500, tinta penuh) → count pill badge
/// (sinyal) → chevron (navigasi). Ikon dipetakan dari keyword nama grup
/// supaya tiap kategori punya identitas visual berbeda.
class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});
  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

/// Mapping keyword grup → ikon Phosphor tematik.
IconData _grupIcon(String grup) {
  final g = grup.toLowerCase();
  if (g.contains('tidur') || g.contains('malam') || g.contains('bangun')) {
    return AppIcons.bedtime;
  }
  if (g.contains('kamar mandi') || g.contains('wudhu') || g.contains('air')) {
    return AppIcons.waterDrop;
  }
  if (g.contains('pakaian') || g.contains('baju') || g.contains('hias')) {
    return AppIcons.personOutline;
  }
  if (g.contains('perlindungan') || g.contains('lindung') || g.contains('aman')) {
    return AppIcons.shieldOutlined;
  }
  if (g.contains('alam') || g.contains('cuaca') || g.contains('hujan') ||
      g.contains('angin') || g.contains('fenomena')) {
    return AppIcons.wbCloudy;
  }
  if (g.contains('petir') || g.contains('gempa') || g.contains('badai') ||
      g.contains('petir') || g.contains('kilat')) {
    return AppIcons.bolt;
  }
  if (g.contains('nikah') || g.contains('pernikahan') || g.contains('cinta') ||
      g.contains('suami') || g.contains('istri')) {
    return AppIcons.favorite;
  }
  if (g.contains('sakit') || g.contains('obat') || g.contains('sehat')) {
    return AppIcons.localFireDepartment;
  }
  if (g.contains('wafat') || g.contains('meninggal') || g.contains('kematian') ||
      g.contains('azab')) {
    return AppIcons.hourglassSimple;
  }
  if (g.contains('jenazah') || g.contains('kubur') || g.contains('makam')) {
    return AppIcons.mosqueOutlined;
  }
  if (g.contains('makan') || g.contains('minum')) {
    return AppIcons.star;
  }
  if (g.contains('masjid') || g.contains('sholat') || g.contains('salat') ||
      g.contains('adzan') || g.contains('azan')) {
    return AppIcons.mosque;
  }
  if (g.contains('quran') || g.contains('baca') || g.contains('tilawah') ||
      g.contains('surat') || g.contains('ayat')) {
    return AppIcons.menuBookOutlined;
  }
  if (g.contains('dzikir') || g.contains('zikir') || g.contains('tasbih')) {
    return AppIcons.selfImprovement;
  }
  if (g.contains('pagi') || g.contains('subuh') || g.contains('petang')) {
    return AppIcons.wbSunny;
  }
  if (g.contains('perjalanan') || g.contains('jalan') || g.contains('safar') ||
      g.contains('bepergian')) {
    return AppIcons.explore;
  }
  if (g.contains('rumah') || g.contains('keluarga') || g.contains('anak') ||
      g.contains('bayi') || g.contains('ibu')) {
    return AppIcons.homeOutlined;
  }
  if (g.contains('ilmu') || g.contains('belajar') || g.contains('orang tua')) {
    return AppIcons.school;
  }
  if (g.contains('rezeki') || g.contains('harta') || g.contains('utang')) {
    return AppIcons.cardGiftcard;
  }
  if (g.contains('haji') || g.contains('umrah') || g.contains('ziarah')) {
    return AppIcons.mosqueOutlined;
  }
  return AppIcons.volunteerActivism;
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
    final l10n = AppL10n.of(context);
    final groups = _groups;
    // Total doa = meta header. Dihitung dari grup, bukan dari _cache, supaya
    // angka di header dan jumlah kartu selalu berasal dari data yang sama.
    final total = groups?.fold<int>(0, (sum, g) => sum + g.$2);

    // Scaffold + header WAJIB di level 1: halaman ini di-push dari aksi cepat
    // Home, dan tanpa keduanya tidak ada tombol kembali sama sekali (dulu
    // ListView polos: tidak ada judul, tidak ada jalan pulang; status memuat
    // dan error juga tanpa jalan keluar). Level 2 & 3 sudah punya sejak awal.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _DoaHeader(
              title: l10n.homeQuickDoa,
              meta: total == null ? null : l10n.doaCount('$total'),
            ),
            Expanded(child: _content(l10n, groups)),
          ],
        ),
      ),
    );
  }

  /// Isi level 1: daftar grup, atau status memuat/error/kosong.
  Widget _content(AppL10n l10n, List<(String, int)>? groups) {
    final error = _error;
    if (error != null && groups == null) {
      return ErrorRetry(message: error, onRetry: _load);
    }
    if (groups == null) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    // Sumber bisa menjawab 200 dengan daftar kosong; itu bukan error, tapi
    // juga bukan daftar. Tanpa cabang ini layar tampil benar-benar kosong.
    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            l10n.doaEmptyGroups,
            textAlign: TextAlign.center,
            style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
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
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Chip ikon tematik — identitas kategori.
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(_grupIcon(grup),
                          size: 22, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Nama grup — bodyLg w500 untuk hierarki lebih tegas.
                    Expanded(
                      child: Text(grup,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodyLg().copyWith(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Count pill badge — sinyal visual, bukan angka telanjang.
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Text('$count',
                          style: AppText.labelCapsSm()
                              .copyWith(color: AppColors.primary)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(AppIcons.chevronRight,
                        size: 16,
                        color: AppColors.onSurfaceVariant
                            .withValues(alpha: 0.5)),
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

/// Header layar Doa, satu implementasi untuk ketiga level.
///
/// Dulu level 2 dan 3 masing-masing menulis baris header sendiri (judul +
/// meta + tombol kembali) dan salinannya sudah menyimpang: level 1 malah
/// tidak punya sama sekali. Satu widget = satu perilaku tombol kembali.
class _DoaHeader extends StatelessWidget {
  final String title;
  final String? meta;

  /// Tombol tambahan di kanan (mis. bagikan di level detail).
  final Widget? trailing;

  const _DoaHeader({required this.title, this.meta, this.trailing});

  @override
  Widget build(BuildContext context) {
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (meta != null)
                  Text(meta!,
                      style: AppText.labelCapsSm()
                          .copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
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
    final l10n = AppL10n.of(context);
    final items = doaApi.byGrup(grup);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _DoaHeader(title: grup, meta: l10n.doaCount('${items.length}')),
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
                  ? Center(child: Text(l10n.doaEmpty))
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
            _DoaHeader(
              title: doa.nama,
              trailing: IconButton(
                icon: Icon(AppIcons.share,
                    size: 20, color: AppColors.onSurfaceVariant),
                onPressed: () => _share(context),
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
      ..write(AppL10n.of(context).appTitle);
    try {
      const channel = MethodChannel('muslim_leveling/share');
      await channel.invokeMethod('shareText', {'text': buf.toString()});
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).doaShareFailed)),
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

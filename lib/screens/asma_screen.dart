import 'dart:io';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/share_photo_service.dart';
import '../../widgets/share_card_kit.dart';
import '../../services/asma_data.dart';
import '../../services/asma_meanings.dart';
import '../../l10n/app_localizations.dart';

/// Asmaul Husna — 99 nama Allah.
///
/// Layout: grid 2 kolom kartu + header (nomor mono, Arab Amiri besar,
/// transliterasi, arti per-locale). Tap kartu → bottom sheet detail
/// (nomor, Arab, translit, arti) + share gambar seperti share ayat Quran.
/// Data lokal (asma_data.dart + asma_meanings.dart) agar offline.
class AsmaScreen extends StatefulWidget {
  const AsmaScreen({super.key});
  @override
  State<AsmaScreen> createState() => _AsmaScreenState();
}

class _AsmaScreenState extends State<AsmaScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final q = _query.trim().toLowerCase();
    final items = q.isEmpty
        ? asmaList
        : asmaList
            .where((a) =>
                a.translit.toLowerCase().contains(q) ||
                asmaMeaning(locale, a.number).toLowerCase().contains(q) ||
                a.number.toString() == q)
            .toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(context, l10n.asmaTitle, l10n.asmaSubtitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: AppText.bodyMd()
                    .copyWith(color: AppColors.onBackground),
                decoration: InputDecoration(
                  hintText: l10n.asmaSearch,
                  hintStyle: AppText.bodyMd()
                      .copyWith(color: AppColors.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search,
                      color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(l10n.asmaEmpty,
                          style: AppText.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant)))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) =>
                          _asmaCard(context, items[i], locale),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _asmaCard(BuildContext context, AsmaItem a, String locale) {
    return PressableScale(
      onTap: () => showAsmaDetailSheet(context, item: a),
      child: FlatCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nomor mono readout HUD.
            Text('${a.number}',
                style: AppText.labelCapsSm()
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xs),
            // Arab — elemen utama, Amiri Quran.
            Text(a.arab,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.arabic(28, height: 1.6)
                    .copyWith(color: AppColors.onBackground)),
            const SizedBox(height: AppSpacing.xs),
            Text(a.translit,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyMd().copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(asmaMeaning(locale, a.number),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyMd()
                    .copyWith(color: AppColors.onSurfaceVariant)),
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

/// Bottom sheet detail 1 nama + tombol share gambar.
Future<void> showAsmaDetailSheet(BuildContext context,
    {required AsmaItem item}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AsmaDetailSheet(item: item),
  );
}

class _AsmaDetailSheet extends StatelessWidget {
  final AsmaItem item;
  const _AsmaDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('${item.number}',
                style: AppText.labelCapsSm()
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
            Text(item.arab,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppText.arabic(44, height: 1.7)
                    .copyWith(color: AppColors.onBackground)),
            const SizedBox(height: AppSpacing.sm),
            Text(item.translit,
                style: AppText.titleLg()
                    .copyWith(color: AppColors.primary)),
            Text(asmaMeaning(locale, item.number),
                textAlign: TextAlign.center,
                style: AppText.bodyLg()
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.share, size: 18),
                label: Text(l10n.qsShare),
                onPressed: () {
                  Navigator.pop(context);
                  showAsmaShareSheet(context, item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu share Asma (preview, dipakai live preview + tes golden).
/// [aspect] = tinggi/lebar: 9/16, 3/4, atau 1.0.
class AsmaSharePreviewCard extends StatelessWidget {
  final AsmaItem item;
  final String meaning;
  final double aspect;
  final ShareBgPreset? preset;
  final bool showArabic;
  final bool showMeaning;

  /// Kegelapan efektif dari pengatur "Gelap". null = patokan preset apa adanya.
  final double? scrim;

  const AsmaSharePreviewCard({
    super.key,
    required this.item,
    required this.meaning,
    this.aspect = 9 / 16,
    this.preset,
    this.showArabic = true,
    this.showMeaning = true,
    this.scrim,
  });

  @override
  Widget build(BuildContext context) {
    // Skala proporsional mengikuti tinggi kartu (pola quran_share_sheet).
    final p = preset ?? shareBgPresets[kShareDefaultPreset];
    final cardSize = Size(kShareCardWidth, kShareCardWidth / aspect);
    final s = (cardSize.height / 604).clamp(0.55, 1.0);
    final q = (cardSize.height / 604).clamp(0.85, 1.15);
    final fg = p.fg;
    final sub = p.sub;
    final accent = AppColors.secondaryFixedDim; // gold, kartu selalu gelap
    return Container(
      width: cardSize.width,
      height: cardSize.height,
      decoration: p.decoration.copyWith(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          ShareScrim(scrim: scrim ?? p.scrim),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 22 * s,
              vertical: 24 * s,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Center(
                  child: Column(
                    children: [
                      Text('ASMAUL HUSNA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11 * q,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: fg)),
                      SizedBox(height: 1 * s),
                      Text('#${item.number} / 99',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 9 * q,
                              color: sub.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                SizedBox(height: 10 * s),
                Divider(color: fg.withValues(alpha: 0.25), height: 1),
                SizedBox(height: 10 * s),
                // ── Konten tengah: Arab + translit + arti ──
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (showArabic)
                        Text(item.arab,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.amiriQuran(
                                fontSize: 44 * q, height: 1.6, color: accent)),
                      Text(item.translit,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20 * q,
                              fontWeight: FontWeight.w700,
                              color: fg)),
                      if (showMeaning)
                        Text(meaning,
                            textAlign: TextAlign.center,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14 * q, height: 1.55, color: sub)),
                    ],
                  ),
                ),
                // ── Pill sitasi: nomor + nama, bukan pengulangan translit.
                // (Dulu pill ini mencetak translit lagi — informasi yang sama
                // dua kali dalam satu kartu; di kartu ayat pill-nya sitasi.)
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14 * s, vertical: 6 * s),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        AppL10n.of(context)
                            .asmaPill(item.translit, item.number),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11 * q,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: fg)),
                  ),
                ),
                SizedBox(height: 14 * s),
                // ── Footer: badge Google Play + branding (kit) ──
                ShareCardFooter(s: s, q: q, fg: fg, sub: sub),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showAsmaShareSheet(BuildContext context,
    {required AsmaItem item}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _AsmaShareScreen(item: item),
    ),
  );
}

class _AsmaShareScreen extends StatefulWidget {
  final AsmaItem item;
  const _AsmaShareScreen({required this.item});

  @override
  State<_AsmaShareScreen> createState() => _AsmaShareScreenState();
}

class _AsmaShareScreenState extends State<_AsmaShareScreen> {
  final _repaintKey = GlobalKey();
  bool _sharing = false;
  double _aspect = 9 / 16;
  bool _showArabic = true;
  bool _showMeaning = true;

  /// Preset background + memori per-mode — kit yang sama dengan share ayat,
  /// jadi 17 preset dan perilakunya identik di kedua kartu.
  final _memory = SharePresetMemory();

  @override
  void initState() {
    super.initState();
    // Foto user yang sudah pernah dipilih dipakai lagi saat sheet dibuka.
    SharePhotoService.current().then((f) {
      if (f != null && mounted) setState(() => _memory.selectCustomPhoto(f));
    });
  }

  /// Ambil foto user, pasang ke kartu, dan beri tahu kalau gagal.
  Future<void> _pickPhoto() async {
    final l10n = AppL10n.of(context);
    try {
      final f = await pickSharePhoto(context);
      if (f == null) return; // dibatalkan user
      setState(() => _memory.selectCustomPhoto(f));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.qsPhotoFailed)));
      }
    }
  }

  Future<void> _share() async {
    final l10n = AppL10n.of(context);
    setState(() => _sharing = true);
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) setState(() => _sharing = false);
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        if (mounted) setState(() => _sharing = false);
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/asma_${widget.item.number}.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());

      const channel = MethodChannel('muslim_leveling/share');
      await channel.invokeMethod('shareFile', {
        'filePath': file.path,
        // Caption = sitasi yang sama dengan pill di kartu (satu sumber, jadi
        // caption tidak bisa beda dari gambarnya — pola share ayat).
        'text':
            '${l10n.asmaPill(widget.item.translit, widget.item.number)} | Muslim Leveling',
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.qsErr)));
      }
    }
    if (mounted) setState(() => _sharing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final meaning = asmaMeaning(locale, widget.item.number);
    final preset = _memory.preset;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text(l10n.asmaShareTitle, style: AppText.titleLg()),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AsmaSharePreviewCard(
                          item: widget.item,
                          meaning: meaning,
                          aspect: _aspect,
                          preset: preset,
                          showArabic: _showArabic,
                          showMeaning: _showMeaning),
                    ),
                  ),
                ),
              ),
            ),
            // ── Kontrol bersama: mode background, 17 preset, konten, rasio
            // (kit yang sama dengan share ayat Quran).
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShareCardControls(
                    memory: _memory,
                    onChanged: () => setState(() {}),
                    contentChips: [
                      ShareContentChipSpec(
                        label: l10n.qsContentArabic,
                        icon: Icons.translate,
                        selected: _showArabic,
                        onTap: () {
                          if (_showArabic && !_showMeaning) return;
                          setState(() => _showArabic = !_showArabic);
                        },
                      ),
                      ShareContentChipSpec(
                        label: l10n.asmaContentMeaning,
                        icon: Icons.menu_book,
                        selected: _showMeaning,
                        onTap: () {
                          if (!_showArabic && _showMeaning) return;
                          setState(() => _showMeaning = !_showMeaning);
                        },
                      ),
                    ],
                    aspect: _aspect,
                    onAspectChanged: (a) => setState(() => _aspect = a),
                    onPickPhoto: _pickPhoto,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _sharing ? null : _share,
                        icon: _sharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.share),
                        label: Text(
                          _sharing ? l10n.qsPreparing : l10n.qsShare,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

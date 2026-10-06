import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/app_localizations.dart';
import '../services/hadis_api.dart';
import '../services/share_photo_service.dart';
import '../theme/app_theme.dart';
import 'share_card_kit.dart';

// ── Kartu share hadis (9:16 yang di-capture) ──────────────────────
//
// Memakai kit yang SAMA dengan share ayat Quran: 17 preset latar (termasuk
// 9 foto bawaan + foto milik user), pengatur gelap, 3 rasio, badge Google Play
// resmi. Menambah preset/rasio di kit otomatis muncul di sini.

class HadisShareCard extends StatelessWidget {
  final HadisItem item;
  final ShareBgPreset preset;
  final Color fg;
  final Color sub;
  final bool showArabic;
  final bool showTranslation;
  final bool showHikmah;
  final Size cardSize;

  /// Kegelapan efektif dari pengatur "Gelap". null = patokan preset apa adanya
  /// (dipakai preview statis & golden test).
  final double? scrim;

  const HadisShareCard({
    super.key,
    required this.item,
    required this.preset,
    required this.fg,
    required this.sub,
    this.showArabic = true,
    this.showTranslation = true,
    this.showHikmah = false,
    this.cardSize = const Size(kShareCardWidth, kShareCardWidth * 16 / 9),
    this.scrim,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final accent = AppColors.secondaryFixedDim; // kartu selalu gelap
    // Skala proporsional dari tinggi kartu (pola quran_share_sheet).
    final s = (cardSize.height / 604).clamp(0.55, 1.0);
    final q = (cardSize.height / 604).clamp(0.85, 1.15);
    return Container(
      width: cardSize.width,
      height: cardSize.height,
      decoration: preset.decoration.copyWith(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          ShareScrim(scrim: scrim ?? preset.scrim),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 22 * s,
              vertical: 24 * s,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header: derajat hadis + nomor ──
                Center(
                  child: Column(
                    children: [
                      Text(
                        l10n.hdDetailTitle('${item.id}'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11 * q,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: fg,
                        ),
                      ),
                      // Derajat hadis ditampilkan hanya kalau sumbernya
                      // mengirimkannya (hasil pencarian tidak mengirim).
                      if (item.grade.isNotEmpty) ...[
                        SizedBox(height: 3 * s),
                        Text(
                          item.grade,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9 * q,
                            color: accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 10 * s),
                Divider(color: fg.withValues(alpha: 0.25), height: 1),
                SizedBox(height: 10 * s),
                // ── Konten tengah: Arab + terjemahan ──
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (showArabic && item.ar.isNotEmpty)
                        Text(
                          item.ar,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiriQuran(
                            fontSize: 22 * q,
                            height: 1.7,
                            color: fg,
                          ),
                        ),
                      if (showTranslation && item.idn.isNotEmpty)
                        Text(
                          item.idn,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13 * q,
                            height: 1.55,
                            color: sub,
                          ),
                        ),
                      // Hikmah opsional: teks bisa panjang, jadi dibatasi dan
                      // dipotong dengan ellipsis, bukan dibiarkan melimpah.
                      if (showHikmah &&
                          item.hikmah != null &&
                          item.hikmah!.isNotEmpty)
                        Text(
                          item.hikmah!,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11 * q,
                            height: 1.5,
                            color: accent.withValues(alpha: 0.9),
                          ),
                        ),
                    ],
                  ),
                ),
                // ── Takhrij: sumber riwayat, satu baris ──
                if (item.takhrij.isNotEmpty)
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * s,
                        vertical: 6 * s,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.takhrij,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10 * q,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 14 * s),
                // ── Footer: badge Google Play resmi + nama app (kit) ──
                ShareCardFooter(s: s, q: q, fg: fg, sub: sub),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Entry point ───────────────────────────────────────────────────

/// Kartu share hadis yang bisa dipakai di luar file ini (preview, tes).
/// [aspect] = tinggi/lebar: 9/16, 3/4, atau 1.0.
class HadisSharePreviewCard extends StatelessWidget {
  final HadisItem item;
  final double aspect;

  const HadisSharePreviewCard({
    super.key,
    required this.item,
    this.aspect = 9 / 16,
  });

  @override
  Widget build(BuildContext context) {
    final preset = shareBgPresets[kShareDefaultPreset];
    return HadisShareCard(
      item: item,
      preset: preset,
      fg: preset.fg,
      sub: preset.sub,
      cardSize: Size(kShareCardWidth, kShareCardWidth / aspect),
    );
  }
}

Future<void> showHadisShareSheet(BuildContext context, {required HadisItem item}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _HadisShareScreen(item: item),
    ),
  );
}

class _HadisShareScreen extends StatefulWidget {
  final HadisItem item;
  const _HadisShareScreen({required this.item});

  @override
  State<_HadisShareScreen> createState() => _HadisShareScreenState();
}

class _HadisShareScreenState extends State<_HadisShareScreen> {
  final _repaintKey = GlobalKey();
  bool _sharing = false;
  bool _showArabic = true;
  bool _showTranslation = true;
  bool _showHikmah = false;
  double _aspect = 9 / 16;

  /// Preset + memori per-mode tinggal di kit; sama persis dengan share ayat.
  final _memory = SharePresetMemory();

  @override
  void initState() {
    super.initState();
    // Foto user yang pernah dipilih dipakai lagi saat sheet dibuka.
    SharePhotoService.current().then((f) {
      if (f != null && mounted) setState(() => _memory.selectCustomPhoto(f));
    });
  }

  Future<void> _pickPhoto() async {
    final l10n = AppL10n.of(context);
    try {
      final f = await pickSharePhoto(context);
      if (f == null) return;
      setState(() => _memory.selectCustomPhoto(f));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.qsPhotoFailed)));
      }
    }
  }

  Size get _cardSize => Size(kShareCardWidth, kShareCardWidth / _aspect);

  ShareBgPreset get _preset => _memory.preset;

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
      final file = File('${dir.path}/hadis_${widget.item.id}.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());

      const channel = MethodChannel('muslim_leveling/share');
      await channel.invokeMethod('shareFile', {
        'filePath': file.path,
        // Sitasi sama dengan yang tercetak di kartu: satu sumber.
        'text': '${l10n.hdDetailTitle('${widget.item.id}')} | '
            '${l10n.hsShareAppName}',
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.hsErr)));
      }
    }
    if (mounted) setState(() => _sharing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final item = widget.item;
    final canHikmah = item.hikmah != null && item.hikmah!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text(l10n.hsTitle, style: AppText.titleLg()),
      ),
      body: SafeArea(
        top: false, // AppBar sudah handle atas
        child: Column(
          children: [
            // ── Preview kartu live ──
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: HadisShareCard(
                        item: item,
                        preset: _preset,
                        fg: _preset.fg,
                        sub: _preset.sub,
                        showArabic: _showArabic,
                        showTranslation: _showTranslation,
                        showHikmah: _showHikmah,
                        cardSize: _cardSize,
                        scrim: _memory.effectiveScrim,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Padding sudah disediakan kit (lihat catatan di share ayat).
            Column(
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
                        // Jangan izinkan keduanya mati — ini yang terakhir.
                        if (_showArabic && !_showTranslation) return;
                        setState(() => _showArabic = !_showArabic);
                      },
                    ),
                    ShareContentChipSpec(
                      label: l10n.qsContentTranslation,
                      icon: Icons.menu_book,
                      selected: _showTranslation,
                      onTap: () {
                        if (!_showArabic && _showTranslation) return;
                        setState(() => _showTranslation = !_showTranslation);
                      },
                    ),
                    // Hikmah khas hadis: tidak ada padanannya di kartu ayat.
                    if (canHikmah)
                      ShareContentChipSpec(
                        label: l10n.hsContentHikmah,
                        icon: Icons.lightbulb_outline,
                        selected: _showHikmah,
                        onTap: () =>
                            setState(() => _showHikmah = !_showHikmah),
                      ),
                  ],
                  aspect: _aspect,
                  onAspectChanged: (a) => setState(() => _aspect = a),
                  onPickPhoto: _pickPhoto,
                ),
                const SizedBox(height: 16),
                SizedBox(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

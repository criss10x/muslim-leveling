import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/quran_texts.g.dart';
import '../services/quran_data.dart';
import '../services/share_photo_service.dart';
import '../theme/app_theme.dart';
import 'share_card_kit.dart';

// ── Kartu 9:16 yang di-capture ────────────────────────────────────

class _QShareCard extends StatelessWidget {
  final QuranSurah surah;
  final QuranAyah ayah;
  final ShareBgPreset preset;
  final Color fg;
  final Color sub;
  final bool showArabic;
  final bool showTranslation;
  final Size cardSize;

  /// Kegelapan efektif dari pengatur "Gelap". null = pakai patokan preset apa
  /// adanya (dipakai preview statis & golden test).
  final double? scrim;

  const _QShareCard({
    required this.surah,
    required this.ayah,
    required this.preset,
    required this.fg,
    required this.sub,
    this.showArabic = true,
    this.showTranslation = true,
    this.cardSize = const Size(340, 604),
    this.scrim,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final accent =
        AppColors.secondaryFixedDim; // bright gold, card bg always dark
    // Skala proporsional: semua ukuran font & spacing diturunkan dari tinggi
    // kartu. Kartu 9:16 (604) = 1.0×; kartu 3:4 (453) ≈ 0.75×; 1:1 (340) = 1×
    // lebar tapi teks lebih besar relatif ruang — pakai rasio terhadap 604
    // supaya 1:1 tetap enak dibaca tanpa teks tumpang tindih.
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
          // Scrim gelap untuk latar estetik — komponen bersama (kit).
          ShareScrim(scrim: scrim ?? preset.scrim),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 22 * s,
              vertical: 24 * s,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header: nama surat ──
                Center(
                  child: Column(
                    children: [
                      Text(
                        surah.nameArabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiriQuran(
                          fontSize: 24 * q,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        surah.nameLatin,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11 * q,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: fg,
                        ),
                      ),
                      SizedBox(height: 1 * s),
                      Text(
                        // Kartu share ikut bahasa aktif, sama seperti daftar.
                        surahMeaning(AppL10n.of(context), surah.number),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9 * q,
                          color: sub.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * s),
                Divider(color: fg.withValues(alpha: 0.25), height: 1),
                SizedBox(height: 10 * s),
                // ── Konten tengah: Arab + terjemahan menyebar merata ──
                // Satu Expanded tunggal dengan spaceEvenly supaya gap atas-
                // tengah-bawah identik — tidak ada "lubang" di antara blok.
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (showArabic)
                        Text(
                          ayah.arabic,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiriQuran(
                            fontSize: 24 * q,
                            height: 1.7,
                            color: fg,
                          ),
                        ),
                      if (showTranslation)
                        Text(
                          ayah.translation,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14 * q,
                            height: 1.55,
                            color: sub,
                          ),
                        ),
                    ],
                  ),
                ),
                // ── Detail ayat (pill sitasi, nempel ke grup bawah) ──
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
                      l10n.dlCiteSurah(surah.nameLatin, ayah.ayah),
                      style: TextStyle(
                        fontSize: 11 * q,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: fg,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14 * s),
                // ── Footer: GP badge + nama apps (kit) ──
                ShareCardFooter(
                  s: s,
                  q: q,
                  fg: fg,
                  sub: sub,
                  // Dibiarkan di ambang minimum Google (28dp artwork) di
                  // SEMUA ukuran kartu: mengerdilkannya demi ruang akan
                  // melanggar syarat yang jadi alasan badge ini diganti.
                  badgeHeight: kPlayBadgeArtworkHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Entry point ───────────────────────────────────────────────────

/// Kartu share yang bisa dipakai di luar file ini (preview, tes).
/// [aspect] = tinggi/lebar: 9/16, 3/4, atau 1.0.
class QSharePreviewCard extends StatelessWidget {
  final QuranSurah surah;
  final QuranAyah ayah;
  final double aspect;

  const QSharePreviewCard({
    super.key,
    required this.surah,
    required this.ayah,
    this.aspect = 9 / 16,
  });

  @override
  Widget build(BuildContext context) {
    final preset = shareBgPresets[kShareDefaultPreset];
    return _QShareCard(
      surah: surah,
      ayah: ayah,
      preset: preset,
      fg: preset.fg,
      sub: preset.sub,
      cardSize: Size(340, 340 / aspect),
    );
  }
}

Future<void> showQuranShareSheet(
  BuildContext context, {
  required QuranSurah surah,
  required QuranAyah ayah,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _QuranShareScreen(surah: surah, ayah: ayah),
    ),
  );
}

class _QuranShareScreen extends StatefulWidget {
  final QuranSurah surah;
  final QuranAyah ayah;
  const _QuranShareScreen({required this.surah, required this.ayah});

  @override
  State<_QuranShareScreen> createState() => _QuranShareScreenState();
}

class _QuranShareScreenState extends State<_QuranShareScreen> {
  final _repaintKey = GlobalKey();
  bool _sharing = false;
  bool _showArabic = true;
  bool _showTranslation = true;
  double _aspect = 9 / 16; // tinggi : lebar kartu share

  /// Preset + memori per-mode tinggal di kit (kit juga memakai default
  /// preset yang sama untuk Asmaul Husna).
  final _memory = SharePresetMemory();

  @override
  void initState() {
    super.initState();
    // Foto user yang sudah pernah dipilih dipakai lagi saat sheet dibuka.
    // Tanpa ini, foto tersimpan hanya terlihat kalau user memilihnya ulang.
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
      final file = File(
        '${dir.path}/ayat_${widget.surah.number}_${widget.ayah.ayah}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List());

      const channel = MethodChannel('muslim_leveling/share');
      await channel.invokeMethod('shareFile', {
        'filePath': file.path,
        // ponytail: sitasi sama dengan yang tercetak di kartu — satu sumber,
        // jadi caption WA/IG tidak bisa beda dari gambarnya.
        'text':
            '${l10n.dlCiteSurah(widget.surah.nameLatin, widget.ayah.ayah)} | Muslim Leveling',
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.qsErr)));
      }
    }
    if (mounted) setState(() => _sharing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text(l10n.qsTitle, style: AppText.titleLg()),
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
                      child: _QShareCard(
                        surah: widget.surah,
                        ayah: widget.ayah,
                        preset: _preset,
                        fg: _preset.fg,
                        sub: _preset.sub,
                        showArabic: _showArabic,
                        showTranslation: _showTranslation,
                        cardSize: _cardSize,
                        scrim: _memory.effectiveScrim,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                    ],
                    aspect: _aspect,
                    onAspectChanged: (a) => setState(() => _aspect = a),
                    onPickPhoto: _pickPhoto,
                  ),
                  const SizedBox(height: 16),
                  // ── Tombol share ──
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
            ),
          ],
        ),
      ),
    );
  }
}

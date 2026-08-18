import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../services/quran_data.dart';
import '../theme/app_theme.dart';

// ── Background preset ─────────────────────────────────────────────

enum _QShareBgKind { solid, gradient, esthetic }

class _BgPreset {
  final String label;
  final IconData icon;
  final _QShareBgKind kind;
  final BoxDecoration decoration;
  final Color fg;
  final Color sub;
  const _BgPreset(
    this.label,
    this.icon,
    this.kind,
    this.decoration,
    this.fg,
    this.sub,
  );
}

// fg = teks utama, sub = teks sekunder -> putih di background gelap.
const _kFg = Colors.white;
const _kSub = Color(0xFFE7EAE8);

final List<_BgPreset> _bgPresets = [
  // Solid
  _BgPreset(
    'Solid',
    Icons.circle,
    _QShareBgKind.solid,
    const BoxDecoration(color: Color(0xFF0B3D2E)),
    _kFg,
    _kSub,
  ),
  _BgPreset(
    'Solid',
    Icons.circle,
    _QShareBgKind.solid,
    const BoxDecoration(color: Color(0xFF101E2B)),
    _kFg,
    _kSub,
  ),
  _BgPreset(
    'Solid',
    Icons.circle,
    _QShareBgKind.solid,
    const BoxDecoration(color: Color(0xFF2B1B33)),
    _kFg,
    _kSub,
  ),
  _BgPreset(
    'Solid',
    Icons.circle,
    _QShareBgKind.solid,
    const BoxDecoration(color: Color(0xFF3B2A10)),
    _kFg,
    _kSub,
  ),
  // Gradient
  _BgPreset(
    'Gradasi',
    Icons.gradient,
    _QShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF064E3B), Color(0xFF34D399)],
      ),
    ),
    _kFg,
    _kSub,
  ),
  _BgPreset(
    'Gradasi',
    Icons.gradient,
    _QShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3A2505), Color(0xFFF59E0B)],
      ),
    ),
    _kFg,
    _kSub,
  ),
  _BgPreset(
    'Gradasi',
    Icons.gradient,
    _QShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E1B4B), Color(0xFF6366F1)],
      ),
    ),
    _kFg,
    _kSub,
  ),
  // Estetik
  _BgPreset(
    'Estetik',
    Icons.image,
    _QShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/mosque_bg.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    _kFg,
    _kSub,
  ),
];

// ── Google Play badge (inline, tanpa aset) ────────────────────────

class _GooglePlayBadge extends StatelessWidget {
  final double compact;
  const _GooglePlayBadge({this.compact = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * compact,
        vertical: 6 * compact,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6 * compact),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow, color: Colors.white, size: 18 * compact),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GET IT ON',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 6 * compact,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'Google Play',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * compact,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Kartu 9:16 yang di-capture ────────────────────────────────────

class _QShareCard extends StatelessWidget {
  final QuranSurah surah;
  final QuranAyah ayah;
  final _BgPreset preset;
  final Color fg;
  final Color sub;

  const _QShareCard({
    required this.surah,
    required this.ayah,
    required this.preset,
    required this.fg,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        AppColors.secondaryFixedDim; // bright gold, card bg always dark
    return Container(
      width: 340,
      height: 604,
      decoration: preset.decoration.copyWith(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Scrim gelap untuk latar estetik agar teks terbaca.
          if (preset.kind == _QShareBgKind.esthetic)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
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
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        surah.nameLatin,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        surah.meaning,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: sub.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: fg.withValues(alpha: 0.25), height: 1),
                const SizedBox(height: 10),
                // ── Arab ayat ──
                Text(
                  ayah.arabic,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiriQuran(
                    fontSize: 24,
                    height: 1.7,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 12),
                // ── Terjemahan ──
                Text(
                  ayah.translation,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, height: 1.55, color: sub),
                ),
                const Spacer(),
                // ── Detail ayat ──
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'QS ${surah.nameLatin} · Ayat ${ayah.ayah}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: fg,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // ── Footer: GP badge + nama apps ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GooglePlayBadge(compact: 0.85),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Muslim Leveling',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: fg,
                            ),
                          ),
                          Text(
                            'Level Up Iman',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8,
                              color: sub.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
  int _presetIdx = _kDefaultPreset; // gradient jade
  bool _sharing = false;

  static const int _kDefaultPreset = 4;

  // ponytail: ingat pilihan per-mode biar ganti mode tidak reset pilihan.
  final Map<_QShareBgKind, int> _lastPerKind = {
    _QShareBgKind.gradient: _kDefaultPreset,
  };

  _BgPreset get _preset => _bgPresets[_presetIdx];

  List<_BgPreset> _presetsFor(_QShareBgKind kind) =>
      _bgPresets.where((p) => p.kind == kind).toList();

  void _selectMode(_QShareBgKind kind) {
    if (kind == _preset.kind) return;
    setState(() {
      _lastPerKind[_preset.kind] = _presetIdx;
      _presetIdx =
          _lastPerKind[kind] ?? _bgPresets.indexWhere((p) => p.kind == kind);
    });
  }

  Future<void> _share() async {
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
        'text':
            'QS ${widget.surah.nameLatin} Ayat ${widget.ayah.ayah} — Muslim Leveling',
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membagikan ayat. Coba lagi.')),
        );
      }
    }
    if (mounted) setState(() => _sharing = false);
  }

  @override
  Widget build(BuildContext context) {
    final kind = _preset.kind;
    final presets = _presetsFor(kind);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text('Bagikan Ayat', style: AppText.titleLg()),
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
                  // ── Mode background ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _modeChip(_QShareBgKind.solid, 'Solid', Icons.circle),
                      _modeChip(
                        _QShareBgKind.gradient,
                        'Gradasi',
                        Icons.gradient,
                      ),
                      _modeChip(_QShareBgKind.esthetic, 'Estetik', Icons.image),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── Pilihan warna/gambar dalam mode terpilih ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var k = 0; k < presets.length; k++) ...[
                        Semantics(
                          button: true,
                          label: presets.length == 1
                              ? presets[k].label
                              : '${presets[k].label} ${k + 1}',
                          selected:
                              _bgPresets.indexOf(presets[k]) == _presetIdx,
                          child: InkWell(
                            onTap: () => setState(
                              () => _presetIdx = _bgPresets.indexOf(presets[k]),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 40,
                                  height: 40,
                                  decoration: presets[k].decoration.copyWith(
                                    border:
                                        _bgPresets.indexOf(presets[k]) ==
                                            _presetIdx
                                        ? Border.all(
                                            color: AppColors.primary,
                                            width: 2.5,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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
                        _sharing ? 'Menyiapkan…' : 'Bagikan',
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

  Widget _modeChip(_QShareBgKind kind, String label, IconData icon) {
    final selected = _preset.kind == kind;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => _selectMode(kind),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.16)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: selected
                ? Border.all(color: AppColors.primary, width: 1.2)
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppText.bodyMd().copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

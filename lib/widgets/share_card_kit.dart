import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Kit kartu share bersama (ayat Quran + Asmaul Husna).
///
/// Dulu 17 preset background, badge Google Play, dan seluruh kontrol
/// (chip mode, grid swatch, chip rasio) hidup di dalam `quran_share_sheet.dart`.
/// Layar Asmaul Husna karena itu hanya bisa menyamainya dengan menyalin —
/// dan salinan kedua selalu menyimpang dari yang pertama. Sekarang keduanya
/// membaca dari file ini, jadi menambah preset berarti menambah di satu tempat.
///
/// Isi kartu TIDAK di sini: setiap layar merakit kontennya sendiri
/// (ayat = Arab + terjemahan, Asma = Arab + translit + arti).

enum ShareBgKind { solid, gradient, esthetic }

/// Satu preset background. Label TIDAK disimpan: 17 preset hanya punya 3 nilai
/// label (solid/gradasi/estetik), jadi menyimpannya 17x berarti 17 tempat untuk
/// lupa diterjemahkan. Label diturunkan dari [kind] lewat [modeLabel].
class ShareBgPreset {
  final IconData icon;
  final ShareBgKind kind;
  final BoxDecoration decoration;
  final Color fg;
  final Color sub;

  /// Opasitas dasar scrim gelap untuk preset estetik: foto terang butuh nilai
  /// tinggi agar teks putih terbaca, foto gelap boleh rendah. 0 = tanpa scrim.
  final double scrim;

  const ShareBgPreset(
    this.icon,
    this.kind,
    this.decoration,
    this.fg,
    this.sub, {
    this.scrim = 0,
  });
}

// fg = teks utama, sub = teks sekunder -> putih di background gelap.
const shareFg = Colors.white;
const shareSub = Color(0xFFE7EAE8);

final List<ShareBgPreset> shareBgPresets = [
  // Solid
  ShareBgPreset(
    Icons.circle,
    ShareBgKind.solid,
    const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 1.4,
        colors: [Color(0xFF1D6A45), Color(0xFF0B3D2E)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.circle,
    ShareBgKind.solid,
    const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 1.4,
        colors: [Color(0xFF244B73), Color(0xFF101E2B)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.circle,
    ShareBgKind.solid,
    const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 1.4,
        colors: [Color(0xFF5A3570), Color(0xFF2B1B33)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.circle,
    ShareBgKind.solid,
    const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 1.4,
        colors: [Color(0xFF6B4A1E), Color(0xFF3B2A10)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  // Gradient
  ShareBgPreset(
    Icons.gradient,
    ShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
        colors: [Color(0xFF022C22), Color(0xFF0F766E), Color(0xFF34D399)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.gradient,
    ShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
        colors: [Color(0xFFF9CE34), Color(0xFFEE2A7B), Color(0xFF6228D7)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.gradient,
    ShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00E5FF), Color(0xFF1200FF)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.gradient,
    ShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFBB73E0), Color(0xFFFF8DDB)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  // Estetik
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/mosque_bg.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.78,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_masjid_interior.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.62,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_taman_laut.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.68,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_malam_ufuk.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.30,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_masjid_pantai.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.55,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_fuji.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.65,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_karpet_balkon.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.55,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_taj_mahal.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.62,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_fractal.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.25,
  ),
];

/// Default preset kartu share (gradient jade).
const int kShareDefaultPreset = 4;

/// Lebar kartu tetap; tinggi mengikuti rasio terpilih.
const double kShareCardWidth = 340;

/// Label mode dari l10n — satu tempat, jadi tidak bisa drift dari ARB.
String shareModeLabel(BuildContext context, ShareBgKind kind) =>
    switch (kind) {
      ShareBgKind.solid => AppL10n.of(context).qsModeSolid,
      ShareBgKind.gradient => AppL10n.of(context).qsModeGradient,
      ShareBgKind.esthetic => AppL10n.of(context).qsModeEsthetic,
    };

/// Ingat preset terakhir per mode, supaya ganti mode tidak mereset pilihan
/// (mis. pilih foto ke-3 di Estetik, geser ke Gradasi, balik ke Estetik →
/// masih foto ke-3).
class SharePresetMemory {
  final Map<ShareBgKind, int> _last = {ShareBgKind.gradient: kShareDefaultPreset};
  int _index = kShareDefaultPreset;

  int get index => _index;
  ShareBgPreset get preset => shareBgPresets[_index];

  void selectPreset(ShareBgPreset p) => _index = shareBgPresets.indexOf(p);

  void selectKind(ShareBgKind kind) {
    if (kind == preset.kind) return;
    _last[preset.kind] = _index;
    _index = _last[kind] ?? shareBgPresets.indexWhere((p) => p.kind == kind);
  }

  List<ShareBgPreset> presetsFor(ShareBgKind kind) =>
      shareBgPresets.where((p) => p.kind == kind).toList();
}

// ── Google Play badge (inline, tanpa aset) ────────────────────────

class GooglePlayBadge extends StatelessWidget {
  final double compact;
  const GooglePlayBadge({super.key, this.compact = 1});

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

/// Footer kartu: badge Google Play + nama app. Satu sumber supaya kedua kartu
/// share memakai branding yang sama persis.
class ShareCardFooter extends StatelessWidget {
  final double s;
  final double q;
  final Color fg;
  final Color sub;

  const ShareCardFooter({
    super.key,
    required this.s,
    required this.q,
    required this.fg,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GooglePlayBadge(compact: 0.85 * s),
        SizedBox(width: 10 * s),
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
                  fontSize: 12 * q,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              Text(
                'Level Up Iman',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8 * q,
                  color: sub.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Scrim gelap untuk preset estetik: foto terang butuh scrim kuat agar teks
/// putih terbaca, foto gelap cukup lemah.
class ShareScrim extends StatelessWidget {
  final ShareBgPreset preset;

  const ShareScrim({super.key, required this.preset});

  @override
  Widget build(BuildContext context) {
    if (preset.kind != ShareBgKind.esthetic || preset.scrim <= 0) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(
                alpha: (preset.scrim - 0.28).clamp(0.10, 0.95),
              ),
              Colors.black.withValues(
                alpha: preset.scrim.clamp(0.10, 0.95),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu chip toggle konten (Arab / Terjemahan / Arti).
class ShareContentChipSpec {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const ShareContentChipSpec({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
}

/// Seluruh kontrol di bawah preview kartu: chip mode background, grid swatch,
/// chip toggle konten, chip rasio. Dipakai sama persis oleh share ayat Quran
/// dan share Asmaul Husna — yang berbeda hanya isi chip kontennya.
class ShareCardControls extends StatelessWidget {
  final SharePresetMemory memory;
  final VoidCallback onChanged;
  final List<ShareContentChipSpec> contentChips;
  final double aspect;
  final ValueChanged<double> onAspectChanged;

  const ShareCardControls({
    super.key,
    required this.memory,
    required this.onChanged,
    required this.contentChips,
    required this.aspect,
    required this.onAspectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final kind = memory.preset.kind;
    final presets = memory.presetsFor(kind);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Mode background ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _modeChip(context, ShareBgKind.solid, Icons.circle),
              _modeChip(context, ShareBgKind.gradient, Icons.gradient),
              _modeChip(context, ShareBgKind.esthetic, Icons.image),
            ],
          ),
          const SizedBox(height: 12),
          // ── Pilihan warna/gambar dalam mode terpilih ──
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var k = 0; k < presets.length; k++) ...[
                Semantics(
                  button: true,
                  label: presets.length == 1
                      ? shareModeLabel(context, presets[k].kind)
                      : '${shareModeLabel(context, presets[k].kind)} ${k + 1}',
                  selected: shareBgPresets.indexOf(presets[k]) == memory.index,
                  child: InkWell(
                    onTap: () {
                      memory.selectPreset(presets[k]);
                      onChanged();
                    },
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
                                shareBgPresets.indexOf(presets[k]) == memory.index
                                ? Border.all(color: AppColors.primary, width: 2.5)
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
          // ── Pilihan konten ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < contentChips.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _contentChip(contentChips[i]),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // ── Pilihan rasio: 9:16 / 3:4 / 1:1 ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final (a, label) in const [
                (9 / 16, '9:16'),
                (3 / 4, '3:4'),
                (1.0, '1:1'),
              ]) ...[
                _ratioChip(label, a),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _contentChip(ShareContentChipSpec spec) {
    final Color fg = spec.selected ? Colors.white : Colors.white70;
    return InkWell(
      onTap: spec.onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: spec.selected
              ? AppColors.primary.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: spec.selected
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(spec.icon, size: 15, color: fg),
            const SizedBox(width: 6),
            Text(
              spec.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratioChip(String label, double a) {
    final selected = aspect == a;
    return InkWell(
      onTap: () => onAspectChanged(a),
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
        child: Text(
          label,
          style: AppText.bodyMd().copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _modeChip(BuildContext context, ShareBgKind kind, IconData icon) {
    final selected = memory.preset.kind == kind;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          memory.selectKind(kind);
          onChanged();
        },
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
                shareModeLabel(context, kind),
                style: AppText.bodyMd().copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

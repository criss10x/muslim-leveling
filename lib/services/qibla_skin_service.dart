import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ── Kibla skin: siapa jabatan arsir dial di Kompas Kiblat ──
///
/// Lima skin hasil 5 mockup appllama (A..E), semua digambar oleh SATU
/// _CompassPainter parameterized (qibla_skin_painter.dart). Skin disimpan di
/// SharedPreferences 'kibla_skin' — preferensi murni visual, bukan data game,
/// jadi ikut pola ThemeService (dan tidak ikut backup cloud GameState).
enum QiblaSkin {
  nurDial('nurDial', 'Nur Dial'),
  shamseh('shamseh', 'Shamseh Medallion'),
  antique('antique', 'Antique Brass'),
  instrument('instrument', 'Instrument Minimal'),
  midnight('midnight', 'Midnight Gold');

  const QiblaSkin(this.id, this.label);

  final String id;
  final String label;

  static QiblaSkin byId(String id) {
    for (final s in QiblaSkin.values) {
      if (s.id == id) return s;
    }
    return defaultSkin;
  }

  static const QiblaSkin defaultSkin = QiblaSkin.nurDial;
}

/// ── Palet skin: warna muka dial, bezel, jarum, aksen, readout ──
/// Semua warna eksplisit (bukan AppColors) — skin boleh "jatuh ke warna yang
/// tak ada di world Night Watch" karena dial adalah instrumen, bukan surface
/// UI. Critique impeccable: kontras antar-skin harus jelas; antik C & gold E
/// boleh dianggap "objek dunia" yang menantang aturan warna.
class QiblaSkinSpec {
  const QiblaSkinSpec({
    required this.faceTop,
    required this.faceBottom,
    required this.ring,
    required this.ringDim,
    required this.needle,
    required this.needleTailNorth,
    required this.tick,
    required this.tickMajor,
    required this.cardinal,
    required this.cardinalEmph,
    required this.textDim,
    required this.kaabaBadgeBg,
    required this.kaabaBadgeBorder,
    required this.showKaabaOnNeedleTip,
    required this.showHourTicks,
    required this.faceGlow,
  });

  final Color faceTop;
  final Color faceBottom;
  final Color ring;          // ring utama (idle)
  final Color ringDim;       // ring saat mencari (dim)
  final Color needle;        // needle head (kiblat)
  final Color? needleTailNorth; // disputed dial C: crimson = utara
  final Color tick;
  final Color tickMajor;
  final Color cardinal;
  final Color cardinalEmph;
  final Color textDim;
  final Color kaabaBadgeBg;
  final Color kaabaBadgeBorder;
  final bool showKaabaOnNeedleTip;
  final bool showHourTicks;   // antiix C jam berorient: 12 tick menit
  final double faceGlow;      // 0..1 idle glow ring (dim state sebelum aligned)
}

QiblaSkinSpec specFor(QiblaSkin skin) {
  switch (skin) {
    case QiblaSkin.nurDial:
      // A · Nur Dial — jade neon di mint gelap (identitas app default)
      return QiblaSkinSpec(
        faceTop: const Color(0xFF182B22),
        faceBottom: const Color(0xFF101B16),
        ring: const Color(0xFF34D399),
        ringDim: const Color(0xFF34D399),
        needle: const Color(0xFF00E1EF),
        needleTailNorth: null,
        tick: const Color(0x66FFFFFF),
        tickMajor: const Color(0xFF34D399),
        cardinal: const Color(0xFFDCE4DE),
        cardinalEmph: const Color(0xFF34D399),
        textDim: const Color(0xFFBACAC1),
        kaabaBadgeBg: const Color(0xFF111111),
        kaabaBadgeBorder: const Color(0xFFE9C400),
        showKaabaOnNeedleTip: true,
        showHourTicks: true,
        faceGlow: 0.18,
      );
    case QiblaSkin.shamseh:
      // B · Shamseh Medallion — emerald arung + bezel putih, band merah
      return QiblaSkinSpec(
        faceTop: const Color(0xFF0E2A1E),
        faceBottom: const Color(0xFF0B1F16),
        ring: const Color(0xFF34D399),
        ringDim: const Color(0xFF34D399),
        needle: const Color(0xFFF6FDF5),
        needleTailNorth: const Color(0xFFDC2626),
        tick: const Color(0x99FFFFFF),
        tickMajor: const Color(0xFFF6FDF5),
        cardinal: const Color(0xFFA7D8B8),
        cardinalEmph: const Color(0xFF34D399),
        textDim: const Color(0xFFA7D8B8),
        kaabaBadgeBg: const Color(0xFF0E2A1E),
        kaabaBadgeBorder: const Color(0xFF34D399),
        showKaabaOnNeedleTip: true,
        showHourTicks: true,
        faceGlow: 0.14,
      );
    case QiblaSkin.antique:
      // C · Antique Brass — ivory, mandala terukir, jarum crimson = utara
      return QiblaSkinSpec(
        faceTop: const Color(0xFFF4E8CF),
        faceBottom: const Color(0xFFE7D6AF),
        ring: const Color(0xFF8A6D3B),
        ringDim: const Color(0xFF8A6D3B),
        needle: const Color(0xFFF7F0DC),
        needleTailNorth: const Color(0xFF9F1D1D),
        tick: const Color(0xFF8A6D3B),
        tickMajor: const Color(0xFF5C4300),
        cardinal: const Color(0xFF5C4300),
        cardinalEmph: const Color(0xFF9F1D1D),
        textDim: const Color(0xFF6B5B3E),
        kaabaBadgeBg: const Color(0xFFF7F0DC),
        kaabaBadgeBorder: const Color(0xFF8A6D3B),
        showKaabaOnNeedleTip: true,
        showHourTicks: false,   // 8 jam angka hanya di layar penuh
        faceGlow: 0.0,
      );
    case QiblaSkin.instrument:
      // D · Instrument Minimal — putih + emerald hari, paling legible
      return QiblaSkinSpec(
        faceTop: const Color(0xFFFFFFFF),
        faceBottom: const Color(0xFFEDF1F4),
        ring: const Color(0xFF047857),
        ringDim: const Color(0xFF047857),
        needle: const Color(0xFF047857),
        needleTailNorth: null,
        tick: const Color(0xFF8B929E),
        tickMajor: const Color(0xFF1A1A1A),
        cardinal: const Color(0xFF5C6370),
        cardinalEmph: const Color(0xFF047857),
        textDim: const Color(0xFF5C6370),
        kaabaBadgeBg: const Color(0xFFFFFFFF),
        kaabaBadgeBorder: const Color(0xFF047857),
        showKaabaOnNeedleTip: true,
        showHourTicks: true,
        faceGlow: 0.0,
      );
    case QiblaSkin.midnight:
      // E · Midnight Gold — obsidian + emas, kardinal serif
      return QiblaSkinSpec(
        faceTop: const Color(0xFF211D12),
        faceBottom: const Color(0xFF0E0C05),
        ring: const Color(0xFFE8B923),
        ringDim: const Color(0xFFE8B923),
        needle: const Color(0xFFFFE16D),
        needleTailNorth: null,
        tick: const Color(0x66FFE16D),
        tickMajor: const Color(0xFFFFE16D),
        cardinal: const Color(0xFFFFE16D),
        cardinalEmph: const Color(0xFFFFE16D),
        textDim: const Color(0xFFB49B45),
        kaabaBadgeBg: const Color(0xFF0E0C05),
        kaabaBadgeBorder: const Color(0xFFE8B923),
        showKaabaOnNeedleTip: true,
        showHourTicks: true,
        faceGlow: 0.14,
      );
  }
}

/// ── Persistensi pilihan skin ──
/// Pola sama seperti ThemeNotifier, hanya get/set; tidak diembed GameState
/// supaya backup cloud tidak membawa preferensi visual peralatan.
class QiblaSkinNotifier extends ChangeNotifier {
  static const _prefKey = 'kibla_skin';
  QiblaSkin _skin = QiblaSkin.defaultSkin;

  QiblaSkin get skin => _skin;
  QiblaSkinSpec get spec => specFor(_skin);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _skin = QiblaSkin.byId(prefs.getString(_prefKey) ?? '');
    notifyListeners();
  }

  Future<void> setSkin(QiblaSkin skin) async {
    _skin = skin;
    await (await SharedPreferences.getInstance()).setString(_prefKey, skin.id);
    notifyListeners();
  }
}

final QiblaSkinNotifier qiblaSkinNotifier = QiblaSkinNotifier();

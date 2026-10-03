import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../l10n/app_localizations.dart';
import '../../services/qibla_skin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../theme/app_icons.dart';

part 'qibla_skin_painter.dart';
part 'qibla_skin_picker.dart';

/// Koordinat Ka'bah (Masjidil Haram, Makkah)
const _kaabaLat = 21.4225;
const _kaabaLon = 39.8262;

/// Koordinat kota-kota Indonesia (lat, lon)
const _cityCoords = <String, List<double>>{
  // Sumatera
  'Medan': [3.5952, 98.6722],
  'Padang': [-0.9471, 100.4172],
  'Pekanbaru': [0.5071, 101.4478],
  'Jambi': [-1.6101, 103.6131],
  'Palembang': [-2.9761, 104.7754],
  'Bengkulu': [-3.8004, 102.2655],
  'Bandar Lampung': [-5.3971, 105.2668],
  'Tanjung Pinang': [0.9186, 104.4558],
  // Jawa
  'Jakarta': [-6.2088, 106.8456],
  'Bandung': [-6.9175, 107.6191],
  'Semarang': [-6.9667, 110.4167],
  'Yogyakarta': [-7.7956, 110.3695],
  'Surabaya': [-7.2575, 112.7521],
  'Serang': [-6.1200, 106.1503],
  'Cirebon': [-6.7320, 108.5523],
  'Tegal': [-6.8694, 109.1402],
  'Pekalongan': [-6.8886, 109.6756],
  'Magelang': [-7.4705, 110.2175],
  'Solo': [-7.5755, 110.8243],
  'Malang': [-7.9666, 112.6326],
  'Bogor': [-6.5950, 106.8166],
  'Bekasi': [-6.2383, 106.9756],
  'Depok': [-6.4025, 106.7942],
  'Tangerang': [-6.1783, 106.6319],
  'Tangerang Selatan': [-6.2883, 106.7189],
  // Bali & Nusa Tenggara
  'Denpasar': [-8.6705, 115.2126],
  'Mataram': [-8.5833, 116.1167],
  'Kupang': [-10.1772, 123.6070],
  // Kalimantan
  'Pontianak': [-0.0263, 109.3425],
  'Palangka Raya': [-2.2096, 113.9108],
  'Banjarmasin': [-3.3186, 114.5944],
  'Samarinda': [-0.5022, 117.1536],
  'Tanjung Selor': [2.8500, 117.3667],
  // Sulawesi
  'Makassar': [-5.1477, 119.4327],
  'Palu': [-0.8917, 119.8707],
  'Kendari': [-3.9985, 122.5130],
  'Manado': [1.4748, 124.8421],
  'Gorontalo': [0.5435, 123.0568],
  // Maluku & Papua
  'Ambon': [-3.6954, 128.1814],
  'Sofifi': [0.7333, 127.5667],
  'Jayapura': [-2.5916, 140.6690],
  'Manokwari': [-0.8615, 134.0630],
};

/// Hitung arah kiblat (bearing) dari lokasi user ke Ka'bah.
/// @return bearing dalam derajat (0-360), di mana 0 = Utara
double _calculateQiblaBearing(double userLat, double userLon) {
  final lat1 = userLat * math.pi / 180;
  final lat2 = _kaabaLat * math.pi / 180;
  final dLon = (_kaabaLon - userLon) * math.pi / 180;

  final y = math.sin(dLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  var bearing = math.atan2(y, x) * 180 / math.pi;
  bearing = (bearing + 360) % 360;
  return bearing;
}

/// Hitung jarak ke Ka'bah (km) — rumus Haversine
double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0; // radius bumi (km)
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

/// Cari koordinat kota berdasarkan nama — match flexible
List<double>? _findCityCoords(String cityName) {
  final lower = cityName.toLowerCase();
  // Exact match
  for (final entry in _cityCoords.entries) {
    if (entry.key.toLowerCase() == lower) return entry.value;
  }
  // Contains match (mis. "Kota Denpasar" → "Denpasar")
  for (final entry in _cityCoords.entries) {
    if (lower.contains(entry.key.toLowerCase())) return entry.value;
  }
  // Reverse: city name contains the query
  for (final entry in _cityCoords.entries) {
    if (entry.key.toLowerCase().contains(lower)) return entry.value;
  }
  return null;
}

/// Interpolasi sudut lewat busur TERPENDEK (350°→10° lewat utara, bukan
/// muter balik 340°). Kunci kompas yang smooth tanpa "lompat" di 0/360.
double _lerpAngle(double a, double b, double t) {
  final diff = (b - a + 540) % 360 - 180;
  return (a + diff * t + 360) % 360;
}

/// Qibla Screen — kompas neon full screen dengan arrow ke Ka'bah.
class QiblaScreen extends StatefulWidget {
  final String cityName;

  const QiblaScreen({super.key, required this.cityName});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  // ponytail: dibaca sekali per build; semua sub-builder pakai ini.
  AppL10n get _l10n => AppL10n.of(context);
  /// Azimuth mentah hasil sensor (target), dan yang dirender (smoothed).
  double _targetAzimuth = 0;
  double _displayAzimuth = 0;
  bool _hasFix = false;
  bool _sensorAvailable = true;
  bool _wasAligned = false;

  /// Preferensi sistem "kurangi gerakan". Denyut glow saat sejajar dimatikan
  /// kalau aktif (glow tetap menyala statis, jadi statusnya tidak hilang).
  bool _reduceMotion = false;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  final List<double> _gravity = [0, 0, 0];
  final List<double> _geomagnetic = [0, 0, 0];
  bool _hasAccel = false;
  bool _hasMag = false;

  late final double _qiblaBearing;
  late final double _distance;
  late final AnimationController _pulse;

  /// Low-pass sensor (0..1, kecil = makin halus tapi makin "berat").
  static const _sensorAlpha = 0.15;

  /// Kecepatan jarum mengejar target per event sensor.
  static const _needleLerp = 0.22;

  @override
  void initState() {
    super.initState();
    // Skin kompas: preferensi tersimpan → dimuat sekali per buka layar
    // (listenable di-refresh saat picker ditutup; setState cukup).
    qiblaSkinNotifier.load();
    final coords = _findCityCoords(widget.cityName) ?? [-6.2088, 106.8456];
    _qiblaBearing = _calculateQiblaBearing(coords[0], coords[1]);
    _distance = _haversineDistance(coords[0], coords[1], _kaabaLat, _kaabaLon);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _initSensors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_reduceMotion && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  void _initSensors() {
    _accelSub = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
      (event) {
        // Low-pass filter — buang jitter frekuensi tinggi dari tangan.
        _gravity[0] += _sensorAlpha * (event.x - _gravity[0]);
        _gravity[1] += _sensorAlpha * (event.y - _gravity[1]);
        _gravity[2] += _sensorAlpha * (event.z - _gravity[2]);
        _hasAccel = true;
        _updateOrientation();
      },
      onError: (e) {
        if (mounted) setState(() => _sensorAvailable = false);
      },
    );

    _magSub = magnetometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
      (event) {
        _geomagnetic[0] += _sensorAlpha * (event.x - _geomagnetic[0]);
        _geomagnetic[1] += _sensorAlpha * (event.y - _geomagnetic[1]);
        _geomagnetic[2] += _sensorAlpha * (event.z - _geomagnetic[2]);
        _hasMag = true;
        _updateOrientation();
      },
      onError: (e) {
        if (mounted) setState(() => _sensorAvailable = false);
      },
    );
  }

  void _updateOrientation() {
    if (!_hasAccel || !_hasMag) return;

    final r = _getRotationMatrix(_gravity, _geomagnetic);
    if (r == null) return;

    final orientation = _getOrientation(r);
    var az = orientation[0] * 180 / math.pi;
    az = (az + 360) % 360;
    _targetAzimuth = az;

    // Fix pertama: langsung snap biar gak muter dari 0. Setelahnya jarum
    // mengejar target lewat busur terpendek — gerakan jadi smooth.
    final next = _hasFix
        ? _lerpAngle(_displayAzimuth, _targetAzimuth, _needleLerp)
        : _targetAzimuth;
    _hasFix = true;

    // Skip repaint kalau pergeseran tak kasat mata (hemat frame).
    final delta = ((next - _displayAzimuth + 540) % 360 - 180).abs();
    if (delta < 0.05) return;

    if (!mounted) return;
    setState(() => _displayAzimuth = next);

    // Haptic + pulse saat masuk/keluar posisi sejajar kiblat.
    final aligned = _isAligned;
    if (aligned && !_wasAligned) {
      HapticFeedback.mediumImpact();
      // Hormati "kurangi gerakan": glow tetap menyala statis (0.45) karena
      // _pulse.value berhenti di 0, jadi status sejajar tidak hilang.
      if (!_reduceMotion) _pulse.repeat(reverse: true);
    } else if (!aligned && _wasAligned) {
      _pulse.stop();
      _pulse.value = 0;
    }
    _wasAligned = aligned;
  }

  /// Selisih sudut ke kiblat, dinormalisasi -180..180.
  double get _relativeAngle =>
      (_qiblaBearing - _displayAzimuth + 540) % 360 - 180;

  bool get _isAligned => _relativeAngle.abs() < 5;

  /// Port SensorManager.getRotationMatrix dari Android
  List<double>? _getRotationMatrix(List<double> g, List<double> m) {
    final ax = g[0], ay = g[1], az = g[2];
    final ex = m[0], ey = m[1], ez = m[2];

    // Normalize accelerometer
    final aNorm = math.sqrt(ax * ax + ay * ay + az * az);
    if (aNorm == 0) return null;
    final nx = ax / aNorm, ny = ay / aNorm, nz = az / aNorm;

    // H = E x A
    final hx = ey * nz - ez * ny;
    final hy = ez * nx - ex * nz;
    final hz = ex * ny - ey * nx;
    final hNorm = math.sqrt(hx * hx + hy * hy + hz * hz);
    if (hNorm == 0) return null;
    final hnx = hx / hNorm, hny = hy / hNorm, hnz = hz / hNorm;

    // M = A x H
    final mx = ny * hnz - nz * hny;
    final my = nz * hnx - nx * hnz;
    final mz = nx * hny - ny * hnx;

    return [hnx, hny, hnz, mx, my, mz, nx, ny, nz];
  }

  /// Port SensorManager.getOrientation
  List<double> _getOrientation(List<double> r) {
    final azimuth = math.atan2(r[1], r[4]);
    return [azimuth, 0, 0];
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _magSub?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    final aligned = _isAligned;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Entrance(child: _header(l10n)),
              if (!_sensorAvailable)
                _sensorUnavailableCard(l10n)
              else ...[
                Expanded(
                  child: Center(
                    child: Entrance(
                      delay: const Duration(milliseconds: 120),
                      child: _compass(l10n, aligned),
                    ),
                  ),
                ),
                Entrance(
                  delay: const Duration(milliseconds: 200),
                  child: _turnHint(l10n, aligned),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: Column(
                  children: [
                    Entrance(
                      delay: const Duration(milliseconds: 280),
                      child: _alignmentCard(l10n, aligned),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Entrance(
                      delay: const Duration(milliseconds: 360),
                      child: _statChips(l10n),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _l10n.qiblaCalibrationHint,
                      textAlign: TextAlign.center,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppL10n l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          PressableScale(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Icon(AppIcons.arrowBack,
                  color: AppColors.onSurface, size: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Pintu masuk ganti skin. Dulu hanya emoji 🎨 + nama skin, sehingga
          // terbaca sebagai badge status, bukan tombol: user harus menebak
          // bahwa label itu bisa ditekan. Sekarang ada kata kerja + chevron.
          Semantics(
            button: true,
            label: l10n.qiblaSkinChange,
            child: PressableScale(
              onTap: () => showQiblaSkinPicker(context),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ikon app, bukan emoji: emoji render berbeda-beda per HP
                    // dan tidak ikut warna tema.
                    Icon(AppIcons.paletteOutlined,
                        size: 15, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.qiblaSkinChange,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.labelCapsSm()
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(AppIcons.chevronRight,
                        size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_l10n.qiblaCompassLabel,
                    style: AppText.labelCaps()
                        .copyWith(color: AppColors.primary, fontSize: 10)),
                const SizedBox(height: 2),
                Text(_l10n.qiblaTitle, style: AppText.displayHero(24)),
                Text(
                  l10n.qiblaCityDistance(
                    widget.cityName, _distance.toStringAsFixed(0)),
                  style: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compass(AppL10n l10n, bool aligned) {
    // Skin dial dari preferensi pengguna (5 pilihan, appllama critique v9).
    // Satu painter per skin; state aligned tetap menyala glow dial.
    final spec = qiblaSkinNotifier.spec;
    final skin = qiblaSkinNotifier.skin;
    final CustomPainter painter = switch (skin) {
      QiblaSkin.nurDial => _NurDialPainter(
          azimuth: _displayAzimuth,
          qiblaBearing: _qiblaBearing,
          isAligned: aligned,
          glow: aligned ? 0.45 + 0.55 * _pulse.value : 0.0,
          spec: spec,
        ),
      QiblaSkin.shamseh => _ShamsehPainter(
          azimuth: _displayAzimuth,
          qiblaBearing: _qiblaBearing,
          isAligned: aligned,
          glow: aligned ? 0.45 + 0.55 * _pulse.value : 0.0,
          spec: spec,
        ),
      QiblaSkin.antique => _AntiquePainter(
          azimuth: _displayAzimuth,
          qiblaBearing: _qiblaBearing,
          isAligned: aligned,
          glow: aligned ? 0.45 + 0.55 * _pulse.value : 0.0,
          spec: spec,
        ),
      QiblaSkin.instrument => _InstrumentPainter(
          azimuth: _displayAzimuth,
          qiblaBearing: _qiblaBearing,
          isAligned: aligned,
          glow: aligned ? 0.45 + 0.55 * _pulse.value : 0.0,
          spec: spec,
        ),
      QiblaSkin.midnight => _MidnightPainter(
          azimuth: _displayAzimuth,
          qiblaBearing: _qiblaBearing,
          isAligned: aligned,
          glow: aligned ? 0.45 + 0.55 * _pulse.value : 0.0,
          spec: spec,
        ),
    };

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => ListenableBuilder(
        listenable: qiblaSkinNotifier,
        builder: (_, __) => SizedBox(
          width: 300,
          height: 300,
          child: CustomPaint(painter: painter),
        ),
      ),
    );
  }

  /// Chip petunjuk arah putar — memberi tahu aksi konkret, bukan cuma angka.
  Widget _turnHint(AppL10n l10n, bool aligned) {
    final rel = _relativeAngle;
    final degrees = rel.abs().round();
    final (label, color) = aligned
        ? (l10n.qiblaAligned, AppColors.primary)
        : rel > 0
            ? (l10n.qiblaTurnRight('$degrees'), AppColors.tertiary)
            : (l10n.qiblaTurnLeft('$degrees'), AppColors.tertiary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: aligned ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        boxShadow: aligned
            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16)]
            : null,
      ),
      child: Text(
        label,
        style: AppText.titleLg().copyWith(color: color, fontSize: 14),
      ),
    );
  }

  Widget _sensorUnavailableCard(AppL10n l10n) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: GlassPanel(
            borderColor: AppColors.tertiary.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.qiblaNoSensorTitle,
                    style: AppText.titleLg().copyWith(color: AppColors.tertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.qiblaNoSensorBody,
                    textAlign: TextAlign.center,
                    style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.qiblaCityBearing(widget.cityName),
                      style: AppText.bodyMd()),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.qiblaNorthDegrees('${_qiblaBearing.toInt()}'),
                    style: AppText.displayHero(36).copyWith(
                      color: AppColors.tertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.qiblaTurnInstruction('${_qiblaBearing.toInt()}'),
                    textAlign: TextAlign.center,
                    style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _alignmentCard(AppL10n l10n, bool aligned) {
    final color = aligned ? AppColors.primary : AppColors.onSurface;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: aligned
              ? [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.tertiary.withValues(alpha: 0.15)
                ]
              : [
                  AppColors.surfaceContainer,
                  AppColors.surfaceContainer.withValues(alpha: 0.6)
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: aligned
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: aligned
            ? [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20)
              ]
            : null,
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              aligned ? '✅' : '🧭',
              key: ValueKey(aligned),
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aligned
                      ? l10n.qiblaAlignedTitle
                      : l10n.qiblaAimTitle,
                  style: AppText.titleLg().copyWith(color: color, fontSize: 15),
                ),
                Text(
                  l10n.qiblaOffset(_relativeAngle.abs().toStringAsFixed(1)),
                  style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChips(AppL10n l10n) {
    Widget chip(String label, String value, Color color) {
      return Expanded(
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          borderColor: color.withValues(alpha: 0.35),
          child: Column(
            children: [
              Text(label,
                  style: AppText.labelCaps().copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 10)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppText.displayHero(20)
                    .copyWith(color: color, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(l10n.qiblaStatTitle, '${_qiblaBearing.toInt()}°', AppColors.tertiary),
        const SizedBox(width: AppSpacing.sm),
        chip(l10n.qiblaDistanceTitle, '${_distance.toStringAsFixed(0)} km',
            AppColors.primary),
      ],
    );
  }
}


part of 'qibla_screen.dart';

/// ── 5 Painter skin kiblat — satu API, lima wajah ──
/// Semua painter menerima azimuth + qiblaBearing + glow kristal + spec pattern
/// warna via [QiblaSkinSpec]. Setiap painter menumpuk render dialnya sendiri
/// sesuai maison design masing-masing (Nur / Shamseh / Antique / Instrument /
/// Midnight), mereka ABSTRAK over azimuth world logika.

/// A · Nur Dial — Jade Neon
class _NurDialPainter extends BaseQiblaPainter {
  _NurDialPainter({required super.azimuth, required super.qiblaBearing,
      required super.isAligned, required super.glow, required super.spec});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(center.dx, center.dy) - 30;
    final bezel = radius + 14;

    // dial mint gelap dengan radial gradient
    final bg = Paint()
      ..shader = RadialGradient(
        colors: [spec.faceTop, spec.faceBottom],
      ).createShader(Rect.fromCircle(center: center, radius: bezel));
    canvas.drawCircle(center, bezel, bg);

    // glow ring (satu-satunya *glow-only-when-aligned* — diligence)
    _paintRing(canvas, center, bezel, spec.ring, isAligned: isAligned, glow: glow);

    _paintTicks(canvas, center, radius, hourTicks: spec.showHourTicks);

    _paintCardinals(canvas, center, radius,
        labels: const ['N', 'E', 'S', 'W']);

    // Jarum kiblat cyan glow
    _paintNeedle(canvas, center, radius,
        needleColor: spec.needle,
        headColor: spec.needle,
        glowColor: spec.needle.withValues(alpha: 0.5),
        northTail: spec.needleTailNorth);

    // Badge Ka'bah di bezel atas (jarum menunjuk kiblat)
    _paintKaabaBadgeOnRing(canvas, center, bezel,
        badgeBg: spec.kaabaBadgeBg, badgeBorder: spec.kaabaBadgeBorder);
  }
}

/// B · Shamseh Medallion — Arabesque Emerald: rosette tone-on-tone
class _ShamsehPainter extends BaseQiblaPainter {
  _ShamsehPainter({required super.azimuth, required super.qiblaBearing,
      required super.isAligned, required super.glow, required super.spec});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(center.dx, center.dy) - 30;
    final bezel = radius + 14;

    // Muka emerald dua-tone
    final bg = Paint()
      ..shader = RadialGradient(
        colors: [spec.faceTop, spec.faceBottom],
      ).createShader(Rect.fromCircle(center: center, radius: bezel));
    canvas.drawCircle(center, bezel, bg);

    // Rosette surya: 12 kelopak conic (r1 dan r2 sup-kontras level sebagai relief)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var i = 0; i < 12; i++) {
      final path = Path();
      final outer = radius - 40;
      final inner = radius * 0.32;
      path.moveTo(0, -inner);
      path.quadraticBezierTo(outer * 0.5, -outer * 0.72, 0, -outer);
      path.quadraticBezierTo(-outer * 0.5, -outer * 0.72, 0, -inner);
      final paint = Paint()
        ..color = const Color(0xFF34D399).withValues(alpha: i % 2 == 0 ? 0.18 : 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
      canvas.rotate(math.pi / 6);
    }
    canvas.restore();

    _paintRing(canvas, center, bezel, spec.ring, isAligned: isAligned, glow: glow);

    _paintTicks(canvas, center, radius, hourTicks: spec.showHourTicks);

    _paintCardinals(canvas, center, radius,
        labels: const ['N', 'E', 'S', 'W']);

    // Jarum dua-panel: kepala putih + ekor merah (biar klarifiksi arah 180°)
    _paintNeedle(canvas, center, radius,
        needleColor: spec.needle,
        headColor: spec.needle,
        glowColor: spec.needle.withValues(alpha: 0.3),
        northTail: spec.needleTailNorth);

    // Band merah di ring NW (penanda kiblat independent dari jarum)
    _paintBandOnRing(canvas, center, bezel,
        color: const Color(0xFFDC2626));

    _paintKaabaBadgeOnRing(canvas, center, bezel,
        badgeBg: spec.kaabaBadgeBg, badgeBorder: spec.kaabaBadgeBorder);
  }
}

/// C · Antique Brass — muka ivory, mandala, bintang 8, jarum crimson = utara
class _AntiquePainter extends BaseQiblaPainter {
  _AntiquePainter({required super.azimuth, required super.qiblaBearing,
      required super.isAligned, required super.glow, required super.spec});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(center.dx, center.dy) - 30;
    final bezel = radius + 14;

    // Muka ivory pucat (perkotaan klasik)
    final bg = Paint()
      ..color = spec.faceTop;
    canvas.drawCircle(center, bezel, bg);

    // Mandala etch dua ring konsentris
    _paintRing(canvas, center, radius * 0.94, spec.ring.withValues(alpha: 0.5),
        isAligned: false, glow: 0, thin: true);
    _paintRing(canvas, center, radius * 0.86, spec.ring.withValues(alpha: 0.35),
        isAligned: false, glow: 0, thin: true);

    // Bintang 8 sudut bronze (pitch mandala)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final starPaint = Paint()
      ..color = const Color(0xFF8A6D3B).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final rad = math.pi / 8 * i - math.pi / 2;
      final r = i.isEven ? radius * 0.55 : radius * 0.42;
      final p = Offset(math.cos(rad) * r, math.sin(rad) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, starPaint);
    canvas.restore();

    // Tick + kardinal serif
    _paintCardinals(canvas, center, radius, serif: true,
        labels: const ['N', 'E', 'S', 'W']);

    // Jarum crimson UTARA — bukan indikator kiblat, hanya arah kompas alam.
    // Critique impeccable: kiblat tunggal via panah origami, bukan via jarum.
    final northPaint = Paint()
      ..color = spec.needleTailNorth!.withValues(alpha: 0.8);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final tip0 = -(radius - 70);
    final pathN = Path()
      ..moveTo(0, tip0)
      ..lineTo(-6, tip0 + 24)
      ..lineTo(6, tip0 + 24)
      ..close();
    canvas.drawPath(pathN, northPaint);
    canvas.restore();

    // Panah kiblat origami IVORY + outline bronze — satu-satunya penunjuk.
    final relativeAngle = qiblaBearing - azimuth;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(relativeAngle * math.pi / 180);

    final armPath = Path()
      ..moveTo(0, -(radius - 56))
      ..lineTo(-7, -(radius - 30))
      ..lineTo(-3, -(radius - 30))
      ..lineTo(-3, 24)
      ..lineTo(3, 24)
      ..lineTo(3, -(radius - 30))
      ..lineTo(7, -(radius - 30))
      ..close();
    final armPaint = Paint()..color = spec.needle;
    canvas.drawPath(armPath, armPaint);
    // outline bronze 1.5px — cukup tampak di muka ivory
    final outlinePaint = Paint()
      ..color = const Color(0xFF8A6D3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(armPath, outlinePaint);
    canvas.restore();

    _paintRing(canvas, center, bezel, spec.ring, isAligned: isAligned, glow: glow);

    // Badge Ka'bah — di bezel atas (utara). Bukan indikator arah; hanya brand.
    _paintKaabaBadgeOnRing(canvas, center, bezel,
        badgeBg: spec.kaabaBadgeBg, badgeBorder: spec.kaabaBadgeBorder);
  }
}

/// D · Instrument Minimal — muka putih, tick abu, arc 45° emerald
class _InstrumentPainter extends BaseQiblaPainter {
  _InstrumentPainter({required super.azimuth, required super.qiblaBearing,
      required super.isAligned, required super.glow, required super.spec});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(center.dx, center.dy) - 30;
    final bezel = radius + 14;

    // Muka putih penuh (light theme)
    final bg = Paint()
      ..shader = RadialGradient(
        colors: [spec.faceTop, spec.faceBottom],
      ).createShader(Rect.fromCircle(center: center, radius: bezel));
    canvas.drawCircle(center, bezel, bg);

    // Ring hairline abu
    final hairline = Paint()
      ..color = const Color(0xFFC5CAD3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, hairline);

    _paintTicks(canvas, center, radius, hourTicks: spec.showHourTicks);
    _paintCardinals(canvas, center, radius, labels: const ['N', 'E', 'S', 'W']);

    // Arc 45° di ring — mengarah ke kiblat (critique: 45° pas "1/8 ring")
    final rel = qiblaBearing - azimuth;
    final arcPaint = Paint()
      ..color = spec.ring.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 14),
      (rel - 22.5) * math.pi / 180,
      45 * math.pi / 180,
      false, arcPaint,
    );

    // Jarum emerald (fixes_v8: radius aman)
    _paintNeedle(canvas, center, radius,
        needleColor: spec.needle, headColor: spec.needle);
    // Ned tail visible
    canvas.drawCircle(center, 22, Paint()
      ..color = spec.ring.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    canvas.drawCircle(center, 6, Paint()..color = spec.ring);

    // Badge Ka'bah CSS kubus kecil (bukan emoji)
    _paintKaabaBadgeOnRing(canvas, center, bezel,
        badgeBg: spec.kaabaBadgeBg, badgeBorder: spec.kaabaBadgeBorder,
        drawCube: true);
  }
}

/// E · Midnight Gold — obsidian + emas, kardinal serif
class _MidnightPainter extends BaseQiblaPainter {
  _MidnightPainter({required super.azimuth, required super.qiblaBearing,
      required super.isAligned, required super.glow, required super.spec});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(center.dx, center.dy) - 30;
    final bezel = radius + 14;

    final bg = Paint()
      ..shader = RadialGradient(
        colors: [spec.faceTop, spec.faceBottom],
      ).createShader(Rect.fromCircle(center: center, radius: bezel));
    canvas.drawCircle(center, bezel, bg);

    // Ring dot emas (60 tick arc 6°)
    _paintHourTicks(canvas, center, radius);
    _paintCardinals(canvas, center, radius, serif: true,
        labels: const ['N', 'E', 'S', 'W']);

    _paintRing(canvas, center, bezel, spec.ring, isAligned: isAligned, glow: glow);

    // Jarum emas
    final relativeAngle = qiblaBearing - azimuth;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(relativeAngle * math.pi / 180);

    final tipY = -(radius - 54);
    final shaft = Rect.fromLTRB(-2, tipY, 2, radius * 0.22);
    final shaftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [spec.needle, spec.needle.withValues(alpha: 0.2)],
      ).createShader(shaft);
    canvas.drawRect(shaft, shaftPaint);
    final head = Path()
      ..moveTo(0, tipY)
      ..lineTo(-8, tipY + 15)
      ..lineTo(8, tipY + 15)
      ..close();
    canvas.drawPath(head, Paint()..color = spec.needle);
    canvas.restore();

    _paintRing(canvas, center, radius * 0.9, spec.ring.withValues(alpha: 0.25),
        isAligned: false, glow: 0, thin: true);

    _paintKaabaBadgeOnRing(canvas, center, bezel,
        badgeBg: spec.kaabaBadgeBg, badgeBorder: spec.kaabaBadgeBorder);
  }
}

/// ── Base painter: helper tick, kardinal, band, needle, badge Ka'bah ──
abstract class BaseQiblaPainter extends CustomPainter {
  BaseQiblaPainter({this.azimuth = 0,
      required this.qiblaBearing,
      this.isAligned = false,
      this.glow = 0,
      required this.spec});

  final double azimuth;
  final double qiblaBearing;
  final bool isAligned;
  final double glow;    // 0..1, membangkitkan when aligned
  final QiblaSkinSpec spec;

  @override
  bool shouldRepaint(covariant BaseQiblaPainter oldDelegate) =>
      oldDelegate.azimuth != azimuth ||
      oldDelegate.isAligned != isAligned ||
      oldDelegate.glow != glow ||
      oldDelegate.qiblaBearing != qiblaBearing;

  /// Glow ring — memenyala hanya saat aligned. critiques: state idle dim.
  void _paintRing(Canvas canvas, Offset center, double radius, Color color,
      {required bool isAligned, required double glow, bool thin = false}) {
    final paint = Paint()
      ..color = color.withValues(alpha: isAligned ? 0.85 : (thin ? 0.5 : 0.45))
      ..style = PaintingStyle.stroke
      ..strokeWidth = thin ? 1 : 2;
    canvas.drawCircle(center, radius, paint);
    if (!thin && isAligned && glow > 0) {
      // extra glow aligned pulse
      canvas.drawCircle(center, radius,
          Paint()
            ..color = color.withValues(alpha: 0.20 * glow)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    }
  }

  void _paintTicks(Canvas canvas, Offset center, double radius,
      {required bool hourTicks}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var i = 0; i < 360; i += 15) {
      final isMain = i % 90 == 0;
      final isMid = i % 45 == 0;
      final angle = (i - 90) * math.pi / 180;
      final len = isMain ? 14.0 : (isMid ? 10.0 : 6.0);
      final startX = math.cos(angle) * radius;
      final startY = math.sin(angle) * radius;
      final endX = math.cos(angle) * (radius - len);
      final endY = math.sin(angle) * (radius - len);
      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..color = isMain ? spec.tickMajor : spec.tick
        ..strokeWidth = isMain ? 3 : 1.5;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
    canvas.restore();
  }

  void _paintHourTicks(Canvas canvas, Offset center, double radius) {
    _paintTicks(canvas, center, radius * 0.96, hourTicks: true);
  }

  void _paintCardinals(Canvas canvas, Offset center, double radius,
      {bool serif = false, required List<String> labels}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (final (label, angle, emph) in [
      ('N', 0, true), ('E', 90, false), ('S', 180, false), ('W', 270, false)
    ]) {
      final radAngle = (angle - 90) * math.pi / 180;
      final textX = math.cos(radAngle) * (radius - 30);
      final textY = math.sin(radAngle) * (radius - 30);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: emph ? spec.cardinalEmph : spec.cardinal,
            fontSize: emph ? 18 : 15,
            fontWeight: FontWeight.bold,
            // C & E: kardinal serif; lainnya sans
            fontFamily: serif ? 'serif' : null,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(canvas, Offset(textX - tp.width / 2, textY - tp.height / 2));
    }
    canvas.restore();
  }

  /// Band kiblat di ring (dial B) — independent cross-check dari jarum.
  void _paintBandOnRing(Canvas canvas, Offset center, double radius,
      {required Color color}) {
    final rel = qiblaBearing - azimuth;
    final rad = (rel - 90) * math.pi / 180;
    // band segmen arc pendek 6° di ring
    final band = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 4),
      rad - 3 * math.pi / 180,
      6 * math.pi / 180,
      false, band,
    );
  }

  /// Jarum kiblat dengan saf head panah lebih compact.
  void _paintNeedle(Canvas canvas, Offset center, double radius,
      {required Color needleColor,
      required Color headColor,
      Color? glowColor,
      Color? northTail}) {
    final relativeAngle = qiblaBearing - azimuth;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(relativeAngle * math.pi / 180);

    final tipY = -(radius - 52);
    const headLen = 22.0;
    final headBase = tipY + headLen;

    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.35 + 0.35 * glow)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawLine(const Offset(0, 16), Offset(0, tipY + 8), glowPaint);
    }

    final needlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [needleColor.withValues(alpha: 0.22), needleColor],
      ).createShader(Rect.fromLTRB(-3, tipY, 3, 16))
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 16), Offset(0, headBase - 4), needlePaint);

    final headPath = Path()
      ..moveTo(0, tipY)
      ..lineTo(-10, headBase)
      ..lineTo(10, headBase)
      ..close();
    canvas.drawPath(headPath, Paint()..color = headColor);

    canvas.restore();

    // northTail kalau ada (dial C: crimson utara digambar saat painter C)
    if (northTail != null) {
      final northPaint = Paint()..color = northTail;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      final path = Path()
        ..moveTo(0, -(radius - 70))
        ..lineTo(-6, -(radius - 46))
        ..lineTo(6, -(radius - 46))
        ..close();
      canvas.drawPath(path, northPaint);
      canvas.restore();
    }
  }

  /// Badge Ka'bah di bezel (18 px circle). Critique: jangan di atas (utara),
  /// tapi menempel arah kiblat di ring luar — mencegah false signal.
  void _paintKaabaBadgeOnRing(Canvas canvas, Offset center, double radius,
      {required Color badgeBg, required Color badgeBorder,
      bool drawCube = false}) {
    final rel = qiblaBearing - azimuth;
    final rad = (rel - 90) * math.pi / 180;
    final mx = center.dx + math.cos(rad) * radius;
    final my = center.dy + math.sin(rad) * radius;
    final mark = Offset(mx, my);

    canvas.drawCircle(mark, 13, Paint()..color = badgeBg);
    canvas.drawCircle(mark, 13,
        Paint()
          ..color = badgeBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    if (drawCube) {
      // kubus kecil — sama bentuk seperti mockup D (ka'bah ikon CSS)
      final cubeRect = Rect.fromCenter(center: mark, width: 9, height: 10);
      final cube = Paint()..color = const Color(0xFF047857);
      final roundedCube = RRect.fromRectAndRadius(cubeRect, const Radius.circular(1));
      canvas.drawRRect(roundedCube, cube);
      final bandPaint = Paint()..color = const Color(0xFFFFFFFF);
      canvas.drawRect(
        Rect.fromCenter(center: mark.translate(0, -1), width: 4.5, height: 1.5),
        bandPaint,
      );
    } else {
      // mockup lain: emoji 🕋 via TextPainter
      final tp = TextPainter(
        text: const TextSpan(text: '🕋', style: TextStyle(fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(mx - tp.width / 2, my - tp.height / 2));
    }
  }
}

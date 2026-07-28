import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Nomor surat di dalam ornamen Rub el Hizb (۞) — dua persegi yang saling
/// diputar 45°, penanda pembagian juz di mushaf. Digambar CustomPainter,
/// bukan aset: vector tetap tajam di semua kerapatan layar, dan warnanya
/// bisa mengikuti token tema aktif tanpa menyiapkan empat file gambar.
class RubElHizbBadge extends StatelessWidget {
  final int number;
  final double size;

  const RubElHizbBadge({
    super.key,
    required this.number,
    this.size = AppSpacing.xxl,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RubElHizbPainter(color: color),
        child: Center(
          child: Text(
            '$number',
            style: AppText.labelCapsSm().copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

class _RubElHizbPainter extends CustomPainter {
  final Color color;

  const _RubElHizbPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Sisakan 1.5px dari tepi supaya stroke tidak terpotong SizedBox induk.
    final radius = size.shortestSide / 2 - 1.5;

    canvas.drawCircle(
      center,
      radius * 0.58,
      Paint()..color = color.withValues(alpha: 0.14),
    );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: 0.75);

    // Dua persegi dengan circumradius sama, beda fase 45° — itulah oktagram.
    for (final phase in const [pi / 4, 0.0]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final angle = phase + i * pi / 2;
        final point = Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _RubElHizbPainter oldDelegate) =>
      oldDelegate.color != color;
}

import 'package:flutter/material.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';

/// Agregasi jumlah sholat wajib per tanggal (key 'YYYY-MM-DD'), 0..5.
/// Sunnah/rawatib/tilawah/sedekah diabaikan — khusus wajib saja.
Map<String, int> wajibPerHari(List<PrayerLog> logs) {
  final m = <String, int>{};
  for (final l in logs) {
    if (GameService.wajibList.contains(l.prayer)) {
      m[l.date] = (m[l.date] ?? 0) + 1;
    }
  }
  return m;
}

/// Heatmap kalender sholat wajib per bulan — gaya GitHub contribution graph.
/// Sel kosong = 0 wajib; 5 shade hijau = 1..5 wajib hari itu.
class PrayerHeatmap extends StatefulWidget {
  const PrayerHeatmap({super.key});

  @override
  State<PrayerHeatmap> createState() => _PrayerHeatmapState();
}

class _PrayerHeatmapState extends State<PrayerHeatmap> {
  static const _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  late DateTime _bulan; // tanggal-1 bulan aktif

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _bulan = DateTime(now.year, now.month);
  }

  static String _key(DateTime d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-${pad(d.month)}-${pad(d.day)}';
  }

  /// 0 wajib = warna empty (netral); 1..5 = 5 shade dari brand emerald.
  Color _cellColor(int count) {
    if (count == 0) return AppColors.surfaceContainerHighest;
    return Color.lerp(
      AppColors.surfaceContainerHighest,
      AppColors.primary,
      count / 5.0,
    )!;
  }

  Color _dayColor(int count) {
    if (count == 0) return AppColors.onSurfaceVariant;
    final cell = _cellColor(count);
    return ThemeData.estimateBrightnessForColor(cell) == Brightness.dark
        ? Colors.white
        : AppColors.onSurface;
  }

  void _geser(int delta) {
    setState(() => _bulan = DateTime(_bulan.year, _bulan.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final counts = wajibPerHari(GameService.current.prayerLog);
    final firstWeekday = _bulan.weekday; // 1=Sen .. 7=Min
    final daysInMonth = DateTime(_bulan.year, _bulan.month + 1, 0).day;
    final today = DateTime.now();
    final isCurrentMonth =
        today.year == _bulan.year && today.month == _bulan.month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${_namaBulan[_bulan.month - 1]} ${_bulan.year}',
                style: AppText.titleLg().copyWith(color: AppColors.onSurface),
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_left, color: AppColors.primary),
              tooltip: 'Bulan sebelumnya',
              onPressed: () => _geser(-1),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: AppColors.primary),
              tooltip: 'Bulan berikutnya',
              onPressed: () => _geser(1),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: _namaHari
              .map(
                (h) => Expanded(
                  child: Center(
                    child: Text(
                      h,
                      style: AppText.labelCapsSm().copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.xs),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            for (var i = 1; i < firstWeekday; i++) const SizedBox.shrink(),
            for (var d = 1; d <= daysInMonth; d++)
              _cell(
                d,
                counts[_key(DateTime(_bulan.year, _bulan.month, d))] ?? 0,
                isToday: isCurrentMonth && d == today.day,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _legend(),
      ],
    );
  }

  Widget _cell(int day, int count, {required bool isToday}) {
    return Container(
      decoration: BoxDecoration(
        color: _cellColor(count),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: isToday
            ? Border.all(color: AppColors.tertiary, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: AppText.labelCapsSm().copyWith(
          color: _dayColor(count),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _legend() {
    Widget shade(int c) => Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _cellColor(c),
            borderRadius: BorderRadius.circular(3),
          ),
        );
    return Row(
      children: [
        Text(
          'Kurang',
          style: AppText.labelCapsSm().copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        for (var c = 1; c <= 5; c++) ...[
          shade(c),
          const SizedBox(width: 4),
        ],
        const SizedBox(width: AppSpacing.base),
        Text(
          'Lengkap',
          style: AppText.labelCapsSm().copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

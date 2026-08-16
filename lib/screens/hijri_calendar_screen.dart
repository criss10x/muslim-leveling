import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/hijri_service.dart';

/// Kalender Islam — grid per bulan Hijriah yang tercakup dalam satu bulan
/// Gregorian aktif (data aladhan.com, cache disk per bulan). Navigasi antar
/// bulan Gregorian; grid di-align ke hari-minggu (pola sama PrayerHeatmap),
/// tanggal penting ditandai emas — info lengkap statik di daftar bawah kartu.
class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  static const _namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  late int _year;
  late int _month;
  List<HijriDay>? _days;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _fetch();
  }

  Future<void> _fetch() async {
    // ponytail: konten lama tetap tampil selama fetch — cache disk membuat
    // perpindahan bulan instan; hanya layar pertama yang menunggu.
    final days = await hijriService.month(_year, _month);
    if (!mounted) return;
    setState(() {
      _days = days;
      _failed = days == null;
    });
  }

  void _shift(int delta) {
    var m = _month + delta;
    var y = _year;
    if (m < 1) {
      m = 12;
      y--;
    } else if (m > 12) {
      m = 1;
      y++;
    }
    setState(() {
      _month = m;
      _year = y;
    });
    _fetch();
  }

  void _jumpToday() {
    final now = DateTime.now();
    setState(() {
      _year = now.year;
      _month = now.month;
    });
    _fetch();
  }

  bool get _awayFromToday {
    final now = DateTime.now();
    return _year != now.year || _month != now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColors.onBackground,
                        ),
                        tooltip: 'Kembali',
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Kalender Islam',
                          style: AppText.titleLg().copyWith(
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: AppColors.onBackground,
                        ),
                        tooltip: 'Bulan sebelumnya',
                        onPressed: () => _shift(-1),
                      ),
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${gregorianMonthNames[_month - 1]} $_year',
                                style: AppText.labelCaps().copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              if (_awayFromToday)
                                PressableScale(
                                  onTap: _jumpToday,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                      vertical: AppSpacing.base,
                                    ),
                                    child: Text(
                                      '· Hari ini',
                                      style:
                                          AppText.labelCapsSm().copyWith(
                                            color: AppColors.primary,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: AppColors.onBackground,
                        ),
                        tooltip: 'Bulan berikutnya',
                        onPressed: () => _shift(1),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.xs,
                      top: AppSpacing.base,
                    ),
                    child: Text(
                      'ANGKA ATAS = HIJRIAH · BAWAH = MASEHI',
                      style: AppText.labelCapsSm().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _days == null
                  ? _failed
                        ? ErrorRetry(
                            message: 'Gagal memuat kalender.',
                            onRetry: _fetch,
                          )
                        : Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.xxl,
                      ),
                      children: _groups(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _groups() {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final groups = <Widget>[];
    List<HijriDay>? bucket;
    for (final d in _days!) {
      // Ganti grup saat bulan Hijriah berganti dalam satu bulan Gregorian.
      if (bucket == null ||
          bucket.last.hMonth != d.hMonth ||
          bucket.last.hYear != d.hYear) {
        if (bucket != null) groups.add(_groupCard(bucket, todayStr));
        bucket = [d];
      } else {
        bucket.add(d);
      }
    }
    if (bucket != null && bucket.isNotEmpty) {
      groups.add(_groupCard(bucket, todayStr));
    }
    return [
      for (var i = 0; i < groups.length; i++) ...[
        groups[i],
        if (i < groups.length - 1) const SizedBox(height: AppSpacing.md),
      ],
    ];
  }

  Widget _groupCard(List<HijriDay> days, String todayStr) {
    final d0 = days.first;
    final important = days
        .where((d) => hijriImportantDates.containsKey((d.hMonth, d.hDay)))
        .toList();
    // Align kolom ke hari-minggu (pola PrayerHeatmap).
    final firstWeekday = d0.gDate.weekday; // 1=Sen .. 7=Min
    return FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${hijriMonthNames[d0.hMonth]} ${d0.hYear} H',
                  style: AppText.titleLg().copyWith(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                hijriMonthArabic[d0.hMonth],
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiriQuran(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            childAspectRatio: 1.3,
            children: [
              for (var i = 1; i < firstWeekday; i++) const SizedBox.shrink(),
              for (final d in days) _dayCell(d, todayStr),
            ],
          ),
          if (important.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final d in important)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.secondaryFixed,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${hijriImportantDates[(d.hMonth, d.hDay)]} — '
                        '${d.hDay} ${hijriMonthNames[d.hMonth]} '
                        '(${d.gDate.day}/${d.gDate.month})',
                        style: AppText.bodyMd().copyWith(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _dayCell(HijriDay d, String todayStr) {
    final key =
        '${d.gDate.year}-${d.gDate.month.toString().padLeft(2, '0')}-${d.gDate.day.toString().padLeft(2, '0')}';
    final isToday = key == todayStr;
    final isImportant = hijriImportantDates.containsKey((d.hMonth, d.hDay));
    return Semantics(
      label: '${d.hDay} ${hijriMonthNames[d.hMonth]}'
          '${isImportant ? ', hari penting' : ''}'
          '${isToday ? ', hari ini' : ''}',
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary.withValues(alpha: 0.15)
              : isImportant
              ? AppColors.secondaryFixed.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isToday ? Border.all(color: AppColors.primary) : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${d.hDay}',
              style: AppText.titleLg().copyWith(
                fontSize: 14,
                color: isToday ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            Text(
              '${d.gDate.day}',
              style: AppText.labelCapsSm().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

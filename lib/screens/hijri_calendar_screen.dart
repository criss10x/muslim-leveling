import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/hijri_service.dart';

/// Kalender Hijriah — grid per bulan Hijriah yang tercakup dalam satu bulan
/// Gregorian aktif (data aladhan.com, cache per bulan). Navigasi antar bulan
/// Gregorian; tanggal penting ditandai dan bisa di-tap.
class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late int _year;
  late int _month;
  List<HijriDay>? _days;
  bool _loading = true;

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final days = await hijriService.month(_year, _month);
    if (!mounted) return;
    setState(() {
      _days = days;
      _loading = false;
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
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.onBackground,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Kalender Hijriah',
                      style: AppText.titleLg().copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: AppColors.onBackground,
                    ),
                    onPressed: () => _shift(-1),
                  ),
                  Text(
                    '${_months[_month - 1]} $_year',
                    style: AppText.labelCaps().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: AppColors.onBackground,
                    ),
                    onPressed: () => _shift(1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _days == null
                  ? ErrorRetry(message: 'Gagal memuat kalender.', onRetry: _fetch)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        100,
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
    // Beri jarak antar kartu tanpa nambah SizedBox manual.
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
        .where(
          (d) =>
              hijriImportantDates.containsKey((d.hMonth, d.hDay)) == true,
        )
        .toList();
    return FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${hijriMonthNames[d0.hMonth]} ${d0.hYear} H',
            style: AppText.titleLg().copyWith(
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            childAspectRatio: 1.3,
            children: [
              for (final d in days) _dayCell(d, todayStr),
            ],
          ),
          if (important.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final d in important)
              PressableScale(
                onTap: () => _showImportant(d),
                child: Padding(
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
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary.withValues(alpha: 0.15)
            : isImportant
            ? AppColors.secondaryFixed.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: isToday
            ? Border.all(color: AppColors.primary)
            : null,
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
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showImportant(HijriDay d) {
    final label = hijriImportantDates[(d.hMonth, d.hDay)] ?? '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label — ${hijriLabel(d)} '
          '(${d.gDate.day}/${d.gDate.month}/${d.gDate.year})',
        ),
        backgroundColor: AppColors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

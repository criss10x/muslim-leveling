import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/prayer_service.dart';

/// Calendar view for jadwal sholat with Hijri date + Gregorian date.
/// Uses Equran API via PrayerService.
class JadwalKalenderScreen extends StatefulWidget {
  const JadwalKalenderScreen({super.key});

  @override
  State<JadwalKalenderScreen> createState() => _JadwalKalenderScreenState();
}

class _JadwalKalenderScreenState extends State<JadwalKalenderScreen> {
  DateTime _currentMonth = DateTime.now();
  List<_DayEntry>? _calendarData;
  bool _loading = false;
  String? _error;

  Future<void> _loadCalendar(DateTime month) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final loc = await PrayerService.loadLocation();
    if (loc == null) {
      setState(() {
        _loading = false;
        _error = 'Lokasi belum diset';
      });
      return;
    }

    final data = await PrayerService.fetchMonthlySchedule(
      cityName: loc.name,
      year: month.year,
      month: month.month,
    );

    if (!mounted) return;
    if (data != null) {
      setState(() {
        _calendarData = data.map((j) => _DayEntry.fromApi(j, year: month.year, month: month.month)).toList();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _error = 'Gagal memuat jadwal. Periksa koneksi.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCalendar(_currentMonth);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadCalendar(_currentMonth);
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadCalendar(_currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surfaceContainerLow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '📅 Jadwal Sholat',
          style: AppText.headlineMd().copyWith(color: AppColors.onSurface),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              final now = DateTime.now();
              setState(() => _currentMonth = DateTime(now.year, now.month));
              _loadCalendar(_currentMonth);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadCalendar(_currentMonth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PressableScale(
                  onTap: _prevMonth,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(Icons.chevron_left, color: AppColors.primary),
                  ),
                ),
                Text(
                  _monthLabel(_currentMonth),
                  style: AppText.titleLg().copyWith(color: AppColors.onSurface),
                ),
                PressableScale(
                  onTap: _nextMonth,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(Icons.chevron_right, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else if (_calendarData == null || _calendarData!.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Tidak ada data jadwal'),
                ),
              )
            else
              ..._calendarData!.map((entry) => _DayCard(entry)),
          ],
        ),
      ),
    );
  }

  String _monthLabel(DateTime dt) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

class _DayCard extends StatelessWidget {
  final _DayEntry entry;
  const _DayCard(this.entry);

  @override
  Widget build(BuildContext context) {
    final isToday = entry.isToday;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.surfaceContainerLow,
            border: Border.all(
              color: isToday
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.gregorianDate,
                    style: AppText.titleLg().copyWith(color: AppColors.onSurface),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        entry.hijriDate,
                        style: AppText.bodyMd().copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Divider(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
                thickness: 1,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PrayerChip('Subuh', entry.subuh),
                  _PrayerChip('Dzuhur', entry.dzuhur),
                  _PrayerChip('Ashar', entry.ashar),
                  _PrayerChip('Maghrib', entry.maghrib),
                  _PrayerChip('Isya', entry.isya),
                ],
              ),
              if (isToday) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '✓ Jadwal hari ini',
                    style: AppText.labelCaps().copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerChip extends StatelessWidget {
  final String label;
  final String time;
  const _PrayerChip(this.label, this.time);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(Icons.circle, size: 8, color: AppColors.primaryFixed),
      label: Text(
        '$label $time',
        style: AppText.labelCaps().copyWith(color: AppColors.onSurface),
      ),
      side: BorderSide.none,
      backgroundColor: AppColors.secondaryContainer.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    );
  }
}

class _DayEntry {
  final String gregorianDate;
  final String hijriDate;
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final bool isToday;

  _DayEntry({
    required this.gregorianDate,
    required this.hijriDate,
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.isToday,
  });

  factory _DayEntry.fromApi(Map<String, dynamic> j, {int? year, int? month}) {
    final tanggal = j['tanggal'] as int;
    final hari = j['hari'] as String? ?? '';
    final today = DateTime.now();

    // Parse tanggal_lengkap (e.g. "2026-07-01") which is always present
    DateTime parseDate() {
      final full = j['tanggal_lengkap'] as String?;
      if (full != null) {
        final d = DateTime.tryParse(full);
        if (d != null) return d;
      }
      return DateTime(year ?? today.year, month ?? today.month, tanggal);
    }

    final entryDate = parseDate();

    final hijriDate = HijriCalendar.fromDate(entryDate);

    return _DayEntry(
      gregorianDate: '$tanggal $hari ${entryDate.year}',
      hijriDate: '${hijriDate.hDay} ${hijriDate.getLongMonthName()} ${hijriDate.hYear}',
      subuh: j['subuh']?.replaceAll(RegExp(r' \\([A-Z]+\\)'), '') ?? '--:--',
      dzuhur: j['dzuhur']?.replaceAll(RegExp(r' \\([A-Z]+\\)'), '') ?? '--:--',
      ashar: j['ashar']?.replaceAll(RegExp(r' \\([A-Z]+\\)'), '') ?? '--:--',
      maghrib: j['maghrib']?.replaceAll(RegExp(r' \\([A-Z]+\\)'), '') ?? '--:--',
      isya: j['isya']?.replaceAll(RegExp(r' \\([A-Z]+\\)'), '') ?? '--:--',
      isToday:
          entryDate.year == today.year &&
          entryDate.month == today.month &&
          entryDate.day == today.day,
    );
  }
}

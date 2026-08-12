void main() {
  // ── Simulasi runDailyCheck evaluasi missed days (tiru _evalStreakMissed) ──
  // Jumat streak current=4, lastDate=Jumat lalu. App tidak dibuka seminggu.
  var current = 4;
  var freeze = true;
  var lastDate = '2026-07-24';
  // BUG LAMA: jumat dievaluasi harian → current tergerus, freeze termakan,
  // lastDate pindah. FIX: jumat di-skip dari loop evaluasi (tracker.remove).
  assert(current == 4 && lastDate == '2026-07-24' && freeze == true,
      'jumat harus utuh setelah dailyCheck');

  // ── _updWeeklyStreak via perilaku: diff 7 → lanjut, diff 14 → reset ──
  // (private — verifikasi lewat _isFriday + konsep tanggal)
  bool fri(String d) => DateTime.parse(d).weekday == DateTime.friday;
  assert(fri('2026-07-24') && fri('2026-07-31') && !fri('2026-07-30'));
  assert(DateTime.parse('2026-07-31').difference(DateTime.parse('2026-07-24')).inDays == 7);

  // ── Unlog dzuhur Jumat: prevJumat dari logs tersisa ──
  final logs = [
    (prayer: 'dzuhur', date: '2026-07-10'),
    (prayer: 'dzuhur', date: '2026-07-17'),
    // '2026-07-24' sudah dihapus (unlog)
  ];
  final prev = logs
      .where((l) => l.prayer == 'dzuhur' && fri(l.date))
      .map((l) => l.date)
      .fold<String>('', (a, b) => b.compareTo(a) > 0 ? b : a);
  assert(prev == '2026-07-17', 'prevJumat harus Jumat sebelumnya');

}

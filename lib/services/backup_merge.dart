// Pure merge helpers for login restore — no Flutter/Firebase deps.
// ponytail: max-progress pick / union. Dialog Cloud|Device when users need control.

/// Game: keep the map with higher cumulative [xp] (level is derived).
/// ponytail: field-by-field — data non-XP yang lebih baru dipertahankan,
/// bukan ditimpa mentah oleh remote yang cuma XP-nya lebih tinggi.
Map<String, dynamic> pickRicherGame(
  Map<String, dynamic> local,
  Map<String, dynamic> remote,
) {
  final lx = (local['xp'] as num?)?.toInt() ?? 0;
  final rx = (remote['xp'] as num?)?.toInt() ?? 0;
  if (rx <= lx) return Map<String, dynamic>.from(local);

  final merged = Map<String, dynamic>.from(remote);
  // Data progres yang TIDAK boleh diregresi oleh remote XP-tinggi:
  // streak, shield, comeback, quest (progress lebih tinggi menang).
  for (final key in [
    'heroStreak',
    'perPrayerStreaks',
    'tilawahStreak',
    'freezeShields',
    'comebackCount',
    'ownedCosmetics',
    'lifeTotals',
  ]) {
    final lv = local[key];
    final rv = remote[key];
    if (lv == null) continue;
    if (rv == null) {
      merged[key] = lv;
      continue;
    }
    if (key == 'perPrayerStreaks' || key == 'lifeTotals') {
      // Map<String, Map> (perPrayerStreaks: {subuh: {current,best,...}}) —
      // merge per-key, nilai lebih kaya menang (bukan seluruh map lokal menang).
      // ponytail: fix reinstall — lokal fresh (kosong) vs remote (kaya):
      // dulu `else merged[key]=lv` membuang streak remote. Sekarang union.
      final lm = Map<String, dynamic>.from(lv as Map);
      final rm = Map<String, dynamic>.from(rv as Map);
      merged[key] = _mergeRichMaps(lm, rm);
    } else if (_isNumericMap(lv) && _isNumericMap(rv)) {
      // Nilai per-key max (freezeShields dll — tapi mereka skalar, jarang di sini).
      merged[key] = {
        ...rv,
        ...{for (final e in (lv as Map).entries) e.key: _maxNum(lv, rv, e.key)},
      };
    } else if (key == 'ownedCosmetics' && lv is List) {
      merged[key] = {...rv as List, ...lv}.toList();
    } else {
      merged[key] = lv; // heroStreak/tilawahStreak: lokal lebih baru
    }
  }
  return merged;
}

/// Merge dua map yang nilainya map-of-record (streak/shield state).
/// Untuk tiap key: pilih nilai yang "lebih kaya" — current lebih besar menang;
/// kalau salah satu kosong ambil yang terisi; kalau sama, gabung best tertinggi
/// & lastDate paling baru.
Map<String, dynamic> _mergeRichMaps(
  Map<String, dynamic> local,
  Map<String, dynamic> remote,
) {
  final out = Map<String, dynamic>.from(remote);
  local.forEach((k, lv) {
    final rv = out[k];
    if (rv == null) {
      out[k] = lv;
      return;
    }
    if (lv is Map && rv is Map) {
      out[k] = _pickRicherStreak(
        Map<String, dynamic>.from(lv),
        Map<String, dynamic>.from(rv),
      );
    } else {
      out[k] = lv; // bukan record — lokal menang
    }
  });
  return out;
}

Map<String, dynamic> _pickRicherStreak(
  Map<String, dynamic> a,
  Map<String, dynamic> b,
) {
  final aCur = (a['current'] as num?)?.toInt() ?? 0;
  final bCur = (b['current'] as num?)?.toInt() ?? 0;
  final aBest = (a['best'] as num?)?.toInt() ?? 0;
  final bBest = (b['best'] as num?)?.toInt() ?? 0;
  final aDate = a['lastDate']?.toString() ?? '';
  final bDate = b['lastDate']?.toString() ?? '';
  // Yang current lebih tinggi menang (atau yang terisi kalau satunya kosong).
  if (aCur != bCur) return aCur > bCur ? a : b;
  // current sama: best lebih tinggi menang.
  if (aBest != bBest) return aBest > bBest ? a : b;
  // current & best sama: lastDate paling baru menang.
  if (aDate != bDate) return aDate.compareTo(bDate) > 0 ? a : b;
  // Identik — kembalikan a (gabungkan freezeAvailable OR).
  if ((a['freezeAvailable'] == false) != (b['freezeAvailable'] == false)) {
    return {...a, 'freezeAvailable': true};
  }
  return a;
}

bool _isNumericMap(Object? v) => v is Map && v.values.every((e) => e is num);

num _maxNum(Map l, Map r, String key) {
  final lv = (l[key] as num?)?.toInt() ?? 0;
  final rv = (r[key] as num?)?.toInt() ?? 0;
  return lv > rv ? lv : rv;
}

/// Learning: union module progress — completed/xpClaimed OR, max quizScore.
Map<String, dynamic> mergeLearning(
  Map<String, dynamic> local,
  Map<String, dynamic> remote,
) {
  final byId = <String, Map<String, dynamic>>{};
  void ingest(Map<String, dynamic> src) {
    final list = src['progress'];
    if (list is! List) return;
    for (final e in list) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final id = m['moduleId']?.toString() ?? '';
      if (id.isEmpty) continue;
      final prev = byId[id];
      if (prev == null) {
        byId[id] = m;
        continue;
      }
      final completed =
          (prev['completed'] == true) || (m['completed'] == true);
      final xpClaimed =
          (prev['xpClaimed'] == true) || (m['xpClaimed'] == true);
      final qs = [
        (prev['quizScore'] as num?)?.toInt() ?? 0,
        (m['quizScore'] as num?)?.toInt() ?? 0,
      ].reduce((a, b) => a > b ? a : b);
      byId[id] = {
        'moduleId': id,
        'completed': completed,
        'quizScore': qs,
        'xpClaimed': xpClaimed,
      };
    }
  }

  ingest(local);
  ingest(remote);
  return {'progress': byId.values.toList()};
}

/// Medali: union keys, tanggal paling awal menang.
Map<String, String> mergeAchievements(
  Map<String, dynamic> local,
  Map<String, dynamic> remote,
) {
  final out = <String, String>{};
  void ingest(Map<String, dynamic> src) {
    src.forEach((k, v) {
      if (v == null) return;
      final date = v.toString();
      final prev = out[k];
      if (prev == null || (date.isNotEmpty && date.compareTo(prev) < 0)) {
        out[k] = date;
      }
    });
  }

  ingest(local);
  ingest(remote);
  return out;
}

/// Penurunan XP terbesar yang masih SAH dalam satu aksi lokal.
/// Satu-satunya jalur sah yang menurunkan XP adalah `GameService.unlogPrayer`:
/// 5 sholat (30+20+20+25+25=120) + hero bonus 50 + bonus tepat waktu/berjamaah
/// 5x30=150 → ~320 sekali sesi. Di atas ambang ini dianggap kehilangan progres.
const maxLegitXpDrop = 500;

/// True bila push [local] akan MENIMPA cloud berprogres lebih tinggi —
/// regresi yang harus ditolak (bukan penurunan sah seperti unlog).
///
/// ponytail: ambang, bukan analisis riwayat log penuh — cukup memisahkan
/// regresi (10.400→53) dari unlog sah (≤~320). Naikkan kalau ada jalur sah
/// lain yang menurunkan XP lebih besar.
bool isXpRegression(
  Map<String, dynamic> local,
  Map<String, dynamic> remote, {
  int maxLegitDrop = maxLegitXpDrop,
}) {
  final lx = (local['xp'] as num?)?.toInt() ?? 0;
  final rx = (remote['xp'] as num?)?.toInt() ?? 0;
  return rx - lx > maxLegitDrop;
}

/// True bila push [local] akan MENGHAPUS riwayat yang masih ada di cloud.
///
/// ponytail: ambang XP saja tidak cukup — regresi level 3 → level 1 (158 → 0 XP)
/// drop-nya cuma 158, di bawah [maxLegitXpDrop], jadi lolos dan SELURUH
/// riwayat terhapus (terbukti di lapangan: cloud 158 XP/3 log → 0 XP/0 log).
/// Riwayat `prayerLog` bersifat monoton (tak ada pruning), dan satu-satunya
/// jalur sah yang menghapus entri (`unlogPrayer`) menghapus TEPAT SATU hari-ini
/// — jadi cloud yang punya ≥2 entri lebih banyak pasti bukan hasil unlog.
bool isHistoryRegression(
  Map<String, dynamic> local,
  Map<String, dynamic> remote, {
  int maxLegitDrop = maxLegitXpDrop,
}) {
  if (isXpRegression(local, remote, maxLegitDrop: maxLegitDrop)) return true;
  final localLogs = (local['prayerLog'] as List?)?.length ?? 0;
  final remoteLogs = (remote['prayerLog'] as List?)?.length ?? 0;
  return remoteLogs > localLogs + 1;
}

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
    if (_isNumericMap(lv) && _isNumericMap(rv)) {
      // perPrayerStreaks / lifeTotals: nilai per-key max.
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

/// Achievements unlocked map {id: yyyy-MM-dd}: union keys, keep earliest date.
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

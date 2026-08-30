import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/backup_merge.dart';

void main() {
  test('pickRicherGame keeps higher XP, ties local', () {
    expect(
      pickRicherGame({'xp': 100}, {'xp': 250})['xp'],
      250,
    );
    expect(
      pickRicherGame({'xp': 300}, {'xp': 250})['xp'],
      300,
    );
    expect(
      pickRicherGame({'xp': 100, 'note': 'local'}, {'xp': 100, 'note': 'remote'})['note'],
      'local',
    );
  });

  test('pickRicherGame preserves local streak/shield when remote XP higher', () {
    final merged = pickRicherGame(
      {
        'xp': 100,
        'freezeShields': 3,
        'heroStreak': {'current': 10, 'best': 15},
        'perPrayerStreaks': {
          'subuh': {'current': 8, 'best': 9, 'freezeAvailable': false},
        },
        'ownedCosmetics': ['a', 'b'],
      },
      {
        'xp': 500, // remote XP lebih tinggi
        'freezeShields': 0,
        'heroStreak': {'current': 2, 'best': 3},
        'perPrayerStreaks': {
          'subuh': {'current': 1, 'best': 2, 'freezeAvailable': true},
        },
        'ownedCosmetics': ['a'],
      },
    );

    expect(merged['xp'], 500); // XP remote menang
    expect(merged['freezeShields'], 3, reason: 'shield lokal lebih tinggi');
    expect((merged['heroStreak'] as Map)['current'], 10,
        reason: 'hero streak lokal dipertahankan');
    expect((merged['perPrayerStreaks'] as Map)['subuh']['current'], 8,
        reason: 'per-prayer streak lokal dipertahankan');
    expect(merged['ownedCosmetics'], containsAll(['a', 'b']),
        reason: 'cosmetic union');
  });

  test('pickRicherGame keeps local when remote missing a field', () {
    final merged = pickRicherGame(
      {'xp': 100, 'freezeShields': 2},
      {'xp': 300}, // remote tidak punya freezeShields
    );
    expect(merged['freezeShields'], 2, reason: 'field lokal dipertahankan');
  });

  test('mergeLearning unions modules and max score', () {
    final learn = mergeLearning(
      {
        'progress': [
          {
            'moduleId': 'm1',
            'completed': true,
            'quizScore': 60,
            'xpClaimed': false,
          },
          {
            'moduleId': 'm2',
            'completed': false,
            'quizScore': 0,
            'xpClaimed': false,
          },
        ],
      },
      {
        'progress': [
          {
            'moduleId': 'm1',
            'completed': false,
            'quizScore': 90,
            'xpClaimed': true,
          },
          {
            'moduleId': 'm3',
            'completed': true,
            'quizScore': 80,
            'xpClaimed': true,
          },
        ],
      },
    );
    final prog = (learn['progress'] as List).cast<Map<String, dynamic>>();
    Map<String, dynamic> byId(String id) =>
        prog.firstWhere((e) => e['moduleId'] == id);
    expect(byId('m1')['completed'], true);
    expect(byId('m1')['quizScore'], 90);
    expect(byId('m1')['xpClaimed'], true);
    expect(byId('m2')['completed'], false);
    expect(byId('m3')['completed'], true);
    expect(prog.length, 3);
  });

  test('mergeAchievements unions and keeps earliest date', () {
    final ach = mergeAchievements(
      {'a': '2026-01-10', 'b': '2026-02-01'},
      {'a': '2026-01-01', 'c': '2026-03-01'},
    );
    expect(ach['a'], '2026-01-01');
    expect(ach['b'], '2026-02-01');
    expect(ach['c'], '2026-03-01');
    expect(ach.length, 3);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';

// ponytail: runnable check for Quran XP constants. Listen-XP deletion is
// compile-verified (no member exists; flutter analyze passes).
void main() {
  test('Quran XP: +1 per ayat, cap 50/hari', () {
    expect(GameService.quranReadAyahDailyCap, 50);
    expect(QuranXpState(date: '2026-01-01', readClaims: 3).toMap(),
        containsPair('readClaims', 3));
    expect(QuranXpState.fromMap({'listenClaims': 6, 'listenMs': 99999}).toMap(),
        isNot(contains('listenClaims')),
        reason: 'listen XP fields must be gone');
  });
}

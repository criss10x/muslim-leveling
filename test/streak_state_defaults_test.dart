import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';

void main() {
  test('StreakState.best defaults ke 0 dan lastDate ke kosong', () {
    // Guard: kalau ada refactor yang ganggu default StreakState,
    // UI ('best N' line + 'hari' suffix + at-risk icon) akan menampilkan
    // string aneh.
    final s = StreakState();
    expect(s.current, 0);
    expect(s.best, 0);
    expect(s.lastDate, '');
    expect(s.freezeAvailable, true);
  });
}

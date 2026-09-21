import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';

void main() {
  test('ownedCosmetics & equipped default empty', () {
    final s = GameState();
    expect(s.ownedCosmetics, isEmpty);
    expect(s.equipped, isEmpty);
  });

  test('round-trips through toMap/fromMap', () {
    final s = GameState(
      ownedCosmetics: const ['aura_sultan', 'title_crescent'],
      equipped: const {'frame': 'shield_classic', 'title': 'title_crescent'},
    );
    final restored = GameState.fromMap(s.toMap());
    expect(restored.ownedCosmetics, ['aura_sultan', 'title_crescent']);
    expect(restored.equipped, {'frame': 'shield_classic', 'title': 'title_crescent'});
  });

  test('old JSON without the new fields still loads', () {
    final legacy = {'xp': 100, 'level': 3}; // no cosmetics keys
    final s = GameState.fromMap(legacy);
    expect(s.ownedCosmetics, isEmpty);
    expect(s.equipped, isEmpty);
    expect(s.xp, 100);
  });

  test('level selalu turunan xp, abaikan level basi di map', () {
    // Restore cloud pernah menulis xp 10555 dengan level 31 (basi) → tab
    // Profil (state.level) beda dari Home (turunkan dari xp).
    final s = GameState.fromMap({'xp': 10555, 'level': 31});
    expect(s.level, GameService.getLevelInfo(10555).level);
    expect(s.level, 32);
  });
}

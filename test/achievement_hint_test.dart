import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/achievement_service.dart';

/// Cek fallback hint bekerja untuk def yang tidak punya unlockHint
/// eksplisit — kalau jatuh ke 'null' (mis. field lupa), locked medals
/// tetap punya teks petunjuk untuk user (kritik P0: locked = dead end).
void main() {
  test('hint fallback tidak null/empty', () {
    for (final d in AchievementService.defs) {
      expect(d.hint, isNotEmpty,
          reason: '${d.id} harus punya hint (eksplisit atau fallback)');
    }
  });

  test('hint eksplisit untuk def ambigu tampil apa adanya', () {
    final hints = {
      for (final d in AchievementService.defs) d.id: d.unlockHint,
    };
    expect(hints['hall_of_fame'], isNotNull);
    expect(hints['hall_of_fame']!.contains('achievement'), isTrue);
  });
}

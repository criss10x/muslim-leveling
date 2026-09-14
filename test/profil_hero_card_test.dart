import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/screens/profil_tab.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:muslim_leveling/widgets/tier_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() => isLightTheme = false);

  testWidgets('hero exposes tier identity without reducing edit target', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final semantics = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues({
      'nickname': 'Pejuang',
      'onboarding_done': true,
      'avatar_path': '',
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: ProfilTab()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.bySemanticsLabel('Profile hero — Warrior'), findsOneWidget);
    final edit = find.byTooltip('Edit profil');
    expect(tester.getSize(edit).shortestSide, greaterThanOrEqualTo(44));
    semantics.dispose();
  });

  testWidgets('hero updates its tier after a live level-up', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final semantics = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues({
      'nickname': 'Pejuang',
      'onboarding_done': true,
      'avatar_path': '',
      'game_state_v1': '{"xp":0,"level":1}',
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: ProfilTab()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.bySemanticsLabel('Profile hero — Warrior'), findsOneWidget);

    await GameService.addXp(865);
    await tester.pump();

    expect(find.bySemanticsLabel('Profile hero — Warrior'), findsNothing);
    expect(find.bySemanticsLabel('Profile hero — Elite'), findsOneWidget);
    expect(find.bySemanticsLabel('Elite achievement frame'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('hero name uses explicit light-theme ink', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    isLightTheme = true;
    SharedPreferences.setMockInitialValues({
      'nickname': 'Pejuang',
      'onboarding_done': true,
      'avatar_path': '',
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: ProfilTab()),
      ),
    );
    await tester.pump();

    expect(
      tester.widget<Text>(find.text('Pejuang')).style?.color,
      AppColors.onSurface,
    );
  });

  testWidgets('hero uses the circular fallback and omits location', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'nickname': 'Pejuang',
      'onboarding_done': true,
      'game_state_v1':
          '{"xp":0,"level":1,"equipped":{"frame":"shield_classic"}}',
      'city_id': '1301',
      'city_name': 'Jakarta',
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: ProfilTab()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('LOKASI'), findsNothing);
    expect(find.text('Jakarta'), findsNothing);
    expect(
      tester
          .widget<TierProfileAvatar>(find.byType(TierProfileAvatar))
          .equippedFrameId,
      'frame_default',
    );
  });

  testWidgets('hero keeps rank identity and tier accent', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'nickname': 'Pejuang',
      'onboarding_done': true,
      'avatar_path': '',
      'game_state_v1': '{"xp":0,"level":1}',
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: ProfilTab()),
      ),
    );
    await tester.pump();

    final tier = getTierVisualConfig('Warrior');
    // Rank tidak lagi jadi sel statistik ke-4 (duplikat pill rank di atas),
    // tapi identitas rank tetap tampil — sekarang hanya di pill.
    expect(
      find.text(GameService.getRankTitle(GameService.current.level)),
      findsOneWidget,
    );
    // Aksen tier tidak hilang dari hero: dipakai glow kartu + border + bar XP.
    final card = tester.widget<Container>(
      find.byKey(const Key('profil-hero-card')),
    );
    final shadow = (card.decoration! as BoxDecoration).boxShadow!.first;
    expect(shadow.color, tier.inkPrimary.withValues(alpha: 0.22));
  });
}

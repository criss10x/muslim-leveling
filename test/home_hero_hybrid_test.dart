import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:muslim_leveling/widgets/tier_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/app_wrap.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    activeThemePreset = AppThemePreset.darkEmerald;
    SharedPreferences.setMockInitialValues({
      'game_state_v1': '{"xp":0,"level":1}',
    });
  });

  Future<void> pumpHero(
    WidgetTester tester, {
    required AppThemePreset preset,
  }) async {
    activeThemePreset = preset;
    await tester.pumpWidget(
      appWrap(const Scaffold(body: HomeTab()), theme: preset.isLight ? AppTheme.light() : AppTheme.dark()),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
    'Home hero renders Islamic pattern and rank medallion in light mode',
    (tester) async {
      await pumpHero(tester, preset: AppThemePreset.lightEmerald);

      final card = tester.widget<Container>(
        find.byKey(const Key('home-hero-card')),
      );
      final decoration = card.decoration! as BoxDecoration;
      final backgroundFinder = find.descendant(
        of: find.byKey(const Key('home-hero-card')),
        matching: find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox || widget.decoration is! BoxDecoration) {
            return false;
          }
          final decoration = widget.decoration as BoxDecoration;
          return decoration.gradient is RadialGradient &&
              decoration.border != null;
        }),
      );
      final background = tester.widget<DecoratedBox>(backgroundFinder);
      final backgroundDecoration = background.decoration as BoxDecoration;
      final backgroundGradient =
          backgroundDecoration.gradient! as RadialGradient;
      final backgroundBorder = backgroundDecoration.border! as Border;
      final pattern = tester.widget<CustomPaint>(
        find.byKey(const Key('home-hero-pattern')),
      );
      final patternPainter = pattern.painter as dynamic;
      expect(decoration.boxShadow, isNull);
      expect(
        backgroundDecoration.borderRadius,
        BorderRadius.circular(AppRadius.xl),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is IgnorePointer && identical(widget.child, background),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('home-hero-pattern')), findsOneWidget);
      final medallionFinder = find.byKey(const Key('home-rank-medallion'));
      final medallion = tester.widget<Container>(medallionFinder);
      final medallionDecoration = medallion.decoration! as BoxDecoration;
      final medallionInner = medallion.child! as Container;
      final medallionInnerDecoration =
          medallionInner.decoration! as BoxDecoration;
      final medallionStar = tester.widget<CustomPaint>(
        find.descendant(
          of: medallionFinder,
          matching: find.byType(CustomPaint),
        ),
      );
      final medallionStarPainter = medallionStar.painter as dynamic;
      expect(medallionFinder, findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is IgnorePointer && identical(widget.child, medallion),
        ),
        findsOneWidget,
      );
      expect(backgroundGradient.colors, [
        AppColors.primaryContainer.withValues(alpha: 0.62),
        AppColors.surfaceContainerLow,
      ]);
      expect(
        backgroundBorder.top.color,
        AppColors.primary.withValues(alpha: 0.22),
      );
      expect(patternPainter.color, AppColors.primary);
      expect(patternPainter.opacity, 0.05);
      expect(medallionDecoration.color, AppColors.primary);
      expect(medallionDecoration.gradient, isNull);
      expect(medallionDecoration.boxShadow, isNull);
      expect(medallionInnerDecoration.color, AppColors.primaryContainer);
      expect(medallionStarPainter.color, AppColors.primary);
      // Eyebrow hero sekarang SAPAAN, bukan label rank generik. Dijaga arah
      // sebaliknya supaya 'CURRENT RANK' tidak diam-diam kembali.
      expect(find.text('CURRENT RANK'), findsNothing,
          reason: 'eyebrow hero = sapaan Assalamualaikum, bukan label rank');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Home hero adds one restrained rank glow in dark mode', (
    tester,
  ) async {
    await pumpHero(tester, preset: AppThemePreset.darkEmerald);

    final card = tester.widget<Container>(
      find.byKey(const Key('home-hero-card')),
    );
    final decoration = card.decoration! as BoxDecoration;
    final pattern = tester.widget<CustomPaint>(
      find.byKey(const Key('home-hero-pattern')),
    );
    final tier = getTierVisualConfig(getTierName(1));
    final patternPainter = pattern.painter as dynamic;
    final medallion = tester.widget<Container>(
      find.byKey(const Key('home-rank-medallion')),
    );
    final medallionDecoration = medallion.decoration! as BoxDecoration;
    final medallionInner = medallion.child! as Container;
    final medallionInnerDecoration =
        medallionInner.decoration! as BoxDecoration;
    expect(decoration.boxShadow, hasLength(1));
    expect(find.byKey(const Key('home-hero-pattern')), findsOneWidget);
    expect(find.byKey(const Key('home-rank-medallion')), findsOneWidget);
    expect(find.byKey(const Key('home-xp-progress-fill')), findsOneWidget);
    expect(patternPainter.color, tier.inkPrimary);
    expect(patternPainter.opacity, 0.09);
    expect(medallionDecoration.color, isNull);
    expect((medallionDecoration.gradient! as LinearGradient).colors, [
      tier.inkPrimary,
      tier.inkSecondary,
    ]);
    expect(medallionDecoration.boxShadow, hasLength(1));
    expect(medallionInnerDecoration.color, AppColors.surfaceContainer);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home hero Jade Field follows Light Mushaf semantic colors', (
    tester,
  ) async {
    await pumpHero(tester, preset: AppThemePreset.lightMushaf);

    final background = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const Key('home-hero-card')),
        matching: find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox || widget.decoration is! BoxDecoration) {
            return false;
          }
          final decoration = widget.decoration as BoxDecoration;
          return decoration.gradient is RadialGradient &&
              decoration.border != null;
        }),
      ),
    );
    final backgroundDecoration = background.decoration as BoxDecoration;
    final gradient = backgroundDecoration.gradient! as RadialGradient;
    final medallion = tester.widget<Container>(
      find.byKey(const Key('home-rank-medallion')),
    );
    final medallionDecoration = medallion.decoration! as BoxDecoration;

    expect(
      gradient.colors.first,
      AppColors.primaryContainer.withValues(alpha: 0.62),
    );
    expect(medallionDecoration.color, AppColors.primary);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home hero ellipsizes a long stored nickname di sapaan', (
    tester,
  ) async {
    const nickname = 'Abdurrahman Fatah Wijaya';
    SharedPreferences.setMockInitialValues({
      'game_state_v1': '{"xp":0,"level":1}',
      'nickname': nickname,
    });
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpHero(tester, preset: AppThemePreset.lightEmerald);

    // Baris '{nama} • Lv N' DIPINDAH ke sapaan, jadi target ellipsis pindah.
    // Diukur: "ASSALAMUALAIKUM, " 141,6px + nama 24 char = 343,2px vs budget
    // @360 sebaris kartu 312px -> harus ter-ellipsis, bukan overflow.
    final greeting = tester.widget<Text>(
      find.text('Assalamualaikum, $nickname'),
    );
    expect(greeting.maxLines, 1);
    expect(greeting.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Header Home tidak lagi memuat logo, nama app, atau gear', (
    tester,
  ) async {
    await pumpHero(tester, preset: AppThemePreset.darkEmerald);

    expect(
      find.byIcon(AppIcons.settingsOutlined),
      findsNothing,
      reason: 'gear mengarah ke tab Profil yang sudah ada di nav bawah',
    );
    expect(
      find.text('MUSLIM LEVELING'),
      findsNothing,
      reason: 'nama app berulang 3x di satu layar; identitas = medallion + nav',
    );
    expect(find.text('Muslim Leveling'), findsNothing);
    // Hero-nya sendiri wajib tetap ada: yang dihapus baris header DI ATASNYA,
    // bukan hero-nya.
    expect(find.byKey(const Key('home-hero-card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/widgets/share_reward.dart';
import 'package:muslim_leveling/widgets/xp_toast.dart';

/// XP share kartu: +10 per share, cap 3/hari (30 XP/hari).
///
/// Yang dijaga tes ini bukan cuma "XP nambah", tapi tiga hal yang gampang
/// salah: cap benar-benar menahan, hari berganti tepat di 03:00 (bukan
/// tengah malam), dan share di atas cap TIDAK memalsukan reward.
/// Membuang toast sampai benar-benar hilang.
///
/// Kenapa bertahap, bukan satu `pump(2200ms)`: `showXpToast` memakai
/// `Future.delayed(1600ms)` lalu `reverse()`. Satu lompatan waktu besar
/// melewati timer-nya tapi menyisakan animasi di frame pertama, jadi toast
/// "macet" terlihat di tes padahal di app sungguhan (frame nyata) tidak.
/// Ini jebakan harness, bukan perilaku produk.
Future<void> _pumpToastAway(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    if (find.textContaining('XP').evaluate().isEmpty) return;
    await tester.pump(const Duration(milliseconds: 200));
  }
  fail('toast XP tidak pernah hilang setelah 8 detik waktu tes');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
    ShareReward.resetForTest();
  });

  test('share pertama memberi +10 XP dan tercatat hari ini', () async {
    await GameService.load();
    final xp0 = GameService.current.xp;

    expect(await GameService.awardShareXp(), GameService.shareXpPerCard);
    expect(GameService.current.xp, xp0 + GameService.shareXpPerCard);
    expect(GameService.current.shareXpCount, 1);
    expect(GameService.current.shareXpDate, GameService.todayStr());
  });

  test('tiga share sehari = 30 XP; share keempat tidak menambah', () async {
    await GameService.load();
    final xp0 = GameService.current.xp;

    expect(await GameService.awardShareXp(), 10);
    expect(await GameService.awardShareXp(), 10);
    expect(await GameService.awardShareXp(), 10);
    expect(GameService.current.xp, xp0 + 30);
    expect(GameService.shareXpCountToday, 3);

    // keempat: 0 XP, dan counter TIDAK naik (bukan cuma XP-nya yang ditahan)
    expect(await GameService.awardShareXp(), 0);
    expect(GameService.current.xp, xp0 + 30);
    expect(GameService.current.shareXpCount, 3);

    // berkali-kali pun tetap 30
    await GameService.awardShareXp();
    await GameService.awardShareXp();
    expect(GameService.current.xp, xp0 + 30);
  });

  test('cap dihitung dari dailyDateKey: reset jam 03:00, bukan tengah malam',
      () async {
    await GameService.load();
    final xp0 = GameService.current.xp;

    // Tiga share pada "hari" yang sama secara dailyDateKey (00:30, 01:00, 02:30
    // semuanya milik hari kalender KEMARIN).
    expect(await GameService.awardShareXp(DateTime(2026, 10, 11, 0, 30)), 10);
    expect(await GameService.awardShareXp(DateTime(2026, 10, 11, 1, 0)), 10);
    expect(await GameService.awardShareXp(DateTime(2026, 10, 11, 2, 30)), 10);
    // 00:30-02:30 masih milik hari IBADAH sebelumnya (03:00 batasnya),
    // jadi cap tersimpan menunjuk 2026-10-10, bukan 2026-10-11.
    expect(GameService.current.shareXpCount, 3);
    expect(GameService.current.shareXpDate, '2026-10-10');

    // 02:59 masih hari ibadah yang sama -> ditahan.
    expect(await GameService.awardShareXp(DateTime(2026, 10, 11, 2, 59)), 0);
    expect(GameService.current.xp, xp0 + 30);

    // 03:00 hari baru -> boleh lagi.
    expect(await GameService.awardShareXp(DateTime(2026, 10, 11, 3, 0)), 10);
    expect(GameService.current.xp, xp0 + 40);
  });

  test('hari kalender berikutnya memberi kuota baru', () async {
    await GameService.load();
    final xp0 = GameService.current.xp;

    await GameService.awardShareXp(DateTime(2026, 10, 10, 10, 0));
    await GameService.awardShareXp(DateTime(2026, 10, 10, 11, 0));
    await GameService.awardShareXp(DateTime(2026, 10, 10, 12, 0));
    expect(await GameService.awardShareXp(DateTime(2026, 10, 10, 13, 0)), 0);

    expect(await GameService.awardShareXp(DateTime(2026, 10, 11, 10, 0)), 10);
    expect(GameService.current.xp, xp0 + 40);
    expect(GameService.current.shareXpCount, 1);
  });

  test('counter share bertahan lewat round-trip map', () async {
    await GameService.load();
    await GameService.awardShareXp(DateTime(2026, 10, 11, 10, 0));

    final restored = GameState.fromMap(GameService.current.toMap());
    expect(restored.shareXpCount, 1);
    expect(restored.shareXpDate, '2026-10-11');
  });

  test('save lama tanpa field share tidak dianggap sudah share', () async {
    // Simulasi pemakai lama: map tanpa shareXpDate/shareXpCount sama sekali.
    final legacy = GameState.fromMap({'xp': 500, 'level': 5});
    expect(legacy.shareXpCount, 0);
    expect(legacy.shareXpDate, '');

    final today = GameService.dailyDateKey(DateTime(2026, 10, 11, 10, 0));
    await GameService.load();
    // hari berganti -> kuota penuh, bukan sisa dari save lama
    await GameService.awardShareXp(DateTime(2026, 10, 11, 10, 0));
    expect(GameService.shareXpCountToday, 1);
    expect(await GameService.awardShareXp(DateTime(2026, 10, 11, 11, 0)), 10);
    await GameService.awardShareXp(DateTime(2026, 10, 11, 12, 0));
    expect(GameService.shareXpCountToday, 3);
    expect(GameService.current.shareXpDate, today);
  });

  testWidgets('notif +10 XP muncul DI ATAS bottom sheet share', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280); // 360x760 dp
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(bottom: 144); // nav 3 tombol
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    addTearDown(tester.view.reset);

    late BuildContext sheetCtx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: ctx,
                  isScrollControlled: true,
                  builder: (c) {
                    sheetCtx = c;
                    return const SafeArea(
                      child: SizedBox(height: 560, child: Text('SHEET')),
                    );
                  },
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Sheet menutupi layar: toast harus tetap tergambar (rootOverlay).
    showXpToast(sheetCtx, GameService.shareXpPerCard);
    // DUA pump: yang pertama memulai ticker animasi (nilainya masih 0, jadi
    // toast belum terlihat), yang kedua memajukan waktu sampai opacity penuh.
    // Satu pump besar saja membuat tes lolos walau toast tak pernah tampak.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('+10 XP'), findsOneWidget,
        reason: 'notif XP harus ada di pohon widget walau bottom sheet terbuka');

    final opacity = find.ancestor(
      of: find.text('+10 XP'),
      matching: find.byType(Opacity),
    );
    expect(opacity, findsWidgets);
    expect(
      (opacity.evaluate().first.widget as Opacity).opacity,
      1.0,
      reason: 'toast harus benar-benar TERLIHAT, bukan sekadar ada di tree',
    );

    // Habiskan masa hidup toast (1600ms tahan + 200ms turun) supaya
    // AnimationController-nya tidak bocor saat pohon widget dibongkar.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
  });

  testWidgets('reveal DITUNDA saat share, muncul setelah app kembali aktif',
      (tester) async {
    await GameService.load();
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold(body: SizedBox());
      }),
    ));

    // Menekan Bagikan: ShareUtil menaruh app ke background, jadi reward
    // TIDAK boleh tampil sekarang (animasinya akan habis sebelum user balik).
    await ShareReward.onShared(ctx);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('+10 XP'), findsNothing,
        reason: 'saat app di background belum boleh ada reveal');
    expect(ShareReward.hasPending, isTrue, reason: 'reward harus tertunda');

    // App kembali aktif -> reveal baru tampil, dan terlihat penuh.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('+10 XP'), findsOneWidget);
    final op = find.ancestor(
        of: find.text('+10 XP'), matching: find.byType(Opacity));
    expect((op.evaluate().first.widget as Opacity).opacity, 1.0);
    expect(ShareReward.hasPending, isFalse, reason: 'reveal hanya sekali');

    await _pumpToastAway(tester);
  });

  testWidgets('cap habis: tidak ada reveal tertunda sama sekali',
      (tester) async {
    await GameService.load();
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold(body: SizedBox());
      }),
    ));

    for (var i = 0; i < GameService.shareDailyCap; i++) {
      await ShareReward.onShared(ctx);
      ShareReward.onResumed();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('+10 XP'), findsOneWidget);
      await _pumpToastAway(tester);
    }
    expect(GameService.shareXpCountToday, GameService.shareDailyCap);

    await ShareReward.onShared(ctx); // ke-4: tidak dapat XP
    expect(ShareReward.hasPending, isFalse,
        reason: 'jangan tunda reveal untuk XP yang tidak diberikan');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('+10 XP'), findsNothing,
        reason: 'share ke-4 tidak memberi XP, jadi tidak boleh ada reveal');
  });

  testWidgets('konteks basi (layar sudah ditutup) tidak menampilkan apa pun',
      (tester) async {
    await GameService.load();
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold(body: SizedBox());
      }),
    ));
    await ShareReward.onShared(ctx);
    expect(ShareReward.hasPending, isTrue);

    // User menutup layar share sebelum kembali ke app.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('+10 XP'), findsNothing);
    expect(ShareReward.hasPending, isFalse);
  });

  testWidgets('pill duduk di atas tombol Bagikan, tidak menutupinya',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2280); // 360x760 dp
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(bottom: 144); // nav 3 tombol
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    addTearDown(tester.view.reset);

    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return Scaffold(
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                const Spacer(),
                const SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(onPressed: null, child: Text('Bagikan'))),
              ],
            ),
          ),
        );
      }),
    ));

    showXpToast(ctx, 10, bottomOffset: 64);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final pill = tester.getRect(find.text('+10 XP'));
    final button = tester.getRect(find.text('Bagikan'));
    final gap = button.top - pill.bottom;
    expect(gap, greaterThanOrEqualTo(4),
        reason: 'pill tidak boleh menutupi tombol yang baru ditekan');
    // Terukur: dengan bottomOffset 64 jaraknya 38,5 dp (teks bukan tepi pill).
    // Kalau bottomOffset diabaikan (default 76), jaraknya 50,5 dp.
    expect(gap, lessThanOrEqualTo(46),
        reason: 'reward harus menempel pada aksi, bukan melayang jauh. '
            'Jarak ~50 dp berarti bottomOffset diabaikan dan dipakai default 76');

    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
  });
}

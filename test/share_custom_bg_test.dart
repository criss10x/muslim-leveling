import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/widgets/quran_share_sheet.dart';
import 'package:muslim_leveling/widgets/share_card_kit.dart';

import 'helpers/app_wrap.dart';

/// Background foto user + pengatur gelap pada kartu share.
///
/// Tiga hal yang dijaga di sini:
/// 1. Mode "Foto Saya" bisa dipilih SEBELUM ada foto. Memilih mode hanya
///    memindahkan pilihan; fotonya baru ada setelah user menekan tombol pilih.
/// 2. Pengatur "Gelap" hanya muncul di background foto, tidak di solid/gradasi.
/// 3. Foto user benar-benar terpakai sebagai background kartu (FileImage).
void main() {
  // Konstanta langsung: data Quran dimuat dari aset, dan yang diuji di sini
  // adalah mekanisme background, bukan isi ayatnya.
  const surah = QuranSurah(
    number: 2,
    nameArabic: 'البقرة',
    nameLatin: 'Al-Baqarah',
    meaning: 'Sapi Betina',
    ayahCount: 286,
    revelation: 'Madaniyah',
  );
  const ayah = QuranAyah(
    ayah: 255,
    arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    translation: 'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup.',
  );

  /// Buka sheet share sungguhan lewat jalur publik (tombol → push), lalu
  /// biarkan layoutnya selesai.
  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      appWrap(
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () =>
                    showQuranShareSheet(context, surah: surah, ayah: ayah),
                child: const Text('buka'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    // pumpAndSettle TIDAK bisa dipakai di layar ini: ada animasi yang berulang
    // tanpa henti, jadi ia menggantung sampai test timeout.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  /// pump bertahap, bukan pumpAndSettle (alasan sama seperti [openSheet]).
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  testWidgets('mode foto user bisa dipilih sebelum ada foto (tidak crash)', (
    tester,
  ) async {
    await openSheet(tester);

    // Pilih mode "Foto Saya" lewat chip mode. Sebelum ada foto, kartu harus
    // tetap tampil dengan preset default — bukan melempar.
    await tester.tap(find.text('Foto Saya'));
    await settle(tester);

    expect(tester.takeException(), isNull,
        reason: 'memilih mode foto tanpa foto harus aman');
    expect(find.text('Pilih foto'), findsOneWidget,
        reason: 'tombol pilih foto wajib ada di mode ini');
    // Belum ada foto = belum ada gambar yang bisa digelapkan, dan kartunya
    // masih memakai preset default (gradasi). Pengatur gelap muncul setelah
    // fotonya ada.
    expect(find.byType(Slider), findsNothing,
        reason: 'tanpa foto belum ada yang bisa diatur gelapnya');
  });

  testWidgets('pengatur gelap TIDAK muncul di solid & gradasi', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Solid'));
    await settle(tester);
    expect(find.byType(Slider), findsNothing,
        reason: 'solid sudah warna bersih, tidak ada yang bisa digelapkan');

    await tester.tap(find.text('Gradasi'));
    await settle(tester);
    expect(find.byType(Slider), findsNothing,
        reason: 'gradasi jade = identitas app, jangan bisa dimatikan');

    await tester.tap(find.text('Estetik'));
    await settle(tester);
    expect(find.byType(Slider), findsOneWidget,
        reason: 'foto bawaan pun perlu bisa diatur gelap-terangnya');
  });

  test('pengatur gelap mengubah scrim efektif, dan reset saat pindah', () {
    final memory = SharePresetMemory();

    // Foto bawaan: patokan scrim milik preset.
    memory.selectKind(ShareBgKind.esthetic);
    final patokan = memory.preset.scrim;
    expect(memory.effectiveScrim, patokan);

    memory.setEffectiveScrim(0.9);
    expect(memory.effectiveScrim, closeTo(0.9, 0.001));

    // Bisa juga MURNI meredupkan: 9 foto bawaan punya patokan keras yang
    // dipilih sepihak oleh app, jadi user harus bisa menurunkannya juga.
    memory.setEffectiveScrim(0.05);
    expect(memory.effectiveScrim, closeTo(0.05, 0.001));

    // 0 = tanpa scrim sama sekali; foto yang sudah gelap boleh dibiarkan apa
    // adanya.
    memory.setEffectiveScrim(0);
    expect(memory.effectiveScrim, 0);

    // Pindah preset membuang pilihan user: kalau ikut terbawa, foto berikutnya
    // terbuka dengan kegelapan milik foto sebelumnya.
    memory.setEffectiveScrim(0.9);
    memory.selectPreset(shareBgPresets.last);
    expect(memory.effectiveScrim, memory.preset.scrim,
        reason: 'kegelapan pilihan user tidak boleh bocor ke preset lain');
  });

  testWidgets('foto user terpakai sebagai background kartu (FileImage)', (
    tester,
  ) async {
    // PNG asli dibuat lewat API Flutter, bukan byte yang ditulis tangan:
    // byte karangan bisa saja ditolak decoder, dan test jadi lulus karena
    // gambar gagal dimuat, bukan karena fiturnya jalan.
    //
    // WAJIB lewat runAsync: `toImage`/`toByteData` menunggu kerja nyata dari
    // engine, sedangkan zona async palsu milik widget test tidak pernah
    // memompanya. Tanpa ini future-nya tidak pernah selesai dan test
    // menggantung sampai harness membunuhnya.
    final png = (await tester.runAsync(_makePngBytes))!;
    final dir = Directory.systemTemp.createTempSync('share_photo_test');
    final f = File('${dir.path}/bg.png')
      ..writeAsBytesSync(png, flush: true);
    expect(f.lengthSync(), greaterThan(0));

    final memory = SharePresetMemory()..selectCustomPhoto(f);
    expect(memory.isCustom, isTrue);
    expect(memory.kind, ShareBgKind.custom);
    expect(memory.preset.kind, ShareBgKind.custom);
    expect(memory.preset.decoration.image, isA<DecorationImage>());

    await tester.pumpWidget(
      appWrap(
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: memory.preset.decoration,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull,
        reason: 'FileImage dari foto user harus bisa digambar');
    expect(find.byType(DecoratedBox), findsWidgets);

    dir.deleteSync(recursive: true);
  });
}

/// PNG 2x2 sungguhan dari Flutter sendiri.
Future<List<int>> _makePngBytes() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 2, 2),
    Paint()..color = const Color(0xFF123456),
  );
  final image = await recorder.endRecording().toImage(2, 2);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

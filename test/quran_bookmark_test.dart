import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_bookmark.dart';

void main() {
  // SharedPreferences.setMockInitialValues kosong — toggle harus jalan
  // in-memory walau tulis prefs gagal/async belum selesai.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggle menambah lalu menghapus bookmark yang sama', () async {
    final b = QuranBookmarks();
    await b.toggle(2, 255, 'arab', 'terjemah');
    expect(b.items.length, 1);
    expect(b.isBookmarked(2, 255), isTrue);

    await b.toggle(2, 255, 'arab', 'terjemah');
    expect(b.items.length, 0);
    expect(b.isBookmarked(2, 255), isFalse);
  });

  test('bookmark baru masuk paling atas (urut waktu terbaru)', () async {
    final b = QuranBookmarks();
    await b.toggle(1, 1, 'a', 't1');
    await b.toggle(2, 2, 'b', 't2');
    expect(b.items.first.surah, 2);
    expect(b.items.first.ayah, 2);
  });
}

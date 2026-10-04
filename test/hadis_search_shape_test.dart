import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/hadis_api.dart';

// Bentuk respons kedua sumber yang dipakai layar Hadis:
//  - proxy  : explore → `text: {ar, id}`; cari → `text` String (ID translation)
//  - sumber : `hadeeth` (terjemahan) + `hadeeth_ar` (Arab) + `attribution` +
//             `hints` (poin pelajaran, dulu bernama `hikmah`)
// Semua bentuk harus menghasilkan idn non-kosong.
void main() {
  test('fromProxy: kedua bentuk text terisi', () {
    final search = HadisItem.fromProxy({
      'id': 4223,
      'text': 'Dari Sālim bin Abdillah... bersabda, "Sebaik-baik orang..."',
    });
    expect(search.idn, contains('Sebaik-baik'));
    expect(search.ar, '');

    final explore = HadisItem.fromProxy({
      'id': 1751,
      'text': {'ar': 'عَنْ أُمِّ عَطِيَّةَ', 'id': 'Dari Ummu Athiyyah...'},
    });
    expect(explore.ar, isNotEmpty);
    expect(explore.idn, contains('Ummu'));
  });

  test('fromSource: field terjemahan bahasa apa pun terpetakan', () {
    // Bentuk nyata respons language=en untuk id 1751.
    final en = HadisItem.fromSource({
      'id': '1751',
      'hadeeth': "'Umm 'Atiyyah (may Allah be pleased with her) reported: One of "
          'the daughters of the Prophet passed away',
      'hadeeth_ar': 'عَنْ أُمِّ عَطِيَّةَ',
      'attribution': 'Agreed upon',
      'grade': 'Authentic',
      'hints': ['The washing of a deceased Muslim is obligatory.'],
      'explanation': 'Zaynab passed away. The Prophet entered upon the women',
    });
    expect(en.id, 1751);
    expect(en.idn, contains("'Umm 'Atiyyah"));
    expect(en.ar, isNotEmpty);
    expect(en.takhrij, 'Agreed upon');
    expect(en.grade, 'Authentic');
    expect(en.hikmah, contains('washing of a deceased'));

    // Turki: grade juga diterjemahkan ("Sahih Hadis").
    final tr = HadisItem.fromSource({
      'id': '1751',
      'hadeeth': 'Ümmü Atiyye dedi ki:',
      'hadeeth_ar': 'عَنْ أُمِّ عَطِيَّةَ',
      'attribution': 'Muttefekun aleyh',
      'grade': 'Sahih Hadis',
      'hints': ['Vefat eden Müslümanın yıkanması farz-ı kifâyedir.'],
    });
    expect(tr.takhrij, 'Muttefekun aleyh');
    expect(tr.hikmah, contains('farz-ı kifâyedir'));
  });

  test('fromSource: hints kosong → hikmah null, bukan string kosong', () {
    final item = HadisItem.fromSource({
      'id': '1',
      'hadeeth': 'x',
      'hadeeth_ar': 'x',
      'hints': <String>[],
    });
    expect(item.hikmah, isNull);
  });

  test('mergeSource mempertahankan teks proxy bila sumber tak punya', () {
    final proxy = HadisItem.fromProxy({
      'id': 1751,
      'text': {'ar': 'عربي', 'id': 'Terjemahan Indonesia'},
      'grade': 'Sahih',
      'takhrij': "Muttafaq 'alaih",
      'hikmah': 'Poin Indonesia',
    });
    // Sumber balas tanpa teks (mis. id itu belum diterjemahkan ke bahasa ini).
    final kosong = HadisItem.fromSource({'id': '1751'});
    final merged = proxy.mergeSource(kosong);
    expect(merged.idn, 'Terjemahan Indonesia');
    expect(merged.ar, 'عربي');
    expect(merged.grade, 'Sahih');
    expect(merged.hikmah, 'Poin Indonesia');

    // Dan sebaliknya: sumber menimpa teks proxy.
    final en = HadisItem.fromSource({
      'id': '1751',
      'hadeeth': 'English translation',
      'hadeeth_ar': 'عربي',
      'grade': 'Authentic',
    });
    final merged2 = proxy.mergeSource(en);
    expect(merged2.idn, 'English translation');
    expect(merged2.grade, 'Authentic');
  });

  test('HadisLang: ms & locale tak dikenal jatuh ke Inggris', () {
    expect(HadisLang.of('id'), HadisLang.id);
    expect(HadisLang.of('en'), HadisLang.en);
    expect(HadisLang.of('tr'), HadisLang.tr);
    // API tidak punya terjemahan Melayu (diuji → 404).
    expect(HadisLang.of('ms'), HadisLang.en);
    expect(HadisLang.of('ar'), HadisLang.en);
  });

  test('total halaman explore tidak berubah (kontrak UI 5 item/halaman)', () {
    expect(hadisExplorePageSize, 5);
    expect(hadisTotalPages, 452);
  });
}

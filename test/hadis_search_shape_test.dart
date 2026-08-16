import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/hadis_api.dart';

// ponytail: runnable check — cari/ returns text as String (ID translation),
// explore/ returns {ar,id}. Both shapes must produce non-empty idn.
void main() {
  test('HadisItem.fromJson: kedua bentuk text terisi', () {
    final search = HadisItem.fromJson({
      'id': 4223,
      'text': 'Dari Sālim bin Abdillah... bersabda, "Sebaik-baik orang..."',
    });
    expect(search.idn, contains('Sebaik-baik'));
    expect(search.ar, '');

    final explore = HadisItem.fromJson({
      'id': 1751,
      'text': {'ar': 'عَنْ أُمِّ عَطِيَّةَ', 'id': 'Dari Ummu Athiyyah...'},
    });
    expect(explore.ar, isNotEmpty);
    expect(explore.idn, contains('Ummu'));
  });
}

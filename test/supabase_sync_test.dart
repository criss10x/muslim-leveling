import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/supabase_sync.dart';

void main() {
  test('backup login gagal bila salah satu data inti tidak tersimpan', () {
    expect(SupabaseSync.allSaved([true, true, false]), isFalse);
  });
}

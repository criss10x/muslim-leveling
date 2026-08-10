import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('does not ship the static Supabase export', () {
    expect(File('assets/supabase_export.json').existsSync(), isFalse);
  });
}

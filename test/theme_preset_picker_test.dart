import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/theme_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:muslim_leveling/widgets/theme_preset_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows four presets and selects Mushaf', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ThemePresetPicker())),
    );
    expect(find.text('Gelap'), findsOneWidget);
    expect(find.text('Terang'), findsOneWidget);
    expect(find.text('Night Mosque'), findsOneWidget);
    expect(find.text('Mushaf'), findsOneWidget);

    await tester.tap(find.text('Mushaf'));
    await tester.pump();

    expect(themeNotifier.preset, AppThemePreset.lightMushaf);
  });
}

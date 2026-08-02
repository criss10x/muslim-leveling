import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/welcome_pejuang.dart';

void main() {
  testWidgets('onboarding presents the first mission with concise benefits', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomePejuangScreen()));

    expect(find.text('MULAI MISI PERTAMA'), findsOneWidget);
    expect(find.text('Sholat → XP → streak'), findsOneWidget);
    expect(find.text('Artikel & quiz Islam'), findsOneWidget);
    expect(find.text('Konsisten, raih badge'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/entitlement_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('all features are available without entitlement state', () async {
    await EntitlementService.load();
    expect(EntitlementService.isPro, isTrue);
    expect(EntitlementService.proStatus.value, isTrue);
  });

  test('deprecated dev toggle retains free access', () async {
    await EntitlementService.load();
    var fired = false;
    void listener() => fired = true;
    EntitlementService.proStatus.addListener(listener);

    await EntitlementService.setProDev(false);
    expect(EntitlementService.isPro, isTrue);
    expect(fired, isFalse);

    EntitlementService.proStatus.removeListener(listener);

    await EntitlementService.load();
    expect(EntitlementService.isPro, isTrue);
  });
}

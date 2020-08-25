import 'package:dartbase_admin/dartbase_admin.dart';
import 'package:test/test.dart';

import 'test_config.dart';

Future main() async {
  setUpAll(() async {
    await Firebase.initialize(projectId, await ServiceAccount.fromFile(serviceAccountPath));
    await Admob.initialize();
  });
  test('Admob Tests', () async {
    var result = Admob.instance.verifyRewardAd(
        'example.com/rewardVerification?ad_network=5450213213286189855&ad_unit=1234567890&timestamp=1598357093204&transaction_id=123456789&user_id=testuserid&signature=MEQCIDE9INfQq8L_7QyndJqgwV8cin3qTKIzxnVuAQCTY0QjAiA4R_tN91omphgtcLqRCqt7oJ4c4682QIV7lW6vvsLSiw&key_id=3335741209');
    expect(result, true);
  });
}

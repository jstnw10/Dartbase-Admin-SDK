import 'package:dartbase/dartbase.dart';
import 'package:firedart/firedart.dart' as fd;
import 'package:test/test.dart';

import 'test_config.dart';

Future main() async {
  setUpAll(() async {
    await Firebase.initialize(projectId, await ServiceAccount.fromFile(serviceAccountPath));

    fd.FirebaseAuth.initialize(webApiKey, fd.VolatileStore());

    await FirebaseAuth.initialize();
  });

  test('Verify Token', () async {
    await fd.FirebaseAuth.instance.signIn(email, pass);
    var token = await fd.FirebaseAuth.instance.tokenProvider.idToken;

    await Future.delayed(const Duration(seconds: 5));
    var id = await FirebaseAuth.instance.verifyIdToken(token);
    expect(id != null, true);
    print(id);
  });
}

import 'package:dartbase_admin/dartbase_admin.dart';
import 'package:firedart/firedart.dart' as fd;
import 'package:test/test.dart';

import 'test_config.dart';

/// We're using firedart here, which is a dart-native firebase CLIENT sdk to sign us in and generate an ID token to use
/// in our tests.
Future main() async {
  setUpAll(() async {
    await Firebase.initialize(
        projectId, await ServiceAccount.fromFile(serviceAccountPath));

    await FirebaseAuth.initialize();
  });

  test('Get user by ID', () async {
    var user = await FirebaseAuth.instance.getUserById(uid);
    print(user.toString());
    expect(user.email, email);
  });

  test('Verify Token', () async {
    fd.FirebaseAuth.initialize(webApiKey, fd.VolatileStore());
    await fd.FirebaseAuth.instance.signIn(email, pass);
    var token = await fd.FirebaseAuth.instance.tokenProvider.idToken;

    await Future.delayed(const Duration(seconds: 5));
    var id = await FirebaseAuth.instance.verifyIdToken(token,
        checkRevoked: true, enforceEmailVerification: true);
    expect(id != null, true);
    print(id);
  });
}

import 'package:firedart/firedart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

Future main() async {
  FirebaseAuth auth;

  setUpAll(() async {
    auth = FirebaseAuth(projectId, await ServiceAccount.fromFile(serviceAccountPath));
  });
}

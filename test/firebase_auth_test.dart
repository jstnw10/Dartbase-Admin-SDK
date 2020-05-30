import 'package:dartbase/dartbase.dart';
import 'package:test/test.dart';

import 'test_config.dart';

Future main() async {
  Firebase auth;

  setUpAll(() async {
    auth =
        Firebase(projectId, await ServiceAccount.fromFile(serviceAccountPath));
  });
}

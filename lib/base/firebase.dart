import 'package:dartbase_admin/auth/service_account/service_account.dart';
import 'package:http/http.dart' as http;

import 'client.dart';

/// For service accounts, you can use ServiceAccount.fromJson(String) or ServiceAccount.fromEnvironmentVariable(optional String)
/// Using the environment variable implementation will crash if you are on a platform that dart:io does not support.
class Firebase {
  static Firebase _instance;

  static bool get initialized => _instance != null;

  static Future<Firebase> initialize(String projectId, ServiceAccount serviceAccount) async {
    assert(!initialized,
        'Firebase global instance is already initialized. Do not call this twice or create a local instance via Firebase()');
    _instance = Firebase(projectId, serviceAccount);
    await _instance.init();
    return _instance;
  }

  static Firebase get instance {
    assert(initialized,
        "Firebase hasn't been initialized. Call Firebase.initialize() before using this global instance. Alternatively, create a local instance via Firebase() and use that.");
    return _instance;
  }

  final String projectId;
  final ServiceAccount serviceAccount;

  final http.Client httpClient = http.Client();
  AdminClient client;

  Firebase(this.projectId, this.serviceAccount);

  Future<void> init() async {
    var accessToken = await serviceAccount.getAccessToken();
    client = AdminClient(httpClient, {'authorization': 'Bearer ${accessToken.accessToken}'});
  }
}

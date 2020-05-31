import 'package:dartbase/auth/service_account/service_account.dart';
import 'package:dartbase/auth/token/verify_token.dart';
import 'package:http/http.dart' as http;

import 'client.dart';
import 'user_gateway.dart';
import 'user_record.dart';

/// For service accounts, you can use ServiceAccount.fromJson(String) or ServiceAccount.fromEnvironmentVariable(optional String)
/// Using the environment variable implementation will crash if you are on a platform that dart:io does not support.
class Firebase {
  static Firebase _instance;

  static bool get initialized => _instance != null;

  static Future<Firebase> initialize(
      String projectId, ServiceAccount serviceAccount) async {
    assert(initialized,
        'Firebase global instance is already initialized. Do not call this twice or create a local instance via Firebase()');
    _instance = Firebase(projectId, serviceAccount);
    await _instance.init();
    return _instance;
  }

  static Firebase get instance {
    assert(!initialized,
        "Firebase hasn't been initialized. Call Firebase.initialize() before using this global instance. Alternatively, create a local instance via Firebase() and use that.");
    return _instance;
  }

  final String projectId;
  final ServiceAccount serviceAccount;

  http.Client httpClient;

  UserGateway _userGateway;

  Firebase(this.projectId, this.serviceAccount, {this.httpClient}) {
    httpClient ??= http.Client();
  }

  Future<void> init() async {
    var accessToken = await serviceAccount.getAccessToken();
    print(accessToken);
    var adminClient = AdminClient(
        httpClient, {'authorization': 'Bearer ${accessToken.accessToken}'});

    _userGateway = UserGateway(projectId, adminClient);
  }

  Future<UserRecord> getUserById(String uid) => _userGateway.getUserById(uid);

  Future<bool> verifyIdToken(String token,
      {Firebase authInstance,
      bool enforceEmailVerification = false,
      bool checkRevoked = false}) async {
    try {
      await verifyToken(token,
          authInstance: authInstance,
          enforceEmailVerification: enforceEmailVerification,
          checkRevoked: checkRevoked);
      return true;
    } catch (error) {
      print(error);
    }
    return false;
  }
}

import 'package:firedart/auth/client.dart';
import 'package:firedart/auth/service_account/service_account.dart';
import 'package:firedart/auth/token/verify_token.dart';
import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/auth/user_record.dart';
import 'package:http/http.dart' as http;

/// For service accounts, you can use ServiceAccount.fromJson(String) or ServiceAccount.fromEnvironmentVariable(optional String)
/// Using the environment variable implementation will crash if you are on a platform that dart:io does not support.
class FirebaseAuth {
  static FirebaseAuth _instance;

  static Future<FirebaseAuth> initialize(String projectId, ServiceAccount serviceAccount) async {
    if (_instance != null) {
      throw Exception('FirebaseAuth instance was already initialized');
    }
    _instance = FirebaseAuth(projectId, serviceAccount);
    await _instance.init();
    return _instance;
  }

  static FirebaseAuth get instance {
    if (_instance == null) {
      throw Exception("FirebaseAuth hasn't been initialized. Please call FirebaseAuth.initialize() before using it.");
    }
    return _instance;
  }

  final String projectId;
  final ServiceAccount serviceAccount;

  http.Client httpClient;

  UserGateway _userGateway;

  FirebaseAuth(this.projectId, this.serviceAccount, {this.httpClient}) {
    httpClient ??= http.Client();
  }

  Future<void> init() async {
    var accessToken = await serviceAccount.getAccessToken();
    print(accessToken);
    var adminClient = AdminClient(httpClient, {'authorization': 'Bearer ${accessToken.accessToken}'});

    _userGateway = UserGateway(projectId, adminClient);
  }

  Future<UserRecord> getUserById(String uid) => _userGateway.getUserById(uid);

  Future<bool> verifyIdToken(String token,
      {FirebaseAuth authInstance, bool enforceEmailVerification = false, bool checkRevoked = false}) async {
    try {
      await verifyToken(token,
          authInstance: authInstance, enforceEmailVerification: enforceEmailVerification, checkRevoked: checkRevoked);
      return true;
    } catch (error) {
      print(error);
    }
    return false;
  }
}

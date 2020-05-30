import 'dart:convert';

import 'client.dart';
import 'user_record.dart';

class UserGateway {
  final AdminClient client;
  final String projectId;

  UserGateway(this.projectId, this.client);

  Future<UserRecord> getUserById(String uid) async {
    var map = await _post('lookup', {'localId': uid});
    return UserRecord.fromJson(map['users'][0]);
  }

  Future<Map<String, dynamic>> _post<T>(
      String method, Map<String, dynamic> body) async {
    var requestUrl =
        'https://identitytoolkit.googleapis.com/v1/projects/$projectId/accounts:$method';

    var response = await client
        .post(requestUrl, body: body)
        .catchError((error) => print(error));

    return json.decode(response.body);
  }
}

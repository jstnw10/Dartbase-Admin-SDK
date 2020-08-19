import 'dart:convert';

import 'package:dartbase_admin/auth/service_account/service_account.dart';
import 'package:http/http.dart' as http;

class VerboseClient extends http.BaseClient {
  http.Client _client;

  VerboseClient() {
    _client = http.Client();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('--> ${request.method} ${request.url}');
    print(request.headers);
    print((request as http.Request).body);

    var response = await _client.send(request);
    print(
        '<-- ${response.statusCode} ${response.reasonPhrase} ${response.request.url}');
    var loggedStream = response.stream.map((event) {
      print(utf8.decode(event));
      return event;
    });

    return http.StreamedResponse(
      loggedStream,
      response.statusCode,
      headers: response.headers,
      contentLength: response.contentLength,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
      request: response.request,
    );
  }
}

class AdminClient extends http.BaseClient {
  final http.Client _client;
  final ServiceAccount _serviceAccount;
  String token;
  DateTime lastDate;

  AdminClient(this._client, this._serviceAccount);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (token == null) {
      /// Generate a fresh token
      var tokenData = await _serviceAccount.generateAdminAccessToken();
      token = tokenData['access_token'];
      lastDate = DateTime.now().add(Duration(seconds: tokenData['expires_in']));
    } else {
      /// Generate a new token after the current one expires.
      if (lastDate.compareTo(DateTime.now()) <= 0) {
        var tokenData = await _serviceAccount.generateAdminAccessToken();
        token = tokenData['access_token'];
        lastDate =
            DateTime.now().add(Duration(seconds: tokenData['expires_in']));
      }
    }

    request.headers['Authorization'] = 'Bearer ${token}';

    print('${request.headers['Authorization']}');

    return _client.send(request);
  }
}

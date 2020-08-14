import 'dart:convert';

import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:dartbase_admin/platform/access_exporter.dart';
import 'package:http/http.dart' as http;

class ServiceAccount {
  final String serviceAccountString;

  Map<String, dynamic> map;

  ServiceAccount.fromJson(this.serviceAccountString) : map = jsonDecode(serviceAccountString);

  ServiceAccount.fromEnvironmentVariable(
      {String environmentVariable = 'GOOGLE_APPLICATION_CREDENTIALS'})
      : serviceAccountString = getPlatformAccess().getEnvironmentVariable(environmentVariable),
        map = jsonDecode(getPlatformAccess().getEnvironmentVariable(environmentVariable));

  Future<String> generateAccessToken() async {
    var builder = JWTBuilder()
      ..issuer = map['client_email']
      ..issuedAt = DateTime.now()
      ..expiresAt = DateTime.now().add(Duration(hours: 3600))
      ..audience = map['token_uri']
      ..setClaim(
          'scope',
          [
            'https://www.googleapis.com/auth/cloud-platform',
            'https://www.googleapis.com/auth/firebase.database',
            'https://www.googleapis.com/auth/firebase.messaging',
            'https://www.googleapis.com/auth/identitytoolkit',
            'https://www.googleapis.com/auth/userinfo.email',
          ].join(' '));

    var signer = JWTRsaSha256Signer(privateKey: map['private_key']);
    var signedToken = builder.getSignedToken(signer).toString();

    var response = await http.post(map['token_uri'], body: {
      'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      'assertion': signedToken,
    });
    var json = jsonDecode(response.body);
    return json['access_token'];
  }

  static Future<ServiceAccount> fromFile(String filePath) async =>
      ServiceAccount.fromJson(await getPlatformAccess().getStringFromFile(filePath));
}

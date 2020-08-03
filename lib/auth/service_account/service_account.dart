import 'dart:convert';

import 'package:dartbase_admin/auth/service_account/token_handler.dart';
import 'package:dartbase_admin/platform/access_exporter.dart';

class ServiceAccount {
  final String serviceAccountString;

  Map<String, String> map;

  ServiceAccount.fromJson(this.serviceAccountString) : map = jsonDecode(serviceAccountString);

  ServiceAccount.fromEnvironmentVariable(
      {String environmentVariable = 'GOOGLE_APPLICATION_CREDENTIALS'})
      : serviceAccountString = getPlatformAccess().getEnvironmentVariable(environmentVariable),
        map = jsonDecode(getPlatformAccess().getEnvironmentVariable(environmentVariable));

  Future<AccessToken> getAccessToken() async {
    return ServiceAccountCredential(jsonDecode(serviceAccountString)).getAccessToken();
  }

  static Future<ServiceAccount> fromFile(String filePath) async =>
      ServiceAccount.fromJson(await getPlatformAccess().getStringFromFile(filePath));
}

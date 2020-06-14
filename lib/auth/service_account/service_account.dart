import 'dart:convert';

import 'package:dartbase_admin/auth/service_account/token_handler.dart';
import 'package:dartbase_admin/platform/access_exporter.dart';

class ServiceAccount {
  final String serviceAccountString;

  ServiceAccount.fromJson(this.serviceAccountString);

  ServiceAccount.fromEnvironmentVariable(
      {String environmentVariable = 'GOOGLE_APPLICATION_CREDENTIALS'})
      : serviceAccountString =
            getPlatformAccess().getEnvironmentVariable(environmentVariable);

  Future<AccessToken> getAccessToken() async {
    return ServiceAccountCredential(jsonDecode(serviceAccountString))
        .getAccessToken();
  }

  static Future<ServiceAccount> fromFile(String filePath) async =>
      ServiceAccount.fromJson(
          await getPlatformAccess().getStringFromFile(filePath));
}

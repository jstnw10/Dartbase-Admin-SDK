import 'dart:convert';

class AuthException implements Exception {
  final String body;

  String get message => jsonDecode(body)['error']['message'];

  String get errorCode => message.split(' ')[0];

  AuthException(this.body);

  @override
  String toString() => 'AuthException: $errorCode';
}

class TokenValidationException implements Exception {
  String body;

  TokenValidationException(this.body);

  @override
  String toString() => 'Token Validation Exception: $body';
}

class InitializationException implements Exception {
  String body;
  InitializationException(this.body);

  @override
  String toString() => 'Initialization Exception: $body';
}

class GeneralSecurityException implements Exception {
  String body;
  GeneralSecurityException(this.body);

  @override
  String toString() => 'General Security Exception: $body';
}

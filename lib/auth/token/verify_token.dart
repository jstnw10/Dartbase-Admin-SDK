import 'dart:convert';

import 'package:firedart/auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'jwt.dart';

/// Verify a Firebase token
Future<void> verifyToken(String token,
        {FirebaseAuth authInstance, bool enforceEmailVerification = false, bool checkRevoked = false}) async =>
    Jwt(token).validate(await _googleCertificates,
        authInstance: authInstance, enforceEmailVerification: enforceEmailVerification, checkRevoked: checkRevoked);

const _certificateUrl = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';

Map<String, String> _googleCertificatesCache;

Future<Map<String, String>> get _googleCertificates async => _googleCertificatesCache ??=
    (jsonDecode((await http.get(_certificateUrl)).body) as Map<String, dynamic>).cast<String, String>();

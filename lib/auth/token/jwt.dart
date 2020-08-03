import 'dart:convert';

import 'package:dartbase_admin/base/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:corsac_jwt/corsac_jwt.dart';
import '../firebase_auth.dart';

class Jwt {
  final String token;

  Jwt(this.token);

  // Returns subject uid if token is valid. Throws exception otherwise.
  Future<String> validate(Map<String, String> certificates,
      {FirebaseAuth firebaseAuth,
      bool enforceEmailVerification = false,
      bool checkRevoked = false}) async {
    assert(firebaseAuth != null || FirebaseAuth.initialized,
        "Firebase Auth hasn't been initialized. Call FirebaseAuth.initialize() before using this global instance. Alternatively, create a local instance via FirebaseAuth() and use that.");

    var auth = firebaseAuth ?? FirebaseAuth.instance;

    var decodedToken = JWT.parse(token);

    /// CREATE A VALIDATOR TO MATCH OUR FIREBASE PROJECT
    var validator = JWTValidator()
      ..audience = 'chacha-44'
      ..issuer = 'https://securetoken.google.com/chacha-44';

    /// GET GOOGLE PUBLIC KEYS
    var response = await http.get(
        'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com');
    Map<String, dynamic> publicKeys = jsonDecode(response.body);

    /// RUN SIGNATURE VERIFICATION
    var verified = false;
    for (var key in publicKeys.values) {
      if (decodedToken.verify(JWTRsaSha256Signer(publicKey: key))) {
        verified = true;
        break;
      }
    }
    if (!verified) {
      throw TokenValidationException('Public key in token is invalid');
    }

    /// RUN VALIDATION
    var errors = validator.validate(decodedToken);
    if (errors.isNotEmpty) {
      throw TokenValidationException(errors.join('\n'));
    }

    if (decodedToken.subject?.isNotEmpty ?? false) {
      throw TokenValidationException('Subject is empty or null.');
    }
    if (decodedToken.subject != null && decodedToken.subject.length > 128) {
      throw TokenValidationException('Subject is larger than 128 characters.');
    }

    /// CHECK IF IT'S REVOKED
    /// https://github.com/firebase/firebase-admin-java/blob/7b991238067137818907847826513bbd62a8f68a/src/main/java/com/google/firebase/auth/RevocationCheckDecorator.java#L63-L67
    if (checkRevoked) {
      var user = await auth.getUserById(decodedToken.subject);
      if (user.tokensValidAfterTime != null) {
        final authTimeUtc =
            DateTime.fromMillisecondsSinceEpoch(decodedToken.issuedAt * 1000);
        final validSinceUtc = user.tokensValidAfterTime;
        if (authTimeUtc.isBefore(validSinceUtc)) {
          throw TokenValidationException('Token is revoked');
        }
      }
    }

    return decodedToken.subject;
  }
}

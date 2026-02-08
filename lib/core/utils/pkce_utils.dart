import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PkceUtils {
  static const _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  /// Generate a cryptographically random code verifier (43-128 characters).
  static String generateCodeVerifier([int length = 128]) {
    final random = Random.secure();
    return List.generate(
      length,
      (_) => _charset[random.nextInt(_charset.length)],
    ).join();
  }

  /// Compute code_challenge = BASE64URL(SHA256(code_verifier)).
  static String generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}

import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:webcrypto/webcrypto.dart';

class DpopGenerator {
  final Uuid _uuid = const Uuid();
  KeyPair<EcdsaPrivateKey, EcdsaPublicKey>? _keyPair;

  Future<void> initialize() async {
    if (_keyPair != null) return;
    _keyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
  }

  Future<String> generateToken({
    required Uri uri,
    required String method,
    String? nonce,
  }) async {
    await initialize();

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final jti = _uuid.v4();
    final jwk = await _keyPair!.publicKey.exportJsonWebKey();
    final header = {
      'typ': 'dpop+jwt',
      'alg': 'ES256',
      'jwk': {
        'kty': jwk['kty'],
        'crv': jwk['crv'],
        'x': jwk['x'],
        'y': jwk['y'],
        'use': 'sig',
      },
    };
    final claims = {
      'htu': uri.toString(),
      'htm': method,
      'jti': jti,
      'iat': now,
      if (nonce != null) 'nonce': nonce,
    };

    final encodedHeader = _base64Url(jsonEncode(header));
    final encodedPayload = _base64Url(jsonEncode(claims));
    final signingInput = '$encodedHeader.$encodedPayload';

    final signatureBytes = await _keyPair!.privateKey.signBytes(
      utf8.encode(signingInput),
      Hash.sha256,
    );
    final encodedSignature = _base64UrlBytes(signatureBytes);

    return '$signingInput.$encodedSignature';
  }

  String _base64UrlBytes(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  String _base64Url(String input) => _base64UrlBytes(utf8.encode(input));
}

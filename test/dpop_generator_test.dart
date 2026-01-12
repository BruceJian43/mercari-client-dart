import 'dart:convert';

import 'package:mercari_client_dart/auth/dpop_generator.dart';
import 'package:test/test.dart';

void main() {
  group('DpopGenerator', () {
    late DpopGenerator generator;

    setUp(() async {
      generator = DpopGenerator();
      await generator.initialize();
    });

    test('generates a token with 3 parts (Header.Payload.Signature)', () async {
      final uri = Uri.parse('https://api.mercari.jp/v2/entities:search');
      final token = await generator.generateToken(uri: uri, method: 'POST');

      final parts = token.split('.');
      expect(parts.length, 3, reason: 'Token must be a standard JWT');
    });

    test('includes correct claims in payload', () async {
      final uri = Uri.parse('https://api.mercari.jp/test');
      const method = 'GET';
      const nonce = 'test-nonce-123';

      final token = await generator.generateToken(
        uri: uri,
        method: method,
        nonce: nonce,
      );

      // Decode the payload (2nd part of JWT)
      final parts = token.split('.');
      final payloadString = utf8.decode(
        base64Url.decode(base64.normalize(parts[1])),
      );
      final payload = jsonDecode(payloadString);

      expect(payload['htu'], 'https://api.mercari.jp/test');
      expect(payload['htm'], 'GET');
      expect(payload['nonce'], 'test-nonce-123');
      expect(payload.containsKey('jti'), isTrue); // Unique ID exists
      expect(payload.containsKey('iat'), isTrue); // Timestamp exists
    });
  });
}

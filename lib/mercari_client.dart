import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'auth/dpop_generator.dart';

class MercariClient {
  static const String _baseUrl = 'https://api.mercari.jp';
  static const String _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  final http.Client _httpClient;
  final DpopGenerator _dpop;
  final Uuid _uuid;

  MercariClient({http.Client? client})
    : _httpClient = client ?? http.Client(),
      _dpop = DpopGenerator(),
      _uuid = const Uuid();

  Future<void> initialize() => _dpop.initialize();

  Future<List<Map<String, dynamic>>> searchItems(String keyword) async {
    final searchSessionId = _uuid.v4();
    final payload = {
      'pageSize': 30,
      'pageToken': '',
      'searchSessionId': searchSessionId,
      'indexRouting': 'INDEX_ROUTING_UNSPECIFIED',
      'searchCondition': {
        'keyword': keyword,
        'sort': 'SORT_SCORE',
        'order': 'ORDER_DESC',
        'status': ['STATUS_ON_SALE'],
        'excludeKeyword': '',
      },
      'defaultDatasets': [],
    };

    final uri = Uri.parse('$_baseUrl/v2/entities:search');
    return await _executeWithRetry(uri, payload);
  }

  Future<List<Map<String, dynamic>>> _executeWithRetry(
    Uri uri,
    Map<String, dynamic> payload,
  ) async {
    var response = await _sendRequest(uri, payload, nonce: null);

    // DPoP-Nonce Retry Logic
    if ((response.statusCode == HttpStatus.badRequest ||
            response.statusCode == HttpStatus.unauthorized) &&
        response.headers.containsKey('dpop-nonce')) {
      final newNonce = response.headers['dpop-nonce'];
      if (newNonce != null && newNonce.isNotEmpty) {
        print('Refreshing DPoP Nonce: $newNonce');
        response = await _sendRequest(uri, payload, nonce: newNonce);
      }
    }

    if (response.statusCode == HttpStatus.ok) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
        'Mercari Search Failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<http.Response> _sendRequest(
    Uri uri,
    Map<String, dynamic> payload, {
    String? nonce,
  }) async {
    final dpopToken = await _dpop.generateToken(
      uri: uri,
      method: 'POST',
      nonce: nonce,
    );

    return _httpClient.post(
      uri,
      headers: {
        'DPoP': dpopToken,
        'X-Platform': 'web',
        'User-Agent': _userAgent,
        'Content-Type': 'application/json',
        'Origin': 'https://jp.mercari.com',
        'Referer': 'https://jp.mercari.com/',
        if (nonce != null) 'DPoP-Nonce': nonce,
      },
      body: jsonEncode(payload),
    );
  }

  void close() {
    _httpClient.close();
  }
}

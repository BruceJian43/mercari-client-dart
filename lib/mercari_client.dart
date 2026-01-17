import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:dpop/dpop.dart';

class MercariClient {
  static const String _baseUrl = 'https://api.mercari.jp';
  static const String _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  final DPopHttpClient _httpClient;
  final Uuid _uuid;

  MercariClient({DPopHttpClient? client})
    : _httpClient = client ?? DPopHttpClient(),
      _uuid = const Uuid();

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
    final response = await _httpClient.post(
      uri,
      headers: {
        'X-Platform': 'web',
        'User-Agent': _userAgent,
        'Content-Type': 'application/json',
        'Origin': 'https://jp.mercari.com',
        'Referer': 'https://jp.mercari.com/',
      },
      body: jsonEncode(payload),
    );

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

  void close() {
    _httpClient.close();
  }
}

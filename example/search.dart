import 'package:mercari_client_dart/mercari_client.dart';

void main(List<String> args) async {
  final keyword = args.isNotEmpty ? args.join(' ') : 'Nintendo Switch';

  final client = MercariClient();

  try {
    print('Searching for "$keyword"...');

    final items = await client.searchItems(keyword);

    if (items.isEmpty) {
      print('No items found.');
    } else {
      for (final item in items.take(5)) {
        print('- ${item['name']} (¥${item['price']})');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
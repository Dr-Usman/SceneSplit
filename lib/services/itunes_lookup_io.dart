import 'dart:convert';
import 'dart:io';

/// Fetches App Store version metadata via the iTunes Lookup API.
Future<Map<String, String>?> fetchIosStoreInfo(String lookupUrl) async {
  final client = HttpClient();
  try {
    final request = await client
        .getUrl(Uri.parse(lookupUrl))
        .timeout(const Duration(seconds: 8));
    final response = await request.close().timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final first = results.first as Map<String, dynamic>;
    final version = first['version'] as String?;
    if (version == null || version.isEmpty) return null;

    final trackViewUrl = (first['trackViewUrl'] as String?) ?? '';
    return {'version': version, 'trackViewUrl': trackViewUrl};
  } finally {
    client.close(force: true);
  }
}

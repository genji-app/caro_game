import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class ConfigLoader {
  static Future<Map<String, dynamic>> getConfig(String url) async {
    try {
      final String randomParam = '?r=${Random().nextDouble()}';
      final http.Response response = await http
          .get(Uri.parse(url + randomParam))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Config HTTP ${response.statusCode}');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty config response');
      }
      final String rawText = response.body;
      final String trimmedText = rawText.trim();
      if (trimmedText.startsWith('{') && trimmedText.endsWith('}')) {
        return jsonDecode(trimmedText) as Map<String, dynamic>;
      }
      final String cleanText = rawText.replaceAll(RegExp(r'\s+'), '');
      final List<int> bytes = base64Decode(cleanText);
      final String decodedText = utf8.decode(bytes);
      return jsonDecode(decodedText) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load config: $e');
    }
  }

  static String base64EncodeFromJson(Object? json) {
    final String jsonString = jsonEncode(json);
    final List<int> utf8Bytes = utf8.encode(jsonString);
    return base64Encode(utf8Bytes);
  }
}

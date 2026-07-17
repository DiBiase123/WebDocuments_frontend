import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webdocuments/config.dart';

class AiService {
  Future<Map<String, String>> analyzeText(String text) async {
    final uri = Uri.parse('${Config.buildUrl()}/api/ai/analyze');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (response.statusCode == 200) {
      return Map<String, String>.from(jsonDecode(response.body));
    }
    throw Exception('Errore analisi AI');
  }
}

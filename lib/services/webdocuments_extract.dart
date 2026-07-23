import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webdocuments/config.dart';

class ExtractService {
  Future<String> extractText(List<int> bytes, String fileName) async {
    final uri = Uri.parse('${Config.buildUrl()}/api/extract');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );
    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);
    if (response.statusCode == 200) {
      return data['text'] ?? '';
    }
    throw Exception(data['error'] ?? 'Errore');
  }
}

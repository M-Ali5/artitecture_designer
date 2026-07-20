import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class AIService {
  AIService({required this.apiToken, String? modelId, http.Client? client})
    : _client = client ?? http.Client(),
      _modelId =
          (modelId == null || modelId.trim().isEmpty) ? 'gpt-image-1' : modelId;

  final String apiToken;
  final http.Client _client;
  final String _modelId;
  String? lastError;

  Future<Uint8List?> generateDesignImage(String prompt) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) {
      lastError = 'Prompt is empty.';
      return null;
    }
    if (apiToken.trim().isEmpty) {
      lastError = 'OpenAI API key missing.';
      return null;
    }

    try {
      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
        body: jsonEncode({
          'model': _modelId,
          'prompt': trimmedPrompt,
          'size': '1024x1024',
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        lastError = 'OpenAI error (${response.statusCode})';
        return null;
      }
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final data = map['data'] as List<dynamic>? ?? [];
      if (data.isEmpty || data.first['b64_json'] == null) {
        lastError = 'No image payload returned from OpenAI.';
        return null;
      }
      return base64Decode(data.first['b64_json'] as String);
    } catch (_) {
      lastError = 'Network or parsing error while generating image.';
      return null;
    }
  }
}

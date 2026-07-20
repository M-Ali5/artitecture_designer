import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class OpenAIService {
  OpenAIService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _requestTimeout = Duration(seconds: 180);
  static const int _maxRedesignAttempts = 2;
  static const Set<String> _allowedImageSizes = {
    'auto',
    '1024x1024',
    '1024x1536',
    '1536x1024',
  };

  Future<Uint8List> generateImage({
    required String apiKey,
    required String prompt,
    String model = 'gpt-image-1',
    String size = '1024x1024',
  }) async {
    final normalizedSize = _sanitizeImageSize(size);
    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'prompt': prompt,
        'size': normalizedSize,
      }),
    ).timeout(
      _requestTimeout,
      onTimeout: () => throw Exception(
        'Image generation timed out. Network ya OpenAI response slow hai, please retry.',
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractOpenAIError(
        statusCode: response.statusCode,
        responseBody: response.body,
      ));
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = map['data'] as List<dynamic>? ?? [];
    if (data.isEmpty || data.first['b64_json'] == null) {
      throw Exception('No generated image received from OpenAI.');
    }

    return base64Decode(data.first['b64_json'] as String);
  }

  Future<Uint8List> redesignImageFromReference({
    required String apiKey,
    required String prompt,
    required Uint8List referenceImageBytes,
    String model = 'gpt-image-1',
    String size = 'auto',
  }) async {
    final normalizedSize = _sanitizeImageSize(size);
    Exception? lastError;
    for (var attempt = 1; attempt <= _maxRedesignAttempts; attempt++) {
      try {
        final mediaType = _detectImageMediaType(referenceImageBytes);
        final extension = _fileExtension(mediaType);
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.openai.com/v1/images/edits'),
        )
          ..headers['Authorization'] = 'Bearer $apiKey'
          ..fields['model'] = model
          ..fields['prompt'] = prompt
          ..fields['size'] = normalizedSize
          ..files.add(
            http.MultipartFile.fromBytes(
              'image',
              referenceImageBytes,
              filename: 'reference.$extension',
              contentType: mediaType,
            ),
          );

        final streamed = await request.send().timeout(
          _requestTimeout,
          onTimeout: () => throw Exception(
            'Image redesign timed out. Network ya OpenAI response slow hai.',
          ),
        );
        final response = await http.Response.fromStream(streamed);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception(
            _extractOpenAIError(
              statusCode: response.statusCode,
              responseBody: response.body,
            ),
          );
        }

        final map = jsonDecode(response.body) as Map<String, dynamic>;
        final data = map['data'] as List<dynamic>? ?? [];
        if (data.isEmpty) {
          throw Exception('No redesigned image received from OpenAI.');
        }
        final first = data.first as Map<String, dynamic>;
        final b64 = first['b64_json']?.toString() ?? '';
        if (b64.isNotEmpty) {
          return base64Decode(b64);
        }

        final imageUrl = first['url']?.toString() ?? '';
        if (imageUrl.isEmpty) {
          throw Exception('OpenAI response did not include image data.');
        }

        final download = await _client.get(Uri.parse(imageUrl)).timeout(
          _requestTimeout,
          onTimeout: () => throw Exception('Downloading redesigned image timed out.'),
        );
        if (download.statusCode < 200 || download.statusCode >= 300) {
          throw Exception('Unable to download redesigned image.');
        }
        return download.bodyBytes;
      } on Exception catch (e) {
        lastError = e;
        if (attempt >= _maxRedesignAttempts || !_isRetryableRedesignError(e)) {
          rethrow;
        }
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw lastError ??
        Exception('Image redesign failed after retries. Please retry.');
  }

  MediaType _detectImageMediaType(Uint8List bytes) {
    if (bytes.length >= 12) {
      // PNG: 89 50 4E 47
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return MediaType('image', 'png');
      }

      // JPEG: FF D8 FF
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return MediaType('image', 'jpeg');
      }

      // WEBP: RIFF....WEBP
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return MediaType('image', 'webp');
      }
    }

    // Safe fallback for compressed picker output.
    return MediaType('image', 'jpeg');
  }

  String _fileExtension(MediaType mediaType) {
    if (mediaType.subtype == 'png') return 'png';
    if (mediaType.subtype == 'webp') return 'webp';
    return 'jpg';
  }

  bool _isRetryableRedesignError(Exception e) {
    final text = e.toString().toLowerCase();
    return text.contains('timed out') ||
        text.contains('temporarily unavailable') ||
        text.contains('unable to download redesigned image') ||
        text.contains('429');
  }

  Future<String> chat({
    required String apiKey,
    required List<Map<String, String>> messages,
    String model = 'gpt-4o-mini',
  }) async {
    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
      }),
    ).timeout(
      _requestTimeout,
      onTimeout: () => throw Exception(
        'Chat request timed out. Network slow hai, please retry.',
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractOpenAIError(
        statusCode: response.statusCode,
        responseBody: response.body,
      ));
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = map['choices'] as List<dynamic>? ?? [];
    if (choices.isEmpty) {
      throw Exception('No assistant response returned.');
    }

    return (choices.first['message']['content'] as String?)?.trim() ?? '';
  }

  String _extractOpenAIError({
    required int statusCode,
    required String responseBody,
  }) {
    String? message;
    try {
      final parsed = jsonDecode(responseBody) as Map<String, dynamic>;
      final errorMap = parsed['error'];
      if (errorMap is Map<String, dynamic>) {
        message = errorMap['message']?.toString();
      }
    } catch (_) {
      message = null;
    }

    if (statusCode == 401 || statusCode == 403) {
      return 'OpenAI key invalid ya expired hai. Settings se key update karein.';
    }
    if (statusCode == 429) {
      return 'OpenAI rate limit exceed ho gayi. Kuch der baad dubara try karein.';
    }
    if (statusCode >= 500) {
      return 'OpenAI server temporarily unavailable hai. Please retry.';
    }
    final lowerMessage = message?.toLowerCase() ?? '';
    if (lowerMessage.contains('invalid size') ||
        lowerMessage.contains('size') && lowerMessage.contains('1024')) {
      return 'Requested image size unsupported hai. App valid size par fallback kar chuki hai; please retry.';
    }

    if (message != null && message.trim().isNotEmpty) {
      return 'OpenAI request failed ($statusCode): ${message.trim()}';
    }
    return 'OpenAI request failed ($statusCode).';
  }

  String _sanitizeImageSize(String size) {
    final normalized = size.trim().toLowerCase();
    if (_allowedImageSizes.contains(normalized)) {
      return normalized;
    }
    return 'auto';
  }
}

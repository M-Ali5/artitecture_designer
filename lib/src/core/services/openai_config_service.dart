import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OpenAIConfigService {
  OpenAIConfigService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _apiKeyKey = 'openai_api_key';
  final FlutterSecureStorage _storage;

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey.trim());
  }

  Future<String> loadApiKey() async {
    return (await _storage.read(key: _apiKeyKey) ?? '').trim();
  }
}

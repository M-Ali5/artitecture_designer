import 'package:shared_preferences/shared_preferences.dart';

class AIConfigService {
  static const String _tokenKey = 'openai_api_key';
  static const String _modelKey = 'openai_model_id';

  Future<void> saveConfig({
    required String apiToken,
    required String modelId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, apiToken.trim());
    await prefs.setString(_modelKey, modelId.trim());
  }

  Future<(String token, String modelId)> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey) ?? '';
    final modelId = prefs.getString(_modelKey) ?? 'gpt-image-1';
    return (token, modelId);
  }
}

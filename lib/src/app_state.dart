import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/services/openai_config_service.dart';

class AppState extends ChangeNotifier {
  AppState(this._configService);

  final OpenAIConfigService _configService;
  String _openAIApiKey = '';

  String get openAIApiKey => _openAIApiKey;
  bool get hasApiKey => _openAIApiKey.isNotEmpty;

  Future<void> load() async {
    await ensureApiKeyLoaded(forceRefresh: true);
  }

  Future<bool> ensureApiKeyLoaded({bool forceRefresh = false}) async {
    if (!forceRefresh && _openAIApiKey.isNotEmpty) return true;
    final previous = _openAIApiKey;

    final saved = await _configService.loadApiKey();
    if (saved.isNotEmpty) {
      _openAIApiKey = saved;
    } else {
      final envKey = (dotenv.env['OPENAI_API_KEY'] ?? '').trim();
      if (envKey.isNotEmpty) {
        _openAIApiKey = envKey;
        await _configService.saveApiKey(envKey);
      } else {
        _openAIApiKey = '';
      }
    }

    if (previous != _openAIApiKey) {
      notifyListeners();
    }
    return _openAIApiKey.isNotEmpty;
  }

  Future<void> setApiKey(String value) async {
    _openAIApiKey = value.trim();
    await _configService.saveApiKey(_openAIApiKey);
    notifyListeners();
  }
}

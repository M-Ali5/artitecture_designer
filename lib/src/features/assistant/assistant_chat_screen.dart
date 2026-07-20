import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../core/services/openai_service.dart';
import '../../models/app_models.dart';
import '../projects/project_repository.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final _controller = TextEditingController();
  final _openAI = OpenAIService();
  final _repo = ProjectRepository();
  final List<AssistantMessage> _messages = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final apiKey = context.read<AppState>().openAIApiKey;
    if (apiKey.isEmpty) return;

    final userMessage = AssistantMessage(
      role: 'user',
      content: text,
      createdAtIso: DateTime.now().toIso8601String(),
    );
    _controller.clear();
    setState(() {
      _messages.add(userMessage);
      _loading = true;
    });

    await _repo.saveAssistantMessage(userMessage);
    try {
      final response = await _openAI.chat(
        apiKey: apiKey,
        messages: [
          {
            'role': 'system',
            'content':
                'You are an architecture assistant. Give practical interior, exterior, layout, construction, and rough-cost guidance.',
          },
          ..._messages.map((m) => {'role': m.role, 'content': m.content}),
        ],
      );
      final assistantMessage = AssistantMessage(
        role: 'assistant',
        content: response,
        createdAtIso: DateTime.now().toIso8601String(),
      );
      if (!mounted) return;
      setState(() => _messages.add(assistantMessage));
      await _repo.saveAssistantMessage(assistantMessage);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assistant request failed. Check API key.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final m = _messages[index];
              final mine = m.role == 'user';
              return Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 620),
                  decoration: BoxDecoration(
                    color: mine ? const Color(0xFF2563EB) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    m.content,
                    style: TextStyle(color: mine ? Colors.white : Colors.black87),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask about planning, layout, construction, costs...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loading ? null : _send,
                  icon: _loading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

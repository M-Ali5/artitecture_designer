import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../core/services/openai_service.dart';

class FloorPlanScreen extends StatefulWidget {
  const FloorPlanScreen({super.key});

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  final _plotController = TextEditingController();
  final _floorsController = TextEditingController(text: '1');
  final _bedsController = TextEditingController(text: '3');
  final _bathsController = TextEditingController(text: '2');
  final _garageController = TextEditingController(text: '1');
  final _gardenController = TextEditingController(text: 'Yes');
  final _budgetController = TextEditingController();
  final _service = OpenAIService();

  String _result = '';
  bool _loading = false;

  @override
  void dispose() {
    _plotController.dispose();
    _floorsController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _garageController.dispose();
    _gardenController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    final key = context.read<AppState>().openAIApiKey;
    if (key.isEmpty) return;
    setState(() => _loading = true);
    try {
      final text = await _service.chat(
        apiKey: key,
        messages: [
          {
            'role': 'system',
            'content':
                'Create practical floor-plan recommendations with room arrangement, circulation, zoning, and rough area allocation.',
          },
          {
            'role': 'user',
            'content':
                'Plot: ${_plotController.text}. Floors: ${_floorsController.text}. Bedrooms: ${_bedsController.text}. '
                'Bathrooms: ${_bathsController.text}. Garage: ${_garageController.text}. Garden: ${_gardenController.text}. '
                'Budget: ${_budgetController.text}. Provide detailed recommendations.',
          },
        ],
      );
      if (!mounted) return;
      setState(() => _result = text);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate floor plan response.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  TextField(
                    controller: _plotController,
                    decoration: const InputDecoration(
                      labelText: 'Plot dimensions (e.g., 40x60 ft)',
                    ),
                  ),
                  TextField(
                    controller: _floorsController,
                    decoration: const InputDecoration(labelText: 'Floors'),
                  ),
                  TextField(
                    controller: _bedsController,
                    decoration: const InputDecoration(labelText: 'Bedrooms'),
                  ),
                  TextField(
                    controller: _bathsController,
                    decoration: const InputDecoration(labelText: 'Bathrooms'),
                  ),
                  TextField(
                    controller: _garageController,
                    decoration: const InputDecoration(labelText: 'Garage slots'),
                  ),
                  TextField(
                    controller: _gardenController,
                    decoration: const InputDecoration(labelText: 'Garden (Yes/No)'),
                  ),
                  TextField(
                    controller: _budgetController,
                    decoration: const InputDecoration(labelText: 'Budget'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _generatePlan,
                      icon: const Icon(Icons.map),
                      label: Text(_loading ? 'Generating...' : 'Generate Plan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_result.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SelectableText(_result),
              ),
            ),
        ],
      ),
    );
  }
}

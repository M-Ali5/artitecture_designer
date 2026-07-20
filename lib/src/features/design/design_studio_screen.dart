import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../core/services/openai_service.dart';
import '../projects/project_repository.dart';

class DesignStudioScreen extends StatefulWidget {
  const DesignStudioScreen({
    super.key,
    required this.type,
    required this.styles,
  });

  final String type;
  final List<String> styles;

  @override
  State<DesignStudioScreen> createState() => _DesignStudioScreenState();
}

class _DesignStudioScreenState extends State<DesignStudioScreen> {
  final _promptController = TextEditingController();
  final _picker = ImagePicker();
  final _service = OpenAIService();
  final _repo = ProjectRepository();

  String? _selectedStyle;
  Uint8List? _referenceBytes;
  Uint8List? _generatedBytes;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.styles.first;
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickReferenceImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final compressed = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 70,
      minWidth: 1280,
      minHeight: 1280,
    );
    if (!mounted) return;
    setState(() {
      _referenceBytes = compressed ?? File(file.path).readAsBytesSync();
    });
  }

  Future<void> _generate() async {
    final apiKey = context.read<AppState>().openAIApiKey;
    if (apiKey.isEmpty) {
      setState(() => _error = 'Set your OpenAI API key in Settings first.');
      return;
    }

    final style = _selectedStyle ?? widget.styles.first;
    final userPrompt = _promptController.text.trim();
    final prompt = userPrompt.isNotEmpty
        ? userPrompt
        : 'Create a premium ${widget.type} architecture concept in $style style. '
              'Keep realistic materials, proper lighting, and high-end design details.';

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final image = await _service.generateImage(apiKey: apiKey, prompt: prompt);
      String referenceUrl = '';
      if (_referenceBytes != null) {
        referenceUrl = await _repo.uploadReferenceImage(
          _referenceBytes!,
          '${DateTime.now().millisecondsSinceEpoch}_ref.jpg',
        );
      }
      final generatedUrl = await _repo.uploadDesignImage(
        image,
        '${DateTime.now().millisecondsSinceEpoch}_generated.png',
      );
      await _repo.saveProject(
        type: widget.type,
        style: style,
        prompt: prompt,
        generatedImageUrl: generatedUrl,
        referenceImageUrl: referenceUrl,
      );
      if (!mounted) return;
      setState(() {
        _generatedBytes = image;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Design generated and saved successfully.')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.type[0].toUpperCase()}${widget.type.substring(1)} AI Designer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStyle,
                    items: widget.styles
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Design style'),
                    onChanged: (v) => setState(() => _selectedStyle = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _promptController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Custom prompt',
                      hintText:
                          'Describe dimensions, material preferences, mood, and details.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickReferenceImage,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Reference'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _generate,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(_loading ? 'Generating...' : 'Generate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_referenceBytes != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reference image'),
                    const SizedBox(height: 8),
                    Image.memory(_referenceBytes!, height: 180, fit: BoxFit.cover),
                  ],
                ),
              ),
            ),
          if (_generatedBytes != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Generated image'),
                    const SizedBox(height: 8),
                    Image.memory(_generatedBytes!, height: 280, fit: BoxFit.cover),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}

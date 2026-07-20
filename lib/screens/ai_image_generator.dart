// lib/screens/ai_image_generator.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ai_config_service.dart';
import '../services/ai_service.dart';

class AIImageGenerator extends StatefulWidget {
  const AIImageGenerator({super.key});

  @override
  State<AIImageGenerator> createState() => _AIImageGeneratorState();
}

class _AIImageGeneratorState extends State<AIImageGenerator>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  Uint8List? _generatedImage;
  String? _errorMessage;

  final List<String> _roomTypes = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Home Office',
  ];
  final List<String> _designStyles = [
    'Modern',
    'Scandinavian',
    'Industrial',
    'Bohemian',
  ];

  String _selectedRoomType = 'Living Room';
  String _selectedStyle = 'Modern';
  String _lastPromptUsed = '';
  double _rotationY = 0;
  final double _rotationX = -0.08;
  late final AnimationController _rotationController;

  final AIConfigService _aiConfigService = AIConfigService();
  String _apiToken = '';
  String _modelId = 'gpt-image-1';

  @override
  void initState() {
    super.initState();
    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 14))
          ..addListener(() {
            if (!mounted || _generatedImage == null) return;
            setState(() {
              _rotationY = _rotationController.value * 2 * math.pi;
            });
          });
    _rotationController.repeat();
    _loadAIConfig();
  }

  Future<void> _loadAIConfig() async {
    final envToken = dotenv.env['OPENAI_API_KEY'] ?? '';
    final (savedToken, savedModelId) = await _aiConfigService.loadConfig();
    if (!mounted) return;
    setState(() {
      _apiToken = (savedToken.isNotEmpty ? savedToken : envToken).trim();
      if (savedModelId.isNotEmpty) {
        _modelId = savedModelId;
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Image Generator'),
        backgroundColor: Color(0xFF2C3E50),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInputCard(),
              if (_isGenerating) _buildLoadingCard(),
              if (_errorMessage != null) _buildErrorCard(),
              if (_generatedImage != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF3498DB), size: 28),
                SizedBox(width: 10),
                Text(
                  'Generate Room Design',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text('Room Type:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _roomTypes.map((room) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(room),
                      selected: _selectedRoomType == room,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRoomType = room;
                        });
                      },
                      selectedColor: Color(0xFF3498DB),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Design Style:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _designStyles.map((style) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(style),
                      selected: _selectedStyle == style,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStyle = style;
                        });
                      },
                      selectedColor: Color(0xFFE67E22),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Or describe your dream room in detail...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF27AE60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Generate Design', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF3498DB)),
            SizedBox(height: 20),
            Text(
              'Generating your room design...',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'This may take 10-20 seconds',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            SizedBox(height: 10),
            Text(
              'Generation Failed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(_errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => setState(() => _errorMessage = null),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              color: Colors.black12,
              padding: const EdgeInsets.all(12),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(_rotationX)
                  ..rotateY(_rotationY),
                child: Image.memory(
                  _generatedImage!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated Design',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$_selectedStyle $_selectedRoomType',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 15),
                Text(
                  '3D preview auto-rotates',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareImage,
                        icon: Icon(Icons.share),
                        label: Text('Share'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _editAndRegenerateImage,
                        icon: Icon(Icons.auto_fix_high),
                        label: Text('Edit AI'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3498DB),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveImage,
                        icon: Icon(Icons.download),
                        label: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 75, 39, 174),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateImage() async {
    await _loadAIConfig();

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    String prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      prompt =
          "A beautiful $_selectedStyle $_selectedRoomType with professional interior design, full room view, wide-angle, cinematic lighting";
    }
    _lastPromptUsed = prompt;

    try {
      final aiService = AIService(apiToken: _apiToken, modelId: _modelId);
      final imageBytes = await aiService.generateDesignImage(prompt);
      if (imageBytes != null) {
        setState(() {
          _generatedImage = imageBytes;
        });
      } else {
        setState(() {
          _errorMessage =
              aiService.lastError ??
              'Unable to generate image right now. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }

    setState(() {
      _isGenerating = false;
    });
  }

  void _shareImage() async {
    if (_generatedImage != null) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/room_design.png');
      await file.writeAsBytes(_generatedImage!);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Check out my AI-generated room design!');
    }
  }

  Future<void> _saveImage() async {
    if (_generatedImage == null) return;
    final hasPermission = await _ensureStoragePermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to save image.'),
        ),
      );
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'artitecture_design_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(_generatedImage!);

    final isSuccess = await GallerySaver.saveImage(
      file.path,
      albumName: 'artitecture_design',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuccess == true
              ? 'Image saved to gallery.'
              : 'Failed to save image. Please allow media permission.',
        ),
      ),
    );
  }

  Future<bool> _ensureStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final statuses = await [Permission.photos, Permission.storage].request();

    final photos = statuses[Permission.photos];
    final storage = statuses[Permission.storage];

    final granted =
        (photos?.isGranted == true || photos?.isLimited == true) ||
        (storage?.isGranted == true);

    if (granted) return true;

    final permanentlyDenied =
        (photos?.isPermanentlyDenied == true) ||
        (storage?.isPermanentlyDenied == true);

    if (permanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<void> _editAndRegenerateImage() async {
    if (_generatedImage == null) return;
    final editController = TextEditingController();
    final instruction = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Generated Image'),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g. make it brighter, add wooden accents',
            labelText: 'Edit instruction',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, editController.text.trim()),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (instruction == null || instruction.isEmpty) return;

    await _loadAIConfig();
    if (!mounted) return;
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    final editedPrompt =
        '${_lastPromptUsed.isEmpty ? _promptController.text.trim() : _lastPromptUsed}. '
        'Edit request: $instruction';

    try {
      final aiService = AIService(apiToken: _apiToken, modelId: _modelId);
      final editedImage = await aiService.generateDesignImage(editedPrompt);
      if (!mounted) return;
      if (editedImage != null) {
        setState(() {
          _generatedImage = editedImage;
          _lastPromptUsed = editedPrompt;
        });
      } else {
        setState(() {
          _errorMessage =
              aiService.lastError ?? 'Could not apply edit. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Edit failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}

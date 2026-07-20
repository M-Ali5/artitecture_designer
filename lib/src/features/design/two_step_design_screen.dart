import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../app_settings_controller.dart';
import '../../core/services/openai_service.dart';
import '../projects/project_repository.dart';

class TwoStepDesignScreen extends StatefulWidget {
  const TwoStepDesignScreen({
    super.key,
    required this.initialType,
    this.initialStyle,
    this.initialColor,
    this.initialPrompt,
  });

  final String initialType;
  final String? initialStyle;
  final String? initialColor;
  final String? initialPrompt;

  @override
  State<TwoStepDesignScreen> createState() => _TwoStepDesignScreenState();
}

class _TwoStepDesignScreenState extends State<TwoStepDesignScreen>
    with WidgetsBindingObserver {
  final _picker = ImagePicker();
  final _promptController = TextEditingController();
  final _service = OpenAIService();
  final _repo = ProjectRepository();

  int _step = 0;
  bool _isGenerating = false;
  bool _isSaving = false;
  bool _isRetryingPending = false;
  int _pendingUploads = 0;
  String _type = 'interior';
  String _selectedSpaceType = '';
  String _selectedStyle = '';
  String _selectedColor = 'Neutral';
  String _error = '';
  Uint8List? _refImage;
  Uint8List? _generatedImage;

  static const _colorPalettes = [
    'Neutral',
    'Warm',
    'Cool',
    'Monochrome',
    'Earthy',
    'Vibrant',
  ];

  static const _examplePhotos = [
    'https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?auto=format&fit=crop&w=500&q=80',
    'https://images.unsplash.com/photo-1617104551722-3b2d51366400?auto=format&fit=crop&w=500&q=80',
    'https://images.unsplash.com/photo-1505693314120-0d443867891c?auto=format&fit=crop&w=500&q=80',
    'https://images.unsplash.com/photo-1616594039964-3e2f26f5ecad?auto=format&fit=crop&w=500&q=80',
  ];

  static const _interiorSpaces = [
    _SpaceOption('Kitchen', Icons.soup_kitchen_outlined),
    _SpaceOption('Living Room', Icons.weekend_outlined),
    _SpaceOption('Bedroom', Icons.bed_outlined),
    _SpaceOption('Bathroom', Icons.bathtub_outlined),
    _SpaceOption('Dining Room', Icons.restaurant_outlined),
    _SpaceOption('Study Room', Icons.edit_note_outlined),
    _SpaceOption('Home Office', Icons.business_center_outlined),
    _SpaceOption('Gaming Room', Icons.sports_esports_outlined),
    _SpaceOption('Restaurant', Icons.local_cafe_outlined),
    _SpaceOption('Office', Icons.meeting_room_outlined),
  ];

  static const _exteriorSpaces = [
    _SpaceOption('House Front', Icons.home_work_outlined),
    _SpaceOption('Luxury Villa', Icons.villa_outlined),
    _SpaceOption('Bungalow', Icons.holiday_village_outlined),
    _SpaceOption('Apartment Exterior', Icons.apartment_outlined),
    _SpaceOption('Farmhouse', Icons.yard_outlined),
    _SpaceOption('Plot Concept', Icons.grid_view_outlined),
    _SpaceOption('Garden Facade', Icons.park_outlined),
    _SpaceOption('Commercial Front', Icons.storefront_outlined),
  ];

  static const _interiorStyles = [
    _StyleOption(
      name: 'Modern',
      imageUrl:
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Minimalistic',
      imageUrl:
          'https://images.unsplash.com/photo-1617806118233-18e1de247200?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Scandinavian',
      imageUrl:
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Luxury',
      imageUrl:
          'https://images.unsplash.com/photo-1616046229478-9901c5536a45?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Bohemian',
      imageUrl:
          'https://images.unsplash.com/photo-1616628182509-6f8e3f6a87f2?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Industrial',
      imageUrl:
          'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Rustic',
      imageUrl:
          'https://images.unsplash.com/photo-1615874959474-d609969a20ed?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Contemporary',
      imageUrl:
          'https://images.unsplash.com/photo-1616593969747-4797dc75033e?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Classic',
      imageUrl:
          'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?auto=format&fit=crop&w=700&q=80',
    ),
  ];

  static const _exteriorStyles = [
    _StyleOption(
      name: 'Modern',
      imageUrl:
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Luxury Villa',
      imageUrl:
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Classic',
      imageUrl:
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Contemporary',
      imageUrl:
          'https://images.unsplash.com/photo-1613977257365-aaae5a9817ff?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Minimalist',
      imageUrl:
          'https://images.unsplash.com/photo-1613553422201-6a67f90f25b0?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Spanish',
      imageUrl:
          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Mediterranean',
      imageUrl:
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=700&q=80',
    ),
    _StyleOption(
      name: 'Eco Green',
      imageUrl:
          'https://images.unsplash.com/photo-1600210492493-0946911123ea?auto=format&fit=crop&w=700&q=80',
    ),
  ];

  List<_SpaceOption> get _currentSpaces =>
      _type == 'interior' ? _interiorSpaces : _exteriorSpaces;
  List<_StyleOption> get _currentStyles =>
      _type == 'interior' ? _interiorStyles : _exteriorStyles;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _type = widget.initialType == 'exterior' ? 'exterior' : 'interior';
    _selectedSpaceType = _currentSpaces.first.name;
    _selectedStyle = _currentStyles.first.name;
    if (widget.initialStyle != null &&
        _currentStyles.any((style) => style.name == widget.initialStyle)) {
      _selectedStyle = widget.initialStyle!;
    }
    if (widget.initialColor != null &&
        _colorPalettes.contains(widget.initialColor)) {
      _selectedColor = widget.initialColor!;
    }
    _promptController.text = widget.initialPrompt?.trim().isNotEmpty == true
        ? widget.initialPrompt!.trim()
        : _buildSuggestedPrompt();
    _bootstrapPendingUploads();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _promptController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _retryPendingUploads(silent: true);
    }
  }

  Future<void> _bootstrapPendingUploads() async {
    final count = await _repo.getPendingUploadCount();
    if (!mounted) return;
    setState(() => _pendingUploads = count);
    if (count > 0) {
      await _retryPendingUploads(silent: true);
    }
  }

  Future<void> _retryPendingUploads({bool silent = false}) async {
    if (_isRetryingPending) return;
    setState(() => _isRetryingPending = true);
    try {
      final result = await _repo.retryPendingUploads();
      if (!mounted) return;
      setState(() {
        _pendingUploads = result.remainingCount;
      });
      if (result.uploadedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.uploadedCount} pending upload(s) synced successfully.',
            ),
          ),
        );
      } else if (!silent && result.lastError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.lastError!)));
      }
    } finally {
      if (mounted) {
        setState(() => _isRetryingPending = false);
      }
    }
  }

  void _changeType(String type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      _selectedSpaceType = _currentSpaces.first.name;
      _selectedStyle = _currentStyles.first.name;
      _promptController.text = _buildSuggestedPrompt();
      _error = '';
    });
  }

  String _buildSuggestedPrompt() {
    return 'Create a photorealistic $_type design for $_selectedSpaceType in $_selectedStyle style with $_selectedColor palette. Keep it premium and practical.';
  }

  Future<void> _showMediaSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Text(
                      'Select Media Source',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Take photo from camera',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickPhoto(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                _SourceTile(
                  icon: Icons.image_outlined,
                  title: 'Choose from gallery',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file == null) return;
    final compressed = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 60,
      minWidth: 900,
      minHeight: 900,
    );
    if (!mounted) return;
    setState(() {
      _refImage = compressed ?? File(file.path).readAsBytesSync();
      _error = '';
    });
  }

  Future<void> _handlePrimaryAction() async {
    if (_step < 3) {
      if (!_canContinueCurrentStep) return;
      setState(() {
        _step += 1;
        _error = '';
      });
      if (_step == 3 && _promptController.text.trim().isEmpty) {
        _promptController.text = _buildSuggestedPrompt();
      }
      return;
    }
    await _generateDesign();
  }

  bool get _canContinueCurrentStep {
    switch (_step) {
      case 0:
        return _refImage != null;
      case 1:
        return _selectedSpaceType.isNotEmpty;
      case 2:
        return _selectedStyle.isNotEmpty;
      case 3:
        return !_isGenerating;
      default:
        return false;
    }
  }

  Future<void> _generateDesign() async {
    final appState = context.read<AppState>();
    final outputSize = context.read<AppSettingsController>().generationSize;
    await appState.ensureApiKeyLoaded(forceRefresh: true);
    final apiKey = appState.openAIApiKey;
    if (apiKey.isEmpty) {
      setState(() {
        _error =
            'Design generate nahi ho saka. Configuration refresh karke dubara try karein.';
      });
      return;
    }
    if (_refImage == null) {
      setState(() => _error = 'Please upload a photo first.');
      return;
    }
    if (_promptController.text.trim().isEmpty) {
      _promptController.text = _buildSuggestedPrompt();
    }

    setState(() {
      _isGenerating = true;
      _error = '';
    });

    final finalPrompt =
        'You are an expert architectural redesign AI. STRICTLY redesign the SAME uploaded $_type image only. '
        'Preserve exact room/building geometry, camera angle, wall/door/window positions, and overall layout. '
        'Do not generate a new or random location. Change only finishes/materials/colors/furniture styling for $_selectedSpaceType in $_selectedStyle style with $_selectedColor palette. '
        'Keep result realistic and professional. User requirements: ${_promptController.text.trim()}';

    try {
      final generated = await _service.redesignImageFromReference(
        apiKey: apiKey,
        prompt: finalPrompt,
        referenceImageBytes: _refImage!,
        size: outputSize,
      );
      if (!mounted) return;
      setState(() {
        _generatedImage = generated;
        _isGenerating = false;
        _isSaving = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Design generated. Saving in background...'),
        ),
      );

      try {
        final result = await _repo.saveGeneratedProjectWithFallback(
          type: _type,
          style: '$_selectedStyle / $_selectedSpaceType / $_selectedColor',
          prompt: finalPrompt,
          generatedImageBytes: generated,
          referenceImageBytes: _refImage!,
        );
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _pendingUploads = result.pendingCount;
        });
        if (result.queued) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image generated. Upload pending ($_pendingUploads). Internet aate hi retry karein.',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project saved successfully.')),
          );
        }
      } on UploadFailure catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image generated, but save failed: ${e.message}'),
          ),
        );
      }
    } catch (e) {
      final raw = e.toString();
      final cleaned = raw.replaceFirst('Exception: ', '').trim();
      setState(
        () => _error = cleaned.isEmpty
            ? 'Generation failed. Network aur OpenAI key check karein.'
            : cleaned,
      );
    } finally {
      if (mounted && _isGenerating) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_step == 0 ? Icons.arrow_back_ios_new : Icons.arrow_back),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step -= 1);
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Step ${_step + 1} / 4',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _canContinueCurrentStep && !_isGenerating
                  ? _handlePrimaryAction
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFFE3E3E3),
                disabledForegroundColor: Colors.black38,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _step == 3
                    ? (_isGenerating
                          ? 'Generating...'
                          : (_generatedImage != null
                                ? 'Regenerate'
                                : 'Generate'))
                    : 'Continue',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _step ? Colors.black : Colors.black26,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_step == 0) _buildAddPhotoStep(),
                  if (_step == 1) _buildSpaceStep(),
                  if (_step == 2) _buildStyleStep(),
                  if (_step == 3) _buildPromptGenerateStep(),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (_isSaving) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Saving generated image...',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        const Text(
          'Add a Photo',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black26),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (_refImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    _refImage!,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else ...[
                const SizedBox(height: 54),
                const Icon(
                  Icons.photo_outlined,
                  size: 54,
                  color: Colors.black38,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Start Redesigning',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Redesign and beautify your space',
                  style: TextStyle(fontSize: 17, color: Colors.black54),
                ),
                const SizedBox(height: 18),
              ],
              FilledButton.icon(
                onPressed: _showMediaSourceSheet,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: Text(_refImage == null ? 'Add a Photo' : 'Change Photo'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Example Photos',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _examplePhotos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _examplePhotos[index],
                  width: 130,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpaceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        const Text(
          'Choose Space',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          _type == 'interior'
              ? 'Select a room to design in your chosen style.'
              : 'Select an exterior category for concept generation.',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'interior', label: Text('Interior')),
            ButtonSegment(value: 'exterior', label: Text('Exterior')),
          ],
          selected: {_type},
          onSelectionChanged: (value) => _changeType(value.first),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _currentSpaces.map((space) {
            final selected = _selectedSpaceType == space.name;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedSpaceType = space.name;
                _promptController.text = _buildSuggestedPrompt();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: MediaQuery.of(context).size.width * 0.43,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected ? Colors.black : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(
                      space.icon,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        space.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStyleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        const Text(
          'Select Style',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select your desired design style to start creating your ideal concept.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: _currentStyles.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.73,
          ),
          itemBuilder: (context, index) {
            final style = _currentStyles[index];
            final selected = _selectedStyle == style.name;
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() {
                _selectedStyle = style.name;
                _promptController.text = _buildSuggestedPrompt();
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? Colors.black : Colors.black12,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(13),
                        ),
                        child: Image.network(
                          style.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.black38,
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Text(
                        style.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPromptGenerateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        const Text(
          'Generate Design',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Generating for $_selectedSpaceType in $_selectedStyle style (${_selectedColor.toLowerCase()} palette).',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        const Text('Choose color palette'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colorPalettes.map((color) {
            final selected = color == _selectedColor;
            return ChoiceChip(
              label: Text(color),
              selected: selected,
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) {
                setState(() {
                  _selectedColor = color;
                  _promptController.text = _buildSuggestedPrompt();
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your design instructions are applied automatically in background.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        if (_pendingUploads > 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$_pendingUploads upload(s) pending. Internet connect karke retry karein.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isRetryingPending
                      ? null
                      : () => _retryPendingUploads(silent: false),
                  child: Text(_isRetryingPending ? 'Retrying...' : 'Retry now'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_generatedImage != null) ...[
          const Text(
            'Generated Preview',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              _generatedImage!,
              height: 240,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}

class _SpaceOption {
  const _SpaceOption(this.name, this.icon);

  final String name;
  final IconData icon;
}

class _StyleOption {
  const _StyleOption({required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

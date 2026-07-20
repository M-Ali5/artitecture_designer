import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/app_models.dart';
import '../../projects/project_repository.dart';

class DesignPreviewViewer extends StatefulWidget {
  const DesignPreviewViewer({
    super.key,
    required this.projects,
    required this.initialIndex,
    this.enableDelete = true,
  });

  final List<DesignProject> projects;
  final int initialIndex;
  final bool enableDelete;

  @override
  State<DesignPreviewViewer> createState() => _DesignPreviewViewerState();
}

class _DesignPreviewViewerState extends State<DesignPreviewViewer> {
  late final PageController _controller;
  final _repo = ProjectRepository();
  late int _index;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.projects.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DesignProject get _current => widget.projects[_index];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.projects.length}'),
        actions: [
          IconButton(
            tooltip: 'Details',
            onPressed: _showDetails,
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: 'Download',
            onPressed: _downloadCurrent,
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: _shareCurrent,
            icon: const Icon(Icons.share_outlined),
          ),
          if (widget.enableDelete)
            IconButton(
              tooltip: 'Delete',
              onPressed: _isDeleting ? null : _deleteCurrent,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.projects.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, index) {
          final project = widget.projects[index];
          if (project.generatedImageUrl.isEmpty) {
            return const Center(
              child: Icon(Icons.image_not_supported, color: Colors.white54, size: 42),
            );
          }
          return InteractiveViewer(
            minScale: 0.7,
            maxScale: 4,
            child: Center(
              child: Image.network(
                project.generatedImageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadCurrent() async {
    final url = _current.generatedImageUrl;
    if (url.isEmpty) return;
    final ok = await GallerySaver.saveImage(url, albumName: 'artitecture_design');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok == true ? 'Image saved to gallery.' : 'Unable to save image.'),
      ),
    );
  }

  Future<void> _shareCurrent() async {
    final url = _current.generatedImageUrl;
    if (url.isEmpty) return;
    await Share.share(url);
  }

  Future<void> _deleteCurrent() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Design'),
        content: const Text('Do you want to delete this design?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    setState(() => _isDeleting = true);
    await _repo.deleteProject(_current.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _showDetails() {
    final p = _current;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text('Type: ${p.type}'),
                const SizedBox(height: 6),
                Text('Style: ${p.style}'),
                const SizedBox(height: 6),
                Text(
                  'Created: ${DateFormat.yMMMd().add_jm().format(DateTime.tryParse(p.createdAtIso) ?? DateTime.now())}',
                ),
                const SizedBox(height: 8),
                const Text('Prompt', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  p.prompt,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

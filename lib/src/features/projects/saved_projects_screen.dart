import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_models.dart';
import '../gallery/widgets/design_preview_viewer.dart';
import 'project_repository.dart';

class SavedProjectsScreen extends StatelessWidget {
  const SavedProjectsScreen({super.key, this.enableDelete = true});

  final bool enableDelete;

  @override
  Widget build(BuildContext context) {
    final repo = ProjectRepository();
    return StreamBuilder<List<DesignProject>>(
      stream: repo.watchProjects(),
      builder: (context, snapshot) {
        final projects = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (projects.isEmpty) {
          return const Center(child: Text('No saved projects yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: projects.length,
          itemBuilder: (context, i) {
            final p = projects[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _openPreview(context, projects, i),
                      borderRadius: BorderRadius.circular(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: p.generatedImageUrl.isNotEmpty
                            ? Image.network(
                                p.generatedImageUrl,
                                width: 82,
                                height: 82,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 82,
                                  height: 82,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image_outlined),
                                ),
                              )
                            : Container(
                                width: 82,
                                height: 82,
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_not_supported),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p.style} ${p.type}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd().add_jm().format(
                                  DateTime.tryParse(p.createdAtIso) ?? DateTime.now(),
                                ),
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.prompt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    if (enableDelete)
                      IconButton(
                        onPressed: () => repo.deleteProject(p.id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openPreview(
    BuildContext context,
    List<DesignProject> projects,
    int index,
  ) async {
    final removed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DesignPreviewViewer(
          projects: projects,
          initialIndex: index,
          enableDelete: enableDelete,
        ),
      ),
    );
    if (removed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Design deleted.')),
      );
    }
  }
}

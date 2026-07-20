import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_models.dart';
import '../projects/project_repository.dart';
import 'widgets/design_preview_viewer.dart';

class DesignGalleryV2Screen extends StatefulWidget {
  const DesignGalleryV2Screen({super.key});

  @override
  State<DesignGalleryV2Screen> createState() => _DesignGalleryV2ScreenState();
}

class _DesignGalleryV2ScreenState extends State<DesignGalleryV2Screen> {
  String _search = '';
  String _filter = 'all';
  String _sort = 'newest';

  @override
  Widget build(BuildContext context) {
    final repo = ProjectRepository();
    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by style or prompt',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) =>
                            setState(() => _search = v.trim().toLowerCase()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _sort,
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Newest'),
                        ),
                        DropdownMenuItem(
                          value: 'oldest',
                          child: Text('Oldest'),
                        ),
                        DropdownMenuItem(value: 'style', child: Text('Style')),
                      ],
                      onChanged: (v) => setState(() => _sort = v ?? 'newest'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Interior',
                      selected: _filter == 'interior',
                      onTap: () => setState(() => _filter = 'interior'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Exterior',
                      selected: _filter == 'exterior',
                      onTap: () => setState(() => _filter = 'exterior'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DesignProject>>(
              stream: repo.watchProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data ?? [];
                final filtered =
                    all.where((p) {
                      final passesFilter =
                          _filter == 'all' || p.type == _filter;
                      final haystack = '${p.style} ${p.prompt}'.toLowerCase();
                      final passesSearch =
                          _search.isEmpty || haystack.contains(_search);
                      return passesFilter && passesSearch;
                    }).toList()..sort((a, b) {
                      if (_sort == 'oldest') {
                        return a.createdAtIso.compareTo(b.createdAtIso);
                      }
                      if (_sort == 'style') {
                        return a.style.toLowerCase().compareTo(
                          b.style.toLowerCase(),
                        );
                      }
                      return b.createdAtIso.compareTo(a.createdAtIso);
                    });

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No designs found.\nTry different search or filters.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F1F1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${filtered.length} results',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final p = filtered[i];
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _openPreview(context, filtered, i),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: p.generatedImageUrl.isNotEmpty
                                        ? Image.network(
                                            p.generatedImageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons
                                                          .broken_image_outlined,
                                                    ),
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      8,
                                      8,
                                      3,
                                    ),
                                    child: Text(
                                      p.style,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      0,
                                      8,
                                      8,
                                    ),
                                    child: Text(
                                      '${p.type} • ${DateFormat.MMMd().format(DateTime.tryParse(p.createdAtIso) ?? DateTime.now())}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
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
        builder: (_) =>
            DesignPreviewViewer(projects: projects, initialIndex: index),
      ),
    );
    if (removed == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Design deleted.')));
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.black : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

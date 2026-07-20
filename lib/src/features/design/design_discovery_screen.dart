import 'package:flutter/material.dart';

import '../../../app_routes.dart';
import 'two_step_design_args.dart';

class DesignDiscoveryScreen extends StatelessWidget {
  const DesignDiscoveryScreen({super.key, this.onTapSettings});

  final VoidCallback? onTapSettings;

  static const _interiorPresets = [
    _DesignPreset(
      title: 'Modern Living Room',
      subtitle: 'Clean + bright + cozy',
      imageUrl:
          'https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?auto=format&fit=crop&w=1200&q=80',
      type: 'interior',
      style: 'Modern',
      color: 'Neutral',
      prompt:
          'Design a modern luxury living room with natural daylight, soft neutral palette, and premium furniture.',
    ),
    _DesignPreset(
      title: 'Scandinavian Bedroom',
      subtitle: 'Soft wood + warm lights',
      imageUrl:
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
      type: 'interior',
      style: 'Scandinavian',
      color: 'Warm',
      prompt:
          'Create a Scandinavian bedroom concept with wood accents, warm ambient lights, and minimal decor.',
    ),
    _DesignPreset(
      title: 'Luxury Kitchen',
      subtitle: 'Marble + elegant finish',
      imageUrl:
          'https://images.unsplash.com/photo-1556911220-bda9f7f7597e?auto=format&fit=crop&w=1200&q=80',
      type: 'interior',
      style: 'Luxury',
      color: 'Monochrome',
      prompt:
          'Design a luxury kitchen with marble finishes, modern cabinets, and elegant lighting.',
    ),
  ];

  static const _exteriorPresets = [
    _DesignPreset(
      title: 'Modern House Front',
      subtitle: 'Sharp lines + premium facade',
      imageUrl:
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
      type: 'exterior',
      style: 'Modern',
      color: 'Cool',
      prompt:
          'Generate a modern exterior facade with clean lines, glass elements, and landscape lighting.',
    ),
    _DesignPreset(
      title: 'Spanish Villa',
      subtitle: 'Warm stone + classic look',
      imageUrl:
          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=1200&q=80',
      type: 'exterior',
      style: 'Spanish',
      color: 'Earthy',
      prompt:
          'Create a Spanish villa exterior with warm earthy palette, tiled roof, and courtyard style entrance.',
    ),
    _DesignPreset(
      title: 'Luxury Villa Exterior',
      subtitle: 'High-end curb appeal',
      imageUrl:
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1200&q=80',
      type: 'exterior',
      style: 'Luxury Villa',
      color: 'Neutral',
      prompt:
          'Design a luxury villa exterior with premium materials, elegant lighting, and modern landscaping.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'IP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'artitecture_design',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Create realistic AI interior & exterior concepts',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onTapSettings,
                    icon: const Icon(
                      Icons.tune,
                      size: 24,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _HomeToolCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?auto=format&fit=crop&w=1200&q=80',
              title: 'Room Restyle',
              subtitle:
                  'Upload a room photo and generate a refined interior concept.',
              onTap: () => _openFlow(context, 'interior', null),
            ),
            const SizedBox(height: 14),
            _HomeToolCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
              title: 'Smart Layout',
              subtitle:
                  'Try optimized furniture and circulation planning instantly.',
              onTap: () => _openFlow(
                context,
                'interior',
                const _DesignPreset(
                  title: 'Layout Boost',
                  subtitle: 'Smart space planning',
                  imageUrl: '',
                  type: 'interior',
                  style: 'Modern',
                  color: 'Neutral',
                  prompt:
                      'Redesign the uploaded room with optimized layout, better furniture circulation, and a clean modern look.',
                ),
              ),
            ),
            const SizedBox(height: 14),
            _HomeToolCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
              title: 'Facade Vision',
              subtitle:
                  'Transform your exterior with modern architectural styling.',
              onTap: () => _openFlow(context, 'exterior', null),
            ),
            const SizedBox(height: 20),
            const Text(
              'Interior Inspiration',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _PresetRow(
              presets: _interiorPresets,
              onTap: (preset) => _openFlow(context, preset.type, preset),
            ),
            const SizedBox(height: 18),
            const Text(
              'Exterior Inspiration',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _PresetRow(
              presets: _exteriorPresets,
              onTap: (preset) => _openFlow(context, preset.type, preset),
            ),
          ],
        ),
      ),
    );
  }

  void _openFlow(BuildContext context, String type, _DesignPreset? preset) {
    Navigator.pushNamed(
      context,
      AppRoutes.createDesign,
      arguments: TwoStepDesignArgs(
        initialType: type,
        initialStyle: preset?.style,
        initialColor: preset?.color,
        initialPrompt: preset == null
            ? 'Generate a professional $type concept.'
            : preset.prompt,
      ),
    );
  }
}

class _HomeToolCard extends StatelessWidget {
  const _HomeToolCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              imageUrl,
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 210,
                color: const Color(0xFFE5E5E5),
                alignment: Alignment.center,
                child: const Icon(Icons.image, color: Colors.black38, size: 34),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Design Now',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.presets, required this.onTap});

  final List<_DesignPreset> presets;
  final ValueChanged<_DesignPreset> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 186,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final preset = presets[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTap(preset),
            child: SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      preset.imageUrl,
                      height: 130,
                      width: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    preset.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    preset.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DesignPreset {
  const _DesignPreset({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    required this.style,
    required this.color,
    required this.prompt,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String type;
  final String style;
  final String color;
  final String prompt;
}

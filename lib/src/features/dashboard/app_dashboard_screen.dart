import 'package:flutter/material.dart';

import '../../../app_routes.dart';
import '../design/design_discovery_screen.dart';
import '../design/two_step_design_screen.dart';
import '../gallery/design_gallery_v2_screen.dart';
import '../profile/my_profile_screen.dart';

class AppDashboardScreen extends StatefulWidget {
  const AppDashboardScreen({super.key});

  @override
  State<AppDashboardScreen> createState() => _AppDashboardScreenState();
}

class _AppDashboardScreenState extends State<AppDashboardScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Create', 'Discover', 'My Profile'];
    final pages = [
      DesignDiscoveryScreen(
        onTapSettings: () =>
            Navigator.pushNamed(context, AppRoutes.settingsRoute),
      ),
      const TwoStepDesignScreen(initialType: 'interior'),
      const DesignGalleryV2Screen(),
      const MyProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: labels[0],
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavItem(
                icon: Icons.layers_outlined,
                label: labels[1],
                selected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _NavItem(
                icon: Icons.explore_outlined,
                label: labels[2],
                selected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: labels[3],
                selected: _index == 3,
                onTap: () => setState(() => _index = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : Colors.black54;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

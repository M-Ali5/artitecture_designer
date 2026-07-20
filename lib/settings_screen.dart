import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'src/app_settings_controller.dart';
import 'src/features/auth/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(
              settings.isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
            ),
            value: settings.isDarkMode,
            onChanged: (v) => settings.setDarkMode(v),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Accent Color'),
            subtitle: Text(settings.accentColor),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAccentPicker(context),
          ),
          _sectionHeader('Designer Settings'),
          SwitchListTile(
            title: const Text('Show Grid'),
            subtitle: const Text('Display canvas grid in Room Designer'),
            value: settings.showGrid,
            onChanged: (v) => settings.setShowGrid(v),
          ),
          SwitchListTile(
            title: const Text('Snap to Grid'),
            subtitle: const Text('Furniture snaps to nearest grid point'),
            value: settings.snapToGrid,
            onChanged: (v) => settings.setSnapToGrid(v),
          ),
          SwitchListTile(
            title: const Text('Include Measurements'),
            subtitle: const Text('Show room dimensions in designer'),
            value: settings.includeMeasurements,
            onChanged: (v) => settings.setIncludeMeasurements(v),
          ),
          ListTile(
            leading: const Icon(Icons.straighten_outlined),
            title: const Text('Default Room Size'),
            subtitle: Text(settings.roomSize),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRoomSizePicker(context),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Generation Quality'),
            subtitle: Text(settings.imageQuality),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showImageQualityPicker(context),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
      ),
    );
  }

  Future<void> _showAccentPicker(BuildContext context) async {
    const options = ['Blue', 'Orange', 'Green', 'Purple', 'Red', 'Teal'];
    final settings = context.read<AppSettingsController>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Accent Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (o) => ListTile(
                  title: Text(o),
                  trailing: settings.accentColor == o
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    await settings.setAccentColor(o);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showRoomSizePicker(BuildContext context) async {
    const sizes = [
      '10 x 10 ft',
      '12 x 12 ft',
      '14 x 16 ft',
      '16 x 20 ft',
      '20 x 24 ft',
    ];
    final settings = context.read<AppSettingsController>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Default Room Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sizes
              .map(
                (s) => ListTile(
                  title: Text(s),
                  trailing: settings.roomSize == s
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    await settings.setRoomSize(s);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showImageQualityPicker(BuildContext context) async {
    const options = ['Standard (720p)', 'High (1080p)', 'Ultra (4K)'];
    final settings = context.read<AppSettingsController>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Generation Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (q) => ListTile(
                  title: Text(q),
                  trailing: settings.imageQuality == q
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    await settings.setImageQuality(q);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !context.mounted) return;
    await context.read<AuthController>().signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.authGate,
      (_) => false,
    );
  }
}

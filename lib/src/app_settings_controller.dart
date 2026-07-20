import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const _kIsDarkMode = 'settings.isDarkMode';
  static const _kShowGrid = 'settings.showGrid';
  static const _kSnapToGrid = 'settings.snapToGrid';
  static const _kIncludeMeasurements = 'settings.includeMeasurements';
  static const _kAccentColor = 'settings.accentColor';
  static const _kImageQuality = 'settings.imageQuality';
  static const _kRoomSize = 'settings.roomSize';

  bool isDarkMode = false;
  bool showGrid = true;
  bool snapToGrid = true;
  bool includeMeasurements = false;
  String accentColor = 'Blue';
  String imageQuality = 'High (1080p)';
  String roomSize = '12 x 12 ft';
  bool isLoaded = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool(_kIsDarkMode) ?? false;
    showGrid = prefs.getBool(_kShowGrid) ?? true;
    snapToGrid = prefs.getBool(_kSnapToGrid) ?? true;
    includeMeasurements = prefs.getBool(_kIncludeMeasurements) ?? false;
    accentColor = prefs.getString(_kAccentColor) ?? 'Blue';
    imageQuality = prefs.getString(_kImageQuality) ?? 'High (1080p)';
    roomSize = prefs.getString(_kRoomSize) ?? '12 x 12 ft';
    isLoaded = true;
    notifyListeners();
  }

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsDarkMode, value);
  }

  Future<void> setShowGrid(bool value) async {
    showGrid = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowGrid, value);
  }

  Future<void> setSnapToGrid(bool value) async {
    snapToGrid = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSnapToGrid, value);
  }

  Future<void> setIncludeMeasurements(bool value) async {
    includeMeasurements = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIncludeMeasurements, value);
  }

  Future<void> setAccentColor(String value) async {
    accentColor = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccentColor, value);
  }

  Future<void> setImageQuality(String value) async {
    imageQuality = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kImageQuality, value);
  }

  Future<void> setRoomSize(String value) async {
    roomSize = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRoomSize, value);
  }

  Color get accentColorValue {
    switch (accentColor) {
      case 'Orange':
        return const Color(0xFFE67E22);
      case 'Green':
        return const Color(0xFF27AE60);
      case 'Purple':
        return const Color(0xFF9B59B6);
      case 'Red':
        return const Color(0xFFE74C3C);
      case 'Teal':
        return const Color(0xFF008080);
      case 'Blue':
      default:
        return const Color(0xFF3498DB);
    }
  }

  String get generationSize {
    switch (imageQuality) {
      case 'Standard (720p)':
        return '1024x1024';
      case 'Ultra (4K)':
        return '1536x1024';
      case 'High (1080p)':
      default:
        return '1024x1536';
    }
  }

  (double widthFt, double heightFt) get defaultRoomDimensions {
    final normalized = roomSize.toLowerCase().replaceAll('ft', '').trim();
    final parts = normalized.split('x');
    if (parts.length != 2) return (12, 12);
    final w = double.tryParse(parts[0].trim()) ?? 12;
    final h = double.tryParse(parts[1].trim()) ?? 12;
    return (w, h);
  }
}

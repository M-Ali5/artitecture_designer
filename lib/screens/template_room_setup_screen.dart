// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_routes.dart';
import '../models/room_designer_args.dart';
import '../widgets/room_floor_preview.dart';

/// Professional step: user only enters room width × height (feet), then opens Room Designer.
class TemplateRoomSetupScreen extends StatefulWidget {
  final TemplateSetupArgs args;

  const TemplateRoomSetupScreen({super.key, required this.args});

  @override
  State<TemplateRoomSetupScreen> createState() => _TemplateRoomSetupScreenState();
}

class _TemplateRoomSetupScreenState extends State<TemplateRoomSetupScreen> {
  final _widthCtrl = TextEditingController(text: '14');
  final _heightCtrl = TextEditingController(text: '12');
  final _formKey = GlobalKey<FormState>();

  void _onDimensionsChanged() => setState(() {});

  double get _previewW =>
      double.tryParse(_widthCtrl.text.trim()) ?? 14;

  double get _previewL =>
      double.tryParse(_heightCtrl.text.trim()) ?? 12;

  @override
  void initState() {
    super.initState();
    _widthCtrl.addListener(_onDimensionsChanged);
    _heightCtrl.addListener(_onDimensionsChanged);
  }

  @override
  void dispose() {
    _widthCtrl.removeListener(_onDimensionsChanged);
    _heightCtrl.removeListener(_onDimensionsChanged);
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final w = double.parse(_widthCtrl.text.trim());
    final h = double.parse(_heightCtrl.text.trim());
    Navigator.pushNamed(
      context,
      AppRoutes.roomDesigner,
      arguments: RoomDesignerArgs(
        widthFt: w,
        heightFt: h,
        templateId: widget.args.templateId,
        roomTitle: widget.args.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.args;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        title: const Text('Room size'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      if (a.subtitle != null && a.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          a.subtitle!,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.35),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Enter your room in feet. The preview below matches width × length.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: RoomFloorPreview(
                          widthFt: _previewW.clamp(0.1, 100).toDouble(),
                          lengthFt: _previewL.clamp(0.1, 100).toDouble(),
                          templateId: a.templateId,
                          maxSide: 220,
                          showDimensionLabels: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.straighten, color: Color(0xFF3498DB), size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Dimensions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Change numbers — room shape updates above',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _widthCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              ],
                              decoration: _fieldDeco('Width', 'ft'),
                              validator: _validateFt,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 14, left: 8, right: 8),
                            child: Text('×', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _heightCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              ],
                              decoration: _fieldDeco('Length', 'ft'),
                              validator: _validateFt,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Typical range: 8–40 ft per side',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Open Room Designer',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDeco(String label, String suffix) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  String? _validateFt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final v = double.tryParse(value.trim());
    if (v == null) return 'Enter a number';
    if (v < 6 || v > 60) return 'Use 6–60 ft';
    return null;
  }
}

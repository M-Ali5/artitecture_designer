// ignore_for_file: deprecated_member_use, use_build_context_synchronously, library_private_types_in_public_api
// room_designer_screen.dart - PROFESSIONAL MOBILE VERSION
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'models/room_designer_args.dart';
import 'src/app_settings_controller.dart';

class RoomDesignerScreen extends StatefulWidget {
  final RoomDesignerArgs? args;

  const RoomDesignerScreen({super.key, this.args});

  @override
  _RoomDesignerScreenState createState() => _RoomDesignerScreenState();
}

class _RoomDesignerScreenState extends State<RoomDesignerScreen> {
  bool is2DView = true;
  double currentZoom = 1.0;
  bool isPropertiesOpen = false;
  String selectedTool = 'select';

  late double _roomWidthFt;
  late double _roomHeightFt;
  bool _presetApplied = false;
  bool _presetCallbackScheduled = false;
  bool _appliedDefaultRoomSize = false;

  List<Map<String, dynamic>> placedFurniture = [];
  int? selectedFurnitureId;

  @override
  void initState() {
    super.initState();
    final a = widget.args;
    _roomWidthFt = a?.widthFt ?? 12;
    _roomHeightFt = a?.heightFt ?? 14;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedDefaultRoomSize || widget.args != null) return;
    final settings = context.read<AppSettingsController>();
    final (w, h) = settings.defaultRoomDimensions;
    _roomWidthFt = w;
    _roomHeightFt = h;
    _appliedDefaultRoomSize = true;
  }

  final List<Map<String, dynamic>> furnitureItems = [
    {
      'name': 'Sofa',
      'icon': Icons.weekend,
      'color': Color(0xFF3498DB),
      'size': 80,
    },
    {'name': 'Bed', 'icon': Icons.bed, 'color': Color(0xFFE67E22), 'size': 100},
    {
      'name': 'Table',
      'icon': Icons.table_restaurant,
      'color': Color(0xFF27AE60),
      'size': 60,
    },
    {
      'name': 'Chair',
      'icon': Icons.chair,
      'color': Color(0xFF9B59B6),
      'size': 40,
    },
    {
      'name': 'Cabinet',
      'icon': Icons.cabin,
      'color': Color(0xFF3498DB),
      'size': 50,
    },
    {
      'name': 'Lamp',
      'icon': Icons.emoji_objects,
      'color': Color(0xFFE67E22),
      'size': 30,
    },
    {
      'name': 'Plant',
      'icon': Icons.forest,
      'color': Color(0xFF27AE60),
      'size': 35,
    },
    {
      'name': 'Rug',
      'icon': Icons.square_foot,
      'color': Color(0xFF9B59B6),
      'size': 90,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildCanvas(settings)),
              _buildBottomFurnitureBar(),
            ],
          ),

          // Collapsible Right Panel
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            right: isPropertiesOpen ? 0 : -280,
            top: 0,
            bottom: 0,
            child: _buildPropertiesPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFF2C3E50),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 430;
          final viewToggle = Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(20),
              selectedBorderColor: Colors.white,
              selectedColor: Colors.white,
              fillColor: Color(0xFF3498DB),
              color: Colors.white70,
              constraints: BoxConstraints(minHeight: 35, minWidth: 50),
              isSelected: [is2DView, !is2DView],
              onPressed: (index) => setState(() => is2DView = index == 0),
              children: [
                Text('2D', style: TextStyle(fontSize: 14)),
                Text('3D', style: TextStyle(fontSize: 14)),
              ],
            ),
          );
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () =>
                    setState(() => isPropertiesOpen = !isPropertiesOpen),
              ),
              IconButton(
                icon: Icon(Icons.save, color: Colors.white),
                onPressed: _saveCurrentDesign,
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF3498DB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.draw, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.args?.roomTitle ?? 'Room Designer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    actions,
                  ],
                ),
                SizedBox(height: 8),
                Center(child: viewToggle),
              ],
            );
          }

          return Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF3498DB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.draw, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.args?.roomTitle ?? 'Room Designer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              viewToggle,
              SizedBox(width: 8),
              actions,
            ],
          );
        },
      ),
    );
  }

  Size _canvasSizeFor(BoxConstraints constraints) {
    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;
    final aspect = _roomWidthFt / _roomHeightFt;
    double w;
    double h;
    if (maxW / maxH > aspect) {
      h = maxH;
      w = h * aspect;
    } else {
      w = maxW;
      h = w / aspect;
    }
    return Size(w, h);
  }

  /// Starter layout for each template (positions as fraction of canvas).
  List<Map<String, dynamic>> _presetFurnitureForTemplate(
    String templateId,
    double cw,
    double ch,
  ) {
    int ts = DateTime.now().millisecondsSinceEpoch;
    final out = <Map<String, dynamic>>[];

    void place(int itemIndex, double fx, double fy) {
      final item = Map<String, dynamic>.from(furnitureItems[itemIndex]);
      final sz = (item['size'] as num).toDouble();
      final x = (cw * fx).clamp(4.0, math.max(4.0, cw - sz - 4));
      final y = (ch * fy).clamp(4.0, math.max(4.0, ch - sz - 4));
      out.add({...item, 'id': ts++, 'x': x, 'y': y});
    }

    switch (templateId) {
      case 'living':
        place(0, 0.10, 0.48); // Sofa
        place(7, 0.32, 0.38); // Rug
        place(5, 0.72, 0.12); // Lamp
        place(6, 0.12, 0.14); // Plant
        break;
      case 'bedroom':
        place(1, 0.22, 0.26); // Bed
        place(5, 0.68, 0.14); // Lamp
        place(7, 0.28, 0.42); // Rug
        place(6, 0.08, 0.55); // Plant
        break;
      case 'kitchen':
        place(2, 0.28, 0.32); // Table
        place(3, 0.14, 0.52); // Chair
        place(3, 0.48, 0.52); // Chair
        place(4, 0.72, 0.18); // Cabinet
        place(5, 0.42, 0.08); // Lamp
        break;
      default:
        break;
    }
    return out;
  }

  Widget _buildCanvas(AppSettingsController settings) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFurnitureId = null;
        });
      },
      child: Container(
        color: Colors.grey[200],
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canvasSize = _canvasSizeFor(constraints);
            final tid = widget.args?.templateId;
            if (!_presetApplied &&
                !_presetCallbackScheduled &&
                tid != null &&
                tid.isNotEmpty) {
              _presetCallbackScheduled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _presetApplied) return;
                setState(() {
                  placedFurniture = _presetFurnitureForTemplate(
                    tid,
                    canvasSize.width,
                    canvasSize.height,
                  );
                  _presetApplied = true;
                });
              });
            }

            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Container(
                  width: canvasSize.width,
                  height: canvasSize.height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // Grid Background
                      CustomPaint(
                        painter: GridPainter(
                          is2DView: is2DView,
                          showGrid: settings.showGrid,
                        ),
                        size: canvasSize,
                      ),

                      // Placed Furniture
                      ...placedFurniture.map(
                        (furniture) => Positioned(
                          left: furniture['x'],
                          top: furniture['y'],
                          child: GestureDetector(
                            onTap: () => setState(
                              () => selectedFurnitureId = furniture['id'],
                            ),
                            child: Draggable(
                              data: furniture,
                              feedback: _buildFurnitureWidget(
                                furniture,
                                isDragging: true,
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: _buildFurnitureWidget(
                                  furniture,
                                  isSelected:
                                      selectedFurnitureId == furniture['id'],
                                ),
                              ),
                              child: _buildFurnitureWidget(
                                furniture,
                                isSelected:
                                    selectedFurnitureId == furniture['id'],
                              ),
                              onDragEnd: (details) {
                                final itemSize =
                                    (furniture['size'] as num?)?.toDouble() ??
                                    50.0;
                                var nextX = details.offset.dx;
                                var nextY = details.offset.dy;
                                if (settings.snapToGrid) {
                                  const step = 20.0;
                                  nextX = (nextX / step).round() * step;
                                  nextY = (nextY / step).round() * step;
                                }
                                nextX = nextX.clamp(
                                  0.0,
                                  math.max(0.0, canvasSize.width - itemSize),
                                );
                                nextY = nextY.clamp(
                                  0.0,
                                  math.max(0.0, canvasSize.height - itemSize),
                                );
                                setState(() {
                                  furniture['x'] = nextX;
                                  furniture['y'] = nextY;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      // Instruction
                      if (placedFurniture.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Tap furniture from bottom bar to add',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Then drag to position',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomFurnitureBar() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Furniture Library',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Tap to add | Drag to move',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: furnitureItems.length,
              itemBuilder: (context, index) {
                final item = furnitureItems[index];
                return GestureDetector(
                  onTap: () => _addFurniture(item),
                  child: Container(
                    width: 70,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: item['color'].withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item['icon'], color: item['color'], size: 30),
                        SizedBox(height: 4),
                        Text(item['name'], style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesPanel() {
    final includeMeasurements = context
        .watch<AppSettingsController>()
        .includeMeasurements;
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2C3E50),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Properties',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => isPropertiesOpen = false),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPropertyField(
                    'Room Type',
                    _roomTypeLabel,
                    Icons.weekend,
                  ),
                  if (includeMeasurements) ...[
                    SizedBox(height: 12),
                    _buildPropertyField(
                      'Dimensions',
                      '${_roomWidthFt % 1 == 0 ? _roomWidthFt.toStringAsFixed(0) : _roomWidthFt.toStringAsFixed(1)} × ${_roomHeightFt % 1 == 0 ? _roomHeightFt.toStringAsFixed(0) : _roomHeightFt.toStringAsFixed(1)} ft',
                      Icons.straighten,
                    ),
                  ],
                  SizedBox(height: 12),
                  _buildPropertyField('Wall Color', 'White', Icons.color_lens),
                  SizedBox(height: 12),
                  _buildPropertyField('Floor', 'Wood', Icons.square_foot),
                  Divider(height: 24),
                  Text('Zoom', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: currentZoom,
                    min: 0.5,
                    max: 3.0,
                    onChanged: (value) => setState(() => currentZoom = value),
                    activeColor: Color(0xFF3498DB),
                  ),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${placedFurniture.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (selectedFurnitureId != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF3498DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Item',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          ...placedFurniture
                              .where((f) => f['id'] == selectedFurnitureId)
                              .map(
                                (f) => Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(f['icon'], color: f['color']),
                                        SizedBox(width: 8),
                                        Text(f['name']),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _removeFurniture(f['id']),
                                      icon: Icon(Icons.delete, size: 16),
                                      label: Text('Remove'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        minimumSize: Size(double.infinity, 35),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  SizedBox(height: 12),
                  if (placedFurniture.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: _clearCanvas,
                      icon: Icon(Icons.delete_sweep),
                      label: Text('Clear All'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyField(
    String label,
    String value,
    IconData icon, {
    bool showEdit = true,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Color(0xFF3498DB)),
        SizedBox(width: 10),
        Expanded(child: Text(label)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        if (showEdit)
          IconButton(
            icon: Icon(Icons.edit, size: 16, color: Colors.grey),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit $label coming soon')),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFurnitureWidget(
    Map<String, dynamic> furniture, {
    bool isDragging = false,
    bool isSelected = false,
  }) {
    return Container(
      width: furniture['size']?.toDouble() ?? 50,
      height: furniture['size']?.toDouble() ?? 50,
      decoration: BoxDecoration(
        color: isDragging
            ? furniture['color'].withOpacity(0.8)
            : furniture['color'],
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Icon(furniture['icon'], color: Colors.white, size: 30),
    );
  }

  void _addFurniture(Map<String, dynamic> furniture) {
    setState(() {
      placedFurniture.add({
        ...furniture,
        'id': DateTime.now().millisecondsSinceEpoch,
        'x': 50.0 + (placedFurniture.length * 40),
        'y': 50.0 + (placedFurniture.length * 40),
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${furniture['name']}'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeFurniture(int id) {
    setState(() {
      placedFurniture.removeWhere((item) => item['id'] == id);
      selectedFurnitureId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Furniture removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearCanvas() {
    setState(() {
      placedFurniture.clear();
      selectedFurnitureId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Canvas cleared'), duration: Duration(seconds: 1)),
    );
  }

  String get _roomTypeLabel {
    switch (widget.args?.templateId) {
      case 'living':
        return 'Living room';
      case 'bedroom':
        return 'Bedroom';
      case 'kitchen':
        return 'Kitchen';
      default:
        return 'Custom';
    }
  }

  Future<void> _saveCurrentDesign() async {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Save Design'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: 'Enter design name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                DatabaseHelper db = DatabaseHelper();
                await db.saveDesign({
                  'name': nameController.text,
                  'roomType': _roomTypeLabel,
                  'dimensions':
                      '${_roomWidthFt % 1 == 0 ? _roomWidthFt.toStringAsFixed(0) : _roomWidthFt.toStringAsFixed(1)} × ${_roomHeightFt % 1 == 0 ? _roomHeightFt.toStringAsFixed(0) : _roomHeightFt.toStringAsFixed(1)} ft',
                  'furnitureData': placedFurniture.toString(),
                  'imagePath': '',
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Design saved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Grid Painter
class GridPainter extends CustomPainter {
  final bool is2DView;
  final bool showGrid;

  GridPainter({required this.is2DView, required this.showGrid});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGrid) return;
    Paint gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

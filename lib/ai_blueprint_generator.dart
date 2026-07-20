// ignore_for_file: deprecated_member_use, use_build_context_synchronously, library_private_types_in_public_api
// ai_blueprint_generator.dart - WORKING WITH MOCK DATA
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_routes.dart';

class AIBlueprintGenerator extends StatefulWidget {
  const AIBlueprintGenerator({super.key});

  @override
  _AIBlueprintGeneratorState createState() => _AIBlueprintGeneratorState();
}

class _AIBlueprintGeneratorState extends State<AIBlueprintGenerator> {
  final TextEditingController _promptController = TextEditingController();

  final List<String> _roomTypes = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Home Office',
    'Bathroom',
    'Dining Room',
    'Kids Room',
    'Studio Apartment',
  ];

  final List<String> _designStyles = [
    'Modern Minimalist',
    'Scandinavian',
    'Industrial',
    'Bohemian',
    'Traditional',
    'Mid-Century Modern',
    'Coastal',
    'Rustic',
  ];

  String _selectedRoomType = 'Living Room';
  String _selectedStyle = 'Modern Minimalist';
  bool _isLoading = false;
  String? _generatedBlueprint;

  // Set this to true if API doesn't work
  final bool _useMockMode = true; // ← CHANGE TO false when API works

  String get _apiKey => (dotenv.env['GEMINI_API_KEY'] ?? '').trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInputCard(),
                      SizedBox(height: 20),
                      if (_isLoading) _buildLoadingCard(),
                      if (_generatedBlueprint != null) _buildBlueprintCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: 15),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI Blueprint Generator',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF3498DB), size: 28),
                SizedBox(width: 10),
                Text(
                  'Describe Your Dream Room',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 15),

            Text('Room Type:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _roomTypes.length,
                itemBuilder: (context, index) {
                  final room = _roomTypes[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRoomType = room),
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: _selectedRoomType == room
                            ? LinearGradient(
                                colors: [Color(0xFF3498DB), Color(0xFF2C3E50)],
                              )
                            : null,
                        color: _selectedRoomType == room
                            ? null
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room,
                        style: TextStyle(
                          color: _selectedRoomType == room
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 15),

            Text(
              'Design Style:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _designStyles.length,
                itemBuilder: (context, index) {
                  final style = _designStyles[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStyle = style),
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: _selectedStyle == style
                            ? LinearGradient(
                                colors: [Color(0xFFE67E22), Color(0xFF2C3E50)],
                              )
                            : null,
                        color: _selectedStyle == style
                            ? null
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        style,
                        style: TextStyle(
                          color: _selectedStyle == style
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 15),

            Text(
              'Or describe in your own words:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Example: A cozy living room with a fireplace...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateBlueprint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF27AE60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Generating...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome),
                          SizedBox(width: 10),
                          Text(
                            'Generate Blueprint',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(color: Color(0xFF3498DB)),
            ),
            SizedBox(height: 20),
            Text(
              'AI is designing your dream space...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Text(
              'This may take a few seconds',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueprintCard() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.article, color: Color(0xFF27AE60), size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your AI Generated Blueprint',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _generatedBlueprint!,
                  style: TextStyle(height: 1.6),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyGeneratedBlueprint,
                    icon: Icon(Icons.copy),
                    label: Text('Copy'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.roomDesigner);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Use these suggestions!')),
                      );
                    },
                    icon: Icon(Icons.design_services),
                    label: Text('Use in Designer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3498DB),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateBlueprint() async {
    setState(() {
      _isLoading = true;
      _generatedBlueprint = null;
    });

    // Use mock mode for testing (works without API)
    if (_useMockMode) {
      await Future.delayed(Duration(seconds: 2));
      _generateMockBlueprint();
      setState(() => _isLoading = false);
      return;
    }

    // Real API call
    if (_apiKey.isEmpty) {
      _generateMockBlueprint();
      setState(() => _isLoading = false);
      return;
    }

    String prompt = _buildPrompt();

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final blueprint = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() => _generatedBlueprint = blueprint);
      } else {
        _generateMockBlueprint();
      }
    } catch (e) {
      _generateMockBlueprint();
    }

    setState(() => _isLoading = false);
  }

  String _buildPrompt() {
    String userInput = _promptController.text.trim();
    if (userInput.isEmpty) {
      userInput =
          "a beautiful ${_selectedStyle.toLowerCase()} $_selectedRoomType";
    }
    return "Create a detailed room design for: $userInput. Include dimensions, colors, furniture, lighting, and tips.";
  }

  void _generateMockBlueprint() {
    setState(() {
      _generatedBlueprint = '''
═══════════════════════════════════════
📐 ROOM DIMENSIONS
═══════════════════════════════════════
• Width: 14 feet
• Length: 18 feet  
• Ceiling Height: 9 feet
• Total Area: 252 sq ft

═══════════════════════════════════════
🎨 COLOR SCHEME
═══════════════════════════════════════
• Walls: Soft Greige (#E8E8E8)
• Flooring: Light Oak Hardwood
• Accent Wall: Navy Blue (#2C3E50)
• Accent Colors: Gold (#D4AF37)

═══════════════════════════════════════
🪑 FURNITURE LAYOUT
═══════════════════════════════════════
• 3-Seat Sofa - Centered on accent wall
• 2 Armchairs - Flanking the sofa
• Coffee Table - Centered (48" x 28")
• TV Console - Opposite sofa
• Bookshelf - On side wall
• Floor Lamp - Reading corner

═══════════════════════════════════════
💡 LIGHTING PLAN
═══════════════════════════════════════
• Ambient: 6 recessed LED lights
• Task: Floor lamp + desk lamp
• Accent: Picture lights + LED strips
• Natural Light: 2 windows with sheers

═══════════════════════════════════════
✨ PROFESSIONAL TIPS
═══════════════════════════════════════
1. Use mirrors to make space feel larger
2. Layer lighting at different heights
3. Add plants for natural elements
4. Use area rugs to define zones
''';
    });
  }

  Future<void> _copyGeneratedBlueprint() async {
    final blueprint = _generatedBlueprint;
    if (blueprint == null || blueprint.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to copy yet.')));
      return;
    }

    await Clipboard.setData(ClipboardData(text: blueprint));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Design copied to clipboard.')),
    );
  }
}

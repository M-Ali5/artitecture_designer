// ignore_for_file: deprecated_member_use, use_build_context_synchronously, library_private_types_in_public_api
// design_gallery_screen.dart
import 'package:flutter/material.dart';
import 'database_helper.dart'; // ADD THIS IMPORT
import 'app_routes.dart';

class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  _DesignGalleryScreenState createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ADD THESE VARIABLES
  List<Map<String, dynamic>> savedDesigns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDesigns(); // Load designs from database
  }

  // ADD THIS METHOD TO LOAD DESIGNS
  Future<void> _loadDesigns() async {
    setState(() => isLoading = true);
    DatabaseHelper db = DatabaseHelper();
    savedDesigns = await db.getAllDesigns();
    setState(() => isLoading = false);
  }

  // ADD HELPER METHOD TO FORMAT DATE
  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null) return 'Unknown';
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildStatsBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGridGallery(),
                    _buildListGallery(),
                    _buildFavoritesGallery(),
                  ],
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
          Expanded(
            child: Text(
              'My Designs',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                  ).createShader(Rect.fromLTWH(0, 0, 150, 30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED STATS BAR - Shows actual counts from database
  Widget _buildStatsBar() {
    int totalDesigns = savedDesigns.length;
    int livingCount = savedDesigns
        .where((d) => d['roomType'] == 'Living Room')
        .length;
    int bedroomCount = savedDesigns
        .where((d) => d['roomType'] == 'Bedroom')
        .length;
    int kitchenCount = savedDesigns
        .where((d) => d['roomType'] == 'Kitchen')
        .length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 10,
        spacing: 10,
        children: [
          _buildStatItem('Total', totalDesigns.toString(), Icons.folder, Color(0xFF3498DB)),
          _buildStatItem('Living', livingCount.toString(), Icons.weekend, Color(0xFFE67E22)),
          _buildStatItem('Bedroom', bedroomCount.toString(), Icons.bed, Color(0xFF27AE60)),
          _buildStatItem('Kitchen', kitchenCount.toString(), Icons.kitchen, Color(0xFF9B59B6)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(20),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3498DB), Color(0xFF2C3E50)],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: [
          Tab(text: 'Grid View'),
          Tab(text: 'List View'),
          Tab(text: 'Favorites'),
        ],
      ),
    );
  }

  // UPDATED GRID GALLERY - Shows designs from database
  Widget _buildGridGallery() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3498DB)),
            SizedBox(height: 20),
            Text('Loading your designs...'),
          ],
        ),
      );
    }

    if (savedDesigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No designs saved yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Create a design in Room Designer and save it',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.roomDesigner);
              },
              icon: Icon(Icons.add),
              label: Text('Create New Design'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3498DB),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: savedDesigns.length,
      itemBuilder: (context, index) => _buildDesignCard(savedDesigns[index]),
    );
  }

  // UPDATED DESIGN CARD - Shows saved design data
  Widget _buildDesignCard(Map<String, dynamic> design) {
    // Random color based on design id
    List<Color> colors = [
      Color(0xFF3498DB),
      Color(0xFFE67E22),
      Color(0xFF27AE60),
      Color(0xFF9B59B6),
    ];
    Color designColor = colors[design['id'] % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [designColor, designColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Icon(Icons.design_services, size: 60, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  design['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  design['roomType'] ?? 'Custom Design',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 10,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formatDate(design['createdAt']),
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                    Spacer(),
                    _buildCardMenu(design),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED LIST GALLERY - Shows designs from database
  Widget _buildListGallery() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF3498DB)));
    }

    if (savedDesigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No designs saved yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: savedDesigns.length,
      itemBuilder: (context, index) => _buildListItem(savedDesigns[index]),
    );
  }

  Widget _buildListItem(Map<String, dynamic> design) {
    List<Color> colors = [
      Color(0xFF3498DB),
      Color(0xFFE67E22),
      Color(0xFF27AE60),
      Color(0xFF9B59B6),
    ];
    Color designColor = colors[design['id'] % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [designColor, designColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.design_services, size: 30, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  design['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '${design['roomType'] ?? 'Custom Design'} • ${_formatDate(design['createdAt'])}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildCardMenu(design),
        ],
      ),
    );
  }

  Widget _buildFavoritesGallery() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the heart icon to save your favorite designs',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMenu(Map<String, dynamic> design) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(value, design),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text('Edit Design')),
        PopupMenuItem(value: 'share', child: Text('Share')),
        PopupMenuItem(value: 'favorite', child: Text('Add to Favorites')),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
      child: Icon(Icons.more_vert, color: Colors.grey[600]),
    );
  }

  // UPDATED MENU ACTION - Now actually deletes from database
  void _handleMenuAction(String action, Map<String, dynamic> design) async {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Editing ${design['name']}...')));
        break;
      case 'share':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sharing ${design['name']}...')));
        break;
      case 'favorite':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${design['name']} to favorites')),
        );
        break;
      case 'delete':
        // Show confirmation dialog
        bool? confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Design'),
            content: Text(
              'Are you sure you want to delete "${design['name']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          DatabaseHelper db = DatabaseHelper();
          await db.deleteDesign(design['id']);
          await _loadDesigns(); // Refresh the list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${design['name']} deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
    }
  }
}

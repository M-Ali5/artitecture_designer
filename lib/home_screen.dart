// ignore_for_file: deprecated_member_use, library_private_types_in_public_api
// home_screen.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'app_routes.dart';
import 'models/room_designer_args.dart';
import 'widgets/room_floor_preview.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;
  const HomeScreen({super.key, this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ADD THESE STATE VARIABLES
  int totalDesigns = 0;
  int inProgressDesigns = 0;
  int completedDesigns = 0;

  // Get user initials for avatar
  String get _userInitials {
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      return widget.userName![0].toUpperCase();
    }
    return 'U';
  }

  // Get display name
  String get _displayName {
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      return widget.userName![0].toUpperCase() + widget.userName!.substring(1);
    }
    return 'User';
  }

  final List<Map<String, dynamic>> recentProjects = [
    {
      'name': 'Modern Living Room',
      'date': '2024-01-15',
      'icon': Icons.weekend,
      'dimensions': '12x14 ft',
      'progress': 0.8,
      'color': Color(0xFF3498DB),
    },
    {
      'name': 'Cozy Bedroom',
      'date': '2024-01-10',
      'icon': Icons.bed,
      'dimensions': '10x12 ft',
      'progress': 0.6,
      'color': Color(0xFFE67E22),
    },
    {
      'name': 'Modern Kitchen',
      'date': '2024-01-05',
      'icon': Icons.kitchen,
      'dimensions': '8x10 ft',
      'progress': 0.4,
      'color': Color(0xFF27AE60),
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadStats(); // ADD THIS LINE - Load stats from database
  }

  // ADD THIS METHOD TO LOAD STATS FROM DATABASE
  Future<void> _loadStats() async {
    DatabaseHelper db = DatabaseHelper();
    totalDesigns = await db.getDesignCount();
    // Simple logic for in-progress and completed
    inProgressDesigns = totalDesigns > 0 ? 2 : 0;
    completedDesigns = totalDesigns > 2 ? totalDesigns - 2 : 0;
    setState(() {});
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  // Show notification dialog
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.notifications, color: Color(0xFF3498DB)),
            SizedBox(width: 10),
            Text('Notifications'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.red),
              title: Text('New Design Template Available!'),
              subtitle: Text('2 hours ago'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.weekend, color: Color(0xFFE67E22)),
              title: Text('Furniture Sale - 50% Off'),
              subtitle: Text('Yesterday'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.people, color: Color(0xFF27AE60)),
              title: Text('Join Design Community'),
              subtitle: Text('3 days ago'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Show template preview (single template — used by grid cards)
  void _showTemplatePreview(String templateName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$templateName Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3498DB), Color(0xFF2C3E50)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Icon(Icons.image, size: 60, color: Colors.white),
              ),
            ),
            SizedBox(height: 15),
            Text('Use this template to create your design quickly!'),
            SizedBox(height: 10),
            Text(
              'Includes: Wall layout, furniture placement, and color scheme',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening $templateName template...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3498DB)),
            child: Text('Use Template'),
          ),
        ],
      ),
    );
  }

  /// Quick Actions → Templates: pick from 3 curated templates
  void _showQuickTemplatesPicker() {
    final templates = <Map<String, Object>>[
      {
        'templateId': 'living',
        'name': 'Classic Living Hall',
        'subtitle': 'Crown molding · warm oak · starter layout included',
      },
      {
        'templateId': 'bedroom',
        'name': 'Cozy Bedroom Bay',
        'subtitle': 'Soft neutrals · bed & lamps · you set width × length',
      },
      {
        'templateId': 'kitchen',
        'name': 'Modern Kitchen Island',
        'subtitle': 'Clean lines · table & chairs preset',
      },
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.photo_library, color: Colors.white, size: 22),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pick a template',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          'Choose one — then enter room width & length (ft)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              ...templates.map((t) {
                final name = t['name'] as String;
                final subtitle = t['subtitle'] as String;
                final templateId = t['templateId'] as String;
                return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.templateRoomSetup,
                          arguments: TemplateSetupArgs(
                            templateId: templateId,
                            title: name,
                            subtitle: subtitle,
                          ),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RoomFloorPreview(
                                widthFt: 14,
                                lengthFt: 12,
                                templateId: templateId,
                                maxSide: 56,
                                compact: true,
                                showDimensionLabels: false,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      subtitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildWelcomeCard(),
                          SizedBox(height: 20),
                          _buildStatsSection(),
                          SizedBox(height: 20),
                          _buildQuickActions(),
                          SizedBox(height: 20),
                          _buildRecentProjects(),
                          SizedBox(height: 20),
                          _buildTemplatesSection(),
                          SizedBox(height: 20),
                          _buildMyTemplatesSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.roomDesigner);
        },
        backgroundColor: Color(0xFF3498DB),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3498DB).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(Icons.architecture, color: Colors.white, size: 24),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'InnoPlanner',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
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
          ),
          SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconButton(
                Icons.notifications_outlined,
                onTap: _showNotifications,
              ),
              SizedBox(width: 8),
              _buildIconButton(
                Icons.settings,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.settingsRoute);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Color(0xFF2C3E50)),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.white, Colors.white70]),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Text(
                _userInitials,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                    ).createShader(Rect.fromLTWH(0, 0, 50, 50)),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  _displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Premium Member',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED STATS SECTION - Now shows real data from database
  Widget _buildStatsSection() {
    return Row(
      children: [
        _buildStatCard(
          'Projects',
          totalDesigns.toString(),
          Icons.folder,
          Color(0xFF3498DB),
        ),
        SizedBox(width: 12),
        _buildStatCard(
          'In Progress',
          inProgressDesigns.toString(),
          Icons.hourglass_empty,
          Color(0xFFE67E22),
        ),
        SizedBox(width: 12),
        _buildStatCard(
          'Completed',
          completedDesigns.toString(),
          Icons.check_circle,
          Color(0xFF27AE60),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                Icons.weekend,
                'Furniture',
                Color(0xFF3498DB),
                () {
                  Navigator.pushNamed(context, AppRoutes.furnitureLibrary);
                },
              ),
              _buildActionItem(
                Icons.photo_library,
                'Templates',
                Color(0xFFE67E22),
                () {
                  _showQuickTemplatesPicker();
                },
              ),
              _buildActionItem(Icons.save, 'My Designs', Color(0xFF27AE60), () {
                Navigator.pushNamed(context, AppRoutes.gallery);
              }),
              _buildActionItem(
                Icons.auto_awesome,
                'AI Design',
                Color(0xFF9B59B6),
                () {
                  Navigator.pushNamed(context, AppRoutes.aiImage);
                },
              ),
              _buildActionItem(Icons.share, 'Export', Color(0xFF9B59B6), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export feature coming soon!')),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 25),
            onPressed: onTap,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                'Recent Projects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.gallery),
              child: Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF3498DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: recentProjects.length,
            itemBuilder: (context, index) {
              return _buildProjectCard(recentProjects[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(right: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: project['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(project['icon'], color: project['color'], size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      project['dimensions'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Last modified: ${project['date']}',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: project['progress'],
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(project['color']),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            'Popular Templates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            _buildTemplateCard('Living Room', Icons.weekend, Color(0xFF3498DB)),
            _buildTemplateCard('Bedroom', Icons.bed, Color(0xFFE67E22)),
            _buildTemplateCard('Kitchen', Icons.kitchen, Color(0xFF27AE60)),
            _buildTemplateCard('Bathroom', Icons.bathtub, Color(0xFF9B59B6)),
            _buildTemplateCard(
              'Office',
              Icons.business_center,
              Color(0xFF3498DB),
            ),
            _buildTemplateCard('Dining', Icons.restaurant, Color(0xFFE67E22)),
            _buildTemplateCard(
              'Classic Living',
              Icons.chair_outlined,
              Color(0xFF8E6E53),
            ),
            _buildTemplateCard(
              'Classic Bedroom',
              Icons.king_bed_outlined,
              Color(0xFF6B4F8A),
            ),
            _buildTemplateCard(
              'Classic Dining',
              Icons.table_restaurant_outlined,
              Color(0xFF7A5A3A),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTemplateCard(String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showTemplatePreview(name),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTemplatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            'My Templates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            _buildTemplateCard(
              'Classic Suite',
              Icons.chair_alt_outlined,
              Color(0xFF8E6E53),
            ),
            _buildTemplateCard(
              'Vintage Hall',
              Icons.living_outlined,
              Color(0xFF6B4F8A),
            ),
            _buildTemplateCard(
              'Royal Dining',
              Icons.table_bar_outlined,
              Color(0xFF7A5A3A),
            ),
          ],
        ),
      ],
    );
  }
}

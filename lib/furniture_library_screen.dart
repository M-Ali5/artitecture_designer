// ignore_for_file: deprecated_member_use, library_private_types_in_public_api
// furniture_library_screen.dart
import 'package:flutter/material.dart';

class FurnitureLibraryScreen extends StatefulWidget {
  const FurnitureLibraryScreen({super.key});

  @override
  _FurnitureLibraryScreenState createState() => _FurnitureLibraryScreenState();
}

class _FurnitureLibraryScreenState extends State<FurnitureLibraryScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> furnitureItems = [
    // Living Room
    {'name': 'Modern Sofa', 'category': 'Living Room', 'icon': Icons.weekend, 'color': 0xFF3498DB, 'price': '\$499', 'dimensions': '80" x 35"'},
    {'name': 'Coffee Table', 'category': 'Living Room', 'icon': Icons.table_restaurant, 'color': 0xFFE67E22, 'price': '\$199', 'dimensions': '48" x 24"'},
    {'name': 'TV Unit', 'category': 'Living Room', 'icon': Icons.tv, 'color': 0xFF27AE60, 'price': '\$299', 'dimensions': '60" x 18"'},
    {'name': 'Bookshelf', 'category': 'Living Room', 'icon': Icons.menu_book, 'color': 0xFF9B59B6, 'price': '\$159', 'dimensions': '36" x 12"'},

    // Bedroom
    {'name': 'Queen Bed', 'category': 'Bedroom', 'icon': Icons.bed, 'color': 0xFFE67E22, 'price': '\$799', 'dimensions': '60" x 80"'},
    {'name': 'Wardrobe', 'category': 'Bedroom', 'icon': Icons.door_back_door, 'color': 0xFF3498DB, 'price': '\$599', 'dimensions': '72" x 24"'},
    {'name': 'Nightstand', 'category': 'Bedroom', 'icon': Icons.table_restaurant, 'color': 0xFF27AE60, 'price': '\$129', 'dimensions': '24" x 18"'},
    {'name': 'Dresser', 'category': 'Bedroom', 'icon': Icons.draw, 'color': 0xFF9B59B6, 'price': '\$349', 'dimensions': '60" x 20"'},

    // Dining
    {'name': 'Dining Table', 'category': 'Dining', 'icon': Icons.table_restaurant, 'color': 0xFFE67E22, 'price': '\$399', 'dimensions': '72" x 36"'},
    {'name': 'Dining Chair', 'category': 'Dining', 'icon': Icons.chair, 'color': 0xFF3498DB, 'price': '\$89', 'dimensions': '20" x 20"'},
    {'name': 'Buffet Cabinet', 'category': 'Dining', 'icon': Icons.cabin, 'color': 0xFF27AE60, 'price': '\$449', 'dimensions': '60" x 18"'},
    {'name': 'Bar Stool', 'category': 'Dining', 'icon': Icons.chair, 'color': 0xFF9B59B6, 'price': '\$79', 'dimensions': '18" x 18"'},

    // Office
    {'name': 'Office Desk', 'category': 'Office', 'icon': Icons.table_restaurant, 'color': 0xFF3498DB, 'price': '\$299', 'dimensions': '60" x 30"'},
    {'name': 'Office Chair', 'category': 'Office', 'icon': Icons.chair, 'color': 0xFFE67E22, 'price': '\$199', 'dimensions': '26" x 26"'},
    {'name': 'Filing Cabinet', 'category': 'Office', 'icon': Icons.cabin, 'color': 0xFF27AE60, 'price': '\$149', 'dimensions': '18" x 24"'},
    {'name': 'Bookcase', 'category': 'Office', 'icon': Icons.menu_book, 'color': 0xFF9B59B6, 'price': '\$179', 'dimensions': '36" x 12"'},

    // Kitchen
    {'name': 'Kitchen Cabinet', 'category': 'Kitchen', 'icon': Icons.kitchen, 'color': 0xFF3498DB, 'price': '\$399', 'dimensions': '36" x 24"'},
    {'name': 'Kitchen Island', 'category': 'Kitchen', 'icon': Icons.table_restaurant, 'color': 0xFFE67E22, 'price': '\$599', 'dimensions': '48" x 36"'},
    {'name': 'Kitchen Table', 'category': 'Kitchen', 'icon': Icons.table_restaurant, 'color': 0xFF27AE60, 'price': '\$249', 'dimensions': '48" x 30"'},
    {'name': 'Bar Stool', 'category': 'Kitchen', 'icon': Icons.chair, 'color': 0xFF9B59B6, 'price': '\$69', 'dimensions': '16" x 16"'},

    // Outdoor
    {'name': 'Patio Set', 'category': 'Outdoor', 'icon': Icons.weekend, 'color': 0xFF3498DB, 'price': '\$699', 'dimensions': '72" x 72"'},
    {'name': 'Lounge Chair', 'category': 'Outdoor', 'icon': Icons.chair, 'color': 0xFFE67E22, 'price': '\$149', 'dimensions': '28" x 32"'},
    {'name': 'Umbrella', 'category': 'Outdoor', 'icon': Icons.beach_access, 'color': 0xFF27AE60, 'price': '\$89', 'dimensions': '96" x 96"'},
    {'name': 'Planter', 'category': 'Outdoor', 'icon': Icons.yard, 'color': 0xFF9B59B6, 'price': '\$49', 'dimensions': '18" x 18"'},
  ];

  List<Map<String, dynamic>> get filteredItems {
    return furnitureItems.where((item) {
      final matchesCategory = selectedCategory == 'All' || item['category'] == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          item['name'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get categories {
    return ['All', ...furnitureItems.map((e) => e['category'] as String).toSet()];
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
              _buildAppBar(context),
              _buildSearchBar(),
              _buildCategoryFilter(),
              Expanded(
                child: _buildFurnitureGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8)],
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
              gradient: LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF3498DB)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.weekend, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Furniture Library',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                  ).createShader(Rect.fromLTWH(0, 0, 200, 30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search furniture...',
          prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: EdgeInsets.all(20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [Color(0xFF3498DB), Color(0xFF2C3E50)])
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? Color(0xFF3498DB).withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF2C3E50),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFurnitureGrid() {
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No furniture found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final color = Color(item['color']);

        return LongPressDraggable<Map<String, dynamic>>(
          data: item,
          feedback: Material(
            elevation: 8,
            color: Colors.transparent,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    item['name'],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: _buildFurnitureCard(item, color),
          ),
          child: _buildFurnitureCard(item, color),
        );
      },
    );
  }

  Widget _buildFurnitureCard(Map<String, dynamic> item, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'], size: 50, color: color),
          ),
          SizedBox(height: 12),
          Text(
            item['name'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 4),
          Text(
            item['category'],
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            item['price'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.straighten, size: 12, color: color),
                SizedBox(width: 4),
                Text(
                  item['dimensions'],
                  style: TextStyle(fontSize: 10, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
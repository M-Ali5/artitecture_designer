// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/innoplanner.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE designs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        roomType TEXT,
        dimensions TEXT,
        furnitureData TEXT,
        imagePath TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }

  // Save a new design
  Future<int> saveDesign(Map<String, dynamic> design) async {
    Database db = await database;
    design['createdAt'] = DateTime.now().toString();
    design['updatedAt'] = DateTime.now().toString();
    return await db.insert('designs', design);
  }

  // Get all designs
  Future<List<Map<String, dynamic>>> getAllDesigns() async {
    Database db = await database;
    return await db.query('designs', orderBy: 'createdAt DESC');
  }

  // Get design by ID
  Future<Map<String, dynamic>?> getDesignById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'designs',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update a design
  Future<int> updateDesign(int id, Map<String, dynamic> design) async {
    Database db = await database;
    design['updatedAt'] = DateTime.now().toString();
    return await db.update('designs', design, where: 'id = ?', whereArgs: [id]);
  }

  // Delete a design
  Future<int> deleteDesign(int id) async {
    Database db = await database;
    return await db.delete('designs', where: 'id = ?', whereArgs: [id]);
  }

  // Get count of designs
  Future<int> getDesignCount() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM designs');
    return result.first['count'] as int;
  }

  // Search designs by name
  Future<List<Map<String, dynamic>>> searchDesigns(String query) async {
    Database db = await database;
    return await db.query(
      'designs',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'createdAt DESC',
    );
  }
}
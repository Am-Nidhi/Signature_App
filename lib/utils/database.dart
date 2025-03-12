import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';

class DatabaseHelper {
  static Database? _database;

  // Create a singleton database instance
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    // If the database is null, open or create the database
    _database = await openDatabase(
      join(await getDatabasesPath(), 'signature_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE signatures(id INTEGER PRIMARY KEY, base64 STRING, image BLOB)",
        );
      },
      version: 1,
    );
    return _database!;
  }

  // Save signature to SQLite (both base64 and BLOB)
  static Future<void> saveSignature(String base64String, Uint8List imageData) async {
    final db = await getDatabase();
    await db.insert(
      'signatures',
      {
        'base64': base64String,
        'image': imageData,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all signatures from the database
  static Future<List<Map<String, dynamic>>> getSignatures() async {
    final db = await getDatabase();
    return await db.query('signatures');
  }
}

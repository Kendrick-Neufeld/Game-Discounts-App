import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            email TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE wishlist (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            juego_id INTEGER NOT NULL,
            usuario_id INTEGER NOT NULL,
            FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
          );
        ''');
      },
    );
  }

  Future<void> insertUser(String username, String password, String email) async {
    final db = await database;
    await db.insert('usuarios', {
      'username': username,
      'password': password,
      'email': email,
    });
  }

  Future<List<Map<String, dynamic>>> getWishlist(int userId) async {
    final db = await database;
    return await db.query(
      'wishlist',
      where: 'usuario_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> addGameToWishlist(int juegoId, int userId) async {
    final db = await database;
    await db.insert('wishlist', {
      'juego_id': juegoId,
      'usuario_id': userId,
    });
  }
}

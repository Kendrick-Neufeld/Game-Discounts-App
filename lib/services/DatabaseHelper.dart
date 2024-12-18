import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            email TEXT NOT NULL,
            profile_picture BLOB
          );
        ''');
        await db.execute('''
         CREATE TABLE wishlist (
           id_wishlist INTEGER PRIMARY KEY AUTOINCREMENT,
           juego_id INTEGER NOT NULL,
           usuario_id INTEGER NOT NULL,
           FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
           UNIQUE (juego_id, usuario_id) -- Evita duplicados
         );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE usuarios ADD COLUMN profile_picture BLOB');
        }
      },
    );
  }

  Future<void> insertUser(String username, String password, String email, Uint8List? profilePicture) async {
    final db = await database;
    await db.insert('usuarios', {
      'username': username,
      'password': password,
      'email': email,
      'profile_picture': profilePicture,
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

  Future<void> addGameToWishlist(int gameId, int userId) async {
    final db = await database;

    // Verificar si el juego ya está en la wishlist
    final existingGame = await db.query(
      'wishlist',
      where: 'juego_id = ? AND usuario_id = ?',
      whereArgs: [gameId, userId],
    );

    if (existingGame.isEmpty) {
      // Si no existe, insertar el juego
      await db.insert(
        'wishlist',
        {
          'juego_id': gameId,
          'usuario_id': userId,
        },
      );
    } else {
      // Juego ya existe, manejar el caso (opcional)
      throw Exception('Este juego ya está en tu wishlist.');
    }
  }

  Future<void> removeGameFromWishlist(int gameId, int userId) async {
    final db = await database;
    int result = await db.delete(
      'wishlist',
      where: 'juego_id = ? AND usuario_id = ?',
      whereArgs: [gameId, userId],
    );
    print('Filas eliminadas: $result'); // Esto debería mostrar 1 si la eliminación fue exitosa
  }

  // Obtener los gameIds de la wishlist del usuario
  Future<List<int>> getWishlistGameIds(int userId) async {
    final db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist',
      columns: ['juego_id'],
      where: 'usuario_id = ?',
      whereArgs: [userId],
    );

    // Convertimos la lista de Map a una lista de gameIds (enteros)
    return List.generate(maps.length, (i) {
      return maps[i]['juego_id'];
    });
  }


  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'usuarios',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<void> updateUser(User updatedUser) async {
    final db = await database;

    await db.update(
      'usuarios', // Nombre de la tabla
      {
        'username': updatedUser.username,
        'password': updatedUser.password,
        'email': updatedUser.email,
        'profile_picture': updatedUser.profilePicture,
      },
      where: 'id = ?', // Condición para identificar el usuario que queremos actualizar
      whereArgs: [updatedUser.id], // El id del usuario que queremos actualizar
    );
  }
}

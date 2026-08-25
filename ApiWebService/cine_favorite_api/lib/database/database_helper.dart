import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cinefavorite.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Chave primária composta para evitar conflito entre filmes e séries
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER NOT NULL,
        mediaType TEXT NOT NULL,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        posterPath TEXT NOT NULL,
        tmdbRating REAL NOT NULL,
        userRating REAL NOT NULL,
        PRIMARY KEY (id, mediaType, userId)
      )
    ''');
  }

  // Adiciona o filme/série garantindo a passagem do userId correto
  Future<int> insertFavorite(Movie movie, String userId) async {
    final db = await instance.database;
    final mapData = movie.toMap();
    mapData['userId'] = userId; // Sobrescreve/garante que userId não seja nulo

    return await db.insert(
      'favorites',
      mapData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Remove um item dos favoritos do usuário ativo
  Future<int> removeFavorite(int id, String mediaType, String userId) async {
    final db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'id = ? AND mediaType = ? AND userId = ?',
      whereArgs: [id, mediaType, userId],
    );
  }

  // Lista todos os favoritos gravados para o usuário atual
  Future<List<Movie>> getFavoritesByUser(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return maps.map((map) => Movie.fromMap(map)).toList();
  }

  // Atualiza a nota local atribuída pelo usuário
  Future<int> updateUserRating(int id, String mediaType, String userId, double newRating) async {
    final db = await instance.database;
    return await db.update(
      'favorites',
      {'userRating': newRating},
      where: 'id = ? AND mediaType = ? AND userId = ?',
      whereArgs: [id, mediaType, userId],
    );
  }

  // Verifica se o item já foi favoritado pelo usuário
  Future<bool> isFavorite(int id, String mediaType, String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'id = ? AND mediaType = ? AND userId = ?',
      whereArgs: [id, mediaType, userId],
    );
    return result.isNotEmpty;
  }
}
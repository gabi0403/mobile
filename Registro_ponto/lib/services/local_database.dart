import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/local_user.dart';
import '../models/point_record.dart';

enum LocalDatabaseError { emailAlreadyExists }

class LocalDatabaseException implements Exception {
  const LocalDatabaseException(this.code);

  final LocalDatabaseError code;
}

class LocalDatabase {
  LocalDatabase._();

  static final instance = LocalDatabase._();
  static const _databaseName = 'registro_ponto.db';
  Future<Database>? _database;

  Future<Database> get database => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: 1,
      onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_salt TEXT NOT NULL,
            password_hash TEXT NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE app_session (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            user_id INTEGER NOT NULL REFERENCES users(id)
          )
        ''');
        await database.execute('''
          CREATE TABLE point_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL REFERENCES users(id),
            email TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            registered_at INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            accuracy_meters REAL NOT NULL,
            distance_meters REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<LocalUser?> currentUser() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT users.id, users.email
      FROM users
      INNER JOIN app_session ON app_session.user_id = users.id
      WHERE app_session.id = 1
      LIMIT 1
    ''');
    if (rows.isEmpty) return null;
    return LocalUser(
      id: rows.first['id']! as int,
      email: rows.first['email']! as String,
    );
  }

  Future<LocalUser> createUser({
    required String email,
    required String passwordSalt,
    required String passwordHash,
  }) async {
    final db = await database;
    return db.transaction((transaction) async {
      final existing = await transaction.query(
        'users',
        columns: ['id'],
        where: 'email = ? COLLATE NOCASE',
        whereArgs: [email],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        throw const LocalDatabaseException(
          LocalDatabaseError.emailAlreadyExists,
        );
      }
      final id = await transaction.insert('users', {
        'email': email,
        'password_salt': passwordSalt,
        'password_hash': passwordHash,
      });
      await transaction.insert('app_session', {
        'id': 1,
        'user_id': id,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return LocalUser(id: id, email: email);
    });
  }

  Future<Map<String, Object?>?> userCredentials(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? COLLATE NOCASE',
      whereArgs: [email],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> setSession(int userId) async {
    final db = await database;
    await db.insert('app_session', {
      'id': 1,
      'user_id': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete('app_session', where: 'id = 1');
  }

  Future<void> insertPoint({
    required LocalUser user,
    required String date,
    required String time,
    required DateTime registeredAt,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required double distanceMeters,
  }) async {
    final db = await database;
    await db.insert('point_records', {
      'user_id': user.id,
      'email': user.email,
      'date': date,
      'time': time,
      'registered_at': registeredAt.millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy_meters': accuracyMeters,
      'distance_meters': distanceMeters,
    });
  }

  Future<List<PointRecord>> recentRecords(int userId) async {
    final db = await database;
    final rows = await db.query(
      'point_records',
      columns: ['date', 'time', 'latitude', 'longitude', 'distance_meters'],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'registered_at DESC',
      limit: 5,
    );
    return rows.map(PointRecord.fromMap).toList();
  }
}

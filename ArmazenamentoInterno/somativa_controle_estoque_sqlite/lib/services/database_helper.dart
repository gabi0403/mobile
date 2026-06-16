import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Padrão Singleton
  static final DatabaseHelper instancia = DatabaseHelper._iniciar();
  static Database? _banco;

  DatabaseHelper._iniciar();

  Future<Database> get banco async {
    if (_banco != null) return _banco!;
    _banco = await _iniciarBanco();
    return _banco!;
  }

  Future<Database> _iniciarBanco() async {
    final caminhoBanco = await getDatabasesPath();
    final caminho = join(caminhoBanco, 'estoque.db');

    return await openDatabase(
      caminho,
      version: 1,
      onCreate: _criarBanco,
      onConfigure: _configurarBanco,
    );
  }

  // Habilita chaves estrangeiras (FOREIGN KEYS) no SQLite
  Future<void> _configurarBanco(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _criarBanco(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        preco_custo REAL NOT NULL,
        preco_venda REAL NOT NULL,
        quantidade_atual INTEGER NOT NULL DEFAULT 0,
        codigo TEXT UNIQUE NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE movimentacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produto_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        data TEXT NOT NULL,
        observacao TEXT,
        FOREIGN KEY (produto_id) REFERENCES produtos (id) ON DELETE CASCADE
      )
    ''');
  }
}
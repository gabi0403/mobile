import 'package:path/path.dart';
import 'package:sa_formativa_petshop_sqlite/model/consulta_model.dart';
import 'package:sa_formativa_petshop_sqlite/model/pet_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  //classe do tipo singleton (permite o instanciamento de um obj por vez)
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  //essa classe não possui um construtor normal
  //ela precisa do factory para estabelece a conexão com o banco de dados
  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  // com essa técnica de escrita de construtor, a classe permite a criação de apenas um obj por vez

  //Conector do danco de bados
  Database? _database; //privado

  //método get da conexão
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb(); //se nao existir inicia uma nova
    return _database!;
  }

  Future<Database> _initDb() async {
    // começar a conexão com o banco
    String path = join(await getDatabasesPath(), "petshop_db");
    return await openDatabase(
      path,
      version: 1,
      // a primeira vez que for rodar o banco , cria as tabelas
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE pets(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          nome TEXT, raca TEXT, 
          nomeDono TEXT, 
          telefone TEXT)''');
        await db.execute('''CREATE TABLE consultas(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          petId INTEGER, 
          tipoServico TEXT, 
          dataHora TEXT, 
          observacoes TEXT,
          FOREIGN KEY(petId) REFERENCES pets(id) ON DELETE CASCADE)''');
      },
      onConfigure: (db) async => await db.execute(
        "PRAGMA foreign_key = ON",
      ), //garante o delete on cascade
    );
  }
  //métodos do CRUD simplificados

  //inserir pet
  Future<int> insertPet(Pet pet) async => (await database).insert("pets", pet.toMap());

  //Listar Pets do DB
  Future<List<Pet>> getPets() async {
    //busca os pets no banco e retrona uma lista em ordem alfabetica
    final List<Map<String, dynamic>> maps = await (await database).query("pets", orderBy: "nome ASC");
    return List.generate(maps.length, (e) => Pet.fromMap(maps[e]));
  }

  // inserir Consulta
  Future<int> insertConsulta(Consulta c) async => (await database).insert("consultas", c.toMap());

  //Get Consulta por Pet
  Future<List<Consulta>> getConsultaPorPet(int petId) async{
    final List<Map<String,dynamic>> maps = await (await database).query("consultas", where: "petId = ?", whereArgs: [petId], orderBy: "dataHora DESC" );
    return List.generate(maps.length, (e)=>Consulta.fromMap(maps[e]));
  }
}

//ajudante de conexão com o dataBase(DB)
import 'package:exemplo_sqflite/nota_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotaDbhelper {
  //atributos
  static const String db_nome = "notas.db";
  static const String table_nome = "notas";
  static const String create_table = 
    """CREATE TABLE IF NOT EXIST $table_nome(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo TEXT NOT NULL,
    conteudo TEXT NOT NULL)""";

  //método de conexão do aplicativo ao banco de dados
  //método do tipo future (async) vai retornar o banco de dados
  Future<Database> _getDB() async{ //async
    return openDatabase(
      //colocar o endereço do DB
      join(await getDatabasesPath(), db_nome),
      onCreate: (db, version){ // se é a primeira vez que esta sendo executado, ele ira criar o DB
        return db.execute(create_table);
      },
      version: 1,
      );
  }// retorna o banco de dados no final 


// CRUD do Banco de Dados (Controller)

//create
void create(Nota nota) async{
    try {
      final Database db = await _getDB();
      await db.insert(table_nome, nota.toMap()); //insere o dado no banco
    } catch (e) {
      print(e);
      return;
    }
  }

//read

  Future<List<Nota>> getNotas() async{
    try {
      final Database db = await _getDB(); // estabelece a conexão
      final List<Map<String,dynamic>> maps = await db.query(table_nome);//pega todos os dados do banco
      //converter o MAP em List<Nota>
      return List.generate(maps.length, (e) => Nota.fromMap(maps[e]));//retorna a lista com os OBJ
    } catch (e) {
      print(e); //mostre o erro
      return []; //retorna uma lista vazia
    }
  }

//Update
  void updateNota(Nota nota) async{
    try {
      final Database db = await _getDB();
      await db.update(table_nome, nota.toMap(), where: "id = ?", whereArgs: [nota.id]);
      //atualiza a nota a partir do id
    } catch (e) {
      print(e);
      return;
    }
  }

// Delete
  void deleteNota (int id) async{
    try {
      final Database db = await _getDB();
      await db.delete(table_nome, where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print(e);
      return;
      
    }
  }
}
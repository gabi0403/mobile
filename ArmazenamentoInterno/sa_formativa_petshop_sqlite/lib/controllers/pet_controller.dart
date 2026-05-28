import 'package:sa_formativa_petshop_sqlite/model/pet_model.dart';
import 'package:sa_formativa_petshop_sqlite/service/database_helper.dart';

class PetController {
  // atributo para estabelecer conexão com o banco
  final _dbHelper = DatabaseHelper();

  // métodos dos controller
  //salvar pet
  Future<int> salvarPet(Pet pet) async => _dbHelper.insertPet(pet);

  Future<List<Pet>> listarTodos() async => _dbHelper.getPets();

  // tá faltando update e delete //
  
}

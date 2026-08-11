import 'package:biblioteca_app_json/model/user_model.dart';
import 'package:biblioteca_app_json/service/api_service.dart';

class UserController {
  // não precisa instanciar obj de service => Static

  //métodos
  //ler
  Future<List<UserModel>> fetchAll() async {
    final list = await ApiService.getList(
      "users?_sort=name",
    ); //?_sort=name => flag para organizar em ordem alfabetica por nome
    //retorna a lista de usuarios convertidos para UserModel
    return list.map<UserModel>((item) => UserModel.fromMap(item)).toList();
  }

  //criar
  Future<UserModel> create(UserModel u) async {
    final created = await ApiService.post("user", u.toMap());
    //add um usuario e retorna o usuario criado -> ID
    return UserModel.fromMap(created);
  }

  //atualizar
  Future<UserModel> update(UserModel u) async {
    final updated = await ApiService.put("users", u.toMap(), u.id!);
    //envia a atualização do usuario e retorna o usuario atualizado do banco
    return UserModel.fromMap(updated);
  }

  //deletar
  Future<void> delete(String id) async {
    await ApiService.delete("user", id);// se nao der certo gera uma exception
  }
}

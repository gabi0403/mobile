import 'package:biblioteca_app_json/model/loan_model.dart';
import 'package:biblioteca_app_json/service/api_service.dart';

class LoanController {
  // Não precisa instanciar a ApiService porque seus métodos são static.

  // Ler todos os empréstimos
  Future<List<LoanModel>> fetchAll() async {
    final list = await ApiService.getList('loans?_sort=loanDate');

    return list.map<LoanModel>((item) => LoanModel.fromMap(item)).toList();
  }

  // Criar um empréstimo
  Future<LoanModel> create(LoanModel loan) async {
    final created = await ApiService.post('loans', loan.toMap());
    return LoanModel.fromMap(created);
  }

  // Atualizar um empréstimo
  Future<LoanModel> update(LoanModel loan) async {
    final updated = await ApiService.put('loans', loan.toMap(), loan.id!);
    return LoanModel.fromMap(updated);
  }

  //Deletar um empréstimo
  // Future<void> delete(String id) async {
  //   await ApiService.delete('loans', id);
  // }
}

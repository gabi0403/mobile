import 'package:biblioteca_app_json/model/book_model.dart';
import 'package:biblioteca_app_json/model/user_model.dart';

class LoanModel {
  //atributos
  final String? id;
  final UserModel user;
  final BookModel book;
  final DateTime startDate;
  final DateTime dueDate;
  final bool returned;

  //construtor
  LoanModel({
    this.id,
    required this.user,
    required this.book,
    required this.startDate,
    required this.dueDate,
    required this.returned
  });

  //métodos ToMap e FromMap
  Map<String,dynamic> toMap() =>{
    "id":id,
    "userId":user.toMap(),
    "bookId":book.toMap(),
    "startDate":startDate.toIso8601String(),
    "dueDate":dueDate.toIso8601String(),
    "returned":returned
  };

  factory LoanModel.fromMap(Map<String,dynamic> map)=> 
  LoanModel(
    id: map["id"].toString(),
    user: UserModel.fromMap(map["userId"]),
    book: BookModel.fromMap(map["bookId"]),
    startDate: DateTime.parse(map["startDate"].toString()),
    dueDate: DateTime.parse(map["dueDate"].toString()),
    returned: map["returned"] == true ? true : false
  );
}

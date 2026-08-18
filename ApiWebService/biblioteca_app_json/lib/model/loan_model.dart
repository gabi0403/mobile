import 'package:biblioteca_app_json/model/book_model.dart';
import 'package:biblioteca_app_json/model/user_model.dart';

class LoanModel {
  final String? id;
  final UserModel? user;
  final BookModel? book;
  final DateTime startDate;
  final DateTime dueDate;
  final bool returned;

  LoanModel({
    this.id,
    this.user,
    this.book,
    required this.startDate,
    required this.dueDate,
    required this.returned,
  });

  Map<String, dynamic> toMap() => {
    "id": id,
    "userId": user?.id,
    "bookId": book?.id,
    "startDate": startDate.toIso8601String(),
    "dueDate": dueDate.toIso8601String(),
    "loanDate": startDate.toIso8601String(),
    "returnDate": dueDate.toIso8601String(),
    "returned": returned,
  };

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    final userId = map["userId"];
    final bookId = map["bookId"];
    final startValue = map["startDate"] ?? map["loanDate"] ?? '2024-01-01';
    final dueValue = map["dueDate"] ?? map["returnDate"] ?? '2024-01-08';

    final parsedUser = userId == null
        ? UserModel(id: null, name: 'Usuário não informado', email: '')
        : userId is Map<String, dynamic>
        ? UserModel.fromMap(userId)
        : UserModel(
            id: userId.toString(),
            name: 'Usuário não informado',
            email: '',
          );

    final parsedBook = bookId == null
        ? BookModel(
            id: null,
            title: 'Livro não informado',
            author: '',
            available: true,
          )
        : bookId is Map<String, dynamic>
        ? BookModel.fromMap(bookId)
        : BookModel(
            id: bookId.toString(),
            title: 'Livro não informado',
            author: '',
            available: true,
          );

    return LoanModel(
      id: map["id"]?.toString(),
      user: parsedUser,
      book: parsedBook,
      startDate: DateTime.tryParse(startValue.toString()) ?? DateTime.now(),
      dueDate: DateTime.tryParse(dueValue.toString()) ?? DateTime.now(),
      returned: map["returned"] == true,
    );
  }
}

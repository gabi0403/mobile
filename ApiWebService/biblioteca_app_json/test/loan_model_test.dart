import 'package:biblioteca_app_json/model/book_model.dart';
import 'package:biblioteca_app_json/model/loan_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'LoanModel.fromMap aceita IDs nulas e strings vindas do json-server',
    () {
      final loan = LoanModel.fromMap({
        'id': '1',
        'userId': null,
        'bookId': '2',
        'loanDate': '2024-01-10',
        'returnDate': '2024-01-17',
        'returned': false,
      });

      expect(loan.user?.name, 'Usuário não informado');
      expect(loan.book?.title, 'Livro não informado');
      expect(loan.startDate, DateTime(2024, 1, 10));
      expect(loan.dueDate, DateTime(2024, 1, 17));
    },
  );

  test('BookModel.fromMap aceita o campo available', () {
    final book = BookModel.fromMap({
      'id': '2',
      'title': 'Duna',
      'author': 'Frank Herbert',
      'available': true,
    });

    expect(book.available, isTrue);
  });
}

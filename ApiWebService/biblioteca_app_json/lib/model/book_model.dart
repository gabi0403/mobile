class BookModel {
  final String? id;
  final String title;
  final String author;
  final bool available;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    required this.available,
  });

  bool get avaliable => available;

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "author": author,
    "available": available,
    "avaliable": available,
  };

  factory BookModel.fromMap(Map<String, dynamic> map) {
    final rawAvailable = map["available"] ?? map["avaliable"] ?? false;

    return BookModel(
      id: map["id"]?.toString(),
      title: map["title"]?.toString() ?? 'Livro não informado',
      author: map["author"]?.toString() ?? '',
      available: rawAvailable == true,
    );
  }
}

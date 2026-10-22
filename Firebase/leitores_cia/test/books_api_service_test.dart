import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:leitores_cia/services/books_api_service.dart';

void main() {
  group('GoogleBooksApiService', () {
    test('pesquisa por autor e interpreta metadados disponíveis', () async {
      late Uri requestedUri;
      final service = GoogleBooksApiService(
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'id': 'google-book-1',
                  'volumeInfo': {
                    'title': 'Duna',
                    'authors': ['Frank Herbert'],
                    'pageCount': 412,
                    'imageLinks': {
                      'thumbnail': 'http://books.example/cover.jpg',
                    },
                  },
                },
              ],
            }),
            200,
          );
        }),
      );

      final books = await service.search('Frank Herbert', filter: 'author');

      expect(requestedUri.scheme, 'https');
      expect(requestedUri.queryParameters['q'], 'inauthor:Frank Herbert');
      expect(books, hasLength(1));
      expect(books.single.googleBooksId, 'google-book-1');
      expect(books.single.title, 'Duna');
      expect(books.single.authors, ['Frank Herbert']);
      expect(books.single.pageCount, 412);
      expect(books.single.thumbnailUrl, 'https://books.example/cover.jpg');
    });

    test(
      'aceita volumes sem metadados opcionais e descarta ID ausente',
      () async {
        final service = GoogleBooksApiService(
          client: MockClient((_) async {
            return http.Response(
              jsonEncode({
                'items': [
                  {'id': 'book-without-details'},
                  {
                    'volumeInfo': {'title': 'Sem ID'},
                  },
                ],
              }),
              200,
            );
          }),
        );

        final books = await service.search('livro');

        expect(books, hasLength(1));
        expect(books.single.title, 'Sem título');
        expect(books.single.authorsDisplay, 'Autor desconhecido');
        expect(books.single.pageCount, 0);
        expect(books.single.thumbnailUrl, isEmpty);
      },
    );

    test('retorna lista vazia para termo menor que dois caracteres', () async {
      var requestMade = false;
      final service = GoogleBooksApiService(
        client: MockClient((_) async {
          requestMade = true;
          return http.Response('{}', 200);
        }),
      );

      expect(await service.search(' a '), isEmpty);
      expect(requestMade, isFalse);
    });

    test('apresenta erro compreensível para falha de rede', () async {
      final service = GoogleBooksApiService(
        client: MockClient((_) async {
          throw http.ClientException('offline');
        }),
      );

      await expectLater(
        service.search('Duna'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Verifique sua conexão'),
          ),
        ),
      );
    });

    test('apresenta erro para resposta JSON inválida', () async {
      final service = GoogleBooksApiService(
        client: MockClient((_) async => http.Response('{', 200)),
      );

      await expectLater(
        service.search('Duna'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('resposta inválida'),
          ),
        ),
      );
    });
  });
}

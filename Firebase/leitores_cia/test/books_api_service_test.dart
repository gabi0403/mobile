import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:leitores_cia/services/books_api_service.dart';

void main() {
  group('OpenLibraryApiService', () {
    test('pesquisa por autor e interpreta metadados da Open Library', () async {
      late Uri requestedUri;
      final service = OpenLibraryApiService(
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'numFound': 1,
              'docs': [
                {
                  'key': '/works/OL893414W',
                  'title': 'Duna',
                  'author_name': ['Frank Herbert'],
                  'first_publish_year': 1965,
                  'number_of_pages_median': 412,
                  'cover_i': 11481354,
                },
              ],
            }),
            200,
          );
        }),
      );

      final books = await service.search('Frank Herbert', filter: 'author');

      expect(requestedUri.scheme, 'https');
      expect(requestedUri.host, 'openlibrary.org');
      expect(requestedUri.path, '/search.json');
      expect(requestedUri.queryParameters['author'], 'Frank Herbert');
      expect(requestedUri.queryParameters['limit'], '20');
      expect(requestedUri.queryParameters.containsKey('key'), isFalse);
      expect(books, hasLength(1));
      expect(books.single.id, 'OL893414W');
      expect(books.single.googleBooksId, 'OL893414W');
      expect(books.single.openLibraryId, 'OL893414W');
      expect(books.single.title, 'Duna');
      expect(books.single.authors, ['Frank Herbert']);
      expect(books.single.pageCount, 412);
      expect(books.single.publishYear, 1965);
      expect(
        books.single.thumbnailUrl,
        'https://covers.openlibrary.org/b/id/11481354-M.jpg',
      );
    });

    test('pesquisa por título usa parâmetro title sem chave de API', () async {
      late Uri requestedUri;
      final service = OpenLibraryApiService(
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'numFound': 0,
              'docs': [],
            }),
            200,
          );
        }),
      );

      final results = await service.search('Duna', filter: 'title');

      expect(results, isEmpty);
      expect(requestedUri.queryParameters['title'], 'Duna');
      expect(requestedUri.queryParameters['limit'], '20');
      expect(requestedUri.queryParameters.containsKey('key'), isFalse);
    });

    test('pesquisa geral (filtro all) usa parâmetro q', () async {
      late Uri requestedUri;
      final service = OpenLibraryApiService(
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'numFound': 0,
              'docs': [],
            }),
            200,
          );
        }),
      );

      await service.search('Ficção Científica', filter: 'all');

      expect(requestedUri.queryParameters['q'], 'Ficção Científica');
      expect(requestedUri.queryParameters['limit'], '20');
      expect(requestedUri.queryParameters.containsKey('key'), isFalse);
    });

    test('suporta capa alternativa por cover_edition_key (OLID)', () async {
      final service = OpenLibraryApiService(
        client: MockClient((_) async {
          return http.Response(
            jsonEncode({
              'numFound': 1,
              'docs': [
                {
                  'key': '/works/OL25310926W',
                  'title': 'DUNA',
                  'cover_edition_key': 'OL33897308M',
                },
              ],
            }),
            200,
          );
        }),
      );

      final books = await service.search('Duna');

      expect(books, hasLength(1));
      expect(
        books.single.thumbnailUrl,
        'https://covers.openlibrary.org/b/olid/OL33897308M-M.jpg',
      );
    });

    test(
      'aceita documentos sem metadados opcionais e descarta ID ausente',
      () async {
        final service = OpenLibraryApiService(
          client: MockClient((_) async {
            return http.Response(
              jsonEncode({
                'docs': [
                  {'key': '/works/book-without-details'},
                  {'title': 'Sem ID'},
                ],
              }),
              200,
            );
          }),
        );

        final books = await service.search('livro');

        expect(books, hasLength(1));
        expect(books.single.id, 'book-without-details');
        expect(books.single.title, 'Sem título');
        expect(books.single.authorsDisplay, 'Autor desconhecido');
        expect(books.single.pageCount, 0);
        expect(books.single.publishYear, isNull);
        expect(books.single.thumbnailUrl, isEmpty);
      },
    );

    test('retorna lista vazia para termo menor que dois caracteres', () async {
      var requestMade = false;
      final service = OpenLibraryApiService(
        client: MockClient((_) async {
          requestMade = true;
          return http.Response('{"docs":[]}', 200);
        }),
      );

      expect(await service.search(' a '), isEmpty);
      expect(requestMade, isFalse);
    });

    test('apresenta erro compreensível para falha de rede', () async {
      final service = OpenLibraryApiService(
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
      final service = OpenLibraryApiService(
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

    test(
      'apresenta mensagem amigável para limite temporário HTTP 429',
      () async {
        final service = OpenLibraryApiService(
          client: MockClient((_) async => http.Response('{}', 429)),
        );

        await expectLater(
          service.search('Duna'),
          throwsA(
            isA<Exception>()
                .having(
                  (error) => error.toString(),
                  'message',
                  contains('muitas buscas'),
                )
                .having(
                  (error) => error.toString(),
                  'message',
                  contains('tente novamente'),
                ),
          ),
        );
      },
    );

    test('GoogleBooksApiService mantém retrocompatibilidade delegando à Open Library', () async {
      final service = GoogleBooksApiService(
        apiKey: 'chave-antiga-ignorada',
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'docs': [
                {
                  'key': '/works/OL123W',
                  'title': 'Obra Legada',
                },
              ],
            }),
            200,
          );
        }),
      );

      final books = await service.search('Duna');
      expect(books, hasLength(1));
      expect(books.single.title, 'Obra Legada');
    });
  });
}

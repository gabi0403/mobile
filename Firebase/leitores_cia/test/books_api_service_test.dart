import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
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

    test('envia a chave configurada como parâmetro da requisição', () async {
      late Uri requestedUri;
      final service = GoogleBooksApiService(
        apiKey: 'test-google-books-key-not-real',
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response('{}', 200);
        }),
      );

      await service.search('Duna', filter: 'title');

      expect(
        requestedUri.queryParameters['key'],
        'test-google-books-key-not-real',
      );
      expect(requestedUri.queryParameters['q'], 'intitle:Duna');
      expect(requestedUri.queryParameters['maxResults'], '20');
    });

    test('omite chave quando nenhuma chave está configurada', () async {
      late Uri requestedUri;
      final service = GoogleBooksApiService(
        apiKey: '',
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response('{}', 200);
        }),
      );

      await service.search('Frank Herbert', filter: 'author');

      expect(requestedUri.queryParameters.containsKey('key'), isFalse);
      expect(requestedUri.queryParameters['q'], 'inauthor:Frank Herbert');
      expect(requestedUri.queryParameters['maxResults'], '20');
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

    test(
      'apresenta mensagem amigável para limite temporário HTTP 429',
      () async {
        final service = GoogleBooksApiService(
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
                )
                .having(
                  (error) => error.toString(),
                  'message',
                  isNot(contains('error.message')),
                ),
          ),
        );
      },
    );

    test(
      'registra só os campos selecionados e sanitiza diagnóstico HTTP 429',
      () async {
        final previousDebugPrint = debugPrint;
        final diagnosticLines = <String>[];
        debugPrint = (message, {wrapWidth}) {
          if (message != null) diagnosticLines.add(message);
        };

        try {
          final service = GoogleBooksApiService(
            apiKey: 'test-api-key-not-real',
            client: MockClient(
              (_) async => http.Response(
                jsonEncode({
                  'error': {
                    'code': 429,
                    'message':
                        'Quota exceeded for test-api-key-not-real '
                        'at https://example.test/private?key=secret '
                        'for reader@example.test',
                    'errors': [
                      {'reason': 'rateLimitExceeded', 'domain': 'books'},
                      {'message': 'unselected detail'},
                    ],
                    'status': 'RESOURCE_EXHAUSTED',
                  },
                }),
                429,
              ),
            ),
          );

          await expectLater(service.search('Duna'), throwsA(isA<Exception>()));

          expect(diagnosticLines, hasLength(1));
          final diagnostic = diagnosticLines.single;
          expect(diagnostic, contains('HTTP 429'));
          expect(diagnostic, contains('error.code: 429'));
          expect(diagnostic, contains('Quota exceeded'));
          expect(diagnostic, contains('rateLimitExceeded'));
          expect(diagnostic, isNot(contains('test-api-key-not-real')));
          expect(diagnostic, isNot(contains('https://')));
          expect(diagnostic, isNot(contains('secret')));
          expect(diagnostic, isNot(contains('reader@example.test')));
          expect(diagnostic, isNot(contains('unselected detail')));
          expect(diagnostic, isNot(contains('RESOURCE_EXHAUSTED')));
        } finally {
          debugPrint = previousDebugPrint;
        }
      },
    );
  });
}

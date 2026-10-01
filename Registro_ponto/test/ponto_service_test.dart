import 'package:flutter_test/flutter_test.dart';
import 'package:registro_ponto/services/ponto_service.dart';

void main() {
  group('PontoService.isWithinAllowedRadius', () {
    test('permite a distância exata de 100 metros', () {
      expect(PontoService.isWithinAllowedRadius(100), isTrue);
    });

    test('bloqueia distâncias superiores a 100 metros', () {
      expect(PontoService.isWithinAllowedRadius(100.01), isFalse);
    });
  });
}
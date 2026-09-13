import 'package:app_mppb_flutter/features/carteira/models/usuario_carteira.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserva data de posse no parse e no cache da carteira', () {
    final usuario = UsuarioCarteira.fromJson({
      'nome': 'Fulano de Tal',
      'matricula': 12345,
      'tipoCargo': 'M',
      'dataPosse': '2020-03-04T00:00:00.000+00:00',
    });

    expect(usuario.dataPosse, '2020-03-04T00:00:00.000+00:00');
    expect(usuario.toJson()['dataPosse'], '2020-03-04T00:00:00.000+00:00');
  });

  test('aceita data de posse numerica quando backend serializa timestamp', () {
    final usuario = UsuarioCarteira.fromJson({
      'nome': 'Fulano de Tal',
      'dataPosse': 1583280000000,
    });

    expect(usuario.dataPosse, '1583280000000');
  });
}

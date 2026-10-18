import 'package:app_mppb_flutter/features/perfil/models/preferencias_notificacao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantem todas as categorias habilitadas por padrao', () {
    final preferencias = PreferenciasNotificacao.fromJson(const {});

    expect(preferencias.noticias, isTrue);
    expect(preferencias.designacoes, isTrue);
    expect(preferencias.contracheques, isTrue);
    expect(preferencias.pagamentos, isTrue);
    expect(preferencias.afastamentos, isTrue);
  });

  test('altera somente a categoria selecionada', () {
    const preferencias = PreferenciasNotificacao();

    final atualizadas = preferencias.copyWith(contracheques: false);

    expect(atualizadas.contracheques, isFalse);
    expect(atualizadas.noticias, isTrue);
    expect(atualizadas.designacoes, isTrue);
    expect(atualizadas.pagamentos, isTrue);
    expect(atualizadas.afastamentos, isTrue);
  });
}

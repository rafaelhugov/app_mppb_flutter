import 'package:app_mppb_flutter/features/perfil/models/preferencias_notificacao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'mantem os dois canais de todas as categorias habilitados por padrao',
    () {
      final preferencias = PreferenciasNotificacao.fromJson(const {});

      expect(preferencias.pushNoticias, isTrue);
      expect(preferencias.pushDesignacoes, isTrue);
      expect(preferencias.pushContracheques, isTrue);
      expect(preferencias.pushPagamentos, isTrue);
      expect(preferencias.pushAfastamentos, isTrue);
      expect(preferencias.centralNoticias, isTrue);
      expect(preferencias.centralDesignacoes, isTrue);
      expect(preferencias.centralContracheques, isTrue);
      expect(preferencias.centralPagamentos, isTrue);
      expect(preferencias.centralAfastamentos, isTrue);
    },
  );

  test('altera push sem alterar a central da mesma categoria', () {
    const preferencias = PreferenciasNotificacao();

    final atualizadas = preferencias.copyWith(pushContracheques: false);

    expect(atualizadas.pushContracheques, isFalse);
    expect(atualizadas.centralContracheques, isTrue);
    expect(atualizadas.pushNoticias, isTrue);
    expect(atualizadas.centralNoticias, isTrue);
  });

  test('interpreta as preferencias antigas nos dois canais', () {
    final preferencias = PreferenciasNotificacao.fromJson(const {
      'noticias': false,
      'designacoes': true,
    });

    expect(preferencias.pushNoticias, isFalse);
    expect(preferencias.centralNoticias, isFalse);
    expect(preferencias.pushDesignacoes, isTrue);
    expect(preferencias.centralDesignacoes, isTrue);
  });
}

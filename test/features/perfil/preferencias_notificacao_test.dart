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
      expect(preferencias.pushLives, isTrue);
      expect(preferencias.centralNoticias, isTrue);
      expect(preferencias.centralDesignacoes, isTrue);
      expect(preferencias.centralContracheques, isTrue);
      expect(preferencias.centralPagamentos, isTrue);
      expect(preferencias.centralAfastamentos, isTrue);
      expect(preferencias.centralLives, isTrue);
    },
  );

  test('altera push sem alterar a central da mesma categoria', () {
    const preferencias = PreferenciasNotificacao();

    final atualizadas = preferencias.copyWith(
      pushContracheques: false,
      pushLives: false,
    );

    expect(atualizadas.pushContracheques, isFalse);
    expect(atualizadas.centralContracheques, isTrue);
    expect(atualizadas.pushLives, isFalse);
    expect(atualizadas.centralLives, isTrue);
    expect(atualizadas.pushNoticias, isTrue);
    expect(atualizadas.centralNoticias, isTrue);
  });

  test('toApiJson envia estritamente os 10 campos aceitos pelo backend', () {
    const preferencias = PreferenciasNotificacao(
      pushLives: false,
      centralLives: false,
    );

    final apiJson = preferencias.toApiJson();
    expect(apiJson.length, 10);
    expect(apiJson.containsKey('pushLives'), isFalse);
    expect(apiJson.containsKey('centralLives'), isFalse);

    final localJson = preferencias.toJson();
    expect(localJson.length, 12);
    expect(localJson['pushLives'], isFalse);
    expect(localJson['centralLives'], isFalse);
  });

  test('interpreta as preferencias antigas nos dois canais', () {
    final preferencias = PreferenciasNotificacao.fromJson(const {
      'noticias': false,
      'designacoes': true,
      'lives': false,
    });

    expect(preferencias.pushNoticias, isFalse);
    expect(preferencias.centralNoticias, isFalse);
    expect(preferencias.pushDesignacoes, isTrue);
    expect(preferencias.centralDesignacoes, isTrue);
    expect(preferencias.pushLives, isFalse);
    expect(preferencias.centralLives, isFalse);
  });
}

import 'package:app_mppb_flutter/features/mensagens/data/mensagens_repository.dart';
import 'package:app_mppb_flutter/features/mensagens/models/grupo_mensagem_model.dart';
import 'package:app_mppb_flutter/features/mensagens/ui/pages/grupos_personalizados_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGruposRepo extends MensagensRepository {
  _FakeGruposRepo() : super(Dio());

  final List<GrupoPersonalizadoModel> _grupos = [
    const GrupoPersonalizadoModel(
      id: 1,
      nome: 'Comissão de Segurança',
      descricao: 'Grupo da comissão',
      quantidadeMembros: 2,
      matriculas: ['101', '102'],
    ),
  ];

  @override
  Future<List<GrupoPersonalizadoModel>> listarGruposPersonalizados() async {
    return [..._grupos];
  }

  @override
  Future<void> removerGrupoPersonalizado(int id) async {
    _grupos.removeWhere((g) => g.id == id);
  }
}

void main() {
  testWidgets(
    'GruposPersonalizadosPage lista e permite remover grupo personalizado',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mensagensRepositoryProvider.overrideWithValue(_FakeGruposRepo()),
          ],
          child: const MaterialApp(home: GruposPersonalizadosPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Comissão de Segurança'), findsOneWidget);
      expect(find.textContaining('2 participante(s)'), findsOneWidget);

      await tester.tap(find.byTooltip('Remover grupo'));
      await tester.pumpAndSettle();

      expect(
        find.text('Nenhum grupo personalizado cadastrado.'),
        findsOneWidget,
      );
    },
  );
}


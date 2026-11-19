import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mensagens_repository.dart';
import '../models/grupo_mensagem_model.dart';

class GruposMensagemNotifier
    extends AsyncNotifier<List<GrupoPersonalizadoModel>> {
  @override
  Future<List<GrupoPersonalizadoModel>> build() async {
    return ref.read(mensagensRepositoryProvider).listarGruposPersonalizados();
  }

  Future<void> recarregar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(mensagensRepositoryProvider).listarGruposPersonalizados(),
    );
  }

  Future<void> criar({
    required String nome,
    String? descricao,
    required List<String> matriculas,
  }) async {
    await ref.read(mensagensRepositoryProvider).criarGrupoPersonalizado(
          nome: nome,
          descricao: descricao,
          matriculas: matriculas,
        );
    await recarregar();
  }

  Future<void> atualizar(
    int id, {
    required String nome,
    String? descricao,
    required List<String> matriculas,
  }) async {
    await ref.read(mensagensRepositoryProvider).atualizarGrupoPersonalizado(
          id,
          nome: nome,
          descricao: descricao,
          matriculas: matriculas,
        );
    await recarregar();
  }

  Future<void> remover(int id) async {
    await ref.read(mensagensRepositoryProvider).removerGrupoPersonalizado(id);
    await recarregar();
  }
}

final gruposMensagemProvider = AsyncNotifierProvider<
    GruposMensagemNotifier, List<GrupoPersonalizadoModel>>(
  GruposMensagemNotifier.new,
);


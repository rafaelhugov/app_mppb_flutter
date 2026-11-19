import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mensagens_repository.dart';
import '../models/acompanhamento_mensagem_model.dart';
import '../models/mensagem_aviso_model.dart';

class AcompanhamentoFiltro {
  const AcompanhamentoFiltro({
    required this.mensagemId,
    this.status,
    this.busca = '',
  });

  final int mensagemId;
  final StatusDestinatario? status;
  final String busca;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcompanhamentoFiltro &&
          other.mensagemId == mensagemId &&
          other.status == status &&
          other.busca == busca;

  @override
  int get hashCode => Object.hash(mensagemId, status, busca);
}

final acompanhamentoMensagemProvider = FutureProvider.family<
    AcompanhamentoMensagemModel, AcompanhamentoFiltro>((ref, filtro) async {
  return ref.read(mensagensRepositoryProvider).acompanharMensagem(
        filtro.mensagemId,
        status: filtro.status,
        busca: filtro.busca,
      );
});


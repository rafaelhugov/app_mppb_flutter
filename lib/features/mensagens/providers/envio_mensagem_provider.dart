import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mensagens_repository.dart';
import '../models/acompanhamento_mensagem_model.dart';
import '../models/grupo_mensagem_model.dart';
import '../models/mensagem_anexo_model.dart';
import '../models/mensagem_aviso_model.dart';

class EnvioMensagemState {
  const EnvioMensagemState({
    this.titulo = '',
    this.conteudo = '',
    this.prioridade = PrioridadeMensagem.normal,
    this.modalidade = ModalidadeEnvio.broadcast,
    this.exigeCiencia = false,
    this.tiposCargo = const [],
    this.orgaoIds = const [],
    this.setorIds = const [],
    this.cargoIds = const [],
    this.grupoPersonalizadoIds = const [],
    this.destinatariosUnicast = const [],
    this.anexos = const [],
    this.dataAgendamento,
    this.dataExpiracao,
    this.totalEstimado,
    this.calculandoPrevia = false,
    this.enviandoAnexo = false,
    this.enviandoMensagem = false,
    this.errorMessage,
  });

  final String titulo;
  final String conteudo;
  final PrioridadeMensagem prioridade;
  final ModalidadeEnvio modalidade;
  final bool exigeCiencia;
  final List<String> tiposCargo;
  final List<int> orgaoIds;
  final List<int> setorIds;
  final List<int> cargoIds;
  final List<int> grupoPersonalizadoIds;
  final List<DestinatarioRhModel> destinatariosUnicast;
  final List<MensagemAnexoModel> anexos;
  final DateTime? dataAgendamento;
  final DateTime? dataExpiracao;
  final int? totalEstimado;
  final bool calculandoPrevia;
  final bool enviandoAnexo;
  final bool enviandoMensagem;
  final String? errorMessage;

  bool get possuiConteudoOuMidia =>
      conteudo.trim().isNotEmpty || anexos.isNotEmpty;

  Map<String, dynamic> toCriteriosJson() {
    return {
      'tiposCargo': tiposCargo,
      'orgaoIds': orgaoIds,
      'setorIds': setorIds,
      'cargoIds': cargoIds,
      'grupoPersonalizadoIds': grupoPersonalizadoIds,
      'matriculas': destinatariosUnicast.map((d) => d.matricula).toList(),
    };
  }

  EnvioMensagemState copyWith({
    String? titulo,
    String? conteudo,
    PrioridadeMensagem? prioridade,
    ModalidadeEnvio? modalidade,
    bool? exigeCiencia,
    List<String>? tiposCargo,
    List<int>? orgaoIds,
    List<int>? setorIds,
    List<int>? cargoIds,
    List<int>? grupoPersonalizadoIds,
    List<DestinatarioRhModel>? destinatariosUnicast,
    List<MensagemAnexoModel>? anexos,
    DateTime? dataAgendamento,
    bool clearAgendamento = false,
    DateTime? dataExpiracao,
    bool clearExpiracao = false,
    int? totalEstimado,
    bool? calculandoPrevia,
    bool? enviandoAnexo,
    bool? enviandoMensagem,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EnvioMensagemState(
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      prioridade: prioridade ?? this.prioridade,
      modalidade: modalidade ?? this.modalidade,
      exigeCiencia: exigeCiencia ?? this.exigeCiencia,
      tiposCargo: tiposCargo ?? this.tiposCargo,
      orgaoIds: orgaoIds ?? this.orgaoIds,
      setorIds: setorIds ?? this.setorIds,
      cargoIds: cargoIds ?? this.cargoIds,
      grupoPersonalizadoIds:
          grupoPersonalizadoIds ?? this.grupoPersonalizadoIds,
      destinatariosUnicast: destinatariosUnicast ?? this.destinatariosUnicast,
      anexos: anexos ?? this.anexos,
      dataAgendamento:
          clearAgendamento ? null : (dataAgendamento ?? this.dataAgendamento),
      dataExpiracao:
          clearExpiracao ? null : (dataExpiracao ?? this.dataExpiracao),
      totalEstimado: totalEstimado ?? this.totalEstimado,
      calculandoPrevia: calculandoPrevia ?? this.calculandoPrevia,
      enviandoAnexo: enviandoAnexo ?? this.enviandoAnexo,
      enviandoMensagem: enviandoMensagem ?? this.enviandoMensagem,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class EnvioMensagemNotifier extends Notifier<EnvioMensagemState> {
  static const Duration margemMinimaExpiracao = Duration(hours: 1);

  @override
  EnvioMensagemState build() => const EnvioMensagemState();

  void resetar() => state = const EnvioMensagemState();

  void setTitulo(String v) => state = state.copyWith(titulo: v, clearError: true);

  void setConteudo(String v) =>
      state = state.copyWith(conteudo: v, clearError: true);

  void setPrioridade(PrioridadeMensagem p) =>
      state = state.copyWith(prioridade: p);

  void setExigeCiencia(bool v) => state = state.copyWith(exigeCiencia: v);

  DateTime dataBaseEnvio() {
    final agora = DateTime.now();
    final ag = state.dataAgendamento;
    if (ag != null && ag.isAfter(agora)) {
      return ag;
    }
    return agora;
  }

  /// Atualiza a data de agendamento e limpa uma expiração que fique com
  /// margem menor que 1 hora após o envio agendado.
  bool setDataAgendamento(DateTime? dt) {
    var limparExpiracao = false;
    if (dt != null && state.dataExpiracao != null) {
      if (state.dataExpiracao!.isBefore(dt.add(margemMinimaExpiracao))) {
        limparExpiracao = true;
      }
    }
    state = state.copyWith(
      dataAgendamento: dt,
      clearAgendamento: dt == null,
      clearExpiracao: limparExpiracao,
      clearError: true,
    );
    return limparExpiracao;
  }

  /// Define a data de expiração garantindo margem mínima de 1 hora após o envio.
  bool setDataExpiracao(DateTime? dt) {
    if (dt == null) {
      state = state.copyWith(clearExpiracao: true, clearError: true);
      return true;
    }
    final minimo = dataBaseEnvio().add(margemMinimaExpiracao);
    if (dt.isBefore(minimo)) {
      state = state.copyWith(
        errorMessage:
            'A data de expiração deve ter pelo menos 1 hora de margem após o envio.',
      );
      return false;
    }
    state = state.copyWith(
      dataExpiracao: dt,
      clearError: true,
    );
    return true;
  }

  Future<void> setModalidade(ModalidadeEnvio m) async {
    state = state.copyWith(modalidade: m, clearError: true);
    await atualizarPreviaAlcance();
  }

  Future<void> atualizarCriteriosMulticast({
    List<String>? tiposCargo,
    List<int>? orgaoIds,
    List<int>? setorIds,
    List<int>? cargoIds,
    List<int>? grupoPersonalizadoIds,
  }) async {
    state = state.copyWith(
      tiposCargo: tiposCargo ?? state.tiposCargo,
      orgaoIds: orgaoIds ?? state.orgaoIds,
      setorIds: setorIds ?? state.setorIds,
      cargoIds: cargoIds ?? state.cargoIds,
      grupoPersonalizadoIds:
          grupoPersonalizadoIds ?? state.grupoPersonalizadoIds,
      clearError: true,
    );
    await atualizarPreviaAlcance();
  }

  Future<void> definirDestinatariosUnicast(
    List<DestinatarioRhModel> lista,
  ) async {
    state = state.copyWith(destinatariosUnicast: lista, clearError: true);
    await atualizarPreviaAlcance();
  }

  Future<void> atualizarPreviaAlcance() async {
    state = state.copyWith(calculandoPrevia: true);
    try {
      final repo = ref.read(mensagensRepositoryProvider);
      final total = await repo.previaAlcance(
        modalidade: state.modalidade,
        criterios: state.toCriteriosJson(),
      );
      state = state.copyWith(totalEstimado: total, calculandoPrevia: false);
    } catch (_) {
      state = state.copyWith(calculandoPrevia: false);
    }
  }

  Future<MensagemAnexoModel?> uploadAnexo(
    File arquivo, {
    int? duracaoSegundos,
  }) async {
    state = state.copyWith(enviandoAnexo: true, clearError: true);
    try {
      final repo = ref.read(mensagensRepositoryProvider);
      final anexo = await repo.uploadAnexo(
        arquivo,
        duracaoSegundos: duracaoSegundos,
      );
      state = state.copyWith(
        enviandoAnexo: false,
        anexos: [...state.anexos, anexo],
      );
      return anexo;
    } catch (_) {
      state = state.copyWith(
        enviandoAnexo: false,
        errorMessage: 'Não foi possível enviar o arquivo/mídia selecionado.',
      );
      return null;
    }
  }

  void adicionarAnexoPreCarregado(MensagemAnexoModel anexo) {
    state = state.copyWith(anexos: [...state.anexos, anexo], clearError: true);
  }

  void removerAnexo(int anexoId) {
    state = state.copyWith(
      anexos: state.anexos.where((a) => a.id != anexoId).toList(),
    );
  }

  Future<MensagemEnviadaModel?> enviar() async {
    if (!state.possuiConteudoOuMidia) {
      state = state.copyWith(
        errorMessage:
            'Informe um texto ou adicione ao menos uma mídia/áudio/documento.',
      );
      return null;
    }

    if (state.dataExpiracao != null &&
        state.dataExpiracao!.isBefore(
          dataBaseEnvio().add(margemMinimaExpiracao),
        )) {
      state = state.copyWith(
        errorMessage:
            'A data de expiração deve ter pelo menos 1 hora de margem após o envio.',
      );
      return null;
    }

    state = state.copyWith(enviandoMensagem: true, clearError: true);
    try {
      final repo = ref.read(mensagensRepositoryProvider);
      final enviada = await repo.enviarOuAgendar(
        titulo: state.titulo.trim().isEmpty ? null : state.titulo.trim(),
        conteudo: state.conteudo.trim().isEmpty ? null : state.conteudo.trim(),
        prioridade: state.prioridade,
        modalidade: state.modalidade,
        exigeCiencia: state.exigeCiencia,
        criterios: state.toCriteriosJson(),
        anexoIds: state.anexos.map((a) => a.id).toList(),
        dataAgendamento: state.dataAgendamento,
        dataExpiracao: state.dataExpiracao,
      );
      state = const EnvioMensagemState();
      return enviada;
    } catch (_) {
      state = state.copyWith(
        enviandoMensagem: false,
        errorMessage:
            'Falha ao publicar o aviso. Verifique os destinatários e tente novamente.',
      );
      return null;
    }
  }
}

final envioMensagemProvider =
    NotifierProvider<EnvioMensagemNotifier, EnvioMensagemState>(
      EnvioMensagemNotifier.new,
    );


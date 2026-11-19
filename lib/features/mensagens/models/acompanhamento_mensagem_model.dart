import 'mensagem_anexo_model.dart';
import 'mensagem_aviso_model.dart';

class MensagemEnviadaModel {
  const MensagemEnviadaModel({
    required this.id,
    this.titulo,
    this.conteudo,
    required this.prioridade,
    required this.modalidade,
    required this.exigeCiencia,
    required this.statusPublicacao,
    this.dataAgendamento,
    this.dataEnvio,
    this.dataExpiracao,
    this.arquivadaRemetente = false,
    required this.totalDestinatarios,
    required this.totalEntregues,
    required this.totalLidos,
    required this.totalCientes,
    required this.totalPendentes,
    this.anexos = const [],
  });

  final int id;
  final String? titulo;
  final String? conteudo;
  final PrioridadeMensagem prioridade;
  final ModalidadeEnvio modalidade;
  final bool exigeCiencia;
  final String statusPublicacao;
  final DateTime? dataAgendamento;
  final DateTime? dataEnvio;
  final DateTime? dataExpiracao;
  final bool arquivadaRemetente;
  final int totalDestinatarios;
  final int totalEntregues;
  final int totalLidos;
  final int totalCientes;
  final int totalPendentes;
  final List<MensagemAnexoModel> anexos;

  factory MensagemEnviadaModel.fromJson(Map<String, dynamic> json) {
    final anexosRaw = (json['anexos'] as List<dynamic>?) ?? const [];
    return MensagemEnviadaModel(
      id: (json['id'] as num).toInt(),
      titulo: json['titulo'] as String?,
      conteudo: json['conteudo'] as String?,
      prioridade: PrioridadeMensagem.fromApi(json['prioridade'] as String?),
      modalidade: ModalidadeEnvio.fromApi(json['modalidade'] as String?),
      exigeCiencia: (json['exigeCiencia'] as bool?) ?? false,
      statusPublicacao: (json['statusPublicacao'] as String?) ?? 'ENVIADA',
      dataAgendamento: _parseDate(json['dataAgendamento']),
      dataEnvio: _parseDate(json['dataEnvio']),
      dataExpiracao: _parseDate(json['dataExpiracao']),
      arquivadaRemetente: (json['arquivadaRemetente'] as bool?) ?? false,
      totalDestinatarios: (json['totalDestinatarios'] as num?)?.toInt() ?? 0,
      totalEntregues: (json['totalEntregues'] as num?)?.toInt() ?? 0,
      totalLidos: (json['totalLidos'] as num?)?.toInt() ?? 0,
      totalCientes: (json['totalCientes'] as num?)?.toInt() ?? 0,
      totalPendentes: (json['totalPendentes'] as num?)?.toInt() ?? 0,
      anexos: anexosRaw
          .map((e) => MensagemAnexoModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}

class DestinatarioStatusModel {
  const DestinatarioStatusModel({
    required this.matricula,
    required this.nome,
    this.setor,
    required this.status,
    this.dataEntrega,
    this.dataLeitura,
    this.dataCiencia,
  });

  final String matricula;
  final String nome;
  final String? setor;
  final StatusDestinatario status;
  final DateTime? dataEntrega;
  final DateTime? dataLeitura;
  final DateTime? dataCiencia;

  factory DestinatarioStatusModel.fromJson(Map<String, dynamic> json) {
    return DestinatarioStatusModel(
      matricula: (json['matricula'] as String?) ?? '',
      nome: (json['nome'] as String?) ?? '',
      setor: json['setor'] as String?,
      status: StatusDestinatario.fromApi(json['status'] as String?),
      dataEntrega: MensagemEnviadaModel._parseDate(json['dataEntrega']),
      dataLeitura: MensagemEnviadaModel._parseDate(json['dataLeitura']),
      dataCiencia: MensagemEnviadaModel._parseDate(json['dataCiencia']),
    );
  }
}

class AcompanhamentoMensagemModel {
  const AcompanhamentoMensagemModel({
    required this.resumo,
    required this.destinatarios,
    required this.pagina,
    required this.tamanho,
    required this.totalElementos,
    required this.totalPaginas,
  });

  final MensagemEnviadaModel resumo;
  final List<DestinatarioStatusModel> destinatarios;
  final int pagina;
  final int tamanho;
  final int totalElementos;
  final int totalPaginas;

  factory AcompanhamentoMensagemModel.fromJson(Map<String, dynamic> json) {
    final destRaw = (json['destinatarios'] as List<dynamic>?) ?? const [];
    return AcompanhamentoMensagemModel(
      resumo: MensagemEnviadaModel.fromJson(
        Map<String, dynamic>.from(json['resumo'] as Map),
      ),
      destinatarios: destRaw
          .map((e) => DestinatarioStatusModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pagina: (json['pagina'] as num?)?.toInt() ?? 0,
      tamanho: (json['tamanho'] as num?)?.toInt() ?? 30,
      totalElementos: (json['totalElementos'] as num?)?.toInt() ?? 0,
      totalPaginas: (json['totalPaginas'] as num?)?.toInt() ?? 0,
    );
  }
}


import 'mensagem_anexo_model.dart';

enum PrioridadeMensagem {
  normal('NORMAL', 'Normal'),
  importante('IMPORTANTE', 'Importante'),
  urgente('URGENTE', 'Urgente');

  const PrioridadeMensagem(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static PrioridadeMensagem fromApi(String? value) {
    final normalized = value?.trim().toUpperCase();
    return PrioridadeMensagem.values.firstWhere(
      (e) => e.apiValue == normalized,
      orElse: () => PrioridadeMensagem.normal,
    );
  }
}

enum ModalidadeEnvio {
  broadcast('BROADCAST', 'Broadcast'),
  multicast('MULTICAST', 'Multicast'),
  unicast('UNICAST', 'Unicast');

  const ModalidadeEnvio(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static ModalidadeEnvio fromApi(String? value) {
    final normalized = value?.trim().toUpperCase();
    return ModalidadeEnvio.values.firstWhere(
      (e) => e.apiValue == normalized,
      orElse: () => ModalidadeEnvio.broadcast,
    );
  }
}

enum StatusDestinatario {
  pendente('PENDENTE'),
  entregue('ENTREGUE'),
  lido('LIDO');

  const StatusDestinatario(this.apiValue);
  final String apiValue;

  static StatusDestinatario fromApi(String? value) {
    final normalized = value?.trim().toUpperCase();
    return StatusDestinatario.values.firstWhere(
      (e) => e.apiValue == normalized,
      orElse: () => StatusDestinatario.pendente,
    );
  }
}

class MensagemAvisoModel {
  const MensagemAvisoModel({
    required this.id,
    this.titulo,
    this.conteudo,
    required this.prioridade,
    required this.modalidade,
    required this.exigeCiencia,
    this.remetenteNome,
    this.remetenteMatricula,
    this.dataEnvio,
    this.dataExpiracao,
    required this.status,
    this.dataEntrega,
    this.dataLeitura,
    this.dataCiencia,
    this.arquivada = false,
    this.anexos = const [],
  });

  final int id;
  final String? titulo;
  final String? conteudo;
  final PrioridadeMensagem prioridade;
  final ModalidadeEnvio modalidade;
  final bool exigeCiencia;
  final String? remetenteNome;
  final String? remetenteMatricula;
  final DateTime? dataEnvio;
  final DateTime? dataExpiracao;
  final StatusDestinatario status;
  final DateTime? dataEntrega;
  final DateTime? dataLeitura;
  final DateTime? dataCiencia;
  final bool arquivada;
  final List<MensagemAnexoModel> anexos;

  bool get naoLida => status != StatusDestinatario.lido;
  bool get pendenteCiencia => exigeCiencia && dataCiencia == null;

  factory MensagemAvisoModel.fromJson(Map<String, dynamic> json) {
    final anexosRaw = (json['anexos'] as List<dynamic>?) ?? const [];
    return MensagemAvisoModel(
      id: (json['id'] as num).toInt(),
      titulo: json['titulo'] as String?,
      conteudo: json['conteudo'] as String?,
      prioridade: PrioridadeMensagem.fromApi(json['prioridade'] as String?),
      modalidade: ModalidadeEnvio.fromApi(json['modalidade'] as String?),
      exigeCiencia: (json['exigeCiencia'] as bool?) ?? false,
      remetenteNome: json['remetenteNome'] as String?,
      remetenteMatricula: json['remetenteMatricula']?.toString(),
      dataEnvio: _parseDate(json['dataEnvio']),
      dataExpiracao: _parseDate(json['dataExpiracao']),
      status: StatusDestinatario.fromApi(json['status'] as String?),
      dataEntrega: _parseDate(json['dataEntrega']),
      dataLeitura: _parseDate(json['dataLeitura']),
      dataCiencia: _parseDate(json['dataCiencia']),
      arquivada: (json['arquivada'] as bool?) ?? false,
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

class CaixaEntradaPageModel {
  const CaixaEntradaPageModel({
    required this.itens,
    required this.pagina,
    required this.tamanho,
    required this.totalElementos,
    required this.totalPaginas,
    required this.totalNaoLidas,
  });

  final List<MensagemAvisoModel> itens;
  final int pagina;
  final int tamanho;
  final int totalElementos;
  final int totalPaginas;
  final int totalNaoLidas;

  factory CaixaEntradaPageModel.fromJson(Map<String, dynamic> json) {
    final itensRaw = (json['itens'] as List<dynamic>?) ?? const [];
    return CaixaEntradaPageModel(
      itens: itensRaw
          .map((e) => MensagemAvisoModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pagina: (json['pagina'] as num?)?.toInt() ?? 0,
      tamanho: (json['tamanho'] as num?)?.toInt() ?? 20,
      totalElementos: (json['totalElementos'] as num?)?.toInt() ?? 0,
      totalPaginas: (json['totalPaginas'] as num?)?.toInt() ?? 0,
      totalNaoLidas: (json['totalNaoLidas'] as num?)?.toInt() ?? 0,
    );
  }
}


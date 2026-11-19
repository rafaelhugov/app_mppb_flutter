import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/acompanhamento_mensagem_model.dart';
import '../models/grupo_mensagem_model.dart';
import '../models/mensagem_anexo_model.dart';
import '../models/mensagem_aviso_model.dart';

final mensagensRepositoryProvider = Provider<MensagensRepository>((ref) {
  return MensagensRepository(ref.read(dioProvider));
});

class MensagensRepository {
  MensagensRepository(this._dio);

  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  String anexoConteudoUrl(int mensagemId, int anexoId) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$base/api/mensagens/$mensagemId/anexos/$anexoId/conteudo';
  }

  String anexoThumbnailUrl(int mensagemId, int anexoId) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$base/api/mensagens/$mensagemId/anexos/$anexoId/thumbnail';
  }

  Future<bool> verificarPermissaoAdmin() async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/mensagens/permissao-admin');
    return (resp.data?['podeEnviar'] as bool?) ?? false;
  }

  // --- Destinatário ---

  Future<CaixaEntradaPageModel> listarRecebidas({
    String filtro = 'TODAS',
    int pagina = 0,
    int tamanho = 20,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/mensagens/recebidas',
      queryParameters: {
        'filtro': filtro,
        'pagina': pagina,
        'tamanho': tamanho,
      },
    );
    return CaixaEntradaPageModel.fromJson(resp.data ?? const {});
  }

  Future<void> confirmarEntregaEmLote(List<int> mensagemIds) async {
    if (mensagemIds.isEmpty) return;
    await _dio.post<void>(
      '/api/mensagens/recebidas/confirmar-entrega',
      data: {'mensagemIds': mensagemIds},
    );
  }

  Future<MensagemAvisoModel> abrirMensagem(int id) async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/mensagens/recebidas/$id');
    return MensagemAvisoModel.fromJson(resp.data ?? const {});
  }

  Future<MensagemAvisoModel> confirmarCiencia(int id) async {
    final resp = await _dio.post<Map<String, dynamic>>('/api/mensagens/recebidas/$id/ciencia');
    return MensagemAvisoModel.fromJson(resp.data ?? const {});
  }

  Future<void> arquivarRecebida(int id, {bool arquivada = true}) async {
    await _dio.patch<void>(
      '/api/mensagens/recebidas/$id/arquivar',
      queryParameters: {'arquivada': arquivada},
    );
  }

  Future<List<int>> baixarAnexoBytes(int mensagemId, int anexoId) async {
    final resp = await _dio.get<List<int>>(
      '/api/mensagens/$mensagemId/anexos/$anexoId/conteudo',
      options: Options(responseType: ResponseType.bytes),
    );
    return resp.data ?? const [];
  }

  // --- Remetente (Admin) ---

  Future<int> previaAlcance({
    required ModalidadeEnvio modalidade,
    Map<String, dynamic>? criterios,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/mensagens/admin/previa-alcance',
      data: {
        'modalidade': modalidade.apiValue,
        'criterios': criterios,
      },
    );
    return (resp.data?['totalEstimado'] as num?)?.toInt() ?? 0;
  }

  Future<MensagemAnexoModel> uploadAnexo(
    File arquivo, {
    int? duracaoSegundos,
    void Function(int sent, int total)? onProgress,
  }) async {
    final nome = arquivo.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'arquivo': await MultipartFile.fromFile(arquivo.path, filename: nome),
    });
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/mensagens/admin/anexos',
      data: formData,
      queryParameters: {
        'duracaoSegundos': ?duracaoSegundos,
      },
      onSendProgress: onProgress,
    );
    return MensagemAnexoModel.fromJson(resp.data ?? const {});
  }

  Future<MensagemEnviadaModel> enviarOuAgendar({
    String? titulo,
    String? conteudo,
    required PrioridadeMensagem prioridade,
    required ModalidadeEnvio modalidade,
    required bool exigeCiencia,
    Map<String, dynamic>? criterios,
    List<int> anexoIds = const [],
    DateTime? dataAgendamento,
    DateTime? dataExpiracao,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/mensagens/admin',
      data: {
        'titulo': titulo,
        'conteudo': conteudo,
        'prioridade': prioridade.apiValue,
        'modalidade': modalidade.apiValue,
        'exigeCiencia': exigeCiencia,
        'criterios': criterios,
        'anexoIds': anexoIds,
        'dataAgendamento': dataAgendamento?.toIso8601String(),
        'dataExpiracao': dataExpiracao?.toIso8601String(),
      },
    );
    return MensagemEnviadaModel.fromJson(resp.data ?? const {});
  }

  Future<List<MensagemEnviadaModel>> listarEnviadas({
    bool arquivada = false,
    int pagina = 0,
    int tamanho = 20,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/mensagens/admin/enviadas',
      queryParameters: {
        'arquivada': arquivada,
        'pagina': pagina,
        'tamanho': tamanho,
      },
    );
    final itens = (resp.data?['itens'] as List<dynamic>?) ?? const [];
    return itens
        .map((e) => MensagemEnviadaModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<AcompanhamentoMensagemModel> acompanharMensagem(
    int id, {
    StatusDestinatario? status,
    String? busca,
    int pagina = 0,
    int tamanho = 30,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/mensagens/admin/$id/acompanhamento',
      queryParameters: {
        if (status != null) 'status': status.apiValue,
        if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
        'pagina': pagina,
        'tamanho': tamanho,
      },
    );
    return AcompanhamentoMensagemModel.fromJson(resp.data ?? const {});
  }

  Future<void> cancelarAgendada(int id) async {
    await _dio.patch<void>('/api/mensagens/admin/$id/cancelar');
  }

  Future<void> arquivarRemetente(int id, {bool arquivada = true}) async {
    await _dio.patch<void>(
      '/api/mensagens/admin/$id/arquivar',
      queryParameters: {'arquivada': arquivada},
    );
  }

  // --- Grupos e Busca RH ---

  Future<CatalogoGruposRhModel> catalogoGruposRh() async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/mensagens/admin/grupos/predefinidos');
    return CatalogoGruposRhModel.fromJson(resp.data ?? const {});
  }

  Future<List<GrupoPersonalizadoModel>> listarGruposPersonalizados() async {
    final resp = await _dio.get<List<dynamic>>('/api/mensagens/admin/grupos/personalizados');
    final lista = resp.data ?? const [];
    return lista
        .map((e) => GrupoPersonalizadoModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<GrupoPersonalizadoModel> criarGrupoPersonalizado({
    required String nome,
    String? descricao,
    required List<String> matriculas,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/mensagens/admin/grupos/personalizados',
      data: {
        'nome': nome,
        'descricao': descricao,
        'matriculas': matriculas,
      },
    );
    return GrupoPersonalizadoModel.fromJson(resp.data ?? const {});
  }

  Future<GrupoPersonalizadoModel> atualizarGrupoPersonalizado(
    int id, {
    required String nome,
    String? descricao,
    required List<String> matriculas,
  }) async {
    final resp = await _dio.put<Map<String, dynamic>>(
      '/api/mensagens/admin/grupos/personalizados/$id',
      data: {
        'nome': nome,
        'descricao': descricao,
        'matriculas': matriculas,
      },
    );
    return GrupoPersonalizadoModel.fromJson(resp.data ?? const {});
  }

  Future<void> removerGrupoPersonalizado(int id) async {
    await _dio.delete<void>('/api/mensagens/admin/grupos/personalizados/$id');
  }

  Future<List<DestinatarioRhModel>> buscarDestinatarios(String termo, {int limite = 20}) async {
    final resp = await _dio.get<List<dynamic>>(
      '/api/mensagens/admin/destinatarios/buscar',
      queryParameters: {'q': termo, 'limite': limite},
    );
    final lista = resp.data ?? const [];
    return lista
        .map((e) => DestinatarioRhModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

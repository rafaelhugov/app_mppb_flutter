import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/ausencia_calendario.dart';
import '../models/concessao_afastamento.dart';
import '../models/operacao_solicitacao_concessao.dart';
import '../models/solicitacao_concessao.dart';
import '../models/sugestao_data_final.dart';
import '../repositories/concessao_afastamento_repository.dart';
import 'ausencias_calendario_state.dart';
import 'concessoes_vigentes_state.dart';

class ConcessaoAfastamentoState {
  final DateTime mesSelecionado;
  final ConcessoesVigentesState concessoes;
  final AusenciasCalendarioState calendario;

  const ConcessaoAfastamentoState({
    required this.mesSelecionado,
    this.concessoes = const ConcessoesVigentesState(),
    this.calendario = const AusenciasCalendarioState(),
  });

  ConcessaoAfastamentoState copyWith({
    DateTime? mesSelecionado,
    ConcessoesVigentesState? concessoes,
    AusenciasCalendarioState? calendario,
  }) {
    return ConcessaoAfastamentoState(
      mesSelecionado: mesSelecionado ?? this.mesSelecionado,
      concessoes: concessoes ?? this.concessoes,
      calendario: calendario ?? this.calendario,
    );
  }
}

class ConcessaoAfastamentoNotifier extends Notifier<ConcessaoAfastamentoState> {
  final Map<String, List<ConcessaoAfastamento>> _concessoesCache = {};
  final Map<String, List<AusenciaCalendario>> _ausenciasCache = {};
  final Map<int, List<SolicitacaoConcessao>> _solicitacoesCriadasLocalmente =
      {};
  String? _ultimoToken;

  @override
  ConcessaoAfastamentoState build() {
    final hoje = DateTime.now();
    ref.listen(authProvider, (previous, next) {
      if (previous?.token != next.token) {
        _concessoesCache.clear();
        _ausenciasCache.clear();
        _ultimoToken = next.token;
        if (next.token != null && next.token!.trim().isNotEmpty) {
          Future.microtask(carregarInicial);
        } else {
          _solicitacoesCriadasLocalmente.clear();
        }
      }
    });
    Future.microtask(carregarInicial);
    return ConcessaoAfastamentoState(
      mesSelecionado: DateTime(hoje.year, hoje.month),
    );
  }

  Future<void> carregarInicial() async {
    await Future.wait([carregarAusencias(), carregarConcessoes()]);
  }

  Future<void> carregarConcessoes({bool forceRefresh = false}) async {
    final token = await _tokenAtual();
    if (token == null) {
      state = state.copyWith(
        concessoes: state.concessoes.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage:
              'Não foi possível carregar as concessões de afastamento.\nTente novamente.',
        ),
      );
      return;
    }

    _limparCacheSeTrocarToken(token);
    final cacheKey = token;
    if (!forceRefresh && _concessoesCache.containsKey(cacheKey)) {
      state = state.copyWith(
        concessoes: state.concessoes.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: null,
          concessoes: _concessoesCache[cacheKey],
        ),
      );
      return;
    }

    state = state.copyWith(
      concessoes: state.concessoes.copyWith(
        isLoading: state.concessoes.concessoes.isEmpty,
        isRefreshing: state.concessoes.concessoes.isNotEmpty,
        errorMessage: null,
      ),
    );

    try {
      final dados = await ref
          .read(concessaoAfastamentoRepositoryProvider)
          .buscarConcessoesVigentes(token: token);
      final dadosComSolicitacoesLocais = _mesclarSolicitacoesCriadas(dados);
      _concessoesCache[cacheKey] = dadosComSolicitacoesLocais;
      state = state.copyWith(
        concessoes: state.concessoes.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: null,
          concessoes: dadosComSolicitacoesLocais,
        ),
      );
    } on DioException catch (e, stack) {
      _tratarErroConcessoes(e, stack);
    } catch (e, stack) {
      _tratarErroConcessoes(e, stack);
    }
  }

  Future<void> carregarAusencias({bool forceRefresh = false}) async {
    final token = await _tokenAtual();
    if (token == null) {
      state = state.copyWith(
        calendario: state.calendario.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage:
              'Não foi possível carregar os afastamentos.\nTente novamente.',
        ),
      );
      return;
    }

    _limparCacheSeTrocarToken(token);

    final mes = state.mesSelecionado;
    final hoje = DateTime.now();
    final currentMonth = DateTime(hoje.year, hoje.month);
    final isFuture = !mes.isBefore(currentMonth);

    final cacheKey = isFuture
        ? '$token-future'
        : '$token-${mes.year}-${mes.month}';

    if (!forceRefresh && _ausenciasCache.containsKey(cacheKey)) {
      state = state.copyWith(
        calendario: state.calendario.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: null,
          ausencias: _ausenciasCache[cacheKey],
        ),
      );
      return;
    }

    state = state.copyWith(
      calendario: state.calendario.copyWith(
        isLoading: state.calendario.ausencias.isEmpty,
        isRefreshing: state.calendario.ausencias.isNotEmpty,
        errorMessage: null,
      ),
    );

    try {
      debugPrint(
        '[ConcessaoAfastamento] Solicitando ausencias: mes=${isFuture ? null : mes.month}, ano=${isFuture ? null : mes.year}',
      );
      final dados = await ref
          .read(concessaoAfastamentoRepositoryProvider)
          .buscarAusenciasCalendario(
            token: token,
            mes: isFuture ? null : mes.month,
            ano: isFuture ? null : mes.year,
          );
      _ausenciasCache[cacheKey] = dados;
      state = state.copyWith(
        calendario: state.calendario.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: null,
          ausencias: dados,
        ),
      );
    } on DioException catch (e, stack) {
      _tratarErroCalendario(e, stack);
    } catch (e, stack) {
      _tratarErroCalendario(e, stack);
    }
  }

  Future<void> mudarMes(int delta) async {
    final atual = state.mesSelecionado;
    state = state.copyWith(
      mesSelecionado: DateTime(atual.year, atual.month + delta),
    );
    await carregarAusencias();
  }

  Future<void> selecionarMesAno(int mes, int ano) async {
    state = state.copyWith(mesSelecionado: DateTime(ano, mes));
    await carregarAusencias();
  }

  Future<void> atualizarTudo() async {
    await Future.wait([
      carregarAusencias(forceRefresh: true),
      carregarConcessoes(forceRefresh: true),
    ]);
  }

  Future<void> solicitarGozo({
    required ConcessaoAfastamento concessao,
    required DateTime dataInicial,
    required int numeroDias,
  }) async {
    final token = await _tokenAtual();
    if (token == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    final solicitacaoCriada = await ref
        .read(concessaoAfastamentoRepositoryProvider)
        .solicitarGozo(
          token: token,
          concessaoId: concessao.id,
          dataInicial: dataInicial,
          numeroDias: numeroDias,
        );

    if (solicitacaoCriada != null) {
      _guardarSolicitacaoCriada(concessao.id, solicitacaoCriada);
      _inserirSolicitacaoCriada(concessao.id, solicitacaoCriada);
    }
    _concessoesCache.clear();
    _ausenciasCache.clear();
    unawaited(carregarInicial());
  }

  Future<List<SugestaoDataFinal>> buscarSugestoesDatasFinais({
    required ConcessaoAfastamento concessao,
    required DateTime dataInicial,
  }) async {
    final token = await _tokenAtual();
    if (token == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    return ref
        .read(concessaoAfastamentoRepositoryProvider)
        .buscarSugestoesDatasFinais(
          token: token,
          concessaoId: concessao.id,
          dataInicial: dataInicial,
        );
  }

  Future<List<OperacaoSolicitacaoConcessao>> buscarOperacoesSolicitacao({
    required SolicitacaoConcessao solicitacao,
  }) async {
    final token = await _tokenAtual();
    if (token == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    return ref
        .read(concessaoAfastamentoRepositoryProvider)
        .buscarOperacoesSolicitacao(
          token: token,
          solicitacaoId: solicitacao.id,
        );
  }

  Future<void> executarOperacaoSolicitacao({
    required SolicitacaoConcessao solicitacao,
    required OperacaoSolicitacaoConcessao operacao,
    DateTime? data,
    DateTime? dataFim,
  }) async {
    final token = await _tokenAtual();
    if (token == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    await ref
        .read(concessaoAfastamentoRepositoryProvider)
        .executarOperacaoSolicitacao(
          token: token,
          solicitacaoId: solicitacao.id,
          operacao: operacao,
          data: data,
          dataFim: dataFim,
        );

    if (operacao == OperacaoSolicitacaoConcessao.cancelar) {
      _removerSolicitacaoCriadaLocalmente(solicitacao.id);
    }
    _concessoesCache.clear();
    _ausenciasCache.clear();
    unawaited(carregarInicial());
  }

  Future<String?> _tokenAtual() async {
    for (var attempt = 0; attempt < 6; attempt++) {
      final stateToken = ref.read(authProvider).token;
      if (stateToken != null && stateToken.trim().isNotEmpty) {
        return stateToken;
      }

      final storedToken = await ref
          .read(secureStorageProvider)
          .read(key: 'auth_token');
      if (storedToken != null && storedToken.trim().isNotEmpty) {
        return storedToken;
      }

      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    return null;
  }

  void _limparCacheSeTrocarToken(String token) {
    if (_ultimoToken != null && _ultimoToken != token) {
      _concessoesCache.clear();
      _ausenciasCache.clear();
      _solicitacoesCriadasLocalmente.clear();
    }
    _ultimoToken = token;
  }

  void _guardarSolicitacaoCriada(
    int concessaoId,
    SolicitacaoConcessao solicitacao,
  ) {
    final solicitacoes = [
      ...?_solicitacoesCriadasLocalmente[concessaoId],
    ].where((item) => item.id != solicitacao.id).toList();
    solicitacoes.add(solicitacao);
    _ordenarSolicitacoes(solicitacoes);
    _solicitacoesCriadasLocalmente[concessaoId] = solicitacoes;
  }

  List<ConcessaoAfastamento> _mesclarSolicitacoesCriadas(
    List<ConcessaoAfastamento> concessoes,
  ) {
    if (_solicitacoesCriadasLocalmente.isEmpty) return concessoes;

    return concessoes.map((concessao) {
      final locais = _solicitacoesCriadasLocalmente[concessao.id];
      if (locais == null || locais.isEmpty) return concessao;

      final idsRemotos = concessao.solicitacoes.map((item) => item.id).toSet();
      final pendentes = locais
          .where((item) => !idsRemotos.contains(item.id))
          .toList();
      if (pendentes.isEmpty) return concessao;

      final solicitacoes = [...concessao.solicitacoes, ...pendentes];
      _ordenarSolicitacoes(solicitacoes);

      return _copyConcessao(concessao, solicitacoes: solicitacoes);
    }).toList();
  }

  void _removerSolicitacaoCriadaLocalmente(int solicitacaoId) {
    final concessoesAfetadas = <int>[];
    final entradas = _solicitacoesCriadasLocalmente.entries.toList();

    for (final entry in entradas) {
      final solicitacoes = entry.value
          .where((item) => item.id != solicitacaoId)
          .toList();
      if (solicitacoes.length != entry.value.length) {
        concessoesAfetadas.add(entry.key);
        if (solicitacoes.isEmpty) {
          _solicitacoesCriadasLocalmente.remove(entry.key);
        } else {
          _solicitacoesCriadasLocalmente[entry.key] = solicitacoes;
        }
      }
    }

    if (concessoesAfetadas.isEmpty) return;
    final idsAfetados = concessoesAfetadas.toSet();
    final concessoes = state.concessoes.concessoes.map((concessao) {
      if (!idsAfetados.contains(concessao.id)) return concessao;
      return _copyConcessao(
        concessao,
        solicitacoes: concessao.solicitacoes
            .where((item) => item.id != solicitacaoId)
            .toList(),
      );
    }).toList();

    state = state.copyWith(
      concessoes: state.concessoes.copyWith(concessoes: concessoes),
    );
  }

  void _inserirSolicitacaoCriada(
    int concessaoId,
    SolicitacaoConcessao solicitacao,
  ) {
    final concessoes = state.concessoes.concessoes;
    if (concessoes.isEmpty) return;

    final atualizadas = concessoes.map((concessao) {
      if (concessao.id != concessaoId) return concessao;

      final solicitacoes = [
        ...concessao.solicitacoes.where((item) => item.id != solicitacao.id),
        solicitacao,
      ];
      _ordenarSolicitacoes(solicitacoes);

      return _copyConcessao(concessao, solicitacoes: solicitacoes);
    }).toList();

    state = state.copyWith(
      concessoes: state.concessoes.copyWith(
        errorMessage: null,
        concessoes: atualizadas,
      ),
    );
  }

  ConcessaoAfastamento _copyConcessao(
    ConcessaoAfastamento concessao, {
    required List<SolicitacaoConcessao> solicitacoes,
  }) {
    return ConcessaoAfastamento(
      id: concessao.id,
      tipo: concessao.tipo,
      descricaoOriginal: concessao.descricaoOriginal,
      diasConcedidos: concessao.diasConcedidos,
      saldoRestante: concessao.saldoRestante,
      periodo: concessao.periodo,
      anoReferencia: concessao.anoReferencia,
      inicioPeriodoAquisitivo: concessao.inicioPeriodoAquisitivo,
      finalPeriodoAquisitivo: concessao.finalPeriodoAquisitivo,
      solicitacoes: solicitacoes,
    );
  }

  void _ordenarSolicitacoes(List<SolicitacaoConcessao> solicitacoes) {
    solicitacoes.sort((a, b) {
      if (a.isGozo != b.isGozo) return a.isGozo ? -1 : 1;

      final dataA = a.inicio ?? a.fim;
      final dataB = b.inicio ?? b.fim;
      if (dataA != null && dataB != null) {
        return dataA.compareTo(dataB);
      }
      if (dataA != null) return -1;
      if (dataB != null) return 1;
      return a.id.compareTo(b.id);
    });
  }

  void _tratarErroConcessoes(dynamic e, [StackTrace? stack]) {
    debugPrint('[ConcessaoAfastamento] Erro ao carregar concessoes: $e');
    if (stack != null) debugPrint(stack.toString());

    state = state.copyWith(
      concessoes: state.concessoes.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: _obterMensagemErro(e),
      ),
    );
  }

  void _tratarErroCalendario(dynamic e, [StackTrace? stack]) {
    debugPrint('[ConcessaoAfastamento] Erro ao carregar afastamentos: $e');
    if (stack != null) debugPrint(stack.toString());

    state = state.copyWith(
      calendario: state.calendario.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: _obterMensagemErro(e, isCalendario: true),
      ),
    );
  }

  String _obterMensagemErro(dynamic e, {bool isCalendario = false}) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'O serviço demorou para responder. Tente novamente.';
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return 'Sem conexão com o serviço. Verifique sua internet e tente novamente.';
      }
      // Outros erros HTTP (500, etc)
    }

    if (isCalendario) {
      return 'Não foi possível carregar os afastamentos.\nTente novamente.';
    }
    return 'Não foi possível carregar as concessões de afastamento.\nTente novamente.';
  }
}

final concessaoAfastamentoProvider =
    NotifierProvider<ConcessaoAfastamentoNotifier, ConcessaoAfastamentoState>(
      () {
        return ConcessaoAfastamentoNotifier();
      },
    );

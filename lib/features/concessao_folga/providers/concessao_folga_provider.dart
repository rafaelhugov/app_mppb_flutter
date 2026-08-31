import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/ausencia_calendario.dart';
import '../models/concessao_folga.dart';
import '../repositories/concessao_folga_repository.dart';
import 'ausencias_calendario_state.dart';
import 'concessoes_vigentes_state.dart';

class ConcessaoFolgaState {
  final DateTime mesSelecionado;
  final ConcessoesVigentesState concessoes;
  final AusenciasCalendarioState calendario;

  const ConcessaoFolgaState({
    required this.mesSelecionado,
    this.concessoes = const ConcessoesVigentesState(),
    this.calendario = const AusenciasCalendarioState(),
  });

  ConcessaoFolgaState copyWith({
    DateTime? mesSelecionado,
    ConcessoesVigentesState? concessoes,
    AusenciasCalendarioState? calendario,
  }) {
    return ConcessaoFolgaState(
      mesSelecionado: mesSelecionado ?? this.mesSelecionado,
      concessoes: concessoes ?? this.concessoes,
      calendario: calendario ?? this.calendario,
    );
  }
}

class ConcessaoFolgaNotifier extends Notifier<ConcessaoFolgaState> {
  final Map<String, List<ConcessaoFolga>> _concessoesCache = {};
  final Map<String, List<AusenciaCalendario>> _ausenciasCache = {};
  String? _ultimoToken;

  @override
  ConcessaoFolgaState build() {
    final hoje = DateTime.now();
    ref.listen(authProvider, (previous, next) {
      if (previous?.token != next.token) {
        _concessoesCache.clear();
        _ausenciasCache.clear();
        _ultimoToken = next.token;
        if (next.token != null && next.token!.trim().isNotEmpty) {
          Future.microtask(carregarInicial);
        }
      }
    });
    Future.microtask(carregarInicial);
    return ConcessaoFolgaState(mesSelecionado: DateTime(hoje.year, hoje.month));
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
              'Não foi possível carregar as concessões de folga.\nTente novamente.',
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
          .read(concessaoFolgaRepositoryProvider)
          .buscarConcessoesVigentes(token: token);
      _concessoesCache[cacheKey] = dados;
      state = state.copyWith(
        concessoes: state.concessoes.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: null,
          concessoes: dados,
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
        '[ConcessaoFolga] Solicitando ausencias: mes=${isFuture ? null : mes.month}, ano=${isFuture ? null : mes.year}',
      );
      final dados = await ref
          .read(concessaoFolgaRepositoryProvider)
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

  Future<void> solicitarMarcacaoFerias({
    required ConcessaoFolga concessao,
    required DateTime dataInicial,
    required int numeroDias,
  }) async {
    final token = await _tokenAtual();
    if (token == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    await ref
        .read(concessaoFolgaRepositoryProvider)
        .solicitarMarcacaoFerias(
          token: token,
          concessaoId: concessao.id,
          dataInicial: dataInicial,
          numeroDias: numeroDias,
        );

    _concessoesCache.clear();
    _ausenciasCache.clear();
    await carregarInicial();
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
    }
    _ultimoToken = token;
  }

  void _tratarErroConcessoes(dynamic e, [StackTrace? stack]) {
    debugPrint('[ConcessaoFolga] Erro ao carregar concessoes: $e');
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
    debugPrint('[ConcessaoFolga] Erro ao carregar afastamentos: $e');
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
    return 'Não foi possível carregar as concessões de folga.\nTente novamente.';
  }
}

final concessaoFolgaProvider =
    NotifierProvider<ConcessaoFolgaNotifier, ConcessaoFolgaState>(() {
      return ConcessaoFolgaNotifier();
    });

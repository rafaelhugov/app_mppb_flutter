import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/designacao_ativa.dart';
import '../repositories/designacoes_repository.dart';

class DesignacoesState {
  final String tipoUsuario;
  final List<DesignacaoAtiva> designacoes;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  const DesignacoesState({
    this.tipoUsuario = 'INDEFINIDO',
    this.designacoes = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  DesignacoesState copyWith({
    String? tipoUsuario,
    List<DesignacaoAtiva>? designacoes,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return DesignacoesState(
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      designacoes: designacoes ?? this.designacoes,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }
}

class DesignacoesNotifier extends Notifier<DesignacoesState> {
  String? _ultimoToken;
  DesignacoesAtivasResponse? _cache;

  @override
  DesignacoesState build() {
    ref.listen(authProvider, (previous, next) {
      if (previous?.token != next.token) {
        _cache = null;
        _ultimoToken = next.token;
        if (next.token != null && next.token!.trim().isNotEmpty) {
          Future.microtask(carregar);
        }
      }
    });
    Future.microtask(carregar);
    return const DesignacoesState(isLoading: true);
  }

  Future<void> carregar({bool forceRefresh = false}) async {
    final token = await _tokenAtual();
    if (token == null) {
      _erro();
      return;
    }

    if (_ultimoToken != null && _ultimoToken != token) {
      _cache = null;
    }
    _ultimoToken = token;

    if (!forceRefresh && _cache != null) {
      _aplicar(_cache!);
      return;
    }

    state = state.copyWith(
      isLoading: state.designacoes.isEmpty,
      isRefreshing: state.designacoes.isNotEmpty,
      errorMessage: null,
    );

    try {
      final response = await ref
          .read(designacoesRepositoryProvider)
          .buscarAtivas(token: token);
      _cache = response;
      _aplicar(response);
    } on DioException {
      _erro();
    } catch (_) {
      _erro();
    }
  }

  void _aplicar(DesignacoesAtivasResponse response) {
    state = state.copyWith(
      tipoUsuario: response.tipoUsuario,
      designacoes: response.designacoes,
      isLoading: false,
      isRefreshing: false,
      errorMessage: null,
    );
  }

  void _erro() {
    state = state.copyWith(
      isLoading: false,
      isRefreshing: false,
      errorMessage: 'Não foi possível carregar suas designações.',
    );
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
}

final designacoesProvider =
    NotifierProvider<DesignacoesNotifier, DesignacoesState>(() {
      return DesignacoesNotifier();
    });

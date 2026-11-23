import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/mensagens_repository.dart';
import '../models/mensagem_aviso_model.dart';

class CaixaEntradaState {
  const CaixaEntradaState({
    this.itens = const [],
    this.filtro = 'TODAS',
    this.isLoading = false,
    this.errorMessage,
    this.totalNaoLidas = 0,
    this.paginaAtual = 0,
    this.totalPaginas = 0,
  });

  final List<MensagemAvisoModel> itens;
  final String filtro;
  final bool isLoading;
  final String? errorMessage;
  final int totalNaoLidas;
  final int paginaAtual;
  final int totalPaginas;

  CaixaEntradaState copyWith({
    List<MensagemAvisoModel>? itens,
    String? filtro,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? totalNaoLidas,
    int? paginaAtual,
    int? totalPaginas,
  }) {
    return CaixaEntradaState(
      itens: itens ?? this.itens,
      filtro: filtro ?? this.filtro,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      totalNaoLidas: totalNaoLidas ?? this.totalNaoLidas,
      paginaAtual: paginaAtual ?? this.paginaAtual,
      totalPaginas: totalPaginas ?? this.totalPaginas,
    );
  }
}

class CaixaEntradaNotifier extends Notifier<CaixaEntradaState> {
  @override
  CaixaEntradaState build() {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    ref.listen(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        state = const CaixaEntradaState();
      } else if (!(previous?.isAuthenticated ?? false) && next.isAuthenticated) {
        Future.microtask(() => carregar());
      }
    });
    if (isAuthenticated) {
      Future.microtask(() => carregar());
    }
    return const CaixaEntradaState();
  }

  Future<void> carregar({String? filtro, bool forceRefresh = false}) async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) return;

    final filtroAlvo = filtro ?? state.filtro;
    if (state.isLoading && !forceRefresh) return;

    state = state.copyWith(
      filtro: filtroAlvo,
      isLoading: true,
      clearError: true,
    );

    try {
      final repo = ref.read(mensagensRepositoryProvider);
      final page = await repo.listarRecebidas(filtro: filtroAlvo, pagina: 0);

      state = state.copyWith(
        itens: page.itens,
        isLoading: false,
        totalNaoLidas: page.totalNaoLidas,
        paginaAtual: page.pagina,
        totalPaginas: page.totalPaginas,
      );

      final pendentesIds = page.itens
          .where((m) => m.status == StatusDestinatario.pendente)
          .map((m) => m.id)
          .toList();
      if (pendentesIds.isNotEmpty) {
        unawaited(
          repo.confirmarEntregaEmLote(pendentesIds).catchError((_) {}),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível carregar as mensagens e avisos.',
      );
    }
  }

  Future<MensagemAvisoModel?> abrirMensagem(int id) async {
    try {
      final repo = ref.read(mensagensRepositoryProvider);
      final atualizada = await repo.abrirMensagem(id);
      _atualizarItemLocal(atualizada);
      return atualizada;
    } catch (_) {
      return null;
    }
  }

  Future<MensagemAvisoModel?> confirmarCiencia(int id) async {
    final repo = ref.read(mensagensRepositoryProvider);
    final atualizada = await repo.confirmarCiencia(id);
    _atualizarItemLocal(atualizada);
    return atualizada;
  }

  Future<void> arquivar(int id, {bool arquivada = true}) async {
    final repo = ref.read(mensagensRepositoryProvider);
    await repo.arquivarRecebida(id, arquivada: arquivada);
    await carregar(forceRefresh: true);
  }

  void _atualizarItemLocal(MensagemAvisoModel atualizada) {
    var eraNaoLida = false;
    final novosItens = state.itens.map((item) {
      if (item.id == atualizada.id) {
        if (item.naoLida && !atualizada.naoLida) {
          eraNaoLida = true;
        }
        return atualizada;
      }
      return item;
    }).toList();

    final novoTotalNaoLidas = eraNaoLida && state.totalNaoLidas > 0
        ? state.totalNaoLidas - 1
        : state.totalNaoLidas;

    state = state.copyWith(
      itens: novosItens,
      totalNaoLidas: novoTotalNaoLidas,
    );
  }
}

final caixaEntradaProvider =
    NotifierProvider<CaixaEntradaNotifier, CaixaEntradaState>(
      CaixaEntradaNotifier.new,
    );


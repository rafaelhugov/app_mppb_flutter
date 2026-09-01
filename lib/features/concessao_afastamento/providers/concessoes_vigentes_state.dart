import '../models/concessao_afastamento.dart';

class ConcessoesVigentesState {
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final List<ConcessaoAfastamento> concessoes;

  const ConcessoesVigentesState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.concessoes = const [],
  });

  ConcessoesVigentesState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Object? errorMessage = _sentinel,
    List<ConcessaoAfastamento>? concessoes,
  }) {
    return ConcessoesVigentesState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      concessoes: concessoes ?? this.concessoes,
    );
  }
}

const _sentinel = Object();

import '../models/ausencia_calendario.dart';

class AusenciasCalendarioState {
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final List<AusenciaCalendario> ausencias;

  const AusenciasCalendarioState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.ausencias = const [],
  });

  AusenciasCalendarioState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Object? errorMessage = _sentinel,
    List<AusenciaCalendario>? ausencias,
  }) {
    return AusenciasCalendarioState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      ausencias: ausencias ?? this.ausencias,
    );
  }
}

const _sentinel = Object();

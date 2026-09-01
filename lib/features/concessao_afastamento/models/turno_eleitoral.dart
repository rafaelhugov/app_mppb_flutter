enum TurnoEleitoral {
  treinamento,
  primeiroTurno,
  segundoTurno,
  desconhecido;

  factory TurnoEleitoral.fromPeriodo(int? periodo) {
    switch (periodo) {
      case 1:
        return TurnoEleitoral.treinamento;
      case 2:
        return TurnoEleitoral.primeiroTurno;
      case 3:
        return TurnoEleitoral.segundoTurno;
      default:
        return TurnoEleitoral.desconhecido;
    }
  }

  String get label {
    switch (this) {
      case TurnoEleitoral.treinamento:
        return 'Treinamento';
      case TurnoEleitoral.primeiroTurno:
        return 'Primeiro turno';
      case TurnoEleitoral.segundoTurno:
        return 'Segundo turno';
      case TurnoEleitoral.desconhecido:
        return 'Turno não informado';
    }
  }
}

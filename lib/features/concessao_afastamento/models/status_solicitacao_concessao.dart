import 'text_normalizer.dart';

enum StatusSolicitacaoConcessao {
  pendente,
  cancelado,
  confirmado,
  negado,
  homologado,
  deferido,
  indeferido,
  migrado,
  desconhecido;

  factory StatusSolicitacaoConcessao.fromJson(String? value) {
    final normalized = normalizarTexto(value);
    switch (normalized) {
      case 'pendente':
      case 'p':
        return StatusSolicitacaoConcessao.pendente;
      case 'cancelado':
      case 'cancelada':
      case 'c':
        return StatusSolicitacaoConcessao.cancelado;
      case 'confirmado':
      case 'confirmada':
      case 'l':
        return StatusSolicitacaoConcessao.confirmado;
      case 'negado':
      case 'negada':
      case 'n':
        return StatusSolicitacaoConcessao.negado;
      case 'homologado':
      case 'homologada':
      case 'h':
        return StatusSolicitacaoConcessao.homologado;
      case 'deferido':
      case 'deferida':
      case 'd':
        return StatusSolicitacaoConcessao.deferido;
      case 'indeferido':
      case 'indeferida':
      case 'i':
        return StatusSolicitacaoConcessao.indeferido;
      case 'migrado':
      case 'migrada':
        return StatusSolicitacaoConcessao.migrado;
      default:
        return StatusSolicitacaoConcessao.desconhecido;
    }
  }

  String get label {
    switch (this) {
      case StatusSolicitacaoConcessao.pendente:
        return 'Pendente';
      case StatusSolicitacaoConcessao.cancelado:
        return 'Cancelado';
      case StatusSolicitacaoConcessao.confirmado:
        return 'Confirmado';
      case StatusSolicitacaoConcessao.negado:
        return 'Negado';
      case StatusSolicitacaoConcessao.homologado:
        return 'Homologado';
      case StatusSolicitacaoConcessao.deferido:
        return 'Deferido';
      case StatusSolicitacaoConcessao.indeferido:
        return 'Indeferido';
      case StatusSolicitacaoConcessao.migrado:
        return 'Migrado';
      case StatusSolicitacaoConcessao.desconhecido:
        return 'Situação não informada';
    }
  }
}

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
      case 'analisado':
      case 'analisada':
      case 'a':
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
        return 'Cancelada';
      case StatusSolicitacaoConcessao.confirmado:
        return 'Confirmada pelo chefe imediato ou DRH';
      case StatusSolicitacaoConcessao.negado:
        return 'Indeferida';
      case StatusSolicitacaoConcessao.homologado:
        return 'Analisada';
      case StatusSolicitacaoConcessao.deferido:
        return 'Deferida';
      case StatusSolicitacaoConcessao.indeferido:
        return 'Indeferida';
      case StatusSolicitacaoConcessao.migrado:
        return 'Analisada';
      case StatusSolicitacaoConcessao.desconhecido:
        return 'Situação não informada';
    }
  }
}

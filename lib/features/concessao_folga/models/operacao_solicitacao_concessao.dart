import 'text_normalizer.dart';

enum OperacaoSolicitacaoConcessao {
  cancelar,
  adiar,
  antecipar,
  interromper,
  suspenderParcialmente,
  suspenderIntegralmente,
}

extension OperacaoSolicitacaoConcessaoLabel on OperacaoSolicitacaoConcessao {
  String get label {
    switch (this) {
      case OperacaoSolicitacaoConcessao.cancelar:
        return 'Cancelar';
      case OperacaoSolicitacaoConcessao.adiar:
        return 'Adiar';
      case OperacaoSolicitacaoConcessao.antecipar:
        return 'Antecipar';
      case OperacaoSolicitacaoConcessao.interromper:
        return 'Interromper';
      case OperacaoSolicitacaoConcessao.suspenderParcialmente:
        return 'Suspender parcial';
      case OperacaoSolicitacaoConcessao.suspenderIntegralmente:
        return 'Suspender integral';
    }
  }

  String get successMessage {
    switch (this) {
      case OperacaoSolicitacaoConcessao.cancelar:
        return 'Solicitação cancelada.';
      case OperacaoSolicitacaoConcessao.adiar:
        return 'Solicitação de adiamento enviada.';
      case OperacaoSolicitacaoConcessao.antecipar:
        return 'Solicitação de antecipação enviada.';
      case OperacaoSolicitacaoConcessao.interromper:
        return 'Solicitação de interrupção enviada.';
      case OperacaoSolicitacaoConcessao.suspenderParcialmente:
        return 'Solicitação de suspensão parcial enviada.';
      case OperacaoSolicitacaoConcessao.suspenderIntegralmente:
        return 'Solicitação de suspensão integral enviada.';
    }
  }
}

OperacaoSolicitacaoConcessao? operacaoSolicitacaoFromJson(dynamic value) {
  final normalized = normalizarTexto(_extractOperationText(value));
  if (normalized.isEmpty) return null;

  if (normalized.contains('cancel')) {
    return OperacaoSolicitacaoConcessao.cancelar;
  }
  if (normalized.contains('adi')) {
    return OperacaoSolicitacaoConcessao.adiar;
  }
  if (normalized.contains('antecip')) {
    return OperacaoSolicitacaoConcessao.antecipar;
  }
  if (normalized.contains('interromp') || normalized.contains('interrup')) {
    return OperacaoSolicitacaoConcessao.interromper;
  }
  if (normalized.contains('parcial') || normalized.contains('parcia')) {
    return OperacaoSolicitacaoConcessao.suspenderParcialmente;
  }
  if (normalized.contains('integral') ||
      normalized.contains('integra') ||
      normalized.contains('total')) {
    return OperacaoSolicitacaoConcessao.suspenderIntegralmente;
  }
  return null;
}

String _extractOperationText(dynamic value) {
  if (value == null) return '';
  if (value is String || value is num || value is bool) return value.toString();
  if (value is Map<String, dynamic>) {
    return [
      value['codigo'],
      value['nome'],
      value['label'],
      value['descricao'],
      value['tipo'],
      value['operacao'],
    ].whereType<Object>().map((item) => item.toString()).join(' ');
  }
  return value.toString();
}

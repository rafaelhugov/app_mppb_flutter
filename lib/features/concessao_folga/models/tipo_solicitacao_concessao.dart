import 'text_normalizer.dart';

enum TipoSolicitacaoConcessao {
  gozo,
  gozoColetivo,
  antecipacao,
  interrupcao,
  adiamento,
  suspensaoParcial,
  suspensaoTotal,
  adiamentoSineDie,
  indenizacao,
  conversao,
  desconhecido;

  factory TipoSolicitacaoConcessao.fromJson(String? value) {
    final normalized = normalizarTexto(value);
    switch (normalized) {
      case 'gozo':
        return TipoSolicitacaoConcessao.gozo;
      case 'gozo coletivo':
        return TipoSolicitacaoConcessao.gozoColetivo;
      case 'antecipacao':
        return TipoSolicitacaoConcessao.antecipacao;
      case 'interrupcao':
        return TipoSolicitacaoConcessao.interrupcao;
      case 'adiamento':
        return TipoSolicitacaoConcessao.adiamento;
      case 'suspensao parcial':
        return TipoSolicitacaoConcessao.suspensaoParcial;
      case 'suspensao total':
        return TipoSolicitacaoConcessao.suspensaoTotal;
      case 'adiamento sine die':
        return TipoSolicitacaoConcessao.adiamentoSineDie;
      case 'indenizacao de ferias':
      case 'indenizacao':
        return TipoSolicitacaoConcessao.indenizacao;
      case 'conversao de ferias':
      case 'conversao':
        return TipoSolicitacaoConcessao.conversao;
      default:
        return TipoSolicitacaoConcessao.desconhecido;
    }
  }

  String get label {
    switch (this) {
      case TipoSolicitacaoConcessao.gozo:
        return 'Gozo';
      case TipoSolicitacaoConcessao.gozoColetivo:
        return 'Gozo coletivo';
      case TipoSolicitacaoConcessao.antecipacao:
        return 'Antecipação';
      case TipoSolicitacaoConcessao.interrupcao:
        return 'Interrupção';
      case TipoSolicitacaoConcessao.adiamento:
        return 'Adiamento';
      case TipoSolicitacaoConcessao.suspensaoParcial:
        return 'Suspensão parcial';
      case TipoSolicitacaoConcessao.suspensaoTotal:
        return 'Suspensão total';
      case TipoSolicitacaoConcessao.adiamentoSineDie:
        return 'Adiamento Sine Die';
      case TipoSolicitacaoConcessao.indenizacao:
        return 'Indenização de férias';
      case TipoSolicitacaoConcessao.conversao:
        return 'Conversão de férias';
      case TipoSolicitacaoConcessao.desconhecido:
        return 'Outra solicitação';
    }
  }
}

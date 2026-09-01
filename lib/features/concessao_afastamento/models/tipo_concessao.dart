import 'text_normalizer.dart';

enum TipoConcessao {
  ferias,
  licencaPremio,
  licencaEleitoral,
  plantao,
  diarias,
  desconhecido;

  factory TipoConcessao.fromJson(String? value) {
    final normalized = normalizarTexto(value);
    switch (normalized) {
      case 'f':
      case 'ferias':
      case 'ferias regulamentares':
        return TipoConcessao.ferias;
      case 'l':
      case 'licenca':
      case 'licenca premio':
      case 'licenca-premio':
        return TipoConcessao.licencaPremio;
      case 'e':
      case 'eleitoral':
      case 'licenca eleitoral':
        return TipoConcessao.licencaEleitoral;
      case 'p':
      case 'plantao':
        return TipoConcessao.plantao;
      case 'diaria':
      case 'diarias':
      case 'afastamento por diarias':
      case 'folga por diarias':
        return TipoConcessao.diarias;
      default:
        return TipoConcessao.desconhecido;
    }
  }

  String get label {
    switch (this) {
      case TipoConcessao.ferias:
        return 'Férias';
      case TipoConcessao.licencaPremio:
        return 'Licença Especial';
      case TipoConcessao.licencaEleitoral:
        return 'Afastamento Eleitoral';
      case TipoConcessao.plantao:
        return 'Plantão';
      case TipoConcessao.diarias:
        return 'Diária';
      case TipoConcessao.desconhecido:
        return 'Outra concessão';
    }
  }
}

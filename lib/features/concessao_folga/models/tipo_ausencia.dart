import 'text_normalizer.dart';

enum TipoAusencia {
  ferias,
  licenca,
  licencaEleitoral,
  plantao,
  diarias,
  outros;

  factory TipoAusencia.fromJson(String? value) {
    final normalized = normalizarTexto(value);
    if (normalized.contains('eleitoral')) return TipoAusencia.licencaEleitoral;
    if (normalized.contains('ferias')) return TipoAusencia.ferias;
    if (normalized.contains('plantao')) return TipoAusencia.plantao;
    if (normalized.contains('diaria')) return TipoAusencia.diarias;
    if (normalized.contains('licenca')) return TipoAusencia.licenca;
    return TipoAusencia.outros;
  }

  String get label {
    switch (this) {
      case TipoAusencia.ferias:
        return 'Férias';
      case TipoAusencia.licenca:
        return 'Licença Especial';
      case TipoAusencia.licencaEleitoral:
        return 'Afastamento Eleiroral';
      case TipoAusencia.plantao:
        return 'Plantão';
      case TipoAusencia.diarias:
        return 'Diária';
      case TipoAusencia.outros:
        return 'Outros';
    }
  }
}

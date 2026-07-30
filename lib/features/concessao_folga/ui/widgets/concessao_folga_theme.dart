import 'package:flutter/material.dart';

import '../../models/status_solicitacao_concessao.dart';
import '../../models/tipo_ausencia.dart';
import '../../models/tipo_concessao.dart';

class ConcessaoFolgaColors {
  static const ferias = Color(0xFF2563EB);
  static const licenca = Color(0xFF7C3AED);
  static const licencaEleitoral = Color(0xFFF97316);
  static const plantao = Color(0xFFDC2626);
  static const diarias = Color(0xFF16A34A);
  static const outros = Color(0xFF6B7280);
  static const surface = Color(0xFFF7EFE3);
  static const ink = Color(0xFF2F2923);
  static const muted = Color(0xFF73543E);
  static const brand = Color(0xFF8F2A1D);
}

extension TipoConcessaoColor on TipoConcessao {
  Color get color {
    switch (this) {
      case TipoConcessao.ferias:
        return ConcessaoFolgaColors.ferias;
      case TipoConcessao.licencaPremio:
        return ConcessaoFolgaColors.licenca;
      case TipoConcessao.licencaEleitoral:
        return ConcessaoFolgaColors.licencaEleitoral;
      case TipoConcessao.plantao:
        return ConcessaoFolgaColors.plantao;
      case TipoConcessao.diarias:
        return ConcessaoFolgaColors.diarias;
      case TipoConcessao.desconhecido:
        return ConcessaoFolgaColors.outros;
    }
  }
}

extension TipoAusenciaColor on TipoAusencia {
  Color get color {
    switch (this) {
      case TipoAusencia.ferias:
        return ConcessaoFolgaColors.ferias;
      case TipoAusencia.licenca:
        return ConcessaoFolgaColors.licenca;
      case TipoAusencia.licencaEleitoral:
        return ConcessaoFolgaColors.licencaEleitoral;
      case TipoAusencia.plantao:
        return ConcessaoFolgaColors.plantao;
      case TipoAusencia.diarias:
        return ConcessaoFolgaColors.diarias;
      case TipoAusencia.outros:
        return ConcessaoFolgaColors.outros;
    }
  }
}

extension StatusSolicitacaoColor on StatusSolicitacaoConcessao {
  Color get color {
    switch (this) {
      case StatusSolicitacaoConcessao.deferido:
      case StatusSolicitacaoConcessao.homologado:
      case StatusSolicitacaoConcessao.confirmado:
      case StatusSolicitacaoConcessao.migrado:
        return const Color(0xFF15803D);
      case StatusSolicitacaoConcessao.pendente:
        return const Color(0xFFB45309);
      case StatusSolicitacaoConcessao.cancelado:
      case StatusSolicitacaoConcessao.negado:
      case StatusSolicitacaoConcessao.indeferido:
        return const Color(0xFFB91C1C);
      case StatusSolicitacaoConcessao.desconhecido:
        return ConcessaoFolgaColors.outros;
    }
  }
}

import 'package:flutter/material.dart';

import '../../models/status_solicitacao_concessao.dart';
import '../../models/tipo_ausencia.dart';
import '../../models/tipo_concessao.dart';

class ConcessaoAfastamentoColors {
  static const ferias = Color(0xFF2563EB);
  static const licenca = Color(0xFF9333EA);
  static const licencaEleitoral = Color(0xFFF97316);
  static const plantao = Color(0xFFD62828);
  static const diarias = Color(0xFF00A86B);
  static const outros = Color(0xFF64748B);
  static const background = Color(0xFFF7F8F6);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF202322);
  static const muted = Color(0xFF697370);
  static const brand = Color(0xFF202322);

  static const statusPendente = Color(0xFFFDE047);
  static const statusConfirmada = Color(0xFFF97316);
  static const statusDeferida = Color(0xFF00A86B);
  static const statusIndeferida = Color(0xFFE5252A);
  static const statusCancelada = Color(0xFFE5E7EB);
  static const statusAnalisada = Color(0xFF2563EB);
}

extension TipoConcessaoColor on TipoConcessao {
  Color get color {
    switch (this) {
      case TipoConcessao.ferias:
        return ConcessaoAfastamentoColors.ferias;
      case TipoConcessao.licencaPremio:
        return ConcessaoAfastamentoColors.licenca;
      case TipoConcessao.licencaEleitoral:
        return ConcessaoAfastamentoColors.licencaEleitoral;
      case TipoConcessao.plantao:
        return ConcessaoAfastamentoColors.plantao;
      case TipoConcessao.diarias:
        return ConcessaoAfastamentoColors.diarias;
      case TipoConcessao.desconhecido:
        return ConcessaoAfastamentoColors.outros;
    }
  }
}

extension TipoAusenciaColor on TipoAusencia {
  Color get color {
    switch (this) {
      case TipoAusencia.ferias:
        return ConcessaoAfastamentoColors.ferias;
      case TipoAusencia.licenca:
        return ConcessaoAfastamentoColors.licenca;
      case TipoAusencia.licencaEleitoral:
        return ConcessaoAfastamentoColors.licencaEleitoral;
      case TipoAusencia.plantao:
        return ConcessaoAfastamentoColors.plantao;
      case TipoAusencia.diarias:
        return ConcessaoAfastamentoColors.diarias;
      case TipoAusencia.outros:
        return ConcessaoAfastamentoColors.outros;
    }
  }
}

extension StatusSolicitacaoColor on StatusSolicitacaoConcessao {
  Color get color {
    switch (this) {
      case StatusSolicitacaoConcessao.deferido:
        return ConcessaoAfastamentoColors.statusDeferida;
      case StatusSolicitacaoConcessao.pendente:
        return ConcessaoAfastamentoColors.statusPendente;
      case StatusSolicitacaoConcessao.confirmado:
        return ConcessaoAfastamentoColors.statusConfirmada;
      case StatusSolicitacaoConcessao.cancelado:
        return ConcessaoAfastamentoColors.statusCancelada;
      case StatusSolicitacaoConcessao.homologado:
      case StatusSolicitacaoConcessao.migrado:
        return ConcessaoAfastamentoColors.statusAnalisada;
      case StatusSolicitacaoConcessao.negado:
      case StatusSolicitacaoConcessao.indeferido:
        return ConcessaoAfastamentoColors.statusIndeferida;
      case StatusSolicitacaoConcessao.desconhecido:
        return ConcessaoAfastamentoColors.outros;
    }
  }

  Color get foreground {
    switch (this) {
      case StatusSolicitacaoConcessao.pendente:
      case StatusSolicitacaoConcessao.cancelado:
        return ConcessaoAfastamentoColors.ink;
      case StatusSolicitacaoConcessao.deferido:
      case StatusSolicitacaoConcessao.homologado:
      case StatusSolicitacaoConcessao.confirmado:
      case StatusSolicitacaoConcessao.migrado:
      case StatusSolicitacaoConcessao.negado:
      case StatusSolicitacaoConcessao.indeferido:
      case StatusSolicitacaoConcessao.desconhecido:
        return Colors.white;
    }
  }

  String get description {
    switch (this) {
      case StatusSolicitacaoConcessao.pendente:
        return 'A ser confirmada pelo chefe imediato (servidores) ou DRH (férias de escala coletiva de membro)';
      case StatusSolicitacaoConcessao.confirmado:
        return 'A ser analisada pelo 2º Subprocurador Geral';
      case StatusSolicitacaoConcessao.deferido:
        return 'Deferida pelo 2º Subprocurador Geral';
      case StatusSolicitacaoConcessao.indeferido:
      case StatusSolicitacaoConcessao.negado:
        return 'Indeferida pelo 2º Subprocurador Geral';
      case StatusSolicitacaoConcessao.cancelado:
        return 'Desistência do solicitante';
      case StatusSolicitacaoConcessao.homologado:
      case StatusSolicitacaoConcessao.migrado:
        return 'Analisada pelo DHR/Secretário Geral';
      case StatusSolicitacaoConcessao.desconhecido:
        return 'Situação não informada';
    }
  }

  bool get isInLegend => this != StatusSolicitacaoConcessao.desconhecido;
}

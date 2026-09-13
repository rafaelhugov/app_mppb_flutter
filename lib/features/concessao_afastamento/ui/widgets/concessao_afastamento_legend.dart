import 'package:flutter/material.dart';

import '../../models/status_solicitacao_concessao.dart';
import '../../models/tipo_ausencia.dart';
import 'concessao_afastamento_theme.dart';

class ConcessaoAfastamentoLegend extends StatelessWidget {
  const ConcessaoAfastamentoLegend({super.key});

  @override
  Widget build(BuildContext context) {
    const tipos = [
      TipoAusencia.ferias,
      TipoAusencia.licenca,
      TipoAusencia.licencaEleitoral,
      TipoAusencia.plantao,
      TipoAusencia.diarias,
      TipoAusencia.outros,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tipos.map((tipo) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF241D19),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x33A96A1D)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tipo.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                tipo.label,
                style: const TextStyle(
                  color: Color(0xFFEDE2CF),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ConcessaoStatusLegend extends StatelessWidget {
  const ConcessaoStatusLegend({super.key});

  static const _statuses = [
    StatusSolicitacaoConcessao.pendente,
    StatusSolicitacaoConcessao.confirmado,
    StatusSolicitacaoConcessao.indeferido,
    StatusSolicitacaoConcessao.deferido,
    StatusSolicitacaoConcessao.cancelado,
    StatusSolicitacaoConcessao.homologado,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legenda',
            style: TextStyle(
              color: ConcessaoAfastamentoColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statuses
                .map((status) => _StatusLegendItem(status: status))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatusLegendItem extends StatelessWidget {
  final StatusSolicitacaoConcessao status;

  const _StatusLegendItem({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 340),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EDF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 72),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: status.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: status.foreground,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              status.description,
              style: const TextStyle(
                color: ConcessaoAfastamentoColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

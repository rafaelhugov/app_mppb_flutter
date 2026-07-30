import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/concessao_folga.dart';
import 'concessao_folga_theme.dart';

class ConcessaoFolgaDetailsSheet extends StatelessWidget {
  final ConcessaoFolga concessao;

  const ConcessaoFolgaDetailsSheet({super.key, required this.concessao});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              concessao.titulo,
              style: const TextStyle(
                color: ConcessaoFolgaColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _DetailLine(
              label: 'Dias concedidos',
              value: '${concessao.diasConcedidos}',
            ),
            _DetailLine(
              label: 'Saldo restante',
              value: '${concessao.saldoRestante} dias',
            ),
            if (concessao.inicioPeriodoAquisitivo != null &&
                concessao.finalPeriodoAquisitivo != null)
              _DetailLine(
                label: 'Período aquisitivo',
                value:
                    '${dateFormat.format(concessao.inicioPeriodoAquisitivo!)} a ${dateFormat.format(concessao.finalPeriodoAquisitivo!)}',
              ),
            const SizedBox(height: 12),
            const Text(
              'Solicitações vinculadas',
              style: TextStyle(
                color: ConcessaoFolgaColors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            if (concessao.solicitacoes.isEmpty)
              const Text(
                'Nenhum período de gozo programado',
                style: TextStyle(color: ConcessaoFolgaColors.muted),
              )
            else
              ...concessao.solicitacoes.map(
                (solicitacao) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ConcessaoFolgaColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: solicitacao.status.color.withAlpha(100),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        solicitacao.tipo.label,
                        style: const TextStyle(
                          color: ConcessaoFolgaColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(solicitacao.inicio)} a ${dateFormat.format(solicitacao.fim)}',
                        style: const TextStyle(
                          color: ConcessaoFolgaColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${solicitacao.status.label} - ${solicitacao.diasCalculados} dia(s)',
                        style: TextStyle(
                          color: solicitacao.status.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: ConcessaoFolgaColors.muted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ConcessaoFolgaColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

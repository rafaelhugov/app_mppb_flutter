import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/concessao_folga.dart';
import 'concessao_folga_details_sheet.dart';
import 'concessao_folga_theme.dart';

class ConcessaoFolgaCard extends StatelessWidget {
  final ConcessaoFolga concessao;

  const ConcessaoFolgaCard({super.key, required this.concessao});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final primeiraSolicitacao = concessao.solicitacoes.isEmpty
        ? null
        : concessao.solicitacoes.first;

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => ConcessaoFolgaDetailsSheet(concessao: concessao),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(235),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: concessao.tipo.color, width: 5),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16432B1D),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    concessao.titulo,
                    style: const TextStyle(
                      color: ConcessaoFolgaColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _SaldoChip(saldo: concessao.saldoRestante),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Dias concedidos',
                    value: '${concessao.diasConcedidos}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    label: 'Saldo disponível',
                    value: '${concessao.saldoRestante} dias',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (primeiraSolicitacao == null)
              const Text(
                'Nenhum período de gozo programado',
                style: TextStyle(
                  color: ConcessaoFolgaColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              )
            else ...[
              Text(
                'Período: ${dateFormat.format(primeiraSolicitacao.inicio)} a ${dateFormat.format(primeiraSolicitacao.fim)}',
                style: const TextStyle(
                  color: ConcessaoFolgaColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: primeiraSolicitacao.status.color.withAlpha(24),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: primeiraSolicitacao.status.color.withAlpha(90),
                      ),
                    ),
                    child: Text(
                      primeiraSolicitacao.status.label,
                      style: TextStyle(
                        color: primeiraSolicitacao.status.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (concessao.solicitacoes.length > 1) ...[
                    const SizedBox(width: 8),
                    Text(
                      '+${concessao.solicitacoes.length - 1}',
                      style: const TextStyle(
                        color: ConcessaoFolgaColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SaldoChip extends StatelessWidget {
  final int saldo;

  const _SaldoChip({required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAD4A3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$saldo dias',
        style: const TextStyle(
          color: Color(0xFF5C3C22),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ConcessaoFolgaColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ConcessaoFolgaColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: ConcessaoFolgaColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final typeColor = concessao.tipo.color;
    final onColor = typeColor.computeLuminance() > 0.45
        ? const Color(0xFF202322)
        : Colors.white;
    final secondaryColor = typeColor.computeLuminance() > 0.45
        ? const Color(0xD9202322)
        : const Color(0xE6FFFFFF);
    final tileColor = Colors.white.withValues(alpha: 0.18);
    final tileBorder = Colors.white.withValues(alpha: 0.36);

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
          color: typeColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: onColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    concessao.titulo,
                    style: TextStyle(
                      color: onColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _SaldoChip(saldo: concessao.saldoRestante, color: onColor),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Dias concedidos',
                    value: '${concessao.diasConcedidos}',
                    background: tileColor,
                    border: tileBorder,
                    labelColor: secondaryColor,
                    valueColor: onColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    label: 'Saldo disponível',
                    value: '${concessao.saldoRestante} dias',
                    background: tileColor,
                    border: tileBorder,
                    labelColor: secondaryColor,
                    valueColor: onColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (primeiraSolicitacao == null)
              const Text(
                'Nenhum período de gozo programado',
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              )
            else ...[
              Text(
                'Período: ${dateFormat.format(primeiraSolicitacao.inicio)} a ${dateFormat.format(primeiraSolicitacao.fim)}',
                style: TextStyle(
                  color: onColor,
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
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.36),
                      ),
                    ),
                    child: Text(
                      primeiraSolicitacao.status.label,
                      style: TextStyle(
                        color: onColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (concessao.solicitacoes.length > 1) ...[
                    const SizedBox(width: 8),
                    Text(
                      '+${concessao.solicitacoes.length - 1}',
                      style: TextStyle(
                        color: secondaryColor,
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
  final Color color;

  const _SaldoChip({required this.saldo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.36)),
      ),
      child: Text(
        '$saldo dias',
        style: TextStyle(
          color: color,
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
  final Color background;
  final Color border;
  final Color labelColor;
  final Color valueColor;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.background,
    required this.border,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.47)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

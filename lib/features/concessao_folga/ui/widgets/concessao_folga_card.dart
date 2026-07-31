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
    final cardColor = Color.lerp(const Color(0xFFFFF8EA), typeColor, 0.12)!;
    final cardBorder = Color.lerp(cardColor, typeColor, 0.32)!;
    final tileColor = Color.lerp(const Color(0xFFFFFBF4), typeColor, 0.06)!;
    final titleColor = Color.lerp(typeColor, ConcessaoFolgaColors.ink, 0.12)!;

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
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: typeColor.withAlpha(18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            const BoxShadow(
              color: Color(0x10432B1D),
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
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    concessao.titulo,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _SaldoChip(saldo: concessao.saldoRestante, color: typeColor),
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
                    border: cardBorder,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    label: 'Saldo disponível',
                    value: '${concessao.saldoRestante} dias',
                    background: tileColor,
                    border: cardBorder,
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
                style: TextStyle(
                  color: titleColor,
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
                      color: Color.lerp(
                        const Color(0xFFFFFBF4),
                        typeColor,
                        0.08,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: typeColor.withAlpha(105)),
                    ),
                    child: Text(
                      primeiraSolicitacao.status.label,
                      style: TextStyle(
                        color: titleColor,
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
  final Color color;

  const _SaldoChip({required this.saldo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Color.lerp(const Color(0xFFFFF8EA), color, 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(90)),
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

  const _InfoTile({
    required this.label,
    required this.value,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withAlpha(120)),
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

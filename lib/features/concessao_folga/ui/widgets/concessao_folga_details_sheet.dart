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

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DEDA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                concessao.titulo,
                style: const TextStyle(
                  color: ConcessaoFolgaColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9EDF0)),
                ),
                child: Column(
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Solicitações vinculadas',
                style: TextStyle(
                  color: ConcessaoFolgaColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (concessao.solicitacoes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE9EDF0)),
                  ),
                  child: const Text(
                    'Nenhum período de gozo programado',
                    style: TextStyle(color: ConcessaoFolgaColors.muted),
                  ),
                )
              else
                ...concessao.solicitacoes.map(
                  (solicitacao) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9EDF0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 56,
                          decoration: BoxDecoration(
                            color: solicitacao.status.color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                solicitacao.tipo.label,
                                style: const TextStyle(
                                  color: ConcessaoFolgaColors.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${dateFormat.format(solicitacao.inicio)} a ${dateFormat.format(solicitacao.fim)}',
                                style: const TextStyle(
                                  color: ConcessaoFolgaColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${solicitacao.status.label} - ${solicitacao.diasCalculados} dia(s)',
                                style: TextStyle(
                                  color: solicitacao.status.color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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

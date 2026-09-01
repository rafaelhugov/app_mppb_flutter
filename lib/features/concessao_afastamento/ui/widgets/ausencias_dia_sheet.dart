import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/ausencia_calendario.dart';
import 'concessao_afastamento_theme.dart';

class AusenciasDiaSheet extends StatelessWidget {
  final DateTime dia;
  final List<AusenciaCalendario> ausencias;

  const AusenciasDiaSheet({
    super.key,
    required this.dia,
    required this.ausencias,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Text(
                dateFormat.format(dia),
                style: const TextStyle(
                  color: ConcessaoAfastamentoColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                itemCount: ausencias.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ausencia = ausencias[index];
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ConcessaoAfastamentoColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(color: ausencia.tipo.color, width: 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ausencia.descricao,
                          style: const TextStyle(
                            color: ConcessaoAfastamentoColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${dateFormat.format(ausencia.dataInicio)} a ${dateFormat.format(ausencia.dataFim)}',
                          style: const TextStyle(
                            color: ConcessaoAfastamentoColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (ausencia.status?.isNotEmpty == true) ...[
                          const SizedBox(height: 5),
                          Text(
                            ausencia.status!,
                            style: const TextStyle(
                              color: ConcessaoAfastamentoColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

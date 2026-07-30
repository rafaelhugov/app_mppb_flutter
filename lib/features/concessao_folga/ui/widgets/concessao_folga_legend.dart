import 'package:flutter/material.dart';

import '../../models/tipo_ausencia.dart';
import 'concessao_folga_theme.dart';

class ConcessaoFolgaLegend extends StatelessWidget {
  const ConcessaoFolgaLegend({super.key});

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
      spacing: 10,
      runSpacing: 8,
      children: tipos.map((tipo) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: tipo.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              tipo.label,
              style: const TextStyle(
                color: ConcessaoFolgaColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

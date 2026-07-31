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

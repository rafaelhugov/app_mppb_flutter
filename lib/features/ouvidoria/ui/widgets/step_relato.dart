import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ouvidoria_provider.dart';
import 'ouvidoria_form_style.dart';

class StepRelato extends ConsumerWidget {
  const StepRelato({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ouvidoriaProvider);
    final notifier = ref.read(ouvidoriaProvider.notifier);
    final model = state.requestModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: OuvidoriaFormStyle.surface,
            border: Border.all(color: OuvidoriaFormStyle.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Descreva o fato com o máximo de detalhes possível. Sempre informe, quando souber:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: OuvidoriaFormStyle.ink,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              _buildHintItem('O que aconteceu;'),
              _buildHintItem(
                'Onde ocorreu (endereço, bairro, município ou referência);',
              ),
              _buildHintItem('Quando ocorreu (data e horário aproximados);'),
              _buildHintItem('Quem são os envolvidos (se conhecido);'),
              _buildHintItem(
                'Outras informações que possam auxiliar a apuração.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: model.texto,
          decoration: OuvidoriaFormStyle.inputDecoration(
            labelText: 'Descrição do Fato',
            alignLabelWithHint: true,
            hintText:
                'Exemplo:\n\nNo dia 15/07/2026, por volta das 14h30, na Rua Exemplo, nº 100, Bairro Centro, município de João Pessoa/PB, ocorreu...',
          ),
          maxLines: 8,
          onChanged: (val) => notifier.updateField((m) => m.texto = val),
        ),
      ],
    );
  }

  Widget _buildHintItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: OuvidoriaFormStyle.ink,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: OuvidoriaFormStyle.ink,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ouvidoria_provider.dart';

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
            color: const Color(0xFFF7EFE3),
            border: Border.all(color: const Color.fromRGBO(214, 169, 47, 0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Descreva o fato com o máximo de detalhes possível. Sempre informe, quando souber:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A241D)),
              ),
              SizedBox(height: 8),
              Text('• O que aconteceu;'),
              Text('• Onde ocorreu (endereço, bairro, município ou referência);'),
              Text('• Quando ocorreu (data e horário aproximados);'),
              Text('• Quem são os envolvidos (se conhecido);'),
              Text('• Outras informações que possam auxiliar a apuração.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: model.texto,
          decoration: const InputDecoration(
            labelText: 'Descrição do Fato',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            hintText: 'Exemplo:\n\nNo dia 15/07/2026, por volta das 14h30, na Rua Exemplo, nº 100, Bairro Centro, município de João Pessoa/PB, ocorreu...',
          ),
          maxLines: 8,
          onChanged: (val) => notifier.updateField((m) => m.texto = val),
        ),
      ],
    );
  }
}

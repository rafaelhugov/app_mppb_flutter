import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ouvidoria_provider.dart';
import '../../data/models/combo_models.dart';

class StepClassificacao extends ConsumerWidget {
  const StepClassificacao({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ouvidoriaProvider);
    final notifier = ref.read(ouvidoriaProvider.notifier);
    final model = state.requestModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Sigilo', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Caso seja declarado sigilo, apenas os fatos relatados estarão protegidos.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            Switch(
              value: model.sigilo,
              activeColor: const Color(0xFF8F2A1D),
              onChanged: (val) => notifier.updateField((m) => m.sigilo = val),
            ),
          ],
        ),
        if (model.sigilo) ...[
          TextFormField(
            initialValue: model.justificativaSigilo,
            decoration: const InputDecoration(
              labelText: 'Justificativa do Sigilo',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            maxLines: 2,
            onChanged: (val) => notifier.updateField((m) => m.justificativaSigilo = val),
          ),
          const SizedBox(height: 12),
        ],
        
        if (!model.sigilo) ...[
          const Text('Origem do Fato', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A241D))),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: model.origemMunicipio,
            decoration: const InputDecoration(labelText: 'Município de Origem *', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
            isDense: true,
            items: state.municipios.map((c) => DropdownMenuItem(value: c.id, child: Text(c.descricao))).toList(),
            onChanged: (val) {
              notifier.updateField((m) => m.origemMunicipio = val);
              notifier.loadBairros(val);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: model.origemBairro,
            decoration: const InputDecoration(labelText: 'Bairro de Origem *', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
            isDense: true,
            disabledHint: const Text('Selecione primeiro o Município'),
            items: (model.origemMunicipio == null || state.bairros.isEmpty) 
                ? null 
                : state.bairros.map((c) => DropdownMenuItem(value: c.id, child: Text(c.descricao))).toList(),
            onChanged: (val) => notifier.updateField((m) => m.origemBairro = val),
          ),
          const SizedBox(height: 24),
        ],

        const Text('Classificação', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A241D))),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: model.tipo,
          decoration: const InputDecoration(labelText: 'Tipo de Manifestação', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          isDense: true,
          items: state.tipos.map((c) => DropdownMenuItem(value: c.id, child: Text(c.descricao))).toList(),
          onChanged: (val) => notifier.updateField((m) => m.tipo = val),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: model.materia,
          decoration: const InputDecoration(labelText: 'Matéria', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          isDense: true,
          items: state.materias.map((c) => DropdownMenuItem(value: c.id, child: Text(c.descricao))).toList(),
          onChanged: (val) {
            notifier.updateField((m) => m.materia = val);
            notifier.loadAssuntos(val);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: model.assunto,
          decoration: const InputDecoration(labelText: 'Assunto', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          isDense: true,
          disabledHint: const Text('Selecione primeiro a Matéria'),
          items: (model.materia == null || state.assuntos.isEmpty)
              ? null
              : state.assuntos.map((c) => DropdownMenuItem(value: c.id, child: Text(c.descricao))).toList(),
          onChanged: (val) => notifier.updateField((m) => m.assunto = val),
        ),
        const SizedBox(height: 24),

        const Text('Destinatário', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A241D))),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: model.municipio,
          decoration: const InputDecoration(labelText: 'Município (Órgão Relacionado)', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          isDense: true,
          items: state.municipios.map((c) => DropdownMenuItem(value: c.id, child: Text(c.descricao))).toList(),
          onChanged: (val) => notifier.updateField((m) => m.municipio = val),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ouvidoria_provider.dart';
import 'ouvidoria_form_style.dart';

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
                  Text(
                    'Sigilo',
                    style: TextStyle(
                      color: OuvidoriaFormStyle.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Caso seja declarado sigilo, apenas os fatos relatados estarão protegidos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: OuvidoriaFormStyle.muted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: model.sigilo,
              activeThumbColor: OuvidoriaFormStyle.accent,
              onChanged: (val) => notifier.updateField((m) => m.sigilo = val),
            ),
          ],
        ),
        if (model.sigilo) ...[
          const SizedBox(height: 14),
          TextFormField(
            initialValue: model.justificativaSigilo,
            decoration: OuvidoriaFormStyle.inputDecoration(
              labelText: 'Justificativa do Sigilo',
            ),
            maxLines: 2,
            onChanged: (val) =>
                notifier.updateField((m) => m.justificativaSigilo = val),
          ),
          const SizedBox(height: 20),
        ],

        if (!model.sigilo) ...[
          const SizedBox(height: 16),
          const Text(
            'Origem do Fato',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: OuvidoriaFormStyle.ink,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: model.origemMunicipio,
            isExpanded: true,
            decoration: OuvidoriaFormStyle.inputDecoration(
              labelText: 'Município de Origem *',
            ),
            items: state.municipios
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      c.descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              notifier.updateField((m) => m.origemMunicipio = val);
              notifier.loadBairros(val);
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: model.origemBairro,
            isExpanded: true,
            decoration: OuvidoriaFormStyle.inputDecoration(
              labelText: 'Bairro de Origem *',
            ),
            disabledHint: const Text(
              'Selecione primeiro o Município',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            items: (model.origemMunicipio == null || state.bairros.isEmpty)
                ? null
                : state.bairros
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            c.descricao,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
            onChanged: (val) =>
                notifier.updateField((m) => m.origemBairro = val),
          ),
          const SizedBox(height: 28),
        ],

        const Text(
          'Classificação',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: OuvidoriaFormStyle.ink,
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          initialValue: model.tipo,
          isExpanded: true,
          decoration: OuvidoriaFormStyle.inputDecoration(
            labelText: 'Tipo de Manifestação',
          ),
          items: state.tipos
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    c.descricao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => notifier.updateField((m) => m.tipo = val),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          initialValue: model.materia,
          isExpanded: true,
          decoration: OuvidoriaFormStyle.inputDecoration(labelText: 'Matéria'),
          items: state.materias
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    c.descricao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            notifier.updateField((m) => m.materia = val);
            notifier.loadAssuntos(val);
          },
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          initialValue: model.assunto,
          isExpanded: true,
          decoration: OuvidoriaFormStyle.inputDecoration(labelText: 'Assunto'),
          disabledHint: const Text(
            'Selecione primeiro a Matéria',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          items: (model.materia == null || state.assuntos.isEmpty)
              ? null
              : state.assuntos
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.descricao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
          onChanged: (val) => notifier.updateField((m) => m.assunto = val),
        ),
        const SizedBox(height: 28),

        const Text(
          'Destinatário',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: OuvidoriaFormStyle.ink,
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          initialValue: model.municipio,
          isExpanded: true,
          decoration: OuvidoriaFormStyle.inputDecoration(
            labelText: 'Município (Órgão Relacionado)',
          ),
          items: state.municipios
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    c.descricao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => notifier.updateField((m) => m.municipio = val),
        ),
      ],
    );
  }
}

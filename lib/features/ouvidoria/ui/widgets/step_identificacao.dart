import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ouvidoria_provider.dart';
import '../../utils/input_formatters.dart';
import 'ouvidoria_form_style.dart';

class StepIdentificacao extends ConsumerWidget {
  const StepIdentificacao({super.key});

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
                    'Manifestação Anônima',
                    style: TextStyle(
                      color: OuvidoriaFormStyle.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'O anonimato inviabiliza a identificação, mas denúncias sem informações podem não ser atendidas.',
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
              value: model.anonimo,
              activeThumbColor: OuvidoriaFormStyle.accent,
              onChanged: (val) => notifier.updateField((m) => m.anonimo = val),
            ),
          ],
        ),
        if (!model.anonimo) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: OuvidoriaFormStyle.border, height: 1),
          ),
          const Text(
            'Dados do Remetente',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: OuvidoriaFormStyle.ink,
            ),
          ),
          const SizedBox(height: 10),
          RadioGroup<String>(
            groupValue: model.tipoRemetente,
            onChanged: (val) =>
                notifier.updateField((m) => m.tipoRemetente = val!),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () =>
                        notifier.updateField((m) => m.tipoRemetente = 'F'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Radio<String>(
                            value: 'F',
                            activeColor: OuvidoriaFormStyle.accent,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Pessoa Física',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: OuvidoriaFormStyle.ink,
                              fontSize: 11.4,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () =>
                        notifier.updateField((m) => m.tipoRemetente = 'J'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Radio<String>(
                            value: 'J',
                            activeColor: OuvidoriaFormStyle.accent,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Pessoa Jurídica',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: OuvidoriaFormStyle.ink,
                              fontSize: 11.4,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: model.cpfCnpj,
            decoration: OuvidoriaFormStyle.inputDecoration(
              labelText: model.tipoRemetente == 'F' ? 'CPF' : 'CNPJ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CpfCnpjInputFormatter()],
            onChanged: (val) => notifier.updateField((m) => m.cpfCnpj = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: model.nome,
            decoration: OuvidoriaFormStyle.inputDecoration(labelText: 'Nome'),
            onChanged: (val) => notifier.updateField((m) => m.nome = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: model.nomeSocial,
            decoration: OuvidoriaFormStyle.inputDecoration(
              labelText: 'Nome Social (Opcional)',
            ),
            onChanged: (val) => notifier.updateField((m) => m.nomeSocial = val),
          ),
          const SizedBox(height: 12),
          if (model.tipoRemetente == 'F') ...[
            DropdownButtonFormField<String>(
              initialValue: model.sexo,
              isExpanded: true,
              decoration: OuvidoriaFormStyle.inputDecoration(labelText: 'Sexo'),
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Masculino')),
                DropdownMenuItem(value: 'F', child: Text('Feminino')),
                DropdownMenuItem(value: 'O', child: Text('Outro')),
              ],
              onChanged: (val) => notifier.updateField((m) => m.sexo = val),
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            initialValue: model.endereco,
            decoration: OuvidoriaFormStyle.inputDecoration(
              labelText: 'Endereço',
            ),
            onChanged: (val) => notifier.updateField((m) => m.endereco = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: model.telefone,
            decoration: OuvidoriaFormStyle.inputDecoration(
              labelText: 'Telefone / Celular',
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [TelefoneInputFormatter()],
            onChanged: (val) => notifier.updateField((m) => m.telefone = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: model.email,
            decoration: OuvidoriaFormStyle.inputDecoration(labelText: 'E-mail'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => notifier.updateField((m) => m.email = val),
          ),
        ],
      ],
    );
  }
}

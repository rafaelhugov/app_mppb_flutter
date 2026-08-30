import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ouvidoria_provider.dart';
import '../../utils/input_formatters.dart';

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
                  Text('Manifestação Anônima', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text('O anonimato inviabiliza a identificação, mas denúncias sem informações podem não ser atendidas.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            Switch(
              value: model.anonimo,
              activeColor: const Color(0xFF8F2A1D),
              onChanged: (val) => notifier.updateField((m) => m.anonimo = val),
            ),
          ],
        ),
        if (!model.anonimo) ...[
          const Divider(),
          const Text('Dados do Remetente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3A241D))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => notifier.updateField((m) => m.tipoRemetente = 'F'),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'F',
                        groupValue: model.tipoRemetente,
                        activeColor: const Color(0xFF8F2A1D),
                        onChanged: (val) => notifier.updateField((m) => m.tipoRemetente = val!),
                      ),
                      const Expanded(child: Text('Pessoa Física')),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => notifier.updateField((m) => m.tipoRemetente = 'J'),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'J',
                        groupValue: model.tipoRemetente,
                        activeColor: const Color(0xFF8F2A1D),
                        onChanged: (val) => notifier.updateField((m) => m.tipoRemetente = val!),
                      ),
                      const Expanded(child: Text('Pessoa Jurídica')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            initialValue: model.cpfCnpj,
            decoration: InputDecoration(
              labelText: model.tipoRemetente == 'F' ? 'CPF' : 'CNPJ',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CpfCnpjInputFormatter()],
            onChanged: (val) => notifier.updateField((m) => m.cpfCnpj = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: model.nome,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (val) => notifier.updateField((m) => m.nome = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: model.nomeSocial,
            decoration: const InputDecoration(
              labelText: 'Nome Social (Opcional)',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (val) => notifier.updateField((m) => m.nomeSocial = val),
          ),
          const SizedBox(height: 12),
          if (model.tipoRemetente == 'F') ...[
            DropdownButtonFormField<String>(
              value: model.sexo,
              decoration: const InputDecoration(
                labelText: 'Sexo',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
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
            decoration: const InputDecoration(
              labelText: 'Endereço',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (val) => notifier.updateField((m) => m.endereco = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: model.telefone,
            decoration: const InputDecoration(
              labelText: 'Telefone / Celular',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [TelefoneInputFormatter()],
            onChanged: (val) => notifier.updateField((m) => m.telefone = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: model.email,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => notifier.updateField((m) => m.email = val),
          ),
        ],
      ],
    );
  }
}

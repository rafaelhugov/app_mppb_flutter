import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ouvidoria_provider.dart';
import 'captcha_widget.dart';
import 'ouvidoria_form_style.dart';

class StepRevisaoEnvio extends ConsumerWidget {
  const StepRevisaoEnvio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ouvidoriaProvider);
    final model = state.requestModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revisão dos Dados',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: OuvidoriaFormStyle.ink,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: OuvidoriaFormStyle.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OuvidoriaFormStyle.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('Anônimo:', model.anonimo ? 'Sim' : 'Não'),
              if (!model.anonimo) ...[
                _buildReviewRow('Remetente:', model.nome ?? ''),
                _buildReviewRow('CPF/CNPJ:', model.cpfCnpj ?? ''),
                _buildReviewRow('Email:', model.email ?? ''),
              ],
              const Divider(),
              _buildReviewRow('Sigilo:', model.sigilo ? 'Sim' : 'Não'),
              _buildReviewRow('Tipo:', _getComboDesc(model.tipo, state.tipos)),
              _buildReviewRow(
                'Matéria:',
                _getComboDesc(model.materia, state.materias),
              ),
              _buildReviewRow(
                'Assunto:',
                _getComboDesc(model.assunto, state.assuntos),
              ),
              _buildReviewRow(
                'Destinatário:',
                _getComboDesc(model.municipio, state.municipios),
              ),
              const Divider(),
              _buildReviewRow(
                'Descrição:',
                model.texto.length > 50
                    ? '${model.texto.substring(0, 50)}...'
                    : model.texto,
              ),
              const Divider(),
              _buildReviewRow('Anexos:', '${model.anexos.length} arquivo(s)'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const CaptchaWidget(),
        if (state.uploadProgress > 0 && state.isSubmitting) ...[
          const SizedBox(height: 16),
          const Text(
            'Enviando anexos...',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: OuvidoriaFormStyle.ink,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.uploadProgress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(
              OuvidoriaFormStyle.accent,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: OuvidoriaFormStyle.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(color: OuvidoriaFormStyle.ink),
            ),
          ),
        ],
      ),
    );
  }

  String _getComboDesc(int? id, List combos) {
    if (id == null) return '-';
    try {
      final item = combos.firstWhere((c) => c.id == id);
      return item.descricao;
    } catch (_) {
      return id.toString();
    }
  }
}

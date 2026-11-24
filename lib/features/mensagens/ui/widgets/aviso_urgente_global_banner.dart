import 'package:flutter/material.dart';

import '../../models/mensagem_aviso_model.dart';
import 'mensagens_theme.dart';

class AvisoUrgenteGlobalBanner extends StatelessWidget {
  const AvisoUrgenteGlobalBanner({
    super.key,
    required this.urgentes,
    required this.onTap,
  });

  final List<MensagemAvisoModel> urgentes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (urgentes.isEmpty) {
      return const SizedBox.shrink();
    }
    final count = urgentes.length;
    final primeira = urgentes.first;
    final titulo = count == 1
        ? (primeira.titulo?.trim().isNotEmpty == true
              ? primeira.titulo!.trim()
              : 'Você tem 1 aviso urgente pendente de leitura')
        : 'Você tem $count avisos urgentes pendentes de leitura';

    return Material(
      color: const Color(0xFFB71C1C),
      child: InkWell(
        onTap: onTap,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                const Icon(
                  Icons.priority_high_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    count == 1 ? 'URGENTE: $titulo' : titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Ler',
                    style: TextStyle(
                      color: Color(0xFFB71C1C),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool?> mostrarModalAvisoUrgente(
  BuildContext context, {
  required List<MensagemAvisoModel> urgentes,
}) {
  final count = urgentes.length;
  final mensagem = count == 1
      ? 'Você recebeu 1 aviso marcado como urgente aguardando sua leitura.'
      : 'Você recebeu $count avisos marcados como urgentes aguardando sua leitura.';

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: MensagensColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: MensagensColors.border),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: MensagensColors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: MensagensColors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Aviso Urgente',
              style: TextStyle(
                color: MensagensColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        mensagem,
        style: const TextStyle(
          fontSize: 13.5,
          color: MensagensColors.muted,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: MensagensColors.muted),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Depois'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: MensagensColors.brandDark,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Ler agora'),
        ),
      ],
    ),
  );
}

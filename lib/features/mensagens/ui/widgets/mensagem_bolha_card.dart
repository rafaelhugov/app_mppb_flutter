import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/mensagem_aviso_model.dart';
import 'anexo_preview_widget.dart';

class MensagemBolhaCard extends StatelessWidget {
  const MensagemBolhaCard({
    super.key,
    required this.mensagem,
    this.onTap,
    this.onConfirmarCiencia,
    this.onArquivar,
  });

  final MensagemAvisoModel mensagem;
  final VoidCallback? onTap;
  final VoidCallback? onConfirmarCiencia;
  final VoidCallback? onArquivar;

  Color _corPrioridade(PrioridadeMensagem p) {
    return switch (p) {
      PrioridadeMensagem.urgente => const Color(0xFFB91C1C),
      PrioridadeMensagem.importante => const Color(0xFFD97706),
      PrioridadeMensagem.normal => const Color(0xFF1E3A8A),
    };
  }

  String _rotuloPrioridade(PrioridadeMensagem p) {
    return switch (p) {
      PrioridadeMensagem.urgente => 'URGENTE',
      PrioridadeMensagem.importante => 'IMPORTANTE',
      PrioridadeMensagem.normal => 'AVISO',
    };
  }

  String _formatarData(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final cor = _corPrioridade(mensagem.prioridade);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: mensagem.naoLida ? 2.5 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        side: BorderSide(
          color: mensagem.naoLida ? cor : const Color(0xFFE2E8F0),
          width: mensagem.naoLida ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _rotuloPrioridade(mensagem.prioridade),
                      style: TextStyle(
                        color: cor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mensagem.remetenteNome ?? 'Procuradoria-Geral de Justiça',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  if (mensagem.naoLida)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NOVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (onArquivar != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: mensagem.arquivada ? 'Desarquivar' : 'Arquivar',
                      onPressed: onArquivar,
                      icon: Icon(
                        mensagem.arquivada
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
              if (mensagem.titulo != null &&
                  mensagem.titulo!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  mensagem.titulo!,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
              if (mensagem.conteudo != null &&
                  mensagem.conteudo!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  mensagem.conteudo!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
              for (final anexo in mensagem.anexos)
                AnexoPreviewWidget(mensagemId: mensagem.id, anexo: anexo),
              if (mensagem.exigeCiencia) ...[
                const SizedBox(height: 10),
                if (mensagem.dataCiencia == null)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onConfirmarCiencia,
                      icon: const Icon(Icons.verified_outlined, size: 18),
                      label: const Text('Confirmar Ciência'),
                    ),
                  )
                else
                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: Color(0xFF15803D),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ciência confirmada em ${_formatarData(mensagem.dataCiencia)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatarData(mensagem.dataEnvio),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.done_all,
                    size: 16,
                    color: mensagem.status == StatusDestinatario.lido
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


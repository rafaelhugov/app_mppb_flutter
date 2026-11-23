import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/mensagem_aviso_model.dart';
import 'anexo_preview_widget.dart';
import 'mensagens_theme.dart';

class MensagemBolhaCard extends StatelessWidget {
  const MensagemBolhaCard({
    super.key,
    required this.mensagem,
    this.onTap,
    this.onConfirmarCiencia,
    this.onArquivar,
    this.incluirAnexos = true,
    this.incluirCiencia = true,
  });

  final MensagemAvisoModel mensagem;
  final VoidCallback? onTap;
  final VoidCallback? onConfirmarCiencia;
  final VoidCallback? onArquivar;
  final bool incluirAnexos;
  final bool incluirCiencia;

  Color _corPrioridade(PrioridadeMensagem p) {
    return switch (p) {
      PrioridadeMensagem.urgente => MensagensColors.red,
      PrioridadeMensagem.importante => MensagensColors.orange,
      PrioridadeMensagem.normal => MensagensColors.blue,
    };
  }

  String _rotuloPrioridade(PrioridadeMensagem p) {
    return switch (p) {
      PrioridadeMensagem.urgente => 'Urgente',
      PrioridadeMensagem.importante => 'Importante',
      PrioridadeMensagem.normal => 'Aviso',
    };
  }

  String _formatarData(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final cor = _corPrioridade(mensagem.prioridade);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: MensagensColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mensagem.naoLida
              ? cor.withValues(alpha: 0.45)
              : MensagensColors.border,
          width: mensagem.naoLida ? 1.4 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101828),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cor.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        _rotuloPrioridade(mensagem.prioridade),
                        style: TextStyle(
                          color: cor,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mensagem.remetenteNome?.trim().isNotEmpty == true
                            ? formatarNomeProprio(mensagem.remetenteNome)
                            : 'Procuradoria-Geral de Justiça',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          color: MensagensColors.muted,
                        ),
                      ),
                    ),
                    if (mensagem.naoLida)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: MensagensColors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Novo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
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
                          color: MensagensColors.muted,
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
                      fontWeight: FontWeight.w800,
                      color: MensagensColors.ink,
                    ),
                  ),
                ],
                if (mensagem.conteudo != null &&
                    mensagem.conteudo!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  MarkdownBody(
                    data: mensagem.conteudo!,
                    selectable: false,
                    onTapLink: (_, href, _) {
                      if (href != null && href.isNotEmpty) {
                        final uri = Uri.tryParse(href);
                        if (uri != null) {
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: MensagensColors.ink,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: MensagensColors.ink,
                      ),
                      em: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: MensagensColors.ink,
                      ),
                      del: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: MensagensColors.muted,
                      ),
                      listBullet: const TextStyle(
                        fontSize: 14,
                        color: MensagensColors.ink,
                      ),
                      a: const TextStyle(
                        color: MensagensColors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
                if (incluirAnexos)
                  for (final anexo in mensagem.anexos)
                    AnexoPreviewWidget(mensagemId: mensagem.id, anexo: anexo),
                if (incluirCiencia && mensagem.exigeCiencia) ...[
                  const SizedBox(height: 12),
                  if (mensagem.dataCiencia == null)
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MensagensColors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onConfirmarCiencia,
                        icon: const Icon(Icons.verified_outlined, size: 18),
                        label: const Text(
                          'Confirmar Ciência',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: MensagensColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: MensagensColors.green,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Ciência confirmada em ${_formatarData(mensagem.dataCiencia)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: MensagensColors.green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        color: MensagensColors.muted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: mensagem.status == StatusDestinatario.lido
                          ? MensagensColors.green
                          : MensagensColors.muted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

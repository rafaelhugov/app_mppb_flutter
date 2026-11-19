import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/mensagem_anexo_model.dart';
import '../../models/mensagem_aviso_model.dart';
import 'mensagens_theme.dart';

/// Item compacto de lista estilo conversa do WhatsApp para a caixa de avisos.
class MensagemConversaTile extends StatelessWidget {
  const MensagemConversaTile({
    super.key,
    required this.mensagem,
    required this.onTap,
  });

  final MensagemAvisoModel mensagem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titulo = (mensagem.titulo != null && mensagem.titulo!.trim().isNotEmpty)
        ? mensagem.titulo!.trim()
        : (mensagem.remetenteNome?.trim().isNotEmpty == true
              ? mensagem.remetenteNome!.trim()
              : 'Comunicado Institucional');
    final preview = _buildPreviewText();
    final horaTexto = _formatarHorarioWhatsApp(mensagem.dataEnvio);
    final naoLida = mensagem.naoLida;

    return Material(
      color: MensagensColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AvatarRemetente(
                nome: mensagem.remetenteNome ?? titulo,
                prioridade: mensagem.prioridade,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: naoLida
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: MensagensColors.ink,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          horaTexto,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: naoLida
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: naoLida
                                ? MensagensColors.green
                                : MensagensColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusCheckIcon(status: mensagem.status),
                        const SizedBox(width: 4),
                        if (mensagem.anexos.isNotEmpty) ...[
                          Icon(
                            _iconeAnexo(mensagem.anexos.first.categoria),
                            size: 15,
                            color: MensagensColors.muted,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: naoLida
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: MensagensColors.muted,
                            ),
                          ),
                        ),
                        if (mensagem.prioridade != PrioridadeMensagem.normal) ...[
                          const SizedBox(width: 6),
                          _PrioridadeDotTag(prioridade: mensagem.prioridade),
                        ],
                        if (mensagem.pendenteCiencia) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: MensagensColors.orange.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Ciente',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: MensagensColors.orange,
                              ),
                            ),
                          ),
                        ],
                        if (naoLida) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: MensagensColors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildPreviewText() {
    final raw = mensagem.conteudo?.trim() ?? '';
    if (raw.isNotEmpty) {
      final limpo = raw
          .replaceAllMapped(
            RegExp(r'\[([^\]]+)\]\([^)]+\)'),
            (m) => m.group(1) ?? '',
          )
          .replaceAll('**', '')
          .replaceAll('~~', '')
          .replaceAll('*', '')
          .replaceAll(RegExp(r'\s*\n+\s*'), ' ')
          .trim();
      if (limpo.isNotEmpty) return limpo;
    }

    if (mensagem.anexos.isNotEmpty) {
      final primeiro = mensagem.anexos.first;
      return switch (primeiro.categoria) {
        CategoriaAnexo.imagem => 'Foto',
        CategoriaAnexo.audio =>
          primeiro.duracaoSegundos != null
              ? 'Mensagem de voz (${_formatarDuracao(primeiro.duracaoSegundos!)})'
              : 'Mensagem de voz',
        CategoriaAnexo.video => 'Vídeo',
        CategoriaAnexo.documento => primeiro.nomeOriginal,
      };
    }

    return mensagem.remetenteNome?.trim().isNotEmpty == true
        ? mensagem.remetenteNome!.trim()
        : 'Comunicado institucional';
  }

  String _formatarDuracao(int segs) {
    final min = segs ~/ 60;
    final sec = (segs % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  String _formatarHorarioWhatsApp(DateTime? dt) {
    if (dt == null) return '';
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final data = DateTime(dt.year, dt.month, dt.day);
    final diff = hoje.difference(data).inDays;
    if (diff == 0) return DateFormat('HH:mm').format(dt);
    if (diff == 1) return 'Ontem';
    return DateFormat('dd/MM/yy').format(dt);
  }

  IconData _iconeAnexo(CategoriaAnexo cat) => switch (cat) {
    CategoriaAnexo.imagem => Icons.photo_camera_rounded,
    CategoriaAnexo.audio => Icons.mic_rounded,
    CategoriaAnexo.video => Icons.videocam_rounded,
    CategoriaAnexo.documento => Icons.insert_drive_file_rounded,
  };
}

class _AvatarRemetente extends StatelessWidget {
  const _AvatarRemetente({required this.nome, required this.prioridade});

  final String nome;
  final PrioridadeMensagem prioridade;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (prioridade) {
      PrioridadeMensagem.urgente => (
        MensagensColors.red.withValues(alpha: 0.12),
        MensagensColors.red,
      ),
      PrioridadeMensagem.importante => (
        MensagensColors.orange.withValues(alpha: 0.12),
        MensagensColors.orange,
      ),
      PrioridadeMensagem.normal => (
        MensagensColors.green.withValues(alpha: 0.12),
        MensagensColors.green,
      ),
    };

    final iniciais = _extrairIniciais(nome);

    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1.2),
      ),
      child: iniciais != null
          ? Text(
              iniciais,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            )
          : Icon(Icons.campaign_rounded, color: fg, size: 24),
    );
  }

  String? _extrairIniciais(String texto) {
    final partes = texto
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return null;
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes.first.substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }
}

class _StatusCheckIcon extends StatelessWidget {
  const _StatusCheckIcon({required this.status});

  final StatusDestinatario status;

  @override
  Widget build(BuildContext context) {
    final isLido = status == StatusDestinatario.lido;
    final icon = status == StatusDestinatario.pendente
        ? Icons.done
        : Icons.done_all;
    return Icon(
      icon,
      size: 16,
      color: isLido ? const Color(0xFF53BDEB) : MensagensColors.muted,
    );
  }
}

class _PrioridadeDotTag extends StatelessWidget {
  const _PrioridadeDotTag({required this.prioridade});

  final PrioridadeMensagem prioridade;

  @override
  Widget build(BuildContext context) {
    final isUrgente = prioridade == PrioridadeMensagem.urgente;
    final fg = isUrgente ? MensagensColors.red : MensagensColors.orange;
    final bg = fg.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isUrgente ? 'URG' : 'IMP',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

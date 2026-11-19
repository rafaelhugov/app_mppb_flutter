import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/mensagem_midia_cache.dart';
import '../../data/mensagens_repository.dart';
import '../../models/mensagem_anexo_model.dart';
import '../pages/midia_viewer_page.dart';
import 'audio_player_card.dart';
import 'mensagens_theme.dart';

class AnexoPreviewWidget extends ConsumerWidget {
  const AnexoPreviewWidget({
    super.key,
    required this.mensagemId,
    required this.anexo,
  });

  final int mensagemId;
  final MensagemAnexoModel anexo;

  void _abrirViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MidiaViewerPage(mensagemId: mensagemId, anexo: anexo),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (anexo.categoria) {
      case CategoriaAnexo.audio:
        return AudioPlayerCard(mensagemId: mensagemId, anexo: anexo);

      case CategoriaAnexo.imagem:
        final repo = ref.read(mensagensRepositoryProvider);
        final token = ref.watch(authProvider).token;
        final url = anexo.possuiThumbnail
            ? repo.anexoThumbnailUrl(mensagemId, anexo.id)
            : repo.anexoConteudoUrl(mensagemId, anexo.id);
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: InkWell(
            onTap: () => _abrirViewer(context),
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 220,
                  minHeight: 120,
                  minWidth: double.infinity,
                ),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  headers: {
                    if (token != null && token.isNotEmpty)
                      'Authorization': 'Bearer $token',
                  },
                  errorBuilder: (_, _, _) => Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: MensagensColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MensagensColors.border),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: MensagensColors.muted,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Toque para abrir a imagem',
                          style: TextStyle(color: MensagensColors.ink),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

      case CategoriaAnexo.video:
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: InkWell(
            onTap: () => _abrirViewer(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: MensagensColors.brandDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    size: 56,
                    color: Colors.white,
                  ),
                  Positioned(
                    left: 12,
                    bottom: 10,
                    right: 12,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.videocam,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            anexo.nomeOriginal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          anexo.tamanhoFormatado,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case CategoriaAnexo.documento:
        final ext = anexo.nomeOriginal.contains('.')
            ? anexo.nomeOriginal.split('.').last.toUpperCase()
            : 'DOC';
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: InkWell(
            onTap: () => _abrirViewer(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: MensagensColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MensagensColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MensagensColors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ext.length > 4 ? ext.substring(0, 4) : ext,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anexo.nomeOriginal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: MensagensColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$ext • ${anexo.tamanhoFormatado}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: MensagensColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Compartilhar',
                    onPressed: () {
                      ref.read(mensagemMidiaCacheProvider).compartilharAnexo(
                            mensagemId: mensagemId,
                            anexoId: anexo.id,
                            nomeArquivo: anexo.nomeOriginal,
                          );
                    },
                    icon: const Icon(
                      Icons.download_outlined,
                      color: MensagensColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

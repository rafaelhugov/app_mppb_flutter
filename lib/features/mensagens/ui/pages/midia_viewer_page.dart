import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/ui/app_feedback.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/mensagem_midia_cache.dart';
import '../../data/mensagens_repository.dart';
import '../../models/mensagem_anexo_model.dart';

class MidiaViewerPage extends ConsumerStatefulWidget {
  const MidiaViewerPage({
    super.key,
    required this.mensagemId,
    required this.anexo,
  });

  final int mensagemId;
  final MensagemAnexoModel anexo;

  @override
  ConsumerState<MidiaViewerPage> createState() => _MidiaViewerPageState();
}

class _MidiaViewerPageState extends ConsumerState<MidiaViewerPage> {
  VideoPlayerController? _videoController;
  Uint8List? _docBytes;
  Uint8List? _imgBytes;
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    if (widget.anexo.categoria == CategoriaAnexo.video) {
      _iniciarVideo();
    } else if (widget.anexo.categoria == CategoriaAnexo.documento) {
      _carregarDocumento();
    } else if (widget.anexo.categoria == CategoriaAnexo.imagem) {
      _carregarImagem();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _iniciarVideo() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final repo = ref.read(mensagensRepositoryProvider);
      final token = ref.read(authProvider).token;
      final url = repo.anexoConteudoUrl(widget.mensagemId, widget.anexo.id);
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );
      _videoController = ctrl;
      await ctrl.initialize();
      await ctrl.play();
      if (mounted) setState(() => _carregando = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Não foi possível reproduzir o vídeo.';
        });
      }
    }
  }

  Future<void> _carregarDocumento() async {
    final ext = _extensao;
    if (ext != 'md' && ext != 'txt' && ext != 'csv' && ext != 'pdf') {
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final bytes = await ref
          .read(mensagensRepositoryProvider)
          .baixarAnexoBytes(widget.mensagemId, widget.anexo.id);
      if (mounted) {
        setState(() {
          _docBytes = Uint8List.fromList(bytes);
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Não foi possível carregar o documento.';
        });
      }
    }
  }

  Future<void> _carregarImagem() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final bytes = await ref
          .read(mensagensRepositoryProvider)
          .baixarAnexoBytes(widget.mensagemId, widget.anexo.id);
      if (!mounted) return;
      if (bytes.isEmpty) {
        setState(() {
          _carregando = false;
          _erro = 'Falha ao carregar imagem.';
        });
        return;
      }
      setState(() {
        _imgBytes = Uint8List.fromList(bytes);
        _carregando = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Falha ao carregar imagem.';
        });
      }
    }
  }

  String get _extensao {
    final nome = widget.anexo.nomeOriginal.toLowerCase();
    final idx = nome.lastIndexOf('.');
    return idx >= 0 ? nome.substring(idx + 1) : '';
  }

  Future<void> _compartilhar() async {
    try {
      await ref.read(mensagemMidiaCacheProvider).compartilharAnexo(
            mensagemId: widget.mensagemId,
            anexoId: widget.anexo.id,
            nomeArquivo: widget.anexo.nomeOriginal,
          );
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(context, 'Falha ao compartilhar arquivo.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDocumento = widget.anexo.categoria == CategoriaAnexo.documento;
    return Scaffold(
      backgroundColor: isDocumento ? Colors.white : Colors.black,
      extendBodyBehindAppBar: !isDocumento,
      appBar: AppBar(
        backgroundColor: isDocumento ? Colors.white : Colors.transparent,
        foregroundColor: isDocumento ? const Color(0xFF101828) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.anexo.nomeOriginal,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isDocumento
              ? null
              : const TextStyle(
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 8),
                  ],
                ),
        ),
        actions: [
          IconButton(
            tooltip: 'Compartilhar / Abrir',
            onPressed: _compartilhar,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.anexo.categoria == CategoriaAnexo.documento
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _compartilhar,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Baixar / Abrir externamente'),
              ),
            ],
          ),
        ),
      );
    }

    switch (widget.anexo.categoria) {
      case CategoriaAnexo.imagem:
        final imgBytes = _imgBytes;
        if (imgBytes == null) {
          return const Center(
            child: Text(
              'Falha ao carregar imagem.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Center(
            child: Image.memory(
              imgBytes,
              errorBuilder: (_, _, _) => const Text(
                'Falha ao carregar imagem.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );

      case CategoriaAnexo.video:
        final ctrl = _videoController;
        if (ctrl == null || !ctrl.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: ctrl.value.aspectRatio,
                  child: VideoPlayer(ctrl),
                ),
              ),
            ),
            VideoProgressIndicator(ctrl, allowScrubbing: true),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: IconButton(
                iconSize: 48,
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
                  });
                },
                icon: Icon(
                  ctrl.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                ),
              ),
            ),
          ],
        );

      case CategoriaAnexo.documento:
      case CategoriaAnexo.audio:
        return _buildDocumentoViewer();
    }
  }

  Widget _buildDocumentoViewer() {
    final ext = _extensao;
    if (ext == 'pdf' && _docBytes != null) {
      return PdfPreview(
        build: (_) async => _docBytes!,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      );
    }
    if (ext == 'md' && _docBytes != null) {
      final texto = utf8.decode(_docBytes!, allowMalformed: true);
      return Markdown(data: texto, selectable: true);
    }
    if ((ext == 'txt' || ext == 'csv') && _docBytes != null) {
      final texto = utf8.decode(_docBytes!, allowMalformed: true);
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          texto,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description, size: 64, color: Color(0xFF1E293B)),
            const SizedBox(height: 12),
            Text(
              widget.anexo.nomeOriginal,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              widget.anexo.tamanhoFormatado,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _compartilhar,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir / Compartilhar arquivo'),
            ),
          ],
        ),
      ),
    );
  }
}

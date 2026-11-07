import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ui/responsive_layout.dart';
import '../models/noticia.dart';
import '../providers/noticia_provider.dart';
import '../utils/noticia_share.dart';
import 'noticias_page.dart';

class NoticiaDetalhesPage extends ConsumerStatefulWidget {
  final Noticia? noticia;
  final String? chave;
  final String? link;
  final String? titulo;

  const NoticiaDetalhesPage({
    super.key,
    this.noticia,
    this.chave,
    this.link,
    this.titulo,
  });

  @override
  ConsumerState<NoticiaDetalhesPage> createState() =>
      _NoticiaDetalhesPageState();
}

class _NoticiaDetalhesPageState extends ConsumerState<NoticiaDetalhesPage> {
  Future<void> _abrirLink(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Noticia _resolveNoticia(WidgetRef ref) {
    if (widget.noticia != null) return widget.noticia!;

    final state = ref.watch(noticiaProvider);
    final key = widget.chave?.trim();
    final link = widget.link?.trim();
    final title = widget.titulo?.trim();

    if (state.noticias.isNotEmpty) {
      if (key != null && key.isNotEmpty) {
        for (final item in state.noticias) {
          if (item.chaveExterna == key) return item;
        }
      }
      if (link != null && link.isNotEmpty) {
        for (final item in state.noticias) {
          if (item.link == link) return item;
        }
      }
      if (title != null && title.isNotEmpty) {
        for (final item in state.noticias) {
          if (item.titulo.toLowerCase() == title.toLowerCase()) return item;
        }
      }
    }

    return Noticia(
      chaveExterna: key,
      titulo: title ?? 'Notícia do MPPB',
      link: link,
      categoria: 'Institucional',
    );
  }

  String _formatDate(Noticia noticia) {
    final raw = noticia.dataPublicacao?.trim();
    if (raw == null || raw.isEmpty) return 'Hoje';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day/$month/${parsed.year}';
  }

  int _readingTime(Noticia noticia) {
    final words = (noticia.resumo ?? '')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .length;
    return (words / 160).ceil().clamp(1, 40);
  }

  List<_NewsTextBlock> _textBlocksFor(String? text) {
    final raw = text?.trim();
    if (raw == null || raw.isEmpty) return [];

    final normalized = raw
        .replaceAll(r'\n', '\n')
        .replaceAll(RegExp(r'\r\n?'), '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
    final explicitParagraphs = normalized
        .split(RegExp(r'\n{2,}'))
        .map((paragraph) => paragraph.replaceAll('\n', ' ').trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList();

    if (explicitParagraphs.length > 1) return _blocksFrom(explicitParagraphs);

    final explicitLines = normalized
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (explicitLines.length > 1) return _blocksFrom(explicitLines);

    final sentences = _splitSentences(normalized);
    if (sentences.length <= 2) return _blocksFrom([normalized]);

    return _blocksFrom(sentences);
  }

  List<_NewsTextBlock> _blocksFrom(List<String> blocks) {
    return blocks
        .map(
          (block) =>
              _NewsTextBlock(text: block, isHeading: _looksLikeHeading(block)),
        )
        .toList();
  }

  bool _looksLikeHeading(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return false;
    if (RegExp(r'[.!?]$').hasMatch(clean)) return false;

    final words = clean.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (words.length > 9 || clean.length > 72) return false;

    final letters = RegExp(r'[A-Za-zÀ-ÿ]').allMatches(clean).length;
    if (letters == 0) return false;

    final uppercase = RegExp(r'[A-ZÀ-Ý]').allMatches(clean).length;
    final uppercaseRatio = uppercase / letters;
    return uppercaseRatio >= 0.45 || words.length <= 5;
  }

  List<String> _splitSentences(String text) {
    final result = <String>[];
    var start = 0;

    for (var index = 0; index < text.length; index++) {
      final current = text[index];
      if (current != '.' && current != '!' && current != '?') continue;

      var end = index + 1;
      while (end < text.length && '"”’'.contains(text[end])) {
        end++;
      }

      var next = end;
      while (next < text.length && text[next].trim().isEmpty) {
        next++;
      }

      if (next >= text.length || _startsSentence(text[next])) {
        final sentence = text.substring(start, end).trim();
        if (sentence.isNotEmpty) result.add(sentence);
        start = next;
        index = next;
      }
    }

    final remaining = text.substring(start).trim();
    if (remaining.isNotEmpty) result.add(remaining);
    return result;
  }

  bool _startsSentence(String value) {
    final lower = value.toLowerCase();
    final upper = value.toUpperCase();
    return lower != upper && value == upper;
  }

  @override
  Widget build(BuildContext context) {
    final noticia = _resolveNoticia(ref);
    final responsive = MppbResponsive.of(context);
    final date = _formatDate(noticia);
    final readingTime = _readingTime(noticia);
    final textBlocks = _textBlocksFor(noticia.resumo);
    final imageUrl = noticia.imagemUrl ?? NoticiasPage.fallbackImageUrl;

    // Adaptação para celular, tablet, iPad e Web
    final isWide = responsive.usesWideLayout || responsive.isTablet;
    final maxContentWidth = isWide ? 820.0 : double.infinity;
    final horizontalPadding = isWide ? 32.0 : 18.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF202322),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Notícia',
          style: TextStyle(
            color: Color(0xFF202322),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Compartilhar notícia',
            icon: const Icon(
              Icons.ios_share_rounded,
              size: 20,
              color: Color(0xFFD62828),
            ),
            onPressed: () => compartilharNoticia(noticia),
          ),
          if (noticia.link != null && noticia.link!.trim().isNotEmpty)
            IconButton(
              tooltip: 'Abrir no portal do MPPB',
              icon: const Icon(
                Icons.open_in_browser_rounded,
                size: 22,
                color: Color(0xFF202322),
              ),
              onPressed: () => _abrirLink(noticia.link),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                36,
              ),
              children: [
                // Imagem de Destaque com Hero e clique para ampliar
                _NewsHeroImage(
                  imageUrl: imageUrl,
                  fallbackImageUrl: NoticiasPage.fallbackImageUrl,
                  heroTag:
                      'noticia-img-${noticia.chaveExterna ?? noticia.link ?? noticia.titulo}',
                  title: noticia.titulo,
                ),
                const SizedBox(height: 18),

                // Tags de categoria, data e tempo de leitura
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1FD62828),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        (noticia.categoria ?? 'Institucional').toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFD62828),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                    _MetaPill(
                      icon: Icons.calendar_today_rounded,
                      text: date,
                      color: const Color(0xFFD62828),
                    ),
                    _MetaPill(
                      icon: Icons.schedule_rounded,
                      text: '$readingTime min de leitura',
                      color: const Color(0xFF2563EB),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Título Editorial
                Text(
                  noticia.titulo,
                  style: TextStyle(
                    color: const Color(0xFF202322),
                    fontSize: isWide ? 26 : 22,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFE9EDF0), height: 1),
                const SizedBox(height: 16),

                // Conteúdo dos Parágrafos
                if (textBlocks.isNotEmpty) ...[
                  ...textBlocks.map(
                    (block) => Padding(
                      padding: EdgeInsets.only(
                        top: block.isHeading ? 6 : 0,
                        bottom: block.isHeading ? 8 : 14,
                      ),
                      child: Text(
                        block.text,
                        textAlign: TextAlign.start,
                        style: block.isHeading
                            ? TextStyle(
                                color: const Color(0xFF202322),
                                fontSize: isWide ? 19 : 17,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              )
                            : TextStyle(
                                color: const Color(0xFF333B38),
                                fontSize: isWide ? 17 : 16,
                                fontWeight: FontWeight.w400,
                                height: 1.55,
                              ),
                      ),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Matéria completa disponível no portal institucional do MPPB.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF697370),
                          fontSize: isWide ? 16 : 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(color: Color(0xFFE9EDF0), height: 1),
                const SizedBox(height: 24),

                // Botões de Ação no Rodapé
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    if (noticia.link != null && noticia.link!.trim().isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () => _abrirLink(noticia.link),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD62828),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text(
                          'Ler matéria completa no portal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => compartilharNoticia(noticia),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF202322),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.ios_share_rounded,
                        size: 18,
                        color: Color(0xFFD62828),
                      ),
                      label: const Text(
                        'Compartilhar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

class _NewsHeroImage extends StatelessWidget {
  final String imageUrl;
  final String fallbackImageUrl;
  final String heroTag;
  final String title;

  const _NewsHeroImage({
    required this.imageUrl,
    required this.fallbackImageUrl,
    required this.heroTag,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Toque para ampliar imagem com zoom e rotação',
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (ctx) => NoticiaImageViewerPage(
                imageUrl: imageUrl,
                fallbackImageUrl: fallbackImageUrl,
                heroTag: heroTag,
                title: title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: heroTag,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.network(
                      fallbackImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC111827),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.zoom_out_map_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Ampliar / Girar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

/// Visualizador imersivo em tela cheia com zoom interativo e botão de rotação
class NoticiaImageViewerPage extends StatefulWidget {
  final String imageUrl;
  final String fallbackImageUrl;
  final String heroTag;
  final String title;

  const NoticiaImageViewerPage({
    super.key,
    required this.imageUrl,
    required this.fallbackImageUrl,
    required this.heroTag,
    required this.title,
  });

  @override
  State<NoticiaImageViewerPage> createState() => _NoticiaImageViewerPageState();
}

class _NoticiaImageViewerPageState extends State<NoticiaImageViewerPage> {
  final TransformationController _transformController =
      TransformationController();
  int _quarterTurns = 0;

  void _rotateClockwise() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
      _transformController.value = Matrix4.identity();
    });
  }

  void _resetZoom() {
    setState(() {
      _quarterTurns = 0;
      _transformController.value = Matrix4.identity();
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Área de Imagem Interativa com Zoom e Rotação
            Center(
              child: GestureDetector(
                onDoubleTap: () {
                  if (_transformController.value != Matrix4.identity()) {
                    _transformController.value = Matrix4.identity();
                  } else {
                    _transformController.value = Matrix4.identity()
                      ..scale(2.5);
                  }
                },
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: _quarterTurns,
                      child: Hero(
                        tag: widget.heroTag,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Image.network(
                            widget.fallbackImageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Barra Superior de Controles
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x80000000),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: IconButton(
                      tooltip: 'Fechar',
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x80000000),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_quarterTurns != 0)
                          IconButton(
                            tooltip: 'Restaurar rotação',
                            icon: const Icon(
                              Icons.restore_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _resetZoom,
                          ),
                        IconButton(
                          tooltip: 'Girar imagem 90°',
                          icon: const Icon(
                            Icons.rotate_90_degrees_cw_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: _rotateClockwise,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Rodapé com Título e Dica
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x99111827),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pinça: zoom • 2 toques: ampliar',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsTextBlock {
  final String text;
  final bool isHeading;

  const _NewsTextBlock({required this.text, required this.isHeading});
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MetaPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x26343A40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF697370),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/responsive_layout.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../providers/noticia_provider.dart';
import '../models/noticia.dart';
import '../utils/noticia_share.dart';

class NoticiasPage extends ConsumerStatefulWidget {
  static const fallbackImageUrl =
      'https://commons.wikimedia.org/wiki/Special:Redirect/file/Minist%C3%A9rio_P%C3%BAblico_da_Para%C3%ADba%2C_Jo%C3%A3o_Pessoa_%28PB%29.jpg?width=900';

  final String? initialNewsKey;
  final String? initialNewsLink;
  final String? initialNewsTitle;

  const NoticiasPage({
    super.key,
    this.initialNewsKey,
    this.initialNewsLink,
    this.initialNewsTitle,
  });

  @override
  ConsumerState<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends ConsumerState<NoticiasPage> {
  String? _openedInitialTarget;

  Future<void> _abrirNoticia(String? link) async {
    if (link == null || link.isEmpty) return;
    final url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _mostrarNoticia(Noticia noticia) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewsDetailSheet(
        noticia: noticia,
        fallbackImageUrl: NoticiasPage.fallbackImageUrl,
        date: _dateFor(noticia),
        readingTime: _readingTime(noticia),
        onOpenLink: () => _abrirNoticia(noticia.link),
        onShare: () => compartilharNoticia(noticia),
      ),
    );
  }

  int _readingTime(Noticia noticia) {
    final words = (noticia.resumo ?? '')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .length;
    return (words / 180).ceil() > 0 ? (words / 180).ceil() : 1;
  }

  String _dateFor(Noticia noticia) {
    final date = noticia.dataPublicacao ?? '';
    return date.split(' ').isNotEmpty ? date.split(' ')[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noticiaProvider);
    _openInitialNewsWhenReady(state);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD62828)),
            )
          : state.errorMessage != null
          ? _buildError(state.errorMessage!)
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(noticiaProvider.notifier).fetchNoticias(),
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: MainLayout.contentBottomPadding(context),
                ),
                children: [
                  _buildHeader(),
                  Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 18),
                      _buildNewsList(state),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _openInitialNewsWhenReady(NoticiaState state) {
    if (state.isLoading ||
        state.errorMessage != null ||
        state.noticias.isEmpty) {
      return;
    }

    final target = _initialTarget;
    if (target == null || _openedInitialTarget == target) {
      return;
    }

    final noticia = _findInitialNews(state.noticias);
    if (noticia == null) {
      return;
    }

    _openedInitialTarget = target;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mostrarNoticia(noticia);
      }
    });
  }

  String? get _initialTarget {
    final key = widget.initialNewsKey?.trim();
    if (key != null && key.isNotEmpty) {
      return 'key:$key';
    }
    final link = widget.initialNewsLink?.trim();
    if (link != null && link.isNotEmpty) {
      return 'link:$link';
    }
    final title = widget.initialNewsTitle?.trim();
    if (title != null && title.isNotEmpty) {
      return 'title:${title.toLowerCase()}';
    }
    return null;
  }

  Noticia? _findInitialNews(List<Noticia> noticias) {
    final key = widget.initialNewsKey?.trim();
    if (key != null && key.isNotEmpty) {
      for (final noticia in noticias) {
        if (noticia.chaveExterna == key) {
          return noticia;
        }
      }
    }

    final link = widget.initialNewsLink?.trim();
    if (link != null && link.isNotEmpty) {
      for (final noticia in noticias) {
        if (noticia.link == link) {
          return noticia;
        }
      }
    }

    final title = widget.initialNewsTitle?.trim().toLowerCase();
    if (title != null && title.isNotEmpty) {
      for (final noticia in noticias) {
        if (noticia.titulo.trim().toLowerCase() == title) {
          return noticia;
        }
      }
    }

    return null;
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(error, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(noticiaProvider.notifier).fetchNoticias(),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const HeroHeaderPublico(
      label: '',
      title: 'Notícias',
      subtitle: '',
      icon: Icons.newspaper,
    );
  }

  Widget _buildSearchBar() {
    final responsive = MppbResponsive.of(context);
    final width = responsive.isTablet ? 460.0 : 304.0;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: width),
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF202322),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x26FFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A202322),
              offset: Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: TextField(
          onChanged: (val) =>
              ref.read(noticiaProvider.notifier).setSearchTerm(val),
          style: const TextStyle(
            color: Color(0xFFF7F8F6),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          decoration: const InputDecoration(
            hintText: 'Buscar notícias...',
            hintStyle: TextStyle(
              color: Color(0xBFF7F8F6),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(Icons.search, color: Color(0xDDF7F8F6), size: 19),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsList(NoticiaState state) {
    if (state.filteredNews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 42),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x26343A40)),
          ),
          child: const Text(
            'Nenhuma notícia encontrada no momento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF697370),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    final children = <Widget>[];
    final responsive = MppbResponsive.of(context);
    final horizontalPadding = MainLayout.publicHorizontalPadding(context);
    final spacing = responsive.isTablet ? 14.0 : 10.0;
    final gridColumns = responsive.isTablet && responsive.isLandscape
        ? 4
        : responsive.gridColumns;
    final itemsPerPage = responsive.isTablet && responsive.isLandscape
        ? 8
        : NoticiaState.itemsPerPage;
    final totalPages = (state.filteredNews.length / itemsPerPage).ceil();
    final currentPage = state.currentPage.clamp(
      1,
      totalPages == 0 ? 1 : totalPages,
    );
    final startIndex = (currentPage - 1) * itemsPerPage;
    final gridNews = state.filteredNews
        .skip(startIndex)
        .take(itemsPerPage)
        .toList();

    if (gridNews.isNotEmpty) {
      children.add(
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 8,
          ),
          child: GridView.builder(
            key: const Key('lista-noticias'),
            padding: EdgeInsets.zero,
            itemCount: gridNews.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: responsive.isTablet ? 286 : 260,
            ),
            itemBuilder: (context, index) => _buildRegularCard(gridNews[index]),
          ),
        ),
      );
    }

    // Pagination
    if (totalPages > 1) {
      children.add(const SizedBox(height: 16));
      children.add(_buildPagination(currentPage, totalPages));
    }

    return Column(children: children);
  }

  Widget _buildRegularCard(Noticia noticia) {
    final responsive = MppbResponsive.of(context);
    final isTablet = responsive.isTablet;

    return GestureDetector(
      onTap: () => _mostrarNoticia(noticia),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x26343A40)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10101828),
              offset: Offset(0, 6),
              blurRadius: 16,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: isTablet ? 112 : 90,
              width: double.infinity,
              child: Image.network(
                noticia.imagemUrl ?? NoticiasPage.fallbackImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.network(
                  NoticiasPage.fallbackImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 12 : 10,
                  isTablet ? 11 : 9,
                  isTablet ? 12 : 10,
                  10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1FD62828),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        (noticia.categoria ?? 'Institucional').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD62828),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.25,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: Color(0xFFD62828),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _dateFor(noticia),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF697370),
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${_readingTime(noticia)}m',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF697370),
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      noticia.titulo,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: Color(0xFF202322),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Abrir',
                                style: TextStyle(
                                  color: Color(0xFFD62828),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                color: Color(0xFFD62828),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                        _NewsShareButton(
                          onPressed: () => compartilharNoticia(noticia),
                          compact: true,
                        ),
                      ],
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

  Widget _buildPagination(int currentPage, int totalPages) {
    void onSelect(int page) => ref.read(noticiaProvider.notifier).setPage(page);

    final List<Widget> pages = [];
    int start = currentPage - 1;
    int end = currentPage + 1;

    if (start < 1) {
      start = 1;
      end = 3;
    }
    if (end > totalPages) {
      end = totalPages;
      start = totalPages - 2;
      if (start < 1) start = 1;
    }

    if (start > 1) {
      pages.add(_buildPageButton(1, currentPage, onSelect));
      if (start > 2) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(
                color: Color(0xFF697370),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }
    }

    for (int i = start; i <= end; i++) {
      pages.add(_buildPageButton(i, currentPage, onSelect));
    }

    if (end < totalPages) {
      if (end < totalPages - 1) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(
                color: Color(0xFF697370),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }
      pages.add(_buildPageButton(totalPages, currentPage, onSelect));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          tooltip: 'Página anterior',
          icon: const Icon(Icons.chevron_left),
          color: currentPage > 1
              ? const Color(0xFFD62828)
              : const Color(0xFFB7C0BD),
          onPressed: currentPage > 1 ? () => onSelect(currentPage - 1) : null,
        ),
        ...pages,
        IconButton(
          tooltip: 'Próxima página',
          icon: const Icon(Icons.chevron_right),
          color: currentPage < totalPages
              ? const Color(0xFFD62828)
              : const Color(0xFFB7C0BD),
          onPressed: currentPage < totalPages
              ? () => onSelect(currentPage + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildPageButton(
    int page,
    int currentPage,
    void Function(int) onSelect,
  ) {
    final isActive = page == currentPage;
    return GestureDetector(
      onTap: () => onSelect(page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFFD62828),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Text(
          '$page',
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFD62828),
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class NewsDetailSheet extends StatelessWidget {
  const NewsDetailSheet({
    super.key,
    required this.noticia,
    required this.fallbackImageUrl,
    required this.date,
    required this.readingTime,
    required this.onOpenLink,
    required this.onShare,
  });

  final Noticia noticia;
  final String fallbackImageUrl;
  final String date;
  final int readingTime;
  final VoidCallback onOpenLink;
  final VoidCallback onShare;

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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final responsive = MppbResponsive.of(context);
    final isTabletLandscape = responsive.isTablet && responsive.isLandscape;
    final maxWidth = responsive.usesWideLayout
        ? 1120.0
        : isTabletLandscape
        ? 1040.0
        : 760.0;
    final heightFactor = isTabletLandscape
        ? 0.90
        : responsive.usesWideLayout
        ? 0.88
        : 0.92;
    final horizontalPadding = responsive.isTablet ? 28.0 : 20.0;
    final textBlocks = _textBlocksFor(noticia.resumo);
    final imageUrl = noticia.imagemUrl ?? fallbackImageUrl;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: heightFactor,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F8F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0x33202322),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Fechar',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF202322),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      32 + bottomInset,
                    ),
                    children: [
                      _NewsDetailImage(
                        imageUrl: imageUrl,
                        fallbackImageUrl: fallbackImageUrl,
                        title: noticia.titulo,
                      ),
                      const SizedBox(height: 16),
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
                              (noticia.categoria ?? 'Institucional')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFD62828),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                          _NewsMetaPill(
                            icon: Icons.calendar_today_rounded,
                            text: date,
                            color: const Color(0xFFD62828),
                          ),
                          _NewsMetaPill(
                            icon: Icons.schedule_rounded,
                            text: '$readingTime min de leitura',
                            color: const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        noticia.titulo,
                        style: TextStyle(
                          color: const Color(0xFF202322),
                          fontSize: responsive.isTablet ? 24 : 22,
                          fontWeight: FontWeight.w700,
                          height: 1.14,
                        ),
                      ),
                      if (textBlocks.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...textBlocks.map(
                          (block) => Padding(
                            padding: EdgeInsets.only(
                              top: block.isHeading ? 4 : 0,
                              bottom: block.isHeading ? 8 : 12,
                            ),
                            child: Text(
                              block.text,
                              textAlign: TextAlign.start,
                              style: block.isHeading
                                  ? TextStyle(
                                      color: const Color(0xFF202322),
                                      fontSize: responsive.isTablet ? 18 : 17,
                                      fontWeight: FontWeight.w700,
                                      height: 1.18,
                                    )
                                  : TextStyle(
                                      color: const Color(0xFF4A5350),
                                      fontSize: responsive.isTablet ? 17 : 16,
                                      fontWeight: FontWeight.w400,
                                      height: 1.42,
                                    ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: onOpenLink,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFD62828),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              icon: const Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                              ),
                              label: const Text('Abrir no site'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 52,
                            height: 48,
                            child: _NewsShareButton(onPressed: onShare),
                          ),
                        ],
                      ),
                    ],
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

class _NewsDetailImage extends StatelessWidget {
  const _NewsDetailImage({
    required this.imageUrl,
    required this.fallbackImageUrl,
    required this.title,
  });

  final String imageUrl;
  final String fallbackImageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ampliar imagem da notícia',
      child: InkWell(
        onTap: () => _showImageViewer(context),
        borderRadius: BorderRadius.circular(22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Image.network(fallbackImageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xCC202322),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Icon(
                      Icons.zoom_out_map_rounded,
                      color: Colors.white,
                      size: 18,
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

  void _showImageViewer(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewsImageViewerSheet(
        imageUrl: imageUrl,
        fallbackImageUrl: fallbackImageUrl,
        title: title,
      ),
    );
  }
}

class _NewsImageViewerSheet extends StatelessWidget {
  const _NewsImageViewerSheet({
    required this.imageUrl,
    required this.fallbackImageUrl,
    required this.title,
  });

  final String imageUrl;
  final String fallbackImageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final responsive = MppbResponsive.of(context);
    final isTabletLandscape = responsive.isTablet && responsive.isLandscape;
    final maxWidth = responsive.usesWideLayout
        ? 1240.0
        : isTabletLandscape
        ? 1120.0
        : 760.0;
    final heightFactor = isTabletLandscape
        ? 0.92
        : responsive.usesWideLayout
        ? 0.90
        : 0.94;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: heightFactor,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF101211),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    responsive.isTablet ? 22 : 16,
                    10,
                    8,
                    8 + padding.top * 0.1,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.isTablet ? 16 : 14,
                            fontWeight: FontWeight.w700,
                            height: 1.18,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Fechar',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Image.network(
                          fallbackImageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: padding.bottom + 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsTextBlock {
  const _NewsTextBlock({required this.text, required this.isHeading});

  final String text;
  final bool isHeading;
}

class _NewsMetaPill extends StatelessWidget {
  const _NewsMetaPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

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

class _NewsShareButton extends StatelessWidget {
  const _NewsShareButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: compact ? const Color(0x0FD62828) : Colors.white,
      borderRadius: BorderRadius.circular(compact ? 12 : 16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        child: Container(
          width: compact ? 34 : double.infinity,
          height: compact ? 34 : double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
            border: Border.all(color: const Color(0x2ED62828)),
          ),
          child: const Icon(
            Icons.ios_share_rounded,
            color: Color(0xFFD62828),
            size: 17,
          ),
        ),
      ),
    );
  }
}

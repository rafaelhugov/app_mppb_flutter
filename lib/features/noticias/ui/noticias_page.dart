import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/noticia_provider.dart';
import '../models/noticia.dart';

class NoticiasPage extends ConsumerStatefulWidget {
  const NoticiasPage({super.key});

  @override
  ConsumerState<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends ConsumerState<NoticiasPage> {
  static const fallbackImageUrl =
      'https://commons.wikimedia.org/wiki/Special:Redirect/file/Minist%C3%A9rio_P%C3%BAblico_da_Para%C3%ADba%2C_Jo%C3%A3o_Pessoa_%28PB%29.jpg?width=900';

  Future<void> _abrirNoticia(String? link) async {
    if (link == null || link.isEmpty) return;
    final url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  int _readingTime(Noticia noticia) {
    final words = (noticia.resumo ?? '')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .length;
    return (words / 180).ceil() > 0 ? (words / 180).ceil() : 1;
  }

  String _shortDateFor(Noticia noticia) {
    final date = noticia.dataPublicacao ?? '';
    final parts = date.split(' ');
    if (parts.length > 1) {
      return '${parts[0]}, ${parts[1]}';
    }
    return date;
  }

  String _dateFor(Noticia noticia) {
    final date = noticia.dataPublicacao ?? '';
    return date.split(' ').isNotEmpty ? date.split(' ')[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noticiaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? _buildError(state.errorMessage!)
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(noticiaProvider.notifier).fetchNoticias(),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 132),
                children: [
                  _buildHeader(),
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 18),
                        _buildNewsList(state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
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
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF241D19), Color(0xFF3A241D), Color(0xFF8F2A1D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.46, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x70FFDE8E)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D24120C),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.newspaper,
              color: Color(0xFF211713),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'COMUNICAÇÃO INSTITUCIONAL',
                  style: TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Notícias',
                  style: TextStyle(
                    color: Color(0xFFFFF8EA),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Informes do Ministério Público da Paraíba.',
                  style: TextStyle(color: Color(0xFFD8C5AA), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x4D9C7A54)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x21432B1D),
              offset: Offset(0, 12),
              blurRadius: 24,
            ),
          ],
        ),
        child: TextField(
          onChanged: (val) =>
              ref.read(noticiaProvider.notifier).setSearchTerm(val),
          style: const TextStyle(
            color: Color(0xFF2F2923),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            hintText: 'Buscar notícias, publicações...',
            hintStyle: TextStyle(
              color: Color(0xFF806F5E),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(Icons.search, color: Color(0xFF806F5E)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16),
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
            color: const Color(0xFFF7EFE3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x479C7A54)),
          ),
          child: const Text(
            'Nenhuma notícia encontrada no momento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF73543E),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    final children = <Widget>[];

    // Featured (apenas na página 1)
    if (state.currentPage == 1 && state.featuredNews != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _buildFeaturedCard(state.featuredNews!),
        ),
      );
    }

    // Grid/Lista de regulares
    if (state.paginatedNews.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: state.paginatedNews
                .map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildRegularCard(n),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    // Pagination
    if (state.totalPages > 1) {
      children.add(const SizedBox(height: 16));
      children.add(_buildPagination(state.currentPage, state.totalPages));
    }

    return Column(children: children);
  }

  Widget _buildFeaturedCard(Noticia noticia) {
    return GestureDetector(
      onTap: () => _abrirNoticia(noticia.link),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7EFE3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x4D9C7A54)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x21432B1D),
              offset: Offset(0, 16),
              blurRadius: 34,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10.5,
                  child: Image.network(
                    noticia.imagemUrl ?? fallbackImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Image.network(fallbackImageUrl, fit: BoxFit.cover),
                  ),
                ),
                // Gradiente escuro em baixo da imagem (como no Vue)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, const Color(0x61241D19)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.42, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8F2A1D),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3324120C),
                          offset: Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Text(
                      (noticia.categoria ?? 'Destaque').toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFF8EA),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF8F2A1D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _dateFor(noticia),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF806F5E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '•',
                          style: TextStyle(color: Color(0xFFC8AA72)),
                        ),
                      ),
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: Color(0xFF8F2A1D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_readingTime(noticia)} min de leitura',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF806F5E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    noticia.titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.18,
                      color: Color(0xFF2F2923),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (noticia.resumo != null)
                    Text(
                      noticia.resumo!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: Color(0xFF73543E),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8F2A1D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Ler notícia',
                          style: TextStyle(
                            color: Color(0xFFFFF8EA),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.open_in_new,
                          color: Color(0xFFFFF8EA),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularCard(Noticia noticia) {
    return GestureDetector(
      onTap: () => _abrirNoticia(noticia.link),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7EFE3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x3D9C7A54)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14432B1D),
              offset: Offset(0, 10),
              blurRadius: 22,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 8.4,
              child: Image.network(
                noticia.imagemUrl ?? fallbackImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Image.network(fallbackImageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        (noticia.categoria ?? 'Institucional').toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF8F2A1D),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '•',
                          style: TextStyle(color: Color(0xFF806F5E)),
                        ),
                      ),
                      Text(
                        _shortDateFor(noticia),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF806F5E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    noticia.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: Color(0xFF2F2923),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (noticia.resumo != null)
                    Text(
                      noticia.resumo!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: Color(0xFF73543E),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Ler mais',
                        style: TextStyle(
                          color: Color(0xFF8F2A1D),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF8F2A1D),
                        size: 14,
                      ),
                    ],
                  ),
                ],
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
                color: Color(0xFF806F5E),
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
                color: Color(0xFF806F5E),
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
          icon: const Icon(Icons.chevron_left),
          color: currentPage > 1
              ? const Color(0xFF8F2A1D)
              : const Color(0xFFDED4C5),
          onPressed: currentPage > 1 ? () => onSelect(currentPage - 1) : null,
        ),
        ...pages,
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: currentPage < totalPages
              ? const Color(0xFF8F2A1D)
              : const Color(0xFFDED4C5),
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
                color: const Color(0xFFE5B84C),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Text(
          '$page',
          style: TextStyle(
            color: const Color(0xFF8F2A1D),
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

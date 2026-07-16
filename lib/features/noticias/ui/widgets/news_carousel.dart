import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/noticia_provider.dart';

class NewsCarousel extends ConsumerStatefulWidget {
  const NewsCarousel({super.key});

  @override
  ConsumerState<NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends ConsumerState<NewsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentNewsIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(noticiaProvider.notifier).fetchNoticias();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openNews(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final noticiaState = ref.watch(noticiaProvider);
    final todasNoticias = noticiaState.noticias;
    final carouselNews = todasNoticias.take(3).toList();

    return Column(
      children: [
        if (noticiaState.isLoading && carouselNews.isEmpty)
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator(color: Color(0xFF8F2A1D))),
          )
        else if (carouselNews.isEmpty)
          Container(
            constraints: const BoxConstraints(minHeight: 108),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x599C7A54)),
            ),
            child: const Row(
              children: [
                Icon(Icons.newspaper, color: Color(0xFF8F2A1D), size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nenhuma notícia disponível no momento.',
                    style: TextStyle(color: Color(0xFF73543E)),
                  ),
                ),
              ],
            ),
          )
        else ...[
          SizedBox(
            height: 420,
            child: PageView.builder(
              controller: _pageController,
              itemCount: carouselNews.length,
              padEnds: false,
              onPageChanged: (index) {
                setState(() {
                  _currentNewsIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final noticia = carouselNews[index];
                String dateFormatted = noticia.dataPublicacao ?? '';
                final parts = dateFormatted.split(' ');
                if (parts.length > 1) {
                  dateFormatted = '${parts[0]}, ${parts[1]}';
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7EFE3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x599C7A54)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x24432B1D), blurRadius: 30, offset: Offset(0, 14)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // IMAGE
                        Expanded(
                          flex: 9,
                          child: GestureDetector(
                            onTap: () => _openNews(noticia.link),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2E2722), Color(0xFF3A241D), Color(0xFF8F2A1D)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                image: noticia.imagemUrl != null && noticia.imagemUrl!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(noticia.imagemUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (noticia.imagemUrl == null || noticia.imagemUrl!.isEmpty)
                                  ? const Center(child: Icon(Icons.newspaper, color: Color(0xFFE5B84C), size: 42))
                                  : null,
                            ),
                          ),
                        ),
                        // CONTENT
                        Expanded(
                          flex: 11,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 18, right: 16, top: 16, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E2722),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    (noticia.categoria ?? 'Destaque').toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFE5B84C),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dateFormatted,
                                  style: const TextStyle(color: Color(0xFF806F5E), fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  noticia.titulo ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF2F2923),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    height: 1.18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    noticia.resumo ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF73543E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ACTIONS
                        Padding(
                          padding: const EdgeInsets.only(left: 18, right: 16, bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _openNews(noticia.link),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8F2A1D),
                                    foregroundColor: const Color(0xFFFFF8EA),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    minimumSize: const Size(0, 40),
                                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Flexible(
                                        child: Text(
                                          'Ler notícia',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.open_in_new, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => context.push('/noticias'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEAD4A3),
                                  foregroundColor: const Color(0xFF5C3C22),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  minimumSize: const Size(0, 40),
                                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                                ),
                                child: const Text('Todas'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // DOTS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              carouselNews.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 7,
                width: _currentNewsIndex == index ? 20 : 7,
                decoration: BoxDecoration(
                  color: _currentNewsIndex == index ? const Color(0xFF8F2A1D) : const Color(0x338F2A1D),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

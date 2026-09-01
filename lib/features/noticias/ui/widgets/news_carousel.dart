import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/noticia_provider.dart';
import '../../utils/noticia_share.dart';

class NewsCarousel extends ConsumerStatefulWidget {
  const NewsCarousel({super.key});

  @override
  ConsumerState<NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends ConsumerState<NewsCarousel>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  Timer? _autoPlayTimer;
  int _currentNewsIndex = 0;
  int _carouselNewsCount = 0;
  bool _isAutoPlayPaused = false;
  late final AnimationController _autoPlayProgressController;

  @override
  void initState() {
    super.initState();
    _autoPlayProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    Future.microtask(() {
      ref.read(noticiaProvider.notifier).fetchNoticias();
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _autoPlayProgressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _restartAutoPlayProgress() {
    _autoPlayProgressController
      ..stop()
      ..forward(from: 0);
  }

  void _syncAutoPlay(int itemCount) {
    if (_carouselNewsCount == itemCount &&
        _autoPlayTimer != null &&
        !_isAutoPlayPaused) {
      return;
    }

    _carouselNewsCount = itemCount;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _autoPlayProgressController.stop();

    if (_isAutoPlayPaused || itemCount < 2) {
      return;
    }

    _restartAutoPlayProgress();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final nextPage = (_currentNewsIndex + 1) % itemCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      _restartAutoPlayProgress();
    });
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlayPaused = !_isAutoPlayPaused;
    });
    _syncAutoPlay(_carouselNewsCount);
  }

  Widget _buildAutoPlayControl(int itemCount) {
    if (itemCount < 2) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Tooltip(
          message: _isAutoPlayPaused ? 'Retomar notícias' : 'Pausar notícias',
          child: InkWell(
            onTap: _toggleAutoPlay,
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _autoPlayProgressController,
                    builder: (context, _) {
                      return CircularProgressIndicator(
                        value: 1 - _autoPlayProgressController.value,
                        strokeWidth: 2.6,
                        backgroundColor: const Color(0xFFE9EDF0),
                        color: const Color(0xFFD62828),
                      );
                    },
                  ),
                  Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE2E4E8)),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10101828),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isAutoPlayPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      color: const Color(0xFF697370),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            itemCount,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 7,
              width: _currentNewsIndex == index ? 20 : 7,
              decoration: BoxDecoration(
                color: _currentNewsIndex == index
                    ? const Color(0xFFD62828)
                    : const Color(0x33D62828),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
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
    _syncAutoPlay(carouselNews.length);

    return Column(
      children: [
        if (noticiaState.isLoading && carouselNews.isEmpty)
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFD62828)),
            ),
          )
        else if (carouselNews.isEmpty)
          Container(
            constraints: const BoxConstraints(minHeight: 108),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x26343A40)),
            ),
            child: const Row(
              children: [
                Icon(Icons.newspaper, color: Color(0xFFD62828), size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nenhuma notícia disponível no momento.',
                    style: TextStyle(color: Color(0xFF697370)),
                  ),
                ),
              ],
            ),
          )
        else ...[
          SizedBox(
            height: 380,
            child: PageView.builder(
              controller: _pageController,
              itemCount: carouselNews.length,
              padEnds: false,
              onPageChanged: (index) {
                setState(() {
                  _currentNewsIndex = index;
                });
                if (!_isAutoPlayPaused && carouselNews.length > 1) {
                  _autoPlayTimer?.cancel();
                  _autoPlayTimer = null;
                  _syncAutoPlay(carouselNews.length);
                }
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x26343A40)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14101828),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
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
                                  colors: [
                                    Color(0xFF202322),
                                    Color(0xFF2563EB),
                                    Color(0xFFD62828),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                image:
                                    noticia.imagemUrl != null &&
                                        noticia.imagemUrl!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(noticia.imagemUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  (noticia.imagemUrl == null ||
                                      noticia.imagemUrl!.isEmpty)
                                  ? const Center(
                                      child: Icon(
                                        Icons.newspaper,
                                        color: Color(0xFFD62828),
                                        size: 42,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        // CONTENT
                        Expanded(
                          flex: 11,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 18,
                              right: 16,
                              top: 16,
                              bottom: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x1FD62828),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    (noticia.categoria ?? 'Destaque')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFD62828),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dateFormatted,
                                  style: const TextStyle(
                                    color: Color(0xFF697370),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  noticia.titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF202322),
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
                                      color: Color(0xFF697370),
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
                          padding: const EdgeInsets.only(
                            left: 18,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 132,
                                child: ElevatedButton(
                                  onPressed: () => _openNews(noticia.link),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD62828),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: const Size(0, 32),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Ler notícia'),
                                        SizedBox(width: 5),
                                        Icon(Icons.open_in_new, size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 38,
                                height: 34,
                                child: _CarouselNewsShareButton(
                                  onPressed: () => compartilharNoticia(noticia),
                                ),
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
          _buildAutoPlayControl(carouselNews.length),
        ],
      ],
    );
  }
}

class _CarouselNewsShareButton extends StatelessWidget {
  const _CarouselNewsShareButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x0FD62828),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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

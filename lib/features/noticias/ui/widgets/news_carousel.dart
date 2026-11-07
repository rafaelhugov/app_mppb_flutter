import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/ui/responsive_layout.dart';
import '../../models/noticia.dart';
import '../../providers/noticia_provider.dart';
import '../noticia_detalhes_page.dart';
import '../../ui/noticias_page.dart';
import '../../utils/noticia_share.dart';

class NewsCarousel extends ConsumerStatefulWidget {
  const NewsCarousel({super.key});

  @override
  ConsumerState<NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends ConsumerState<NewsCarousel>
    with TickerProviderStateMixin {
  PageController? _pageController;
  double? _currentViewportFraction;
  Timer? _autoPlayTimer;
  int _currentNewsIndex = 0;
  int _carouselNewsCount = 0;
  bool _isAutoPlayPaused = false;
  late final AnimationController _autoPlayProgressController;
  late final AnimationController _swipeAnimationController;

  // Variáveis para o efeito físico de baralho/cartas empilhadas
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0.0;
  Offset _animStartOffset = Offset.zero;
  Offset _animTargetOffset = Offset.zero;
  double _animStartAngle = 0.0;
  double _animTargetAngle = 0.0;
  int _targetIndexAfterAnim = -1;

  @override
  void initState() {
    super.initState();
    _autoPlayProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _swipeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_targetIndexAfterAnim >= 0 && _carouselNewsCount > 0) {
          setState(() {
            _currentNewsIndex = _targetIndexAfterAnim % _carouselNewsCount;
            _dragOffset = Offset.zero;
            _dragAngle = 0.0;
            _targetIndexAfterAnim = -1;
          });
        } else {
          setState(() {
            _dragOffset = Offset.zero;
            _dragAngle = 0.0;
          });
        }

        if (!_isAutoPlayPaused && _carouselNewsCount > 1) {
          _restartAutoPlayProgress();
        }
      }
    });

    Future.microtask(() {
      ref.read(noticiaProvider.notifier).fetchNoticias();
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _autoPlayProgressController.dispose();
    _swipeAnimationController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  double _viewportFractionFor(MppbResponsiveMetrics responsive) {
    if (responsive.windowClass == MppbWindowClass.large) return 0.25;
    if (responsive.isTablet && responsive.isLandscape) return 0.25;
    if (responsive.usesWideLayout) return 0.32;
    return 0.87;
  }

  PageController _controllerFor(double viewportFraction) {
    final currentController = _pageController;
    if (currentController != null &&
        _currentViewportFraction == viewportFraction) {
      return currentController;
    }

    final initialPage = _currentNewsIndex;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _currentViewportFraction = viewportFraction;
    _pageController?.dispose();

    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: viewportFraction,
    );
    return _pageController!;
  }

  void _restartAutoPlayProgress() {
    _autoPlayProgressController
      ..stop()
      ..forward(from: 0);
  }

  void _syncAutoPlay(int itemCount, {required bool isStackedMobile}) {
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
      if (!mounted) return;
      if (isStackedMobile) {
        _animateCardSwipe(isNext: true);
      } else {
        final controller = _pageController;
        if (controller == null || !controller.hasClients) {
          return;
        }
        final nextPage = (_currentNewsIndex + 1) % itemCount;
        controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
        _restartAutoPlayProgress();
      }
    });
  }

  void _animateCardSwipe({required bool isNext}) {
    final count = _carouselNewsCount;
    if (count <= 1 || _swipeAnimationController.isAnimating) {
      _animateSnapBack();
      return;
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    _animStartOffset = _dragOffset;
    _animStartAngle = _dragAngle;
    _animTargetOffset =
        Offset(isNext ? -screenWidth * 1.25 : screenWidth * 1.25, 0);
    _animTargetAngle = isNext ? -0.22 : 0.22;
    _targetIndexAfterAnim = isNext
        ? (_currentNewsIndex + 1) % count
        : (_currentNewsIndex - 1 + count) % count;

    _swipeAnimationController.forward(from: 0.0);
  }

  void _animateSnapBack() {
    _animStartOffset = _dragOffset;
    _animStartAngle = _dragAngle;
    _animTargetOffset = Offset.zero;
    _animTargetAngle = 0.0;
    _targetIndexAfterAnim = -1;
    _swipeAnimationController.forward(from: 0.0);
  }

  void _goToIndex(int targetIndex, {required bool isStackedMobile}) {
    if (_currentNewsIndex == targetIndex ||
        _swipeAnimationController.isAnimating) {
      return;
    }

    if (isStackedMobile) {
      final isNext = targetIndex > _currentNewsIndex;
      final screenWidth = MediaQuery.sizeOf(context).width;
      _animStartOffset = Offset.zero;
      _animStartAngle = 0.0;
      _animTargetOffset =
          Offset(isNext ? -screenWidth * 1.25 : screenWidth * 1.25, 0);
      _animTargetAngle = isNext ? -0.22 : 0.22;
      _targetIndexAfterAnim = targetIndex;
      _swipeAnimationController.forward(from: 0.0);
    } else {
      _pageController?.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _toggleAutoPlay({required bool isStackedMobile}) {
    setState(() {
      _isAutoPlayPaused = !_isAutoPlayPaused;
    });
    _syncAutoPlay(_carouselNewsCount, isStackedMobile: isStackedMobile);
  }

  Widget _buildAutoPlayControl(int itemCount, {required bool isStackedMobile}) {
    if (itemCount < 2) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(itemCount, (index) {
              final isCurrent = _currentNewsIndex == index;
              if (isCurrent) {
                return GestureDetector(
                  onTap: () =>
                      _goToIndex(index, isStackedMobile: isStackedMobile),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 5,
                    width: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EDF0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedBuilder(
                      animation: _autoPlayProgressController,
                      builder: (context, _) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _isAutoPlayPaused
                              ? 1.0
                              : _autoPlayProgressController.value
                                  .clamp(0.0, 1.0),
                          child: Container(
                            color: const Color(0xFFD62828),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
              return GestureDetector(
                onTap: () =>
                    _goToIndex(index, isStackedMobile: isStackedMobile),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 5,
                  width: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: _isAutoPlayPaused ? 'Retomar rotação' : 'Pausar rotação',
            child: InkWell(
              onTap: () => _toggleAutoPlay(isStackedMobile: isStackedMobile),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  _isAutoPlayPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: _isAutoPlayPaused
                      ? const Color(0xFFD62828)
                      : const Color(0xFF94A3B8),
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
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

  String? _newsImageUrl(Noticia noticia) {
    final url = noticia.imagemUrl?.trim();
    if (url == null || url.isEmpty) return null;
    if (kIsWeb) return null;
    return url.replaceFirst(
      'http://www.mppb.mp.br/',
      'https://www.mppb.mp.br/',
    );
  }

  void _showNewsModal(Noticia noticia) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NoticiaDetalhesPage(noticia: noticia),
      ),
    );
  }

  Widget _buildNewsCard({
    required Noticia noticia,
    required bool compactCard,
    required double cardHorizontalPadding,
    required double cardTopPadding,
    required double cardBottomPadding,
    bool isFront = true,
  }) {
    String dateFormatted = noticia.dataPublicacao ?? '';
    final parts = dateFormatted.split(' ');
    if (parts.length > 1) {
      dateFormatted = '${parts[0]}, ${parts[1]}';
    }
    final imageUrl = _newsImageUrl(noticia);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1F343A40)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A101828),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // IMAGEM
          Expanded(
            flex: compactCard ? 8 : 9,
            child: GestureDetector(
              onTap: isFront ? () => _showNewsModal(noticia) : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(19),
                    topRight: Radius.circular(19),
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
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null
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
          // CONTEÚDO
          Expanded(
            flex: compactCard ? 10 : 11,
            child: Padding(
              padding: EdgeInsets.only(
                left: cardHorizontalPadding,
                right: cardHorizontalPadding,
                top: cardTopPadding,
                bottom: cardBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compactCard ? 7 : 9,
                      vertical: compactCard ? 5 : 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1FD62828),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      (noticia.categoria ?? 'Destaque').toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFFD62828),
                        fontSize: compactCard ? 8.5 : 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: compactCard ? 6 : 8),
                  Text(
                    dateFormatted,
                    style: TextStyle(
                      color: const Color(0xFF697370),
                      fontSize: compactCard ? 10.5 : 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: compactCard ? 6 : 8),
                  Text(
                    noticia.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF202322),
                      fontSize: compactCard ? 14 : 17,
                      fontWeight: FontWeight.w900,
                      height: compactCard ? 1.08 : 1.15,
                    ),
                  ),
                  if (!compactCard) ...[
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        noticia.resumo ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF697370),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // AÇÕES
          Padding(
            padding: EdgeInsets.only(
              left: cardHorizontalPadding,
              right: cardHorizontalPadding,
              bottom: compactCard ? 10 : 16,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: compactCard ? 104 : 132,
                  child: ElevatedButton(
                    onPressed: isFront ? () => _showNewsModal(noticia) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD62828),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(0, compactCard ? 28 : 32),
                      padding: EdgeInsets.symmetric(
                        horizontal: compactCard ? 9 : 12,
                        vertical: compactCard ? 6 : 8,
                      ),
                      textStyle: TextStyle(
                        fontSize: compactCard ? 10 : 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ler notícia'),
                          SizedBox(width: 5),
                          Icon(Icons.article_outlined, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: compactCard ? 32 : 38,
                  height: compactCard ? 30 : 34,
                  child: _CarouselNewsShareButton(
                    onPressed: isFront
                        ? () => compartilharNoticia(noticia)
                        : () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o efeito de Baralho de Cartas Empilhadas (Stacked Deck)
  /// onde as cartas ficam sobrepostas no mesmo centro, com as orelhas
  /// das cartas de trás inclinadas para esquerda e direita.
  Widget _buildStackedDeck(
    List<Noticia> carouselNews,
    MppbResponsiveMetrics responsive,
    double carouselHeight,
  ) {
    final count = carouselNews.length;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Largura do card calculada para permitir que as cartas de trás
    // fiquem visíveis inclinadas nas bordas laterais exatamente como na referência
    final cardWidth = (screenWidth - 56).clamp(280.0, 390.0);
    final compactCard = responsive.isTablet && responsive.isLandscape;
    final cardHorizontalPadding = compactCard ? 12.0 : 18.0;
    final cardTopPadding = compactCard ? 10.0 : 16.0;
    final cardBottomPadding = compactCard ? 6.0 : 10.0;

    final frontNoticia = carouselNews[_currentNewsIndex % count];
    final nextIndex = (_currentNewsIndex + 1) % count;
    final prevIndex = (_currentNewsIndex - 1 + count) % count;

    final hasBackCards = count > 1;
    final hasLeftCard = count > 2;

    return SizedBox(
      height: carouselHeight,
      child: AnimatedBuilder(
        animation: _swipeAnimationController,
        builder: (context, _) {
          final animProgress = CurvedAnimation(
            parent: _swipeAnimationController,
            curve: Curves.easeOutCubic,
          ).value;

          Offset currentOffset = _dragOffset;
          double currentAngle = _dragAngle;

          if (_swipeAnimationController.isAnimating) {
            currentOffset =
                Offset.lerp(_animStartOffset, _animTargetOffset, animProgress)!;
            currentAngle = ui.lerpDouble(
                _animStartAngle, _animTargetAngle, animProgress)!;
          }

          final swipeFactor =
              (currentOffset.dx.abs() / (screenWidth * 0.65)).clamp(0.0, 1.0);
          final isSwipingLeft = currentOffset.dx < 0;

          return GestureDetector(
            onHorizontalDragStart: (_) {
              if (_swipeAnimationController.isAnimating) return;
              _autoPlayTimer?.cancel();
              _autoPlayProgressController.stop();
            },
            onHorizontalDragUpdate: (details) {
              if (_swipeAnimationController.isAnimating) return;
              setState(() {
                _dragOffset += Offset(details.primaryDelta ?? 0, 0);
                _dragAngle = (_dragOffset.dx / 1200).clamp(-0.16, 0.16);
              });
            },
            onHorizontalDragEnd: (details) {
              if (_swipeAnimationController.isAnimating) return;
              final velocity = details.primaryVelocity ?? 0;
              if (_dragOffset.dx < -50 || velocity < -300) {
                _animateCardSwipe(isNext: true);
              } else if (_dragOffset.dx > 50 || velocity > 300) {
                _animateCardSwipe(isNext: false);
              } else {
                _animateSnapBack();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. CARTA DE TRÁS À ESQUERDA (inclinada ~ -0.10 rad / -5.7 graus)
                if (hasLeftCard) ...[
                  Builder(
                    builder: (_) {
                      final noticia = carouselNews[prevIndex];
                      final leftScale = isSwipingLeft
                          ? ui.lerpDouble(0.91, 0.88, swipeFactor)!
                          : ui.lerpDouble(0.91, 1.0, swipeFactor)!;
                      final leftAngle = isSwipingLeft
                          ? ui.lerpDouble(-0.10, -0.13, swipeFactor)!
                          : ui.lerpDouble(-0.10, 0.0, swipeFactor)!;
                      final leftTranslateY = isSwipingLeft
                          ? ui.lerpDouble(8.0, 12.0, swipeFactor)!
                          : ui.lerpDouble(8.0, 0.0, swipeFactor)!;
                      final leftOpacity = isSwipingLeft
                          ? ui.lerpDouble(0.85, 0.70, swipeFactor)!
                          : ui.lerpDouble(0.85, 1.0, swipeFactor)!;

                      return Transform.translate(
                        offset: Offset(0, leftTranslateY),
                        child: Transform.rotate(
                          angle: leftAngle,
                          alignment: Alignment.bottomCenter,
                          child: Transform.scale(
                            scale: leftScale,
                            child: Opacity(
                              opacity: leftOpacity,
                              child: SizedBox(
                                width: cardWidth,
                                height: carouselHeight,
                                child: IgnorePointer(
                                  child: _buildNewsCard(
                                    noticia: noticia,
                                    compactCard: compactCard,
                                    cardHorizontalPadding:
                                        cardHorizontalPadding,
                                    cardTopPadding: cardTopPadding,
                                    cardBottomPadding: cardBottomPadding,
                                    isFront: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // 2. CARTA DE TRÁS À DIREITA (inclinada ~ +0.10 rad / +5.7 graus)
                if (hasBackCards) ...[
                  Builder(
                    builder: (_) {
                      final noticia = carouselNews[nextIndex];
                      final rightScale = isSwipingLeft
                          ? ui.lerpDouble(0.94, 1.0, swipeFactor)!
                          : ui.lerpDouble(0.94, 0.88, swipeFactor)!;
                      final rightAngle = isSwipingLeft
                          ? ui.lerpDouble(0.10, 0.0, swipeFactor)!
                          : ui.lerpDouble(0.10, 0.13, swipeFactor)!;
                      final rightTranslateY = isSwipingLeft
                          ? ui.lerpDouble(5.0, 0.0, swipeFactor)!
                          : ui.lerpDouble(5.0, 12.0, swipeFactor)!;
                      final rightOpacity = isSwipingLeft
                          ? ui.lerpDouble(0.90, 1.0, swipeFactor)!
                          : ui.lerpDouble(0.90, 0.70, swipeFactor)!;

                      return Transform.translate(
                        offset: Offset(0, rightTranslateY),
                        child: Transform.rotate(
                          angle: rightAngle,
                          alignment: Alignment.bottomCenter,
                          child: Transform.scale(
                            scale: rightScale,
                            child: Opacity(
                              opacity: rightOpacity,
                              child: SizedBox(
                                width: cardWidth,
                                height: carouselHeight,
                                child: IgnorePointer(
                                  child: _buildNewsCard(
                                    noticia: noticia,
                                    compactCard: compactCard,
                                    cardHorizontalPadding:
                                        cardHorizontalPadding,
                                    cardTopPadding: cardTopPadding,
                                    cardBottomPadding: cardBottomPadding,
                                    isFront: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // 3. CARTA DA FRENTE (Ativa, reta e no topo)
                Transform.translate(
                  offset: currentOffset,
                  child: Transform.rotate(
                    angle: currentAngle,
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: cardWidth,
                      height: carouselHeight,
                      child: _buildNewsCard(
                        noticia: frontNoticia,
                        compactCard: compactCard,
                        cardHorizontalPadding: cardHorizontalPadding,
                        cardTopPadding: cardTopPadding,
                        cardBottomPadding: cardBottomPadding,
                        isFront: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageViewLayout(
    List<Noticia> carouselNews,
    MppbResponsiveMetrics responsive,
    double carouselHeight,
    PageController pageController,
  ) {
    final compactCard = responsive.isTablet && responsive.isLandscape;
    final cardHorizontalPadding = compactCard ? 12.0 : 18.0;
    final cardTopPadding = compactCard ? 10.0 : 16.0;
    final cardBottomPadding = compactCard ? 6.0 : 10.0;
    final itemRightPadding =
        responsive.isTablet && responsive.isLandscape ? 8.0 : 12.0;

    return SizedBox(
      height: carouselHeight,
      child: PageView.builder(
        controller: pageController,
        itemCount: carouselNews.length,
        padEnds: false,
        onPageChanged: (index) {
          setState(() {
            _currentNewsIndex = index;
          });
          if (!_isAutoPlayPaused && carouselNews.length > 1) {
            _autoPlayTimer?.cancel();
            _autoPlayTimer = null;
            _syncAutoPlay(carouselNews.length, isStackedMobile: false);
          }
        },
        itemBuilder: (context, index) {
          final noticia = carouselNews[index];
          return Padding(
            padding: EdgeInsets.only(right: itemRightPadding),
            child: _buildNewsCard(
              noticia: noticia,
              compactCard: compactCard,
              cardHorizontalPadding: cardHorizontalPadding,
              cardTopPadding: cardTopPadding,
              cardBottomPadding: cardBottomPadding,
              isFront: true,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noticiaState = ref.watch(noticiaProvider);
    final responsive = MppbResponsive.of(context);
    final todasNoticias = noticiaState.noticias;
    final isStackedMobile = !responsive.usesWideLayout &&
        !(responsive.isTablet && responsive.isLandscape);

    final carouselNews = todasNoticias
        .take(responsive.isTablet && responsive.isLandscape ? 8 : 4)
        .toList();

    _syncAutoPlay(carouselNews.length, isStackedMobile: isStackedMobile);

    final carouselHeight = responsive.isTablet && responsive.isLandscape
        ? 292.0
        : 380.0;

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
          if (isStackedMobile)
            _buildStackedDeck(carouselNews, responsive, carouselHeight)
          else
            _buildPageViewLayout(
              carouselNews,
              responsive,
              carouselHeight,
              _controllerFor(_viewportFractionFor(responsive)),
            ),
          const SizedBox(height: 10),
          _buildAutoPlayControl(
            carouselNews.length,
            isStackedMobile: isStackedMobile,
          ),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/responsive_layout.dart';
import '../../models/video_item.dart';
import '../../providers/videos_provider.dart';
import '../../utils/video_share.dart';
import 'live_banner_card.dart';
import '../video_watch_page.dart';

class VideosCarousel extends ConsumerStatefulWidget {
  const VideosCarousel({super.key});

  @override
  ConsumerState<VideosCarousel> createState() => _VideosCarouselState();
}

class _VideosCarouselState extends ConsumerState<VideosCarousel> {
  PageController? _pageController;
  double? _currentViewportFraction;
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final current = ref.read(videosProvider);
      if (current.videos.isEmpty && !current.isLoading) {
        ref.read(videosProvider.notifier).fetchVideos();
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  double _viewportFractionFor(MppbResponsiveMetrics responsive) {
    if (responsive.windowClass == MppbWindowClass.large) return 0.26;
    if (responsive.isTablet && responsive.isLandscape) return 0.28;
    if (responsive.usesWideLayout) return 0.35;
    return 0.86;
  }

  PageController _controllerFor(double viewportFraction) {
    final current = _pageController;
    if (current != null && _currentViewportFraction == viewportFraction) {
      return current;
    }

    _currentViewportFraction = viewportFraction;
    _pageController?.dispose();
    _pageController = PageController(
      viewportFraction: viewportFraction,
      keepPage: true,
    );
    return _pageController!;
  }

  void _compartilhar(VideoItem video) {
    compartilharVideo(video);
  }

  Widget _buildVideoCard({
    required BuildContext context,
    required VideoItem video,
    required double itemRightPadding,
    required bool isCompact,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: itemRightPadding),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x1F343A40)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F101828),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x0F101828),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: () => VideoWatchPage.open(context, video: video),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. CAPA / THUMBNAIL COMPLETA (Edge-to-Edge)
              CachedNetworkImage(
                imageUrl: video.fallbackThumbnail,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF0F172A),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFD62828),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF0F172A),
                  child: const Center(
                    child: Icon(Icons.videocam_rounded,
                        color: Colors.white38, size: 40),
                  ),
                ),
              ),

              // 2. GRADIENTES CINEMATOGRÁFICOS DE CONTRASTE
              // Gradiente superior para badges e botão share
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 64,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xA6000000),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Gradiente inferior profundo para título e ações
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 140,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0x80090D16),
                        Color(0xF5090D16),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. BADGES SUPERIORES
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: video.isAoVivo
                            ? const Color(0xFFD62828)
                            : const Color(0xCC0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: video.isAoVivo
                              ? const Color(0xFFEF4444)
                              : Colors.white.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(video.badgeIcon,
                              color: Colors.white, size: 11),
                          const SizedBox(width: 4.5),
                          Text(
                            video.badgeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _compartilhar(video),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0x990F172A),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                              width: 0.8,
                            ),
                          ),
                          child: const Icon(
                            Icons.ios_share_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. BOTÃO PLAY CENTRAL CINEMATOGRÁFICO
              Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD62828).withValues(alpha: 0.92),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66D62828),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              // 5. INFORMAÇÕES INFERIORES (TÍTULO, DATA E AÇÃO)
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (video.dataPublicacao != null &&
                        video.dataPublicacao!.isNotEmpty) ...[
                      Text(
                        video.dataPublicacao!,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      video.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.15,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD62828),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33D62828),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_fill_rounded,
                                  color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Assistir',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (video.duracao != null &&
                            video.duracao!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.60),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 0.6,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule_rounded,
                                    color: Color(0xFFCBD5E1), size: 10),
                                const SizedBox(width: 3),
                                Text(
                                  video.duracao!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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

  Widget _buildVideoDots(int count) {
    if (count < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isCurrent = _currentVideoIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            width: isCurrent ? 20 : 6,
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFFD62828)
                  : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videosState = ref.watch(videosProvider);
    final responsive = MppbResponsive.of(context);
    final pageController = _controllerFor(_viewportFractionFor(responsive));

    final videos = videosState.videos;
    final liveAtiva = videosState.liveAtiva;

    if (videosState.isLoading && videos.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFFD62828)),
      );
    }

    if (videos.isEmpty && liveAtiva == null) {
      return const SizedBox.shrink();
    }

    final carouselVideos = videos.take(4).toList();
    final carouselHeight = responsive.isTablet && responsive.isLandscape ? 220.0 : 240.0;
    final itemRightPadding = responsive.isTablet && responsive.isLandscape ? 10.0 : 12.0;
    final isMobile = !responsive.usesWideLayout &&
        !(responsive.isTablet && responsive.isLandscape);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (liveAtiva != null) ...[
          LiveBannerCard(liveVideo: liveAtiva),
        ],

        // Cabeçalho da Seção TV MPPB
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x1FD62828),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.live_tv_rounded,
                  color: Color(0xFFD62828),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'TV MPPB',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => context.go('/videos'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD62828),
                  foregroundColor: const Color(0xFFD62828),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  minimumSize: const Size(82, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFD62828)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text(
                  'Mais vídeos',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Carrossel de Vídeos com Efeito Coverflow
        SizedBox(
          height: carouselHeight,
          child: PageView.builder(
            controller: pageController,
            itemCount: carouselVideos.length,
            padEnds: false,
            onPageChanged: (index) {
              setState(() {
                _currentVideoIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final video = carouselVideos[index];
              final cardWidget = _buildVideoCard(
                context: context,
                video: video,
                itemRightPadding: itemRightPadding,
                isCompact: responsive.isTablet && responsive.isLandscape,
              );

              if (!isMobile) {
                return cardWidget;
              }

              // Efeito Coverflow Cinemático 3D no Mobile
              return AnimatedBuilder(
                animation: pageController,
                builder: (context, child) {
                  double page = _currentVideoIndex.toDouble();
                  if (pageController.hasClients &&
                      pageController.position.haveDimensions &&
                      pageController.page != null) {
                    page = pageController.page!;
                  }

                  final diff = (index - page).abs();
                  final scale = (1.0 - (diff * 0.07)).clamp(0.92, 1.0);
                  final translateY = (diff * 5.0).clamp(0.0, 7.0);
                  final opacity = (1.0 - (diff * 0.22)).clamp(0.72, 1.0);

                  return Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: cardWidget,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Dots indicadores de paginação de vídeos
        _buildVideoDots(carouselVideos.length),
      ],
    );
  }
}

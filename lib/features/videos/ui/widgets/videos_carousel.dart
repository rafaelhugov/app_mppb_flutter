import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/responsive_layout.dart';
import '../../models/video_item.dart';
import '../../providers/videos_provider.dart';
import '../../utils/video_share.dart';
import 'live_banner_card.dart';
import 'video_player_sheet.dart';

class VideosCarousel extends ConsumerStatefulWidget {
  const VideosCarousel({super.key});

  @override
  ConsumerState<VideosCarousel> createState() => _VideosCarouselState();
}

class _VideosCarouselState extends ConsumerState<VideosCarousel> {
  PageController? _pageController;
  double? _currentViewportFraction;

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
    return 0.88;
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
      keepPage: false,
    );
    return _pageController!;
  }

  void _compartilhar(VideoItem video) {
    compartilharVideo(video);
  }

  @override
  Widget build(BuildContext context) {
    final videosState = ref.watch(videosProvider);
    final responsive = MppbResponsive.of(context);
    final pageController = _controllerFor(_viewportFractionFor(responsive));

    final videos = videosState.videos;
    final liveAtiva = videosState.liveAtiva;

    // Se estiver carregando e não tiver vídeos
    if (videosState.isLoading && videos.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFFD62828)),
      );
    }

    // Se não houver vídeos e nenhum erro
    if (videos.isEmpty && liveAtiva == null) {
      return const SizedBox.shrink();
    }

    final carouselHeight = responsive.isTablet && responsive.isLandscape ? 280.0 : 310.0;
    final itemRightPadding = responsive.isTablet && responsive.isLandscape ? 10.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Se houver Live Ativa, mostra o Banner de Destaque
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TV MPPB',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Sessões, transmissões e conteúdos oficiais',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/videos'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD62828),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ver todos'),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Carrossel de Vídeos
        SizedBox(
          height: carouselHeight,
          child: PageView.builder(
            controller: pageController,
            itemCount: videos.take(8).length,
            padEnds: false,
            itemBuilder: (context, index) {
              final video = videos[index];

              return Padding(
                padding: EdgeInsets.only(right: itemRightPadding),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x26343A40)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14101828),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // THUMBNAIL COM PLAY OVERLAY
                      Expanded(
                        flex: 11,
                        child: GestureDetector(
                          onTap: () => VideoPlayerSheet.show(context, video),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: video.fallbackThumbnail,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFF1E293B),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFD62828),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: const Color(0xFF1E293B),
                                    child: const Center(
                                      child: Icon(Icons.videocam_rounded, color: Colors.white54, size: 36),
                                    ),
                                  ),
                                ),
                                // Gradiente para contraste do botão Play
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black38,
                                        Colors.transparent,
                                        Colors.black54,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                // Botão Play Central
                                Center(
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD62828).withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x66000000),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                // Badge de Categoria no Topo
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(video.badgeIcon, color: Colors.white, size: 11),
                                        const SizedBox(width: 4),
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // INFORMAÇÕES E BOTÕES
                      Expanded(
                        flex: 9,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (video.dataPublicacao != null && video.dataPublicacao!.isNotEmpty)
                                    Text(
                                      video.dataPublicacao!,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    video.titulo,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                      height: 1.18,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => VideoPlayerSheet.show(context, video),
                                      icon: const Icon(Icons.play_circle_outline_rounded, size: 15),
                                      label: const Text('Assistir'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD62828),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        minimumSize: const Size(0, 30),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _compartilhar(video),
                                    icon: const Icon(Icons.share_outlined, size: 16),
                                    color: const Color(0xFF64748B),
                                    tooltip: 'Compartilhar',
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
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
            },
          ),
        ),
      ],
    );
  }
}

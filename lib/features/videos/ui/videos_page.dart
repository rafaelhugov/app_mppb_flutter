import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/mppb_app_bar.dart';
import '../../../core/ui/responsive_layout.dart';
import '../models/video_item.dart';
import '../providers/videos_provider.dart';
import '../utils/video_share.dart';
import 'widgets/live_banner_card.dart';
import 'widgets/video_player_sheet.dart';

class VideosPage extends ConsumerStatefulWidget {
  const VideosPage({super.key});

  @override
  ConsumerState<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends ConsumerState<VideosPage> {
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  void _compartilhar(VideoItem video) {
    compartilharVideo(video);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videosProvider);
    final responsive = MppbResponsive.of(context);
    final videos = state.filteredVideos;
    final liveAtiva = state.liveAtiva;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const MppbAppBar(),
      body: RefreshIndicator(
        color: const Color(0xFFD62828),
        onRefresh: () => ref.read(videosProvider.notifier).fetchVideos(isUserRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  16,
                  responsive.horizontalPadding,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LIVE ATIVA SE HOUVER
                    if (liveAtiva != null) ...[
                      LiveBannerCard(liveVideo: liveAtiva),
                    ],

                    // BARRA DE PESQUISA
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          ref.read(videosProvider.notifier).setSearchTerm(val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar vídeos, sessões, transmissões...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B), size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(videosProvider.notifier).setSearchTerm('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // PÍLULAS DE FILTRO
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Todos (${state.videos.length})',
                            isSelected: state.filtroSelecionado == TipoVideoFiltro.todos,
                            onTap: () => ref.read(videosProvider.notifier).setFiltro(TipoVideoFiltro.todos),
                            icon: Icons.video_collection_outlined,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Sessões & Lives (${state.sessoesCount})',
                            isSelected: state.filtroSelecionado == TipoVideoFiltro.sessoes,
                            onTap: () => ref.read(videosProvider.notifier).setFiltro(TipoVideoFiltro.sessoes),
                            icon: Icons.gavel_rounded,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Institucionais (${state.institucionaisCount})',
                            isSelected: state.filtroSelecionado == TipoVideoFiltro.institucionais,
                            onTap: () => ref.read(videosProvider.notifier).setFiltro(TipoVideoFiltro.institucionais),
                            icon: Icons.videocam_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // CONTEÚDO: LOADING, ERRO OU LISTA
            if (state.isLoading && videos.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD62828)),
                ),
              )
            else if (videos.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0x1AD62828),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.video_library_outlined,
                            color: Color(0xFFD62828),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum vídeo encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tente buscar com outros termos ou altere o filtro.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  0,
                  responsive.horizontalPadding,
                  32,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final video = videos[index];
                      return _buildVideoCard(context, video);
                    },
                    childCount: videos.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Material(
      color: isSelected ? const Color(0xFFD62828) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      elevation: isSelected ? 2 : 0,
      shadowColor: const Color(0x40D62828),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? const Color(0xFFD62828) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, VideoItem video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // THUMBNAIL COM OVERLAY
          GestureDetector(
            onTap: () => VideoPlayerSheet.show(context, video),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.fallbackThumbnail,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFF0F172A),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD62828)),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFF0F172A),
                        child: const Center(
                          child: Icon(Icons.videocam_rounded, color: Colors.white54, size: 40),
                        ),
                      ),
                    ),
                    // Gradiente
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black45,
                            Colors.transparent,
                            Colors.black54,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Botão Central de Play
                    Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD62828).withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                    // Badge da Categoria
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(video.badgeIcon, color: Colors.white, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              video.badgeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
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

          // CONTEÚDO
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (video.dataPublicacao != null && video.dataPublicacao!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        video.dataPublicacao!,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Text(
                  video.titulo,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => VideoPlayerSheet.show(context, video),
                        icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                        label: const Text('Assistir Vídeo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD62828),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => _compartilhar(video),
                      icon: const Icon(Icons.share_outlined, size: 20),
                      color: const Color(0xFF64748B),
                      tooltip: 'Compartilhar',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

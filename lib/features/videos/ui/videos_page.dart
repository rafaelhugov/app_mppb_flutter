import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/responsive_layout.dart';
import '../models/video_item.dart';
import '../providers/videos_provider.dart';
import '../utils/video_share.dart';
import 'video_watch_page.dart';
import 'widgets/live_banner_card.dart';

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

  Future<void> _abrirNoYouTube(VideoItem video) async {
    final uri = Uri.tryParse(video.youtubeUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirCanalMPPB() async {
    final uri = Uri.parse('https://www.youtube.com/@CanalMPPB');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videosProvider);
    final responsive = MppbResponsive.of(context);
    final videos = state.filteredVideos;
    final liveAtiva = state.liveAtiva;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                  14,
                  responsive.horizontalPadding,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LIVE ATIVA EM DESTAQUE SE HOUVER
                    if (liveAtiva != null) ...[
                      LiveBannerCard(liveVideo: liveAtiva),
                      const SizedBox(height: 12),
                    ],

                    // CABEÇALHO DO CANAL OFICIAL NO ESTILO YOUTUBE
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/canal_mppb_avatar.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/brasao_mppb_sem_fundo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.account_balance_rounded,
                                    color: Color(0xFFD62828),
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text(
                                      'Canal MPPB',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ministério Público da Paraíba',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: _abrirCanalMPPB,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                                  SizedBox(width: 3),
                                  Text(
                                    'Canal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CAMPO DE BUSCA
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                            fontSize: 13.5,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B), size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(videosProvider.notifier).setSearchTerm('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ABAS NO ESTILO YOUTUBE (TODOS, VÍDEOS, AO VIVO & SESSÕES)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Todos (${state.videos.length})',
                            isSelected: state.filtroSelecionado == TipoVideoFiltro.todos,
                            onTap: () => ref.read(videosProvider.notifier).setFiltro(TipoVideoFiltro.todos),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Vídeos (${state.institucionaisCount})',
                            isSelected: state.filtroSelecionado == TipoVideoFiltro.institucionais,
                            onTap: () => ref.read(videosProvider.notifier).setFiltro(TipoVideoFiltro.institucionais),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Ao Vivo & Sessões (${state.sessoesCount})',
                            isSelected: state.filtroSelecionado == TipoVideoFiltro.sessoes,
                            onTap: () => ref.read(videosProvider.notifier).setFiltro(TipoVideoFiltro.sessoes),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // CONTEÚDO: CARREGANDO, VAZIO OU FEED
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
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0x1AD62828),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.video_library_outlined,
                            color: Color(0xFFD62828),
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 14),
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
                          'Tente pesquisar com outro termo ou mude de aba.',
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
  }) {
    return Material(
      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, VideoItem video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => VideoWatchPage.open(context, video: video),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // THUMBNAIL 16:9 ESTILO YOUTUBE
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
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
                      // BADGE DE DURAÇÃO OU AO VIVO NO CANTO INFERIOR DIREITO
                      if (video.isAoVivo)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD62828),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'AO VIVO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        )
                      else if (video.duracao != null && video.duracao!.isNotEmpty)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video.duracao!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      // BADGE SUPERIOR DE TIPO
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(video.badgeIcon, size: 11, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                video.badgeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
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

              // INFORMAÇÕES DO VÍDEO ABAIXO DA THUMBNAIL ESTILO YOUTUBE
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AVATAR DO CANAL
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/canal_mppb_avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/brasao_mppb_sem_fundo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFFD62828),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // TÍTULO E METADADOS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'Canal MPPB',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              if (video.visualizacoes != null && video.visualizacoes!.isNotEmpty) ...[
                                const Text(' • ', style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                                Text(
                                  video.visualizacoes!,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                ),
                              ],
                              if (video.dataPublicacao != null && video.dataPublicacao!.isNotEmpty) ...[
                                const Text(' • ', style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                                Flexible(
                                  child: Text(
                                    video.dataPublicacao!,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // BOTÃO DE 3 PONTINHOS COM MENU (FUNDO BRANCO PURO)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF64748B)),
                      padding: EdgeInsets.zero,
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      onSelected: (val) {
                        if (val == 'compartilhar') {
                          _compartilhar(video);
                        } else if (val == 'youtube') {
                          _abrirNoYouTube(video);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'compartilhar',
                          child: Row(
                            children: [
                              Icon(Icons.share_rounded, size: 17, color: Color(0xFF334155)),
                              SizedBox(width: 10),
                              Text(
                                'Compartilhar',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'youtube',
                          child: Row(
                            children: [
                              Icon(Icons.open_in_new_rounded, size: 17, color: Color(0xFFFF0000)),
                              SizedBox(width: 10),
                              Text(
                                'Abrir no YouTube',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

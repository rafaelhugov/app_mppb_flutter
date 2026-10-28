import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/video_item.dart';
import '../providers/videos_provider.dart';
import '../utils/video_share.dart';

class VideoWatchPage extends ConsumerStatefulWidget {
  final VideoItem? video;
  final String? initialVideoId;

  const VideoWatchPage({
    super.key,
    this.video,
    this.initialVideoId,
  });

  static Future<void> open(BuildContext context, {required VideoItem video}) {
    return context.push('/videos/watch', extra: video);
  }

  @override
  ConsumerState<VideoWatchPage> createState() => _VideoWatchPageState();
}

class _VideoWatchPageState extends ConsumerState<VideoWatchPage> {
  late VideoItem _currentVideo;
  late final YoutubePlayerController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video ??
        VideoItem(
          id: widget.initialVideoId ?? '',
          titulo: 'Vídeo da TV MPPB',
        );

    _controller = YoutubePlayerController.fromVideoId(
      videoId: _currentVideo.id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        loop: false,
        playsInline: true,
        enableCaption: true,
      ),
    );

    _controller.setFullScreenListener((isFullScreen) {
      if (isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _selecionarVideo(VideoItem novoVideo) {
    if (novoVideo.id == _currentVideo.id) return;
    setState(() {
      _currentVideo = novoVideo;
      _isDescriptionExpanded = false;
    });
    _controller.loadVideoById(videoId: novoVideo.id);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
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

  void _compartilhar(VideoItem video) {
    compartilharVideo(video);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videosProvider);
    final outrosVideos = state.videos.where((v) => v.id != _currentVideo.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 2),
                  Text(
                    'TV MPPB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Ministério Público da Paraíba',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // PLAYER DE VÍDEO 16:9 FIXO NO TOPO
            Container(
              color: Colors.black,
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _controller,
                  aspectRatio: 16 / 9,
                ),
              ),
            ),

            // CONTEÚDO SCROLLABLE (DETALHES, CANAL, AÇÕES E RECOMENDADOS)
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                children: [
                  // BADGE DE STATUS E DATA
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _currentVideo.badgeBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_currentVideo.badgeIcon, size: 12, color: _currentVideo.badgeColor),
                            const SizedBox(width: 4),
                            Text(
                              _currentVideo.badgeLabel,
                              style: TextStyle(
                                color: _currentVideo.badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_currentVideo.duracao != null && _currentVideo.duracao!.isNotEmpty)
                        Text(
                          'Duração: ${_currentVideo.duracao}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // TÍTULO DO VÍDEO
                  Text(
                    _currentVideo.titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // METADADOS (VISUALIZAÇÕES E DATA)
                  Row(
                    children: [
                      if (_currentVideo.visualizacoes != null && _currentVideo.visualizacoes!.isNotEmpty) ...[
                        Text(
                          _currentVideo.visualizacoes!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ],
                      if (_currentVideo.dataPublicacao != null && _currentVideo.dataPublicacao!.isNotEmpty)
                        Text(
                          _currentVideo.dataPublicacao!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // LINHA DO CANAL MPPB COM AVATAR
                  InkWell(
                    onTap: _abrirCanalMPPB,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
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
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Canal MPPB',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 13,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Ministério Público da Paraíba',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.subscriptions_rounded, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Canal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // BARRA DE AÇÕES ESTILO YOUTUBE
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _abrirNoYouTube(_currentVideo),
                          icon: const Icon(Icons.play_circle_filled_rounded, color: Color(0xFFFF0000), size: 18),
                          label: const Text(
                            'Abrir no YouTube',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _compartilhar(_currentVideo),
                          icon: const Icon(Icons.share_rounded, color: Color(0xFF475569), size: 17),
                          label: const Text(
                            'Compartilhar',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // DESCRIÇÃO EXPANSÍVEL
                  if (_currentVideo.descricao != null && _currentVideo.descricao!.trim().isNotEmpty) ...[
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isDescriptionExpanded = !_isDescriptionExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Descrição',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentVideo.descricao!.trim(),
                              maxLines: _isDescriptionExpanded ? null : 2,
                              overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isDescriptionExpanded ? 'Mostrar menos' : '...mais',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Divider(color: Color(0xFFE2E8F0), height: 24),

                  // SEÇÃO: MAIS DA TV MPPB (PRÓXIMOS VÍDEOS ESTILO YOUTUBE)
                  Row(
                    children: [
                      const Text(
                        'Mais da TV MPPB',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${outrosVideos.length} vídeos',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (outrosVideos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Nenhum outro vídeo disponível no momento.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...outrosVideos.map((item) => _buildRecomendadoCard(item)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendadoCard(VideoItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selecionarVideo(item),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // THUMBNAIL COMPACTA 16:9 COM BADGE DE DURAÇÃO
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 120,
                    height: 68,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: item.fallbackThumbnail,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFF0F172A),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD62828)),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF0F172A),
                            child: const Icon(Icons.videocam_rounded, color: Colors.white38, size: 24),
                          ),
                        ),
                        if (item.isAoVivo)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD62828),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'AO VIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          )
                        else if (item.duracao != null && item.duracao!.isNotEmpty)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.duracao!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // METADADOS À DIREITA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Canal MPPB',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (item.visualizacoes != null && item.visualizacoes!.isNotEmpty) ...[
                            Text(
                              item.visualizacoes!,
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                            ),
                            const Text(' • ', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                          ],
                          if (item.dataPublicacao != null && item.dataPublicacao!.isNotEmpty)
                            Flexible(
                              child: Text(
                                item.dataPublicacao!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // MENU 3 PONTINHOS (FUNDO BRANCO PURO)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF94A3B8)),
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
                      _compartilhar(item);
                    } else if (val == 'youtube') {
                      _abrirNoYouTube(item);
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
        ),
      ),
    );
  }
}

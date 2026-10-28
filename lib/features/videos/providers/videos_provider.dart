import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/video_item.dart';
import '../models/videos_response.dart';

class VideosState {
  final bool isLoading;
  final List<VideoItem> videos;
  final VideoItem? liveAtiva;
  final String? errorMessage;
  final String searchTerm;
  final TipoVideoFiltro filtroSelecionado;

  const VideosState({
    this.isLoading = false,
    this.videos = const [],
    this.liveAtiva,
    this.errorMessage,
    this.searchTerm = '',
    this.filtroSelecionado = TipoVideoFiltro.todos,
  });

  VideosState copyWith({
    bool? isLoading,
    List<VideoItem>? videos,
    VideoItem? liveAtiva,
    bool clearLiveAtiva = false,
    String? errorMessage,
    String? searchTerm,
    TipoVideoFiltro? filtroSelecionado,
  }) {
    return VideosState(
      isLoading: isLoading ?? this.isLoading,
      videos: videos ?? this.videos,
      liveAtiva: clearLiveAtiva ? null : (liveAtiva ?? this.liveAtiva),
      errorMessage: errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
      filtroSelecionado: filtroSelecionado ?? this.filtroSelecionado,
    );
  }

  String _normalize(String value) => value.toLowerCase().trim();

  List<VideoItem> get filteredVideos {
    final term = _normalize(searchTerm);

    return videos.where((video) {
      // 1. Filtro por categoria
      final matchesCategory = switch (filtroSelecionado) {
        TipoVideoFiltro.todos => true,
        TipoVideoFiltro.sessoes => video.isSessao,
        TipoVideoFiltro.institucionais => video.isInstitucional,
      };

      if (!matchesCategory) return false;

      // 2. Filtro por busca de texto
      if (term.isEmpty) return true;
      final searchable = _normalize(
        '${video.titulo} ${video.descricao ?? ''} ${video.badgeLabel}',
      );
      return searchable.contains(term);
    }).toList();
  }

  int get sessoesCount => videos.where((v) => v.isSessao).length;
  int get institucionaisCount => videos.where((v) => v.isInstitucional).length;
}

class VideosNotifier extends Notifier<VideosState> {
  @override
  VideosState build() {
    return const VideosState();
  }

  Future<void> fetchVideos({bool isUserRefresh = false}) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/public/videos');

      if (!ref.mounted) return;
      if (response.statusCode == 200 && response.data != null) {
        final parsed = VideosResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        state = state.copyWith(
          isLoading: false,
          videos: parsed.videos,
          liveAtiva: parsed.liveAtiva,
          clearLiveAtiva: parsed.liveAtiva == null,
        );
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível carregar os vídeos no momento.',
      );
    }
  }

  void setSearchTerm(String term) {
    state = state.copyWith(searchTerm: term);
  }

  void setFiltro(TipoVideoFiltro filtro) {
    state = state.copyWith(filtroSelecionado: filtro);
  }
}

final videosProvider = NotifierProvider<VideosNotifier, VideosState>(() {
  return VideosNotifier();
});

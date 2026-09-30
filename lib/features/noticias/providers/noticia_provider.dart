import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/noticia.dart';

class NoticiaState {
  static const int itemsPerPage = 6;

  final bool isLoading;
  final List<Noticia> noticias;
  final String? errorMessage;
  final String searchTerm;
  final int currentPage;

  NoticiaState({
    this.isLoading = false,
    this.noticias = const [],
    this.errorMessage,
    this.searchTerm = '',
    this.currentPage = 1,
  });

  NoticiaState copyWith({
    bool? isLoading,
    List<Noticia>? noticias,
    String? errorMessage,
    String? searchTerm,
    int? currentPage,
  }) {
    return NoticiaState(
      isLoading: isLoading ?? this.isLoading,
      noticias: noticias ?? this.noticias,
      errorMessage: errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  String _normalize(String value) {
    return value.toLowerCase();
  }

  List<Noticia> get filteredNews {
    final term = _normalize(searchTerm);
    return noticias.where((noticia) {
      final searchable = _normalize(
        '${noticia.titulo} ${noticia.resumo ?? ''} ${noticia.categoria ?? ''}',
      );
      return term.isEmpty || searchable.contains(term);
    }).toList();
  }

  Noticia? get featuredNews =>
      filteredNews.isNotEmpty ? filteredNews.first : null;
  List<Noticia> get regularNews =>
      filteredNews.length > 1 ? filteredNews.sublist(1) : [];

  int get totalPages {
    final pages = (filteredNews.length / itemsPerPage).ceil();
    return pages > 0 ? pages : 1;
  }

  List<Noticia> get paginatedNews {
    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    if (start >= filteredNews.length) return [];
    if (end > filteredNews.length) return filteredNews.sublist(start);
    return filteredNews.sublist(start, end);
  }
}

class NoticiaNotifier extends Notifier<NoticiaState> {
  @override
  NoticiaState build() {
    Future.microtask(() => fetchNoticias());
    return NoticiaState();
  }

  Future<void> fetchNoticias() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (!ref.mounted) return;
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/public/noticias');

      if (!ref.mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final noticiasList = data
            .map((item) => Noticia.fromJson(item))
            .toList();

        state = state.copyWith(isLoading: false, noticias: noticiasList);
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar notícias: $e',
      );
    }
  }

  void setSearchTerm(String term) {
    state = state.copyWith(
      searchTerm: term,
      currentPage: 1,
    ); // Volta pra pág 1 ao pesquisar
  }

  void setPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }
}

final noticiaProvider = NotifierProvider<NoticiaNotifier, NoticiaState>(() {
  return NoticiaNotifier();
});

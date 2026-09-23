import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/diario_oficial.dart';

class DiarioOficialState {
  final bool isLoading;
  final List<DiarioOficial> diarios;
  final String? errorMessage;
  final int currentPage;
  final DateTime? selectedDate;

  const DiarioOficialState({
    this.isLoading = false,
    this.diarios = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.selectedDate,
  });

  List<DiarioOficial> get filteredDiarios {
    if (selectedDate == null) return diarios;
    return diarios.where((d) {
      if (d.dataPublicacao == null) return false;
      return d.dataPublicacao!.year == selectedDate!.year &&
          d.dataPublicacao!.month == selectedDate!.month &&
          d.dataPublicacao!.day == selectedDate!.day;
    }).toList();
  }

  int get totalPages {
    final total = filteredDiarios.length;
    if (total == 0) return 0;
    if (total <= 9) return 1;
    return 1 + ((total - 9) / 8).ceil();
  }

  List<DiarioOficial> get paginatedDiarios {
    final filtered = filteredDiarios;
    if (currentPage == 1) {
      return filtered.take(9).toList();
    } else {
      final start = 9 + (currentPage - 2) * 8;
      return filtered.skip(start).take(8).toList();
    }
  }

  DiarioOficialState copyWith({
    bool? isLoading,
    List<DiarioOficial>? diarios,
    String? errorMessage,
    int? currentPage,
    DateTime? selectedDate,
    bool clearDate = false,
  }) {
    return DiarioOficialState(
      isLoading: isLoading ?? this.isLoading,
      diarios: diarios ?? this.diarios,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
    );
  }
}

class DiarioOficialNotifier extends Notifier<DiarioOficialState> {
  @override
  DiarioOficialState build() {
    Future.microtask(() => fetchDiarios());
    return const DiarioOficialState();
  }

  Future<void> fetchDiarios() async {
    state = state.copyWith(isLoading: true, errorMessage: null, currentPage: 1);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/public/diarios-oficiais/recentes');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final diariosList = data
            .map((item) => DiarioOficial.fromJson(item))
            .toList();

        state = state.copyWith(isLoading: false, diarios: diariosList);
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Não foi possível carregar os diários oficiais. Verifique sua conexão.',
      );
    }
  }

  void setPage(int page) {
    if (page > 0 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }

  void setFilterDate(DateTime? date) {
    state = state.copyWith(
      selectedDate: date,
      clearDate: date == null,
      currentPage: 1,
    );
  }
}

final diarioOficialProvider =
    NotifierProvider<DiarioOficialNotifier, DiarioOficialState>(() {
      return DiarioOficialNotifier();
    });

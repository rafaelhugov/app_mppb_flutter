import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/diario_oficial_provider.dart';
import '../models/diario_oficial.dart';

class DiarioOficialPage extends ConsumerWidget {
  const DiarioOficialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diarioOficialProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 64.0),
          children: [
            _buildHeader(context, ref, state),
            if (state.selectedDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      'Filtro: ${DateFormat('dd/MM/yyyy').format(state.selectedDate!)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C534C)),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => ref.read(diarioOficialProvider.notifier).setFilterDate(null),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Limpar filtro'),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF8F2A1D)),
                    ),
                  ],
                ),
              ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              _buildError(state.errorMessage!, ref)
            else
              _buildListContent(state.paginatedDiarios, state.currentPage, state.totalPages, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DiarioOficialState state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 34),
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 44),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x3DD6A92F), width: 1)),
        gradient: LinearGradient(
          colors: [Color(0xFF241D19), Color(0xFF3A241D), Color(0xFF8F2A1D)],
          stops: [0.0, 0.46, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'MPPB+',
                  style: TextStyle(color: Color(0xFFE3C474), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.9),
                ),
                SizedBox(height: 8),
                Text(
                  'Diário Oficial',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFF8EA),
                    shadows: [Shadow(color: Color(0x38000000), offset: Offset(0, 2), blurRadius: 12)],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Acesse as edições do Diário Oficial\nEletrônico do MPPB.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFD8C5AA), height: 1.4),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              state.selectedDate != null ? Icons.event_available : Icons.calendar_month,
              color: state.selectedDate != null ? const Color(0xFFE3C474) : const Color(0xFFFFF8EA),
              size: 28,
            ),
            onPressed: () => _selectDate(context, ref, state),
            tooltip: 'Filtrar por data',
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref, DiarioOficialState state) async {
    final validDates = state.diarios
        .map((d) => d.dataPublicacao)
        .where((d) => d != null)
        .map((d) => DateTime(d!.year, d.month, d.day))
        .toSet();

    if (validDates.isEmpty) return;

    final firstDate = validDates.reduce((a, b) => a.isBefore(b) ? a : b);
    final lastDate = validDates.reduce((a, b) => a.isAfter(b) ? a : b);
    final initialDate = state.selectedDate ?? lastDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime val) {
        final date = DateTime(val.year, val.month, val.day);
        return validDates.contains(date);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8F2A1D),
              onPrimary: Colors.white,
              onSurface: Color(0xFF5C534C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(diarioOficialProvider.notifier).setFilterDate(picked);
    }
  }

  Widget _buildError(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(diarioOficialProvider.notifier).fetchDiarios(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8F2A1D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(List<DiarioOficial> diarios, int currentPage, int totalPages, WidgetRef ref) {
    if (diarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Text('Nenhum diário oficial encontrado.', style: TextStyle(color: Color(0xFF635041))),
        ),
      );
    }

    // Na página 1 e sem filtro, o primeiro item é a Última Edição. Nas demais páginas, todos são itens normais.
    final hasLatest = currentPage == 1 && ref.read(diarioOficialProvider).selectedDate == null;
    final startIndexForGrid = hasLatest ? 1 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasLatest && diarios.isNotEmpty) ...[
            _DiarioCard(diario: diarios[0], isLatest: true),
            const SizedBox(height: 12),
          ],
          for (int i = startIndexForGrid; i < diarios.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _DiarioCard(diario: diarios[i], isLatest: false)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: i + 1 < diarios.length
                        ? _DiarioCard(diario: diarios[i + 1], isLatest: false)
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _buildPagination(currentPage, totalPages, ref),
        ],
      ),
    );
  }

  Widget _buildPagination(int currentPage, int totalPages, WidgetRef ref) {
    if (totalPages <= 1) return const SizedBox();

    final onSelect = (int page) {
      ref.read(diarioOficialProvider.notifier).setPage(page);
    };

    List<Widget> pages = [];
    int start = (currentPage - 1).clamp(1, totalPages);
    int end = (start + 2).clamp(1, totalPages);
    start = (end - 2).clamp(1, totalPages);

    if (start > 1) {
      pages.add(_buildPageButton(1, currentPage, onSelect));
      if (start > 2) {
        pages.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Color(0xFF806F5E), fontWeight: FontWeight.w800))));
      }
    }

    for (int i = start; i <= end; i++) {
      pages.add(_buildPageButton(i, currentPage, onSelect));
    }

    if (end < totalPages) {
      if (end < totalPages - 1) {
        pages.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Color(0xFF806F5E), fontWeight: FontWeight.w800))));
      }
      pages.add(_buildPageButton(totalPages, currentPage, onSelect));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          color: currentPage > 1 ? const Color(0xFF806F5E) : const Color(0xFFC0AFA2),
          onPressed: currentPage > 1 ? () => onSelect(currentPage - 1) : null,
        ),
        ...pages,
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          color: currentPage < totalPages ? const Color(0xFF806F5E) : const Color(0xFFC0AFA2),
          onPressed: currentPage < totalPages ? () => onSelect(currentPage + 1) : null,
        ),
      ],
    );
  }

  Widget _buildPageButton(int page, int currentPage, void Function(int) onSelect) {
    final isActive = page == currentPage;
    return GestureDetector(
      onTap: () => onSelect(page),
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: isActive
            ? BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFA63022), Color(0xFF7A1C11)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [BoxShadow(color: Color(0x337A1C11), offset: Offset(0, 4), blurRadius: 12)],
              )
            : null,
        child: Text(
          '$page',
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF806F5E),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _DiarioCard extends StatelessWidget {
  final DiarioOficial diario;
  final bool isLatest;

  const _DiarioCard({required this.diario, required this.isLatest});

  Future<void> _abrirPdf(BuildContext context) async {
    final urlPdf = 'https://ged-api.mppb.mp.br/public/arquivos/${diario.idArquivo}/file';
    final url = Uri.parse(urlPdf);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o PDF do Diário Oficial.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFCFAF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFEFEAE4), width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F5D4D40),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLatest)
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EA),
                border: Border.all(color: const Color(0x4DD6A92F)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ÚLTIMA EDIÇÃO',
                style: TextStyle(
                  color: Color(0xFF8F2A1D),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0x70FFDE8E), width: 1),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x4C24120C), offset: Offset(0, 12), blurRadius: 28)],
            ),
            child: const Icon(Icons.newspaper, color: Color(0xFF211713), size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            'Nº ${diario.numeroEdicao}',
            style: TextStyle(
              fontFamily: GoogleFonts.ebGaramond().fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5C534C),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            diario.dataPublicacao != null
                ? 'Publicado em\n${DateFormat('dd/MM/yyyy').format(diario.dataPublicacao!)}'
                : 'Data indisponível',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF806F5E),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA63022), Color(0xFF7A1C11)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Color(0x337A1C11), offset: Offset(0, 4), blurRadius: 12)],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _abrirPdf(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Baixar PDF',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.download, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

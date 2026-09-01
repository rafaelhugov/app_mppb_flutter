import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../providers/diario_oficial_provider.dart';
import '../models/diario_oficial.dart';

class DiarioOficialPage extends ConsumerWidget {
  const DiarioOficialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diarioOficialProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MainLayout.contentBottomPadding(context),
          ),
          children: [
            _buildHeader(context, ref, state),
            if (state.selectedDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      'Filtro: ${DateFormat('dd/MM/yyyy').format(state.selectedDate!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF697370),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => ref
                          .read(diarioOficialProvider.notifier)
                          .setFilterDate(null),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Limpar filtro'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD62828),
                      ),
                    ),
                  ],
                ),
              ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD62828)),
                ),
              )
            else if (state.errorMessage != null)
              _buildError(state.errorMessage!, ref)
            else
              _buildListContent(
                state.paginatedDiarios,
                state.currentPage,
                state.totalPages,
                ref,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    DiarioOficialState state,
  ) {
    return HeroHeaderPublico(
      label: '',
      title: 'Diário Oficial',
      subtitle: '',
      icon: Icons.description_rounded,
      rightWidget: IconButton(
        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(
          state.selectedDate != null
              ? Icons.event_available
              : Icons.calendar_month,
          color: state.selectedDate != null
              ? const Color(0xFFD62828)
              : const Color(0xFF697370),
          size: 21,
        ),
        onPressed: () => _selectDate(context, ref, state),
        tooltip: 'Filtrar por data',
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    DiarioOficialState state,
  ) async {
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
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: const Locale('pt', 'BR'),
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      helpText: 'Selecione uma data',
      selectableDayPredicate: (DateTime val) {
        final date = DateTime(val.year, val.month, val.day);
        return validDates.contains(date);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD62828),
              onPrimary: Colors.white,
              onSurface: Color(0xFF202322),
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
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(diarioOficialProvider.notifier).fetchDiarios(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD62828),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(
    List<DiarioOficial> diarios,
    int currentPage,
    int totalPages,
    WidgetRef ref,
  ) {
    if (diarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Text(
            'Nenhum diário oficial encontrado.',
            style: TextStyle(color: Color(0xFF697370)),
          ),
        ),
      );
    }

    // Na página 1 e sem filtro, o primeiro item é a Última Edição. Nas demais páginas, todos são itens normais.
    final hasLatest =
        currentPage == 1 &&
        ref.read(diarioOficialProvider).selectedDate == null;
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
                  Expanded(
                    child: _DiarioCard(diario: diarios[i], isLatest: false),
                  ),
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

    void onSelect(int page) {
      ref.read(diarioOficialProvider.notifier).setPage(page);
    }

    List<Widget> pages = [];
    int start = (currentPage - 1).clamp(1, totalPages);
    int end = (start + 2).clamp(1, totalPages);
    start = (end - 2).clamp(1, totalPages);

    if (start > 1) {
      pages.add(_buildPageButton(1, currentPage, onSelect));
      if (start > 2) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(
                color: Color(0xFF697370),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    }

    for (int i = start; i <= end; i++) {
      pages.add(_buildPageButton(i, currentPage, onSelect));
    }

    if (end < totalPages) {
      if (end < totalPages - 1) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(
                color: Color(0xFF697370),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
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
          color: currentPage > 1
              ? const Color(0xFFD62828)
              : const Color(0xFFB7C0BD),
          onPressed: currentPage > 1 ? () => onSelect(currentPage - 1) : null,
        ),
        ...pages,
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          color: currentPage < totalPages
              ? const Color(0xFFD62828)
              : const Color(0xFFB7C0BD),
          onPressed: currentPage < totalPages
              ? () => onSelect(currentPage + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildPageButton(
    int page,
    int currentPage,
    void Function(int) onSelect,
  ) {
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
                color: const Color(0xFFD62828),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Text(
          '$page',
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFD62828),
            fontWeight: FontWeight.w500,
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

  String get _pdfUrl =>
      'https://ged-api.mppb.mp.br/public/arquivos/${diario.idArquivo}/file';

  Future<Uint8List> _carregarPdf() async {
    final response = await Dio().get<List<int>>(
      _pdfUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const []);
  }

  Future<void> _abrirPdfExterno(BuildContext context) async {
    final url = Uri.parse(_pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o PDF do Diário Oficial.'),
          ),
        );
      }
    }
  }

  void _mostrarPdf(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DiarioPdfSheet(
        diario: diario,
        loadPdf: _carregarPdf,
        onOpenExternal: () => _abrirPdfExterno(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, isLatest ? 10 : 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EDF0), width: 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10101828),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLatest)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 6.0),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A86B),
                  border: Border.all(color: const Color(0xFF00A86B)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'ÚLTIMA EDIÇÃO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          Text(
            'Nº ${diario.numeroEdicao}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202322),
              height: 1.2,
            ),
          ),
          SizedBox(height: isLatest ? 6 : 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF697370),
                height: 1.25,
              ),
              children: [
                const TextSpan(text: 'Publicado em\n'),
                TextSpan(
                  text: diario.dataPublicacao != null
                      ? DateFormat('dd/MM/yyyy').format(diario.dataPublicacao!)
                      : 'Data indisponível',
                  style: const TextStyle(
                    color: Color(0xFF202322),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isLatest ? 12 : 14),
          _DiarioActions(
            onOpen: () => _mostrarPdf(context),
            onDownload: () => _abrirPdfExterno(context),
            compact: isLatest,
          ),
        ],
      ),
    );
  }
}

class _DiarioActions extends StatelessWidget {
  const _DiarioActions({
    required this.onOpen,
    required this.onDownload,
    this.compact = false,
  });

  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final actions = Row(
      children: [
        _DiarioActionButton(
          label: 'Abrir',
          filled: true,
          compact: compact,
          onTap: onOpen,
        ),
        const SizedBox(width: 8),
        _DiarioActionButton(
          label: 'Baixar',
          filled: false,
          compact: compact,
          onTap: onDownload,
        ),
      ],
    );

    if (!compact) return actions;

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: 210, child: actions),
    );
  }
}

class _DiarioActionButton extends StatelessWidget {
  const _DiarioActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : const Color(0xFFD62828);
    return Expanded(
      child: SizedBox(
        height: compact ? 30 : 32,
        child: Material(
          color: filled ? const Color(0xFFD62828) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: filled
                ? BorderSide.none
                : const BorderSide(color: Color(0x66D62828)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: compact ? 11 : 11,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiarioPdfSheet extends StatelessWidget {
  const _DiarioPdfSheet({
    required this.diario,
    required this.loadPdf,
    required this.onOpenExternal,
  });

  final DiarioOficial diario;
  final Future<Uint8List> Function() loadPdf;
  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8F6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0x33202322),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Diário Oficial Nº ${diario.numeroEdicao}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onOpenExternal,
                    tooltip: 'Abrir fora do app',
                    icon: const Icon(
                      Icons.open_in_new_rounded,
                      color: Color(0xFF697370),
                      size: 20,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF202322),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Uint8List>(
                future: loadPdf(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD62828),
                      ),
                    );
                  }

                  if (snapshot.hasError ||
                      snapshot.data == null ||
                      snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.picture_as_pdf_outlined,
                              color: Color(0xFFD62828),
                              size: 42,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Não foi possível carregar o PDF.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF697370),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: onOpenExternal,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFD62828),
                                side: const BorderSide(
                                  color: Color(0x66D62828),
                                ),
                              ),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Abrir no navegador'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final pdfBytes = snapshot.data!;
                  return Padding(
                    padding: EdgeInsets.only(bottom: bottomInset + 10),
                    child: PdfPreview(
                      build: (_) async => pdfBytes,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      canDebug: false,
                      allowPrinting: false,
                      allowSharing: false,
                      pdfFileName: 'diario-oficial-${diario.numeroEdicao}.pdf',
                      loadingWidget: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD62828),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

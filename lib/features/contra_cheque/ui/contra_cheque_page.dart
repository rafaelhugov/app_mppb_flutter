import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/ui/main_layout.dart';
import '../providers/contra_cheque_provider.dart';
import 'widgets/competencia_selector.dart';
import 'widgets/grafico_contracheque.dart';
import 'widgets/contracheque_lancamentos.dart';
import '../../../core/ui/widgets/feature_header.dart';

class ContraChequePage extends ConsumerWidget {
  const ContraChequePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contraChequeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: FeatureHeader(
              category: '',
              title: 'Contracheque',
              description: '',
              icon: Icons.receipt_long,
            ),
          ),
          if (!state.isLoading && state.competenciaSelecionada != null)
            const SliverPersistentHeader(
              pinned: true,
              delegate: _CompetenciaHeaderDelegate(),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: MainLayout.authenticatedHorizontalPadding,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: state.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF00A86B),
                        ),
                      ),
                    )
                  : state.errorMessage != null
                  ? _buildError(state.errorMessage!, ref)
                  : _buildContent(state, context),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: MainLayout.contentBottomPadding(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ContraChequeState state, BuildContext context) {
    if (state.contrachequeAtual == null) {
      if (state.competenciaSelecionada != null) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE9EDF0)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 54,
                    color: Color(0xFF00A86B),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhum contracheque encontrado para esta competência.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF697370),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    final cheque = state.contrachequeAtual!;
    final vantagens = cheque.lancamentos.where((l) => l.tipo == 'V').toList();
    final descontos = cheque.lancamentos.where((l) => l.tipo == 'D').toList();

    return Column(
      children: [
        GraficoContracheque(
          totalVantagens: cheque.valorBruto, // ou calcular da soma
          totalDescontos: cheque.totalDescontos,
          salarioLiquido: cheque.valorLiquido,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _abrirPdf(
            context,
            cheque.linkPdf,
            'contracheque-${cheque.mes}-${cheque.ano}.pdf',
          ),
          icon: const Icon(Icons.file_download, size: 18),
          label: const Text('BAIXAR PDF'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2563EB),
            side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 22),
        if (cheque.lancamentos.isNotEmpty)
          ContrachequeLancamentos(
            vantagens: vantagens,
            descontos: descontos,
            totalVantagens: cheque.valorBruto, // Usando valor bruto como total
          ),
      ],
    );
  }

  Widget _buildError(String error, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EDF0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Color(0xFFD62828)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFFD62828),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirPdf(
    BuildContext context,
    String? linkPdf,
    String fileName,
  ) async {
    if (linkPdf == null || linkPdf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link do PDF indisponível.')),
      );
      return;
    }

    final url = Uri.parse(linkPdf);
    final pdfFuture = Dio()
        .getUri<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        )
        .then((response) => Uint8List.fromList(response.data ?? const []));

    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                      const Expanded(
                        child: Text(
                          'Contracheque',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF202322),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
                    future: pdfFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00A86B),
                          ),
                        );
                      }

                      if (snapshot.hasError ||
                          snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Não foi possível carregar o PDF.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF697370),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }

                      final pdfBytes = snapshot.data!;
                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: bottomInset + 72),
                            child: PdfPreview(
                              build: (_) async => pdfBytes,
                              canChangeOrientation: false,
                              canChangePageFormat: false,
                              canDebug: false,
                              allowPrinting: false,
                              allowSharing: false,
                              pdfFileName: fileName,
                              loadingWidget: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00A86B),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: bottomInset + 12,
                            child: SizedBox(
                              height: 42,
                              child: FilledButton(
                                onPressed: () => Printing.sharePdf(
                                  bytes: pdfBytes,
                                  filename: fileName,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A86B),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Salvar PDF'),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompetenciaHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _CompetenciaHeaderDelegate();

  @override
  double get minExtent => 62;

  @override
  double get maxExtent => 62;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MainLayout.authenticatedHorizontalPadding,
          6,
          MainLayout.authenticatedHorizontalPadding,
          4,
        ),
        child: const Align(
          alignment: Alignment.center,
          child: CompetenciaSelector(),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CompetenciaHeaderDelegate oldDelegate) => false;
}

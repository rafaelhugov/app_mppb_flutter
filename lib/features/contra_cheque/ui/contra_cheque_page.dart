import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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
          onPressed: () => _abrirPdf(context, cheque.linkPdf),
          icon: const Icon(Icons.file_download, size: 18),
          label: const Text('BAIXAR PDF'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF007A4D),
            side: const BorderSide(color: Color(0x9900A86B), width: 1.2),
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

  Future<void> _abrirPdf(BuildContext context, String? linkPdf) async {
    if (linkPdf == null || linkPdf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link do PDF indisponível.')),
      );
      return;
    }

    final url = Uri.parse(linkPdf);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o PDF.')),
        );
      }
    }
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/contra_cheque_provider.dart';
import 'widgets/competencia_selector.dart';
import 'widgets/grafico_contracheque.dart';
import 'widgets/contracheque_lancamentos.dart';

class ContraChequePage extends ConsumerWidget {
  const ContraChequePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contraChequeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(82, 56, 41, 0.20),
              Color.fromRGBO(82, 56, 41, 0),
            ],
            stops: [0.0, 0.3], // Aproximando o 240px
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverToBoxAdapter(
                child: state.isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: Color(0xFF8F2A1D)),
                        ),
                      )
                    : state.errorMessage != null
                        ? _buildError(state.errorMessage!, ref)
                        : _buildContent(state, context),
              ),
            ),
            // Padding extra no final para o scroll não ficar colado
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: Color.fromRGBO(214, 169, 47, 0.24)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(255, 221, 132, 0.14),
            offset: Offset(0, -1),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF241D19),
            Color(0xFF3A241D),
            Color(0xFF8F2A1D),
          ],
          stops: [0.0, 0.46, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 44),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color.fromRGBO(255, 222, 142, 0.44)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(36, 18, 12, 0.30),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.receipt_long, color: Color(0xFF211713), size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ÁREA FINANCEIRA',
                  style: TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Contracheque',
                  style: TextStyle(
                    color: Color(0xFFFFF8EA),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.22),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Visualize e baixe seus últimos contracheques.',
                  style: TextStyle(
                    color: Color(0xFFD8C5AA),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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
            const CompetenciaSelector(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFE3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color.fromRGBO(156, 122, 84, 0.35)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long, size: 54, color: Color(0xFF8F2A1D)),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhum contracheque encontrado para esta competência.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF73543E),
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
    final proventos = cheque.lancamentos.where((l) => l.tipo == 'V').toList();
    final descontos = cheque.lancamentos.where((l) => l.tipo == 'D').toList();

    return Column(
      children: [
        const CompetenciaSelector(),
        const SizedBox(height: 16),
        GraficoContracheque(
          totalVantagens: cheque.valorBruto, // ou calcular da soma
          totalDescontos: cheque.totalDescontos,
          salarioLiquido: cheque.valorLiquido,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _abrirPdf(context, cheque.linkPdf),
          icon: const Icon(Icons.file_download, size: 18),
          label: const Text('BAIXAR PDF'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8F2A1D),
            side: const BorderSide(color: Color.fromRGBO(143, 42, 29, 0.55), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ),
        const SizedBox(height: 22),
        if (cheque.lancamentos.isNotEmpty)
          ContrachequeLancamentos(
            proventos: proventos,
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
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(143, 42, 29, 0.20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Color(0xFF8F2A1D)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFF8F2A1D),
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

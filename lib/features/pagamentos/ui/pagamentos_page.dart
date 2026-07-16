import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/pagamentos_provider.dart';
import '../models/pagamento_model.dart';
import '../../../shared/providers/privacy_provider.dart';

class PagamentosPage extends ConsumerStatefulWidget {
  const PagamentosPage({super.key});

  @override
  ConsumerState<PagamentosPage> createState() => _PagamentosPageState();
}

class _PagamentosPageState extends ConsumerState<PagamentosPage> {
  final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  String _formatarData(String? dataStr) {
    if (dataStr == null || dataStr.isEmpty) return '';
    try {
      final partes = dataStr.split(' ')[0].split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
    } catch (_) {}
    return dataStr;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagamentosProvider);
    final isPrivacyEnabled = ref.watch(privacyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: _buildExercicioSelector(state),
            ),
          ),
          if (state.isLoadingAnos || state.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF8F2A1D)),
              ),
            )
          else if (state.errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x338F2A1D)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFF8F2A1D), size: 24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: Color(0xFF8F2A1D), fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (state.dados != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildResumoCard(state.dados!, isPrivacyEnabled),
                  const SizedBox(height: 24),
                  _buildSectionHeading(state.dados!.pagamentos.length),
                  const SizedBox(height: 12),
                  ...state.dados!.pagamentos.map((p) => _buildPagamentoCard(p, isPrivacyEnabled)),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Fonte: Sistema Pitágoras.',
                      style: TextStyle(
                        color: Color(0xFF9C8E7E),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // padding bottom
                ]),
              ),
            )
          else if (state.dados == null || state.anosDisponiveis.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x2E9C7A54)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8F2A1D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.assignment_late, color: Color(0xFFF7EFE3), size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum pagamento encontrado para\n${state.exercicioAtual}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF73543E),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0x70FFDE8E)),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Color(0x4C24120C), offset: Offset(0, 12), blurRadius: 28),
              ],
            ),
            child: const Icon(Icons.assignment, color: Color(0xFF211713), size: 30),
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
                Text(
                  'Pagamentos',
                  style: TextStyle(
                    color: const Color(0xFFFFF8EA),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    fontFamily: GoogleFonts.ebGaramond().fontFamily,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Consulte os pagamentos por exercício.',
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

  void _mostrarModalExercicio(BuildContext context, int exercicioAtual, List<int> anosDisponiveis) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7EFE3),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selecionar Competência',
                    style: TextStyle(
                      color: Color(0xFF2F2923),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE0D0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF5A4A3D)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (anosDisponiveis.isEmpty)
                const Text(
                  'Nenhum exercício disponível.',
                  style: TextStyle(color: Color(0xFF73543E), fontSize: 14),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: anosDisponiveis.map((year) {
                    final isSelected = year == exercicioAtual;
                    return InkWell(
                      onTap: () {
                        ref.read(pagamentosProvider.notifier).selecionarExercicio(year);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8F2A1D) : const Color(0xFFEBE0D0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$year',
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF8F2A1D),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExercicioSelector(PagamentosState state) {
    final bool hasAnos = state.anosDisponiveis.isNotEmpty;
    final int exercicioAtual = state.exercicioAtual;
    final int currentIndex = state.anosDisponiveis.indexOf(exercicioAtual);
    final bool canGoBack = hasAnos && currentIndex < state.anosDisponiveis.length - 1; // Array decrecente
    final bool canGoForward = hasAnos && currentIndex > 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x339C7A54)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D432B1D), offset: Offset(0, 4), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: canGoBack ? () => ref.read(pagamentosProvider.notifier).mudarExercicio(-1) : null,
            icon: const Icon(Icons.chevron_left, size: 28),
            color: const Color(0xFF8F2A1D),
            disabledColor: const Color(0x408F2A1D),
          ),
          Expanded(
            child: InkWell(
              onTap: hasAnos ? () => _mostrarModalExercicio(context, exercicioAtual, state.anosDisponiveis) : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.calendar_today, color: Color(0xFF8F2A1D), size: 12),
                        SizedBox(width: 5),
                        Text(
                          'EXERCÍCIO',
                          style: TextStyle(
                            color: Color(0xFF9C7A54),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$exercicioAtual',
                      style: const TextStyle(
                        color: Color(0xFF2F2923),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: canGoForward ? () => ref.read(pagamentosProvider.notifier).mudarExercicio(1) : null,
            icon: const Icon(Icons.chevron_right, size: 28),
            color: const Color(0xFF8F2A1D),
            disabledColor: const Color(0x408F2A1D),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCard(PagamentoResponse dados, bool isPrivacyEnabled) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E2722), Color(0xFF3A241D), Color(0xFF6B2018)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x38D6A92F)),
        boxShadow: const [
          BoxShadow(color: Color(0x382E1E16), offset: Offset(0, 16), blurRadius: 32),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RESUMO DO EXERCÍCIO',
                style: TextStyle(
                  color: Color(0xFFD8C5AA),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x2EE5B84C),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x4DE5B84C)),
                ),
                child: Text(
                  '${dados.totalPagamentos} pagamento${dados.totalPagamentos != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Color(0xFFE5B84C),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Valor Bruto Total', style: TextStyle(color: Color(0xFFCDBDA9), fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      isPrivacyEnabled ? '••••••' : formatadorMoeda.format(dados.totalBruto),
                      style: const TextStyle(color: Color(0xFFE3C474), fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Valor Líquido Total', style: TextStyle(color: Color(0xFFCDBDA9), fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      isPrivacyEnabled ? '••••••' : formatadorMoeda.format(dados.totalLiquido),
                      style: const TextStyle(color: Color(0xFF7EE8A2), fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Text(
          'Pagamentos',
          style: TextStyle(
            color: Color(0xFF2F2923),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          '$count item${count != 1 ? 's' : ''}',
          style: const TextStyle(color: Color(0xFF73543E), fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildPagamentoCard(Pagamento pag, bool isPrivacyEnabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEE2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x599C7A54)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pag.nuProcesso != null) ...[
                    Row(
                      children: const [
                        Icon(Icons.folder, color: Color(0xFFB09E8C), size: 13),
                        SizedBox(width: 6),
                        Text('PROCESSO', style: TextStyle(color: Color(0xFF8C7F70), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nº ${pag.nuProcesso}',
                      style: TextStyle(color: const Color(0xFF3B2A20), fontSize: 17, fontWeight: FontWeight.w700, fontFamily: GoogleFonts.ebGaramond().fontFamily),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (pag.documento != null) ...[
                    Row(
                      children: const [
                        Icon(Icons.description, color: Color(0xFFB09E8C), size: 13),
                        SizedBox(width: 6),
                        Text('DOCUMENTO', style: TextStyle(color: Color(0xFF8C7F70), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nº ${pag.documento}',
                      style: TextStyle(color: const Color(0xFF3B2A20), fontSize: 17, fontWeight: FontWeight.w700, fontFamily: GoogleFonts.ebGaramond().fontFamily),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (pag.dtPagamento != null)
                    Row(
                      children: [
                        const Icon(Icons.event, color: Color(0xFF9C8E7E), size: 14),
                        const SizedBox(width: 6),
                        Text('Pago em ${_formatarData(pag.dtPagamento)}', style: const TextStyle(color: Color(0xFF8C7F70), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                ],
              ),
              if (pag.dsModalidadePag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1EFE6),
                    border: Border.all(color: const Color(0x263F7D49)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: Color(0xFF3F7D49), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _capitalize(pag.dsModalidadePag!),
                        style: const TextStyle(color: Color(0xFF3F7D49), fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Color(0x599C7A54), height: 1, thickness: 1),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.attach_money, color: Color(0xFFB09E8C), size: 13),
                        SizedBox(width: 6),
                        Text('VALOR BRUTO', style: TextStyle(color: Color(0xFF8C7F70), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPrivacyEnabled ? '••••••' : formatadorMoeda.format(pag.vlBruto ?? 0),
                      style: const TextStyle(color: Color(0xFF3B2A20), fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: const Color(0x599C7A54)), // using dash or solid
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.check_circle, color: Color(0xFFB09E8C), size: 13),
                        SizedBox(width: 6),
                        Text('VALOR LÍQUIDO', style: TextStyle(color: Color(0xFF8C7F70), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPrivacyEnabled ? '••••••' : formatadorMoeda.format(pag.vlLiquido ?? 0),
                      style: const TextStyle(color: Color(0xFF3F7D49), fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Color(0x599C7A54), height: 1, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: Color(0xFF9C8E7E), size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(color: Color(0xFF4A3E35), fontSize: 12, fontWeight: FontWeight.w700),
                          children: [
                            if (pag.cdElemento != null)
                              TextSpan(
                                text: 'Elemento ${pag.cdElemento} — ',
                                style: const TextStyle(color: Color(0xFF9C8E7E), fontWeight: FontWeight.w500),
                              ),
                            TextSpan(text: pag.descricaoElemento ?? 'Pagamento'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (pag.sigla != null)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x1E8F2A1D),
                    border: Border.all(color: const Color(0x338F2A1D)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pag.sigla!,
                    style: const TextStyle(color: Color(0xFF8F2A1D), fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.toLowerCase().replaceFirst(s[0].toLowerCase(), s[0].toUpperCase());
  }
}

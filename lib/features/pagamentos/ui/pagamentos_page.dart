import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../providers/pagamentos_provider.dart';
import '../models/pagamento_model.dart';
import '../../../shared/providers/privacy_provider.dart';
import '../../../shared/widgets/privacy_toggle_button.dart';

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
      backgroundColor: const Color(0xFFF7F8F6),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MainLayout.authenticatedHorizontalPadding,
                vertical: 8.0,
              ),
              child: _buildExercicioSelector(state),
            ),
          ),
          if (state.isLoadingAnos || state.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00A86B)),
              ),
            )
          else if (state.errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: MainLayout.authenticatedHorizontalPadding,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE9EDF0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFD62828),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFD62828),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (state.dados != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: MainLayout.authenticatedHorizontalPadding,
                vertical: 8.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildResumoCard(state.dados!, isPrivacyEnabled),
                  const SizedBox(height: 16),
                  _buildSectionHeading(state.dados!.pagamentos.length),
                  const SizedBox(height: 12),
                  ...state.dados!.pagamentos.map(
                    (p) => _buildPagamentoCard(p, isPrivacyEnabled),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Fonte: Sistema Pitágoras.',
                      style: TextStyle(
                        color: Color(0xFF697370),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  SizedBox(height: MainLayout.contentBottomPadding(context)),
                ]),
              ),
            )
          else if (state.dados == null || state.anosDisponiveis.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: MainLayout.authenticatedHorizontalPadding,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE9EDF0)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD62828),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assignment_late,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum pagamento encontrado para\n${state.exercicioAtual}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF697370),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
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
    return const HeroHeaderPublico(
      label: '',
      title: 'Pagamentos',
      subtitle: '',
      icon: Icons.assignment,
    );
  }

  void _mostrarModalExercicio(
    BuildContext context,
    int exercicioAtual,
    List<int> anosDisponiveis,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F8F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selecionar Exercício',
                    style: TextStyle(
                      color: Color(0xFF202322),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE9EDF0)),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF697370),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (anosDisponiveis.isEmpty)
                const Text(
                  'Nenhum exercício disponível.',
                  style: TextStyle(color: Color(0xFF697370), fontSize: 14),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: anosDisponiveis.map((year) {
                    final isSelected = year == exercicioAtual;
                    return InkWell(
                      onTap: () {
                        ref
                            .read(pagamentosProvider.notifier)
                            .selecionarExercicio(year);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF202322)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9EDF0)),
                        ),
                        child: Text(
                          '$year',
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFF7F8F6)
                                : const Color(0xFF202322),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
    final bool canGoBack =
        hasAnos &&
        currentIndex < state.anosDisponiveis.length - 1; // Array decrecente
    final bool canGoForward = hasAnos && currentIndex > 0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 196),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF202322),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A101828),
                offset: Offset(0, 5),
                blurRadius: 14,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 3, 4, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSelectorButton(
                      icon: Icons.chevron_left_rounded,
                      enabled: canGoBack,
                      onTap: () => ref
                          .read(pagamentosProvider.notifier)
                          .mudarExercicio(-1),
                    ),
                    SizedBox(
                      width: 132,
                      child: InkWell(
                        onTap: hasAnos
                            ? () => _mostrarModalExercicio(
                                context,
                                exercicioAtual,
                                state.anosDisponiveis,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFFF4F7F4),
                                  size: 10,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'EXERCÍCIO',
                                  style: TextStyle(
                                    color: Color(0xFFDDE4DF),
                                    fontSize: 7,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.35,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$exercicioAtual',
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildSelectorButton(
                      icon: Icons.chevron_right_rounded,
                      enabled: canGoForward,
                      onTap: () => ref
                          .read(pagamentosProvider.notifier)
                          .mudarExercicio(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0x0FFFFFFF),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0x26FFFFFF)),
          ),
          child: Icon(
            icon,
            size: 17,
            color: enabled ? const Color(0xFFF7F8F6) : const Color(0x55F7F8F6),
          ),
        ),
      ),
    );
  }

  Widget _buildResumoCard(PagamentoResponse dados, bool isPrivacyEnabled) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9EDF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10101828),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESUMO DO EXERCÍCIO',
                    style: TextStyle(
                      color: Color(0xFF697370),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.45,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF00A86B),
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 6, height: 6),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '${dados.totalPagamentos} pagamento${dados.totalPagamentos != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF007A4D),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const PrivacyToggleButton(size: 36, compact: true),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildResumoMetricCard(
                  label: 'Bruto',
                  value: isPrivacyEnabled
                      ? '••••••'
                      : formatadorMoeda.format(dados.totalBruto),
                  color: const Color(0xFFD62828),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildResumoMetricCard(
                  label: 'Líquido',
                  value: isPrivacyEnabled
                      ? '••••••'
                      : formatadorMoeda.format(dados.totalLiquido),
                  color: const Color(0xFF00A86B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumoMetricCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x20343A40)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF697370),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
            color: Color(0xFF202322),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$count item${count != 1 ? 's' : ''}',
          style: const TextStyle(
            color: Color(0xFF697370),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPagamentoCard(Pagamento pag, bool isPrivacyEnabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EDF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
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
                        Icon(Icons.folder, color: Color(0xFF697370), size: 12),
                        SizedBox(width: 6),
                        Text(
                          'Processo',
                          style: TextStyle(
                            color: Color(0xFF697370),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Nº ${pag.nuProcesso}',
                      style: TextStyle(
                        color: const Color(0xFF202322),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (pag.documento != null) ...[
                    Row(
                      children: const [
                        Icon(
                          Icons.description,
                          color: Color(0xFF697370),
                          size: 12,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Documento',
                          style: TextStyle(
                            color: Color(0xFF697370),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Nº ${pag.documento}',
                      style: TextStyle(
                        color: const Color(0xFF202322),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (pag.dtPagamento != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.event,
                          color: Color(0xFF697370),
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pago em ${_formatarData(pag.dtPagamento)}',
                          style: const TextStyle(
                            color: Color(0xFF697370),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (pag.dsModalidadePag != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A86B), // Solid vivid green
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _capitalize(pag.dsModalidadePag!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Color(0xFFE9EDF0), height: 1, thickness: 1),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.attach_money,
                          color: Color(0xFFD62828),
                          size: 13,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Valor bruto',
                          style: TextStyle(
                            color: Color(0xFF697370),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPrivacyEnabled
                          ? '••••••'
                          : formatadorMoeda.format(pag.vlBruto ?? 0),
                      style: const TextStyle(
                        color: Color(0xFFD62828),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: const Color(0xFFE9EDF0),
              ), // using dash or solid
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF00A86B),
                          size: 13,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Valor líquido',
                          style: TextStyle(
                            color: Color(0xFF697370),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPrivacyEnabled
                          ? '••••••'
                          : formatadorMoeda.format(pag.vlLiquido ?? 0),
                      style: const TextStyle(
                        color: Color(0xFF00A86B),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Color(0xFFE9EDF0), height: 1, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF697370),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFF202322),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            if (pag.cdElemento != null)
                              TextSpan(
                                text: 'Elemento ${pag.cdElemento} — ',
                                style: const TextStyle(
                                  color: Color(0xFF697370),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            TextSpan(
                              text: pag.descricaoElemento ?? 'Pagamento',
                            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD62828), // Solid vivid red
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pag.sigla!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/ui/responsive_layout.dart';
import '../../../../shared/providers/privacy_provider.dart';
import '../../../../shared/widgets/privacy_blur_text.dart';
import '../../models/contra_cheque.dart';

class ContrachequeLancamentos extends StatelessWidget {
  final List<LancamentoContracheque> vantagens;
  final List<LancamentoContracheque> descontos;
  final double totalVantagens;

  const ContrachequeLancamentos({
    super.key,
    required this.vantagens,
    required this.descontos,
    required this.totalVantagens,
  });

  @override
  Widget build(BuildContext context) {
    final int totalLancs = vantagens.length + descontos.length;
    final responsive = MppbResponsive.of(context);
    final sideBySide =
        responsive.usesWideLayout &&
        vantagens.isNotEmpty &&
        descontos.isNotEmpty;

    final vantagensGroup = vantagens.isNotEmpty
        ? _LancamentoGroup(
            titulo: 'Vantagens',
            colorBgHeader: const Color(0xFF00A86B),
            colorBorderHeader: const Color(0xFF00A86B),
            lancamentos: vantagens,
            totalVantagens: totalVantagens,
          )
        : null;

    final descontosGroup = descontos.isNotEmpty
        ? _LancamentoGroup(
            titulo: 'Descontos',
            colorBgHeader: const Color(0xFFD62828),
            colorBorderHeader: const Color(0xFFD62828),
            lancamentos: descontos,
            totalVantagens: totalVantagens,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lançamentos',
              style: TextStyle(
                color: Color(0xFF202322),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            Text(
              '$totalLancs itens',
              style: const TextStyle(
                color: Color(0xFF697370),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (sideBySide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: vantagensGroup!),
              const SizedBox(width: 14),
              Expanded(child: descontosGroup!),
            ],
          )
        else ...[
          ?vantagensGroup,
          if (descontosGroup != null) ...[
            const SizedBox(height: 22),
            descontosGroup,
          ],
        ],
      ],
    );
  }
}

class _LancamentoGroup extends StatelessWidget {
  final String titulo;
  final Color colorBgHeader;
  final Color colorBorderHeader;
  final List<LancamentoContracheque> lancamentos;
  final double totalVantagens;

  const _LancamentoGroup({
    required this.titulo,
    required this.colorBgHeader,
    required this.colorBorderHeader,
    required this.lancamentos,
    required this.totalVantagens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x26343A40)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorBgHeader,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(21),
              ),
              border: Border(bottom: BorderSide(color: colorBorderHeader)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${lancamentos.length} lançamento${lancamentos.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              children: lancamentos.asMap().entries.map((entry) {
                final idx = entry.key;
                final lanc = entry.value;
                return _LancamentoItem(
                  lancamento: lanc,
                  totalVantagens: totalVantagens,
                  showTopBorder: idx > 0,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LancamentoItem extends ConsumerWidget {
  final LancamentoContracheque lancamento;
  final double totalVantagens;
  final bool showTopBorder;

  const _LancamentoItem({
    required this.lancamento,
    required this.totalVantagens,
    required this.showTopBorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyEnabled = ref.watch(privacyProvider);
    final isVantagem = lancamento.tipo == 'V';
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final formattedValue = currencyFormatter
        .format(lancamento.valor)
        .replaceAll('\u00A0', ' ');
    final displayedValue = isVantagem ? formattedValue : '- $formattedValue';

    double percent = 0;
    if (totalVantagens > 0) {
      percent = (lancamento.valor / totalVantagens) * 100;
    }
    final String percentStr = NumberFormat('0.0', 'pt_BR').format(percent);

    final Color colorTrend = isVantagem
        ? const Color(0xFF00A86B)
        : const Color(0xFFD62828);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showTopBorder
            ? Border(top: BorderSide(color: const Color(0x20343A40)))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _normalizarDescricao(lancamento.descricao),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Código ${lancamento.codigo}',
                  style: const TextStyle(
                    color: Color(0xFF697370),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PrivacyBlurText(
                text: displayedValue,
                enabled: isPrivacyEnabled,
                style: TextStyle(
                  color: colorTrend,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrivacyBlurText(
                    text: '$percentStr% do bruto',
                    enabled: isPrivacyEnabled,
                    style: TextStyle(
                      color: colorTrend,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _normalizarDescricao(String descricao) {
  final texto = descricao.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (texto.isEmpty) return texto;

  const nomesPadronizados = <String, String>{
    'AUXILIO ALIMENTACAO': 'Auxílio-alimentação',
    'AUXILIO-ALIMENTACAO': 'Auxílio-alimentação',
    'AUXILIO SAUDE': 'Auxílio-saúde',
    'AUXILIO-SAUDE': 'Auxílio-saúde',
    'CONSIGNACAO': 'Consignação',
    'IMPOSTO DE RENDA': 'Imposto de renda',
    'PENSAO ALIMENTICIA': 'Pensão alimentícia',
    'PLANO DE SAUDE': 'Plano de saúde',
    'PREVIDENCIA': 'Previdência',
    'SUBSIDIO': 'Subsídio',
    'VENCIMENTO': 'Vencimento',
  };

  return nomesPadronizados[texto.toUpperCase()] ?? texto;
}

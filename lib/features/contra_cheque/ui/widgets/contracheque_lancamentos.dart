import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/providers/privacy_provider.dart';
import '../../models/contra_cheque.dart';

class ContrachequeLancamentos extends StatelessWidget {
  final List<LancamentoContracheque> proventos;
  final List<LancamentoContracheque> descontos;
  final double totalVantagens;

  const ContrachequeLancamentos({
    super.key,
    required this.proventos,
    required this.descontos,
    required this.totalVantagens,
  });

  @override
  Widget build(BuildContext context) {
    final int totalLancs = proventos.length + descontos.length;

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
                color: Color(0xFF2F2923),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            Text(
              '$totalLancs itens',
              style: const TextStyle(
                color: Color(0xFF73543E),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (proventos.isNotEmpty)
          _LancamentoGroup(
            titulo: 'Proventos',
            icon: Icons.trending_up,
            colorTitle: const Color(0xFF2F7A43),
            colorBgHeader: const Color(0xFF3F7A4A).withOpacity(0.08),
            colorBorderHeader: const Color(0xFF3F7A4A).withOpacity(0.20),
            colorIconBg: const Color(0xFF3F7A4A).withOpacity(0.16),
            lancamentos: proventos,
            totalVantagens: totalVantagens,
          ),
        if (descontos.isNotEmpty) ...[
          const SizedBox(height: 22),
          _LancamentoGroup(
            titulo: 'Descontos',
            icon: Icons.trending_down,
            colorTitle: const Color(0xFFC42E45),
            colorBgHeader: const Color(0xFFC42E45).withOpacity(0.07),
            colorBorderHeader: const Color(0xFFC42E45).withOpacity(0.18),
            colorIconBg: const Color(0xFFC42E45).withOpacity(0.14),
            lancamentos: descontos,
            totalVantagens: totalVantagens,
          ),
        ],
      ],
    );
  }
}

class _LancamentoGroup extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Color colorTitle;
  final Color colorBgHeader;
  final Color colorBorderHeader;
  final Color colorIconBg;
  final List<LancamentoContracheque> lancamentos;
  final double totalVantagens;

  const _LancamentoGroup({
    required this.titulo,
    required this.icon,
    required this.colorTitle,
    required this.colorBgHeader,
    required this.colorBorderHeader,
    required this.colorIconBg,
    required this.lancamentos,
    required this.totalVantagens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF9C7A54).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF432B1D).withOpacity(0.10),
            blurRadius: 26,
            offset: const Offset(0, 12),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(bottom: BorderSide(color: colorBorderHeader)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: colorTitle,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${lancamentos.length} lançamento${lancamentos.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Color(0xFF806F5E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorIconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: colorTitle, size: 20),
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
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formattedValue = currencyFormatter.format(lancamento.valor);
    final displayedValue = isPrivacyEnabled ? '••••••' : (isVantagem ? formattedValue : '- $formattedValue');
    
    double percent = 0;
    if (totalVantagens > 0) {
      percent = (lancamento.valor / totalVantagens) * 100;
    }
    final String percentStr = percent.toStringAsFixed(1);
    
    final Color colorTrend = isVantagem ? const Color(0xFF1F7A3E) : const Color(0xFFC42E45);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showTopBorder
            ? Border(top: BorderSide(color: const Color(0xFF9C7A54).withOpacity(0.22)))
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
                  lancamento.descricao,
                  style: const TextStyle(
                    color: Color(0xFF2F2923),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Código ${lancamento.codigo}',
                  style: const TextStyle(
                    color: Color(0xFF806F5E),
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
              Text(
                displayedValue,
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
                  Icon(
                    isVantagem ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 10,
                    color: colorTrend,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    isPrivacyEnabled ? '•••' : '$percentStr%',
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

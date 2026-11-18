import 'package:flutter/material.dart';

import '../../models/concessao_afastamento.dart';
import '../../models/tipo_concessao.dart';
import 'concessao_afastamento_theme.dart';

class ResumoCategoriaItem {
  final TipoConcessao tipo;
  final int totalSaldo;
  final int totalConcedido;
  final int quantidadeConcessoes;

  const ResumoCategoriaItem({
    required this.tipo,
    required this.totalSaldo,
    required this.totalConcedido,
    required this.quantidadeConcessoes,
  });

  int get diasUsufruidos =>
      (totalConcedido - totalSaldo).clamp(0, totalConcedido);
}

class _AcumuladorCategoria {
  int totalSaldo = 0;
  int totalConcedido = 0;
  int quantidadeConcessoes = 0;
}

/// Mini-Dashboard executivo exibido no topo da listagem de concessões vigentes.
/// Apresenta o saldo consolidado total e por categoria com opção de filtro interativo.
class ConcessoesResumoDashboard extends StatelessWidget {
  final List<ConcessaoAfastamento> concessoes;
  final TipoConcessao? filtroTipoSelecionado;
  final ValueChanged<TipoConcessao?>? onTipoSelecionado;

  const ConcessoesResumoDashboard({
    super.key,
    required this.concessoes,
    this.filtroTipoSelecionado,
    this.onTipoSelecionado,
  });

  int get _saldoTotalGeral =>
      concessoes.fold<int>(0, (total, c) => total + c.saldoRestante);

  int get _concedidoTotalGeral =>
      concessoes.fold<int>(0, (total, c) => total + c.diasConcedidos);

  int get _usufruidoTotalGeral =>
      (_concedidoTotalGeral - _saldoTotalGeral).clamp(0, _concedidoTotalGeral);

  double get _taxaDisponivel => _concedidoTotalGeral > 0
      ? (_saldoTotalGeral / _concedidoTotalGeral).clamp(0.0, 1.0)
      : 0.0;

  List<ResumoCategoriaItem> _calcularResumosPorCategoria() {
    final map = <TipoConcessao, _AcumuladorCategoria>{};

    for (final c in concessoes) {
      final acc = map.putIfAbsent(c.tipo, () => _AcumuladorCategoria());
      acc.totalSaldo += c.saldoRestante;
      acc.totalConcedido += c.diasConcedidos;
      acc.quantidadeConcessoes += 1;
    }

    final items = map.entries.map((entry) {
      return ResumoCategoriaItem(
        tipo: entry.key,
        totalSaldo: entry.value.totalSaldo,
        totalConcedido: entry.value.totalConcedido,
        quantidadeConcessoes: entry.value.quantidadeConcessoes,
      );
    }).toList();

    // Ordena colocando categorias com saldo maior primeiro
    items.sort((a, b) => b.totalSaldo.compareTo(a.totalSaldo));
    return items;
  }

  IconData _obterIconeTipo(TipoConcessao tipo) {
    switch (tipo) {
      case TipoConcessao.ferias:
        return Icons.beach_access_rounded;
      case TipoConcessao.licencaPremio:
        return Icons.workspace_premium_rounded;
      case TipoConcessao.licencaEleitoral:
        return Icons.how_to_vote_rounded;
      case TipoConcessao.plantao:
        return Icons.access_time_filled_rounded;
      case TipoConcessao.diarias:
        return Icons.receipt_long_rounded;
      case TipoConcessao.desconhecido:
        return Icons.event_available_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (concessoes.isEmpty) {
      return const SizedBox.shrink();
    }

    final categorias = _calcularResumosPorCategoria();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Faixa Superior de Cabeçalho
            _buildHeaderStrip(),

            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

            // 2. Corpo do Dashboard
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de Progresso Global
                  _buildProgressoGeral(),

                  const SizedBox(height: 14),

                  // Lista / Grid de Saldos por Categoria
                  _buildCategoriasResumo(categorias),

                  // Feedback de filtro ativo (se houver)
                  if (filtroTipoSelecionado != null) ...[
                    const SizedBox(height: 10),
                    _buildFiltroAtivoBanner(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SUB-WIDGETS VISUAIS
  // ===========================================================================

  Widget _buildHeaderStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: const Icon(
              Icons.pie_chart_outline_rounded,
              size: 18,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo de Concessões',
                  style: TextStyle(
                    fontFamily: 'Rawline',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${concessoes.length} ${concessoes.length == 1 ? "concessão ativa" : "concessões ativas"} no total',
                  style: const TextStyle(
                    fontFamily: 'Rawline',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          // Badge do Saldo Total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 13,
                  color: Color(0xFF15803D),
                ),
                const SizedBox(width: 4),
                Text(
                  '$_saldoTotalGeral dias livres',
                  style: const TextStyle(
                    fontFamily: 'Rawline',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressoGeral() {
    final pctDisponivel = (_taxaDisponivel * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Disponível: $_saldoTotalGeral dias ($pctDisponivel%)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Rawline',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF94A3B8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Usufruído: $_usufruidoTotalGeral dias',
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Rawline',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: _taxaDisponivel,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF16A34A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriasResumo(List<ResumoCategoriaItem> categorias) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final itemWidth = isWide
            ? (constraints.maxWidth - 8) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categorias.map((item) {
            final isSelecionado = filtroTipoSelecionado == item.tipo;
            final cor = item.tipo.color;

            return SizedBox(
              width: itemWidth,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTipoSelecionado != null
                      ? () {
                          // Se já estiver selecionado, remove o filtro; senão, aplica
                          if (isSelecionado) {
                            onTipoSelecionado!(null);
                          } else {
                            onTipoSelecionado!(item.tipo);
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelecionado
                          ? cor.withValues(alpha: 0.08)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelecionado ? cor : const Color(0xFFE2E8F0),
                        width: isSelecionado ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Ícone da Categoria
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: cor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _obterIconeTipo(item.tipo),
                            size: 16,
                            color: cor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Textos (Nome e Quantidade)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.tipo.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Rawline',
                                  fontSize: 12,
                                  fontWeight: isSelecionado
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                '${item.quantidadeConcessoes} ${item.quantidadeConcessoes == 1 ? "período" : "períodos"}',
                                style: const TextStyle(
                                  fontFamily: 'Rawline',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Saldo da Categoria em Destaque
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.totalSaldo}d',
                              style: TextStyle(
                                fontFamily: 'Rawline',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: item.totalSaldo > 0
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              item.totalSaldo == 1 ? 'restante' : 'restantes',
                              style: const TextStyle(
                                fontFamily: 'Rawline',
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFiltroAtivoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_outlined,
            size: 14,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Filtrando por: ${filtroTipoSelecionado!.label}',
              style: const TextStyle(
                fontFamily: 'Rawline',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E40AF),
              ),
            ),
          ),
          InkWell(
            onTap: () => onTipoSelecionado?.call(null),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Text(
                    'Ver todas',
                    style: TextStyle(
                      fontFamily: 'Rawline',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.close_rounded, size: 12, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

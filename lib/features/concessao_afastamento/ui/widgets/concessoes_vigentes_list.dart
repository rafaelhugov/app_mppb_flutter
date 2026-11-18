import 'package:flutter/material.dart';

import '../../../../../core/ui/main_layout.dart';
import '../../../../../core/ui/responsive_layout.dart';
import '../../models/concessao_afastamento.dart';
import '../../models/operacao_solicitacao_concessao.dart';
import '../../models/solicitacao_concessao.dart';
import '../../models/sugestao_data_final.dart';
import '../../models/tipo_concessao.dart';
import 'concessao_afastamento_card.dart';
import 'concessao_afastamento_theme.dart';
import 'concessoes_resumo_dashboard.dart';

class ConcessoesVigentesList extends StatefulWidget {
  final List<ConcessaoAfastamento> concessoes;
  final bool isMembro;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final Future<void> Function(
    ConcessaoAfastamento concessao,
    DateTime dataInicial,
    int numeroDias,
  )?
  onSolicitar;
  final Future<List<SugestaoDataFinal>> Function(
    ConcessaoAfastamento concessao,
    DateTime dataInicial,
  )?
  onBuscarSugestoes;
  final Future<List<OperacaoSolicitacaoConcessao>> Function(
    SolicitacaoConcessao solicitacao,
  )?
  onBuscarOperacoes;
  final Future<void> Function(
    SolicitacaoConcessao solicitacao,
    OperacaoSolicitacaoConcessao operacao, {
    DateTime? data,
    DateTime? dataFim,
  })?
  onExecutarOperacao;

  const ConcessoesVigentesList({
    super.key,
    required this.concessoes,
    required this.isMembro,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
    required this.onRefresh,
    this.onSolicitar,
    this.onBuscarSugestoes,
    this.onBuscarOperacoes,
    this.onExecutarOperacao,
  });

  @override
  State<ConcessoesVigentesList> createState() => _ConcessoesVigentesListState();
}

class _ConcessoesVigentesListState extends State<ConcessoesVigentesList> {
  TipoConcessao? _filtroTipo;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.concessoes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null && widget.concessoes.isEmpty) {
      return _ErrorState(
        message: widget.errorMessage!,
        onRetry: widget.onRetry,
      );
    }

    final responsive = MppbResponsive.of(context);
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final spacing = responsive.isTablet ? 14.0 : 10.0;

    final concessoesFiltradas = _filtroTipo == null
        ? widget.concessoes
        : widget.concessoes.where((c) => c.tipo == _filtroTipo).toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        primary: false,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          16,
          horizontalPadding,
          MainLayout.contentBottomPadding(context),
        ),
        children: [
          if (widget.errorMessage != null)
            _InlineError(
              message: widget.errorMessage!,
              onRetry: widget.onRetry,
            ),
          if (widget.concessoes.isEmpty)
            const _EmptyState()
          else
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MainLayout.contentMaxWidth(context),
                ),
                child: Column(
                  children: [
                    // Mini-Dashboard de Resumo e Filtro de Saldos por Categoria
                    ConcessoesResumoDashboard(
                      concessoes: widget.concessoes,
                      filtroTipoSelecionado: _filtroTipo,
                      onTipoSelecionado: (tipo) {
                        setState(() {
                          _filtroTipo = tipo;
                        });
                      },
                    ),

                    if (concessoesFiltradas.isEmpty && _filtroTipo != null)
                      _FiltroVazioState(
                        tipo: _filtroTipo!,
                        onLimparFiltro: () {
                          setState(() {
                            _filtroTipo = null;
                          });
                        },
                      )
                    else if (responsive.usesWideLayout)
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: concessoesFiltradas.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                              mainAxisExtent: 292,
                            ),
                        itemBuilder: (context, index) =>
                            ConcessaoAfastamentoCard(
                              concessao: concessoesFiltradas[index],
                              isMembro: widget.isMembro,
                              onSolicitar: widget.onSolicitar,
                              onBuscarSugestoes: widget.onBuscarSugestoes,
                              onBuscarOperacoes: widget.onBuscarOperacoes,
                              onExecutarOperacao: widget.onExecutarOperacao,
                            ),
                      )
                    else
                      Column(
                        children: concessoesFiltradas
                            .map(
                              (concessao) => ConcessaoAfastamentoCard(
                                concessao: concessao,
                                isMembro: widget.isMembro,
                                onSolicitar: widget.onSolicitar,
                                onBuscarSugestoes: widget.onBuscarSugestoes,
                                onBuscarOperacoes: widget.onBuscarOperacoes,
                                onExecutarOperacao: widget.onExecutarOperacao,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FiltroVazioState extends StatelessWidget {
  final TipoConcessao tipo;
  final VoidCallback onLimparFiltro;

  const _FiltroVazioState({
    required this.tipo,
    required this.onLimparFiltro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.filter_list_off_rounded,
            size: 36,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhuma concessão encontrada para ${tipo.label}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Rawline',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onLimparFiltro,
            icon: const Icon(Icons.clear_all_rounded, size: 16),
            label: const Text('Limpar filtro'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 42,
              color: ConcessaoAfastamentoColors.brand,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: ConcessaoAfastamentoColors.muted,
          ),
          SizedBox(height: 10),
          Text(
            'Nenhuma concessão vigente encontrada.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ConcessaoAfastamentoColors.muted),
          ),
        ],
      ),
    );
  }
}

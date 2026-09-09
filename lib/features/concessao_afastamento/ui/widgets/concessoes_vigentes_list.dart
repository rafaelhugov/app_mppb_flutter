import 'package:flutter/material.dart';

import '../../../../../core/ui/main_layout.dart';
import '../../../../../core/ui/responsive_layout.dart';
import '../../models/concessao_afastamento.dart';
import '../../models/operacao_solicitacao_concessao.dart';
import '../../models/solicitacao_concessao.dart';
import '../../models/sugestao_data_final.dart';
import 'concessao_afastamento_card.dart';
import 'concessao_afastamento_theme.dart';

class ConcessoesVigentesList extends StatelessWidget {
  final List<ConcessaoAfastamento> concessoes;
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
  Widget build(BuildContext context) {
    if (isLoading && concessoes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && concessoes.isEmpty) {
      return _ErrorState(message: errorMessage!, onRetry: onRetry);
    }

    final responsive = MppbResponsive.of(context);
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final spacing = responsive.isTablet ? 14.0 : 10.0;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        primary: false,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          16,
          horizontalPadding,
          MainLayout.contentBottomPadding(context),
        ),
        children: [
          if (errorMessage != null)
            _InlineError(message: errorMessage!, onRetry: onRetry),
          if (concessoes.isEmpty)
            const _EmptyState()
          else
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MainLayout.contentMaxWidth(context),
                ),
                child: responsive.usesWideLayout
                    ? GridView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: concessoes.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          mainAxisExtent: 292,
                        ),
                        itemBuilder: (context, index) =>
                            ConcessaoAfastamentoCard(
                              concessao: concessoes[index],
                              onSolicitar: onSolicitar,
                              onBuscarSugestoes: onBuscarSugestoes,
                              onBuscarOperacoes: onBuscarOperacoes,
                              onExecutarOperacao: onExecutarOperacao,
                            ),
                      )
                    : Column(
                        children: concessoes
                            .map(
                              (concessao) => ConcessaoAfastamentoCard(
                                concessao: concessao,
                                onSolicitar: onSolicitar,
                                onBuscarSugestoes: onBuscarSugestoes,
                                onBuscarOperacoes: onBuscarOperacoes,
                                onExecutarOperacao: onExecutarOperacao,
                              ),
                            )
                            .toList(),
                      ),
              ),
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

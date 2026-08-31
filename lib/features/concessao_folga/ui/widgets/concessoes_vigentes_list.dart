import 'package:flutter/material.dart';

import '../../../../../core/ui/main_layout.dart';
import '../../models/concessao_folga.dart';
import '../../models/operacao_solicitacao_concessao.dart';
import '../../models/solicitacao_concessao.dart';
import 'concessao_folga_card.dart';
import 'concessao_folga_theme.dart';

class ConcessoesVigentesList extends StatelessWidget {
  final List<ConcessaoFolga> concessoes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final Future<void> Function(
    ConcessaoFolga concessao,
    DateTime dataInicial,
    int numeroDias,
  )?
  onSolicitar;
  final Future<List<String>> Function(
    ConcessaoFolga concessao,
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

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MainLayout.contentBottomPadding(context),
        ),
        children: [
          if (errorMessage != null)
            _InlineError(message: errorMessage!, onRetry: onRetry),
          if (concessoes.isEmpty)
            const _EmptyState()
          else
            ...concessoes.map(
              (concessao) => ConcessaoFolgaCard(
                concessao: concessao,
                onSolicitar: onSolicitar,
                onBuscarSugestoes: onBuscarSugestoes,
                onBuscarOperacoes: onBuscarOperacoes,
                onExecutarOperacao: onExecutarOperacao,
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
              color: ConcessaoFolgaColors.brand,
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
            color: ConcessaoFolgaColors.muted,
          ),
          SizedBox(height: 10),
          Text(
            'Nenhuma concessão vigente encontrada.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ConcessaoFolgaColors.muted),
          ),
        ],
      ),
    );
  }
}

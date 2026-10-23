import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/app_feedback.dart';
import '../../models/concessao_afastamento.dart';
import '../../models/operacao_solicitacao_concessao.dart';
import '../../models/solicitacao_concessao.dart';
import '../../models/status_solicitacao_concessao.dart';
import '../../models/tipo_solicitacao_concessao.dart';
import 'concessao_afastamento_theme.dart';

class ConcessaoAfastamentoDetailsSheet extends StatelessWidget {
  final ConcessaoAfastamento concessao;
  final bool isMembro;
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

  const ConcessaoAfastamentoDetailsSheet({
    super.key,
    required this.concessao,
    required this.isMembro,
    this.onBuscarOperacoes,
    this.onExecutarOperacao,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final gozos = concessao.solicitacoes.where((item) => item.isGozo).toList();
    final movimentacoes = concessao.solicitacoes
        .where((item) => item.isMovimentacao)
        .toList();
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      decoration: const BoxDecoration(
        color: ConcessaoAfastamentoColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DEDA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  concessao.titulo,
                  style: const TextStyle(
                    color: ConcessaoAfastamentoColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE9EDF0)),
                  ),
                  child: Column(
                    children: [
                      _DetailLine(
                        label: 'Dias concedidos',
                        value: '${concessao.diasConcedidos}',
                      ),
                      _DetailLine(
                        label: 'Saldo restante',
                        value: '${concessao.saldoRestante} dias',
                      ),
                      if (concessao.inicioPeriodoAquisitivo != null &&
                          concessao.finalPeriodoAquisitivo != null)
                        _DetailLine(
                          label: 'Período aquisitivo',
                          value:
                              '${dateFormat.format(concessao.inicioPeriodoAquisitivo!)} a ${dateFormat.format(concessao.finalPeriodoAquisitivo!)}',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SolicitacoesSection(
                  title: 'Gozos programados',
                  emptyMessage: 'Nenhum período de gozo programado',
                  solicitacoes: gozos,
                  isMembro: isMembro,
                  dateFormat: dateFormat,
                  onBuscarOperacoes: onBuscarOperacoes,
                  onExecutarOperacao: onExecutarOperacao,
                ),
                const SizedBox(height: 16),
                _SolicitacoesSection(
                  title: 'Movimentações e pendências',
                  emptyMessage: 'Nenhuma movimentação registrada',
                  solicitacoes: movimentacoes,
                  isMembro: isMembro,
                  dateFormat: dateFormat,
                  onBuscarOperacoes: onBuscarOperacoes,
                  onExecutarOperacao: onExecutarOperacao,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SolicitacoesSection extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final List<SolicitacaoConcessao> solicitacoes;
  final bool isMembro;
  final DateFormat dateFormat;
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

  const _SolicitacoesSection({
    required this.title,
    required this.emptyMessage,
    required this.solicitacoes,
    required this.isMembro,
    required this.dateFormat,
    required this.onBuscarOperacoes,
    required this.onExecutarOperacao,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ConcessaoAfastamentoColors.ink,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (solicitacoes.isEmpty)
          _EmptySolicitacoesBox(message: emptyMessage)
        else
          ...solicitacoes.map(
            (solicitacao) => _SolicitacaoTile(
              solicitacao: solicitacao,
              isMembro: isMembro,
              dateFormat: dateFormat,
              onBuscarOperacoes: onBuscarOperacoes,
              onExecutarOperacao: onExecutarOperacao,
            ),
          ),
      ],
    );
  }
}

class _EmptySolicitacoesBox extends StatelessWidget {
  final String message;

  const _EmptySolicitacoesBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EDF0)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: ConcessaoAfastamentoColors.muted),
      ),
    );
  }
}

class _SolicitacaoTile extends StatelessWidget {
  final SolicitacaoConcessao solicitacao;
  final bool isMembro;
  final DateFormat dateFormat;
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

  const _SolicitacaoTile({
    required this.solicitacao,
    required this.isMembro,
    required this.dateFormat,
    required this.onBuscarOperacoes,
    required this.onExecutarOperacao,
  });

  @override
  Widget build(BuildContext context) {
    final dias = solicitacao.diasCalculados ?? solicitacao.diasInformados;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 58,
            decoration: BoxDecoration(
              color: solicitacao.status.color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  solicitacao.tipo.label,
                  style: const TextStyle(
                    color: ConcessaoAfastamentoColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _periodDescription(solicitacao, dateFormat),
                  style: const TextStyle(
                    color: ConcessaoAfastamentoColors.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusPill(
                      label: solicitacao.status.label,
                      color: solicitacao.status.color,
                      foreground: solicitacao.status.foreground,
                    ),
                    if (dias != null && dias > 0)
                      Text(
                        solicitacao.possuiDiasParaRetorno
                            ? '$dias dia(s) solicitados para estorno do saldo disponível'
                            : '$dias dia(s)',
                        style: const TextStyle(
                          color: ConcessaoAfastamentoColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _statusContext(solicitacao, isMembro),
                  style: const TextStyle(
                    color: ConcessaoAfastamentoColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _SolicitacaoActions(
                  solicitacao: solicitacao,
                  onBuscarOperacoes: onBuscarOperacoes,
                  onExecutarOperacao: onExecutarOperacao,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _periodDescription(
    SolicitacaoConcessao solicitacao,
    DateFormat dateFormat,
  ) {
    final inicio = solicitacao.inicio;
    final fim = solicitacao.fim;
    if (inicio != null && fim != null) {
      return '${dateFormat.format(inicio)} a ${dateFormat.format(fim)}';
    }

    switch (solicitacao.tipo) {
      case TipoSolicitacaoConcessao.interrupcao:
        return fim == null
            ? 'Interrupção registrada'
            : 'Interrupção a partir de ${dateFormat.format(fim)}';
      case TipoSolicitacaoConcessao.suspensaoTotal:
        return 'Suspensão integral do gozo';
      case TipoSolicitacaoConcessao.suspensaoParcial:
        return 'Suspensão parcial do gozo';
      case TipoSolicitacaoConcessao.adiamentoSineDie:
        return 'Adiamento sem nova data definida';
      case TipoSolicitacaoConcessao.indenizacao:
      case TipoSolicitacaoConcessao.conversao:
        return 'Movimentação registrada';
      case TipoSolicitacaoConcessao.gozo:
      case TipoSolicitacaoConcessao.gozoColetivo:
      case TipoSolicitacaoConcessao.antecipacao:
      case TipoSolicitacaoConcessao.adiamento:
      case TipoSolicitacaoConcessao.desconhecido:
        return 'Período não informado';
    }
  }

  String _statusContext(SolicitacaoConcessao solicitacao, bool isMembro) {
    switch (solicitacao.status) {
      case StatusSolicitacaoConcessao.pendente:
        return isMembro
            ? 'Aguardando análise do DRH'
            : 'Aguardando confirmação do chefe imediato';
      case StatusSolicitacaoConcessao.confirmado:
        return isMembro
            ? 'Aguardando análise do 2º Subprocurador-Geral'
            : 'Aguardando análise pelo fluxo de recursos humanos';
      case StatusSolicitacaoConcessao.deferido:
        return isMembro
            ? 'Deferida pelo 2º Subprocurador-Geral'
            : 'Solicitação deferida';
      case StatusSolicitacaoConcessao.homologado:
      case StatusSolicitacaoConcessao.migrado:
        return 'Analisada pelo DHR/Secretário-Geral';
      case StatusSolicitacaoConcessao.cancelado:
        return 'Desistência do solicitante';
      case StatusSolicitacaoConcessao.negado:
      case StatusSolicitacaoConcessao.indeferido:
        return isMembro
            ? 'Indeferida pelo 2º Subprocurador-Geral'
            : 'Solicitação indeferida';
      case StatusSolicitacaoConcessao.desconhecido:
        return 'Situação não informada';
    }
  }
}

class _SolicitacaoActions extends StatefulWidget {
  final SolicitacaoConcessao solicitacao;
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

  const _SolicitacaoActions({
    required this.solicitacao,
    required this.onBuscarOperacoes,
    required this.onExecutarOperacao,
  });

  @override
  State<_SolicitacaoActions> createState() => _SolicitacaoActionsState();
}

class _SolicitacaoActionsState extends State<_SolicitacaoActions> {
  late Future<List<OperacaoSolicitacaoConcessao>> _future;
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OperacaoSolicitacaoConcessao>> _load() async {
    final fetch = widget.onBuscarOperacoes;
    if (fetch == null) return const [];
    return fetch(widget.solicitacao);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onExecutarOperacao == null) return const SizedBox.shrink();

    return FutureBuilder<List<OperacaoSolicitacaoConcessao>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Não foi possível carregar ações.',
              style: TextStyle(
                color: ConcessaoAfastamentoColors.muted,
                fontSize: 12,
              ),
            ),
          );
        }

        final operacoes = snapshot.data ?? const [];
        if (operacoes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Nenhuma ação disponível.',
              style: TextStyle(
                color: ConcessaoAfastamentoColors.muted,
                fontSize: 12,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildOperationChips(operacoes),
              ),
              if (_isExecuting) ...[
                const SizedBox(height: 10),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Processando alteração...',
                      style: TextStyle(
                        color: ConcessaoAfastamentoColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildOperationChips(
    List<OperacaoSolicitacaoConcessao> operacoes,
  ) {
    final hasAdiar = operacoes.contains(OperacaoSolicitacaoConcessao.adiar);
    final hasAntecipar = operacoes.contains(
      OperacaoSolicitacaoConcessao.antecipar,
    );
    final chips = <Widget>[];
    var addedAlterarData = false;

    for (final operacao in operacoes) {
      if (operacao == OperacaoSolicitacaoConcessao.adiar ||
          operacao == OperacaoSolicitacaoConcessao.antecipar) {
        if (!addedAlterarData && (hasAdiar || hasAntecipar)) {
          chips.add(
            _OperationChip(
              label: 'Alterar data',
              enabled: !_isExecuting,
              onTap: () => _handleAlterarData(hasAdiar, hasAntecipar),
            ),
          );
          addedAlterarData = true;
        }
        continue;
      }

      chips.add(
        _OperationChip(
          label: operacao.label,
          destructive:
              operacao == OperacaoSolicitacaoConcessao.cancelar ||
              operacao == OperacaoSolicitacaoConcessao.suspenderIntegralmente,
          enabled: !_isExecuting,
          onTap: () => _handleOperation(operacao),
        ),
      );
    }
    return chips;
  }

  Future<void> _handleAlterarData(bool podeAdiar, bool podeAntecipar) async {
    final inicio = widget.solicitacao.inicio;
    if (inicio == null) {
      AppFeedback.showWarning(
        context,
        'Esta solicitação não possui data inicial para alterar.',
      );
      return;
    }

    final data = await _showDateOperationSheet(
      title: 'Alterar data',
      dateLabel: 'Nova data inicial',
      initialDate: inicio,
      rejectWeekendStart: true,
    );
    if (data == null) return;

    final novaData = normalizarData(data);
    final dataAtual = normalizarData(inicio);
    if (novaData.isAtSameMomentAs(dataAtual)) {
      if (!mounted) return;
      AppFeedback.showWarning(context, 'Informe uma data diferente da atual.');
      return;
    }

    final operacao = novaData.isBefore(dataAtual)
        ? OperacaoSolicitacaoConcessao.antecipar
        : OperacaoSolicitacaoConcessao.adiar;
    final operacaoDisponivel =
        (operacao == OperacaoSolicitacaoConcessao.adiar && podeAdiar) ||
        (operacao == OperacaoSolicitacaoConcessao.antecipar && podeAntecipar);

    if (!operacaoDisponivel) {
      if (!mounted) return;
      AppFeedback.showWarning(
        context,
        '${operacao.label} não está disponível para este gozo.',
      );
      return;
    }

    await _run(operacao, data: novaData);
  }

  Future<void> _handleOperation(OperacaoSolicitacaoConcessao operacao) async {
    switch (operacao) {
      case OperacaoSolicitacaoConcessao.cancelar:
      case OperacaoSolicitacaoConcessao.suspenderIntegralmente:
        await _confirmAndRun(operacao);
      case OperacaoSolicitacaoConcessao.adiar:
      case OperacaoSolicitacaoConcessao.antecipar:
      case OperacaoSolicitacaoConcessao.interromper:
        final data = await _showDateOperationSheet(
          title: operacao.label,
          dateLabel: _dateLabel(operacao),
          rejectWeekendStart:
              operacao == OperacaoSolicitacaoConcessao.adiar ||
              operacao == OperacaoSolicitacaoConcessao.antecipar,
        );
        if (data != null) {
          await _run(operacao, data: data);
        }
      case OperacaoSolicitacaoConcessao.suspenderParcialmente:
        final periodo = await _showPeriodOperationSheet();
        if (periodo != null) {
          await _run(operacao, data: periodo.$1, dataFim: periodo.$2);
        }
    }
  }

  Future<void> _confirmAndRun(OperacaoSolicitacaoConcessao operacao) async {
    final confirm = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: ConcessaoAfastamentoColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(operacao.label),
        content: Text(
          'Deseja realmente ${operacao.label.toLowerCase()} esta solicitação?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE5252A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _run(operacao);
    }
  }

  Future<DateTime?> _showDateOperationSheet({
    required String title,
    required String dateLabel,
    DateTime? initialDate,
    bool rejectWeekendStart = false,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DateOperationSheet(
        title: title,
        dateLabel: dateLabel,
        initialDate: initialDate,
        rejectWeekendStart: rejectWeekendStart,
      ),
    );
  }

  Future<(DateTime, DateTime)?> _showPeriodOperationSheet() {
    return showModalBottomSheet<(DateTime, DateTime)>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PeriodOperationSheet(),
    );
  }

  Future<void> _run(
    OperacaoSolicitacaoConcessao operacao, {
    DateTime? data,
    DateTime? dataFim,
  }) async {
    final execute = widget.onExecutarOperacao;
    if (execute == null) return;

    setState(() => _isExecuting = true);
    final feedback = AppFeedback.showLoading(
      context,
      title: 'Processando alteração',
      message: 'Aguarde enquanto salvamos sua solicitação.',
    );
    try {
      await execute(widget.solicitacao, operacao, data: data, dataFim: dataFim);
      feedback.dismiss();
      if (!mounted) return;
      AppFeedback.showSuccess(context, operacao.successMessage);
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      feedback.dismiss();
      if (!mounted) return;
      setState(() => _isExecuting = false);
      AppFeedback.showError(context, _operationErrorMessage(e));
    }
  }

  String _operationErrorMessage(Object error) {
    if (error is DioException) {
      final responseMessage = _extractResponseMessage(error.response?.data);
      if (responseMessage != null) {
        return 'Não foi possível executar a operação: $responseMessage';
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return 'Não foi possível executar a operação: sessão expirada ou usuário sem permissão.';
      }
      if (statusCode != null) {
        return 'Não foi possível executar a operação. Código HTTP $statusCode.';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'O serviço demorou para responder. Tente novamente.';
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return 'Sem conexão com o serviço. Verifique sua internet e tente novamente.';
      }
    }

    return 'Não foi possível executar a operação: $error';
  }

  String _dateLabel(OperacaoSolicitacaoConcessao operacao) {
    switch (operacao) {
      case OperacaoSolicitacaoConcessao.adiar:
        return 'Data de adiamento';
      case OperacaoSolicitacaoConcessao.antecipar:
        return 'Data de antecipação';
      case OperacaoSolicitacaoConcessao.interromper:
        return 'Data de interrupção';
      case OperacaoSolicitacaoConcessao.cancelar:
      case OperacaoSolicitacaoConcessao.suspenderParcialmente:
      case OperacaoSolicitacaoConcessao.suspenderIntegralmente:
        return 'Data';
    }
  }

  String? _extractResponseMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      final message = data.trim();
      return message.isEmpty ? null : message;
    }
    if (data is Map) {
      for (final key in const [
        'message',
        'mensagem',
        'detail',
        'detalhe',
        'error',
        'erro',
      ]) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      final errors = data['errors'] ?? data['erros'];
      if (errors is List) {
        final messages = errors
            .whereType<Object>()
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    }
    return null;
  }
}

class _OperationChip extends StatelessWidget {
  final String label;
  final bool destructive;
  final bool enabled;
  final VoidCallback onTap;

  const _OperationChip({
    required this.label,
    this.destructive = false,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = destructive
        ? const Color(0xFFE5252A)
        : ConcessaoAfastamentoColors.ink;
    final background = destructive
        ? const Color(0xFFFFF1F2)
        : const Color(0xFFF1F3F5);
    final border = destructive
        ? const Color(0xFFFFB3B8)
        : const Color(0xFFD7DEDA);

    return Material(
      color: enabled ? background : const Color(0xFFF7F8F6),
      borderRadius: BorderRadius.circular(12),
      elevation: enabled ? 1 : 0,
      shadowColor: const Color(0x26101828),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? border : const Color(0xFFE9EDF0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? foreground : ConcessaoAfastamentoColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color foreground;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _DateOperationSheet extends StatefulWidget {
  final String title;
  final String dateLabel;
  final DateTime? initialDate;
  final bool rejectWeekendStart;

  const _DateOperationSheet({
    required this.title,
    required this.dateLabel,
    this.initialDate,
    this.rejectWeekendStart = false,
  });

  @override
  State<_DateOperationSheet> createState() => _DateOperationSheetState();
}

class _DateOperationSheetState extends State<_DateOperationSheet> {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final initialDate = widget.initialDate;
    _selected =
        initialDate != null &&
            !(widget.rejectWeekendStart && _isWeekend(initialDate))
        ? initialDate
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final weekendSelected = _selected != null && _isWeekend(_selected!);

    return _OperationSheetFrame(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DatePickerTile(
            label: widget.dateLabel,
            value: _selected == null
                ? 'Selecionar data'
                : _dateFormat.format(_selected!),
            onTap: _selectDate,
          ),
          if (widget.rejectWeekendStart && weekendSelected) ...[
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'A data inicial não pode cair em final de semana.',
                style: TextStyle(
                  color: Color(0xFFE5252A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed:
                  _selected == null ||
                      (widget.rejectWeekendStart && weekendSelected)
                  ? null
                  : () => Navigator.of(context).pop(_selected),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE5252A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Confirmar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year - 1);
    final lastDate = DateTime(today.year + 5);
    final initialDate = _selectableInitialDate(
      _selected ?? widget.initialDate ?? today,
      firstDate,
      lastDate,
    );
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: widget.rejectWeekendStart
          ? (date) => !_isWeekend(date)
          : null,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: const Locale('pt', 'BR'),
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      builder: _concessaoDatePickerTheme,
    );
    if (selected != null) {
      setState(() => _selected = selected);
    }
  }

  DateTime _dateWithinRange(
    DateTime date,
    DateTime firstDate,
    DateTime lastDate,
  ) {
    if (date.isBefore(firstDate)) return firstDate;
    if (date.isAfter(lastDate)) return lastDate;
    return date;
  }

  DateTime _selectableInitialDate(
    DateTime date,
    DateTime firstDate,
    DateTime lastDate,
  ) {
    var candidate = _dateWithinRange(date, firstDate, lastDate);
    if (!widget.rejectWeekendStart || !_isWeekend(candidate)) {
      return candidate;
    }

    while (candidate.isBefore(lastDate) && _isWeekend(candidate)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    if (!_isWeekend(candidate)) return candidate;

    candidate = _dateWithinRange(date, firstDate, lastDate);
    while (candidate.isAfter(firstDate) && _isWeekend(candidate)) {
      candidate = candidate.subtract(const Duration(days: 1));
    }
    return candidate;
  }

  bool _isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

class _PeriodOperationSheet extends StatefulWidget {
  const _PeriodOperationSheet();

  @override
  State<_PeriodOperationSheet> createState() => _PeriodOperationSheetState();
}

class _PeriodOperationSheetState extends State<_PeriodOperationSheet> {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  DateTime? _inicio;
  DateTime? _fim;

  @override
  Widget build(BuildContext context) {
    return _OperationSheetFrame(
      title: 'Suspender parcial',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DatePickerTile(
            label: 'Início da suspensão',
            value: _inicio == null
                ? 'Selecionar data'
                : _dateFormat.format(_inicio!),
            onTap: () => _selectDate(isStart: true),
          ),
          const SizedBox(height: 10),
          _DatePickerTile(
            label: 'Fim da suspensão',
            value: _fim == null ? 'Selecionar data' : _dateFormat.format(_fim!),
            onTap: () => _selectDate(isStart: false),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: _inicio == null || _fim == null
                  ? null
                  : () => Navigator.of(context).pop((_inicio!, _fim!)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE5252A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Confirmar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: (isStart ? _inicio : _fim) ?? today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 5),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: const Locale('pt', 'BR'),
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      builder: _concessaoDatePickerTheme,
    );
    if (selected != null) {
      setState(() {
        if (isStart) {
          _inicio = selected;
          if (_fim != null && _fim!.isBefore(selected)) {
            _fim = selected;
          }
        } else {
          _fim = selected;
        }
      });
    }
  }
}

Widget _concessaoDatePickerTheme(BuildContext context, Widget? child) {
  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFD62828),
        onPrimary: Colors.white,
        onSurface: Color(0xFF202322),
      ),
    ),
    child: child!,
  );
}

class _OperationSheetFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _OperationSheetFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DEDA),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: ConcessaoAfastamentoColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: ConcessaoAfastamentoColors.muted,
                  tooltip: 'Fechar',
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9EDF0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFFE5252A),
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: ConcessaoAfastamentoColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        color: ConcessaoAfastamentoColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: ConcessaoAfastamentoColors.muted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: ConcessaoAfastamentoColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

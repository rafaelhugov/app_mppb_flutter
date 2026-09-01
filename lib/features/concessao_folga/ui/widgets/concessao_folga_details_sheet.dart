import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/concessao_folga.dart';
import '../../models/operacao_solicitacao_concessao.dart';
import '../../models/solicitacao_concessao.dart';
import 'concessao_folga_theme.dart';

class ConcessaoFolgaDetailsSheet extends StatelessWidget {
  final ConcessaoFolga concessao;
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

  const ConcessaoFolgaDetailsSheet({
    super.key,
    required this.concessao,
    this.onBuscarOperacoes,
    this.onExecutarOperacao,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
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
                  color: ConcessaoFolgaColors.ink,
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
              const Text(
                'Solicitações vinculadas',
                style: TextStyle(
                  color: ConcessaoFolgaColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (concessao.solicitacoes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE9EDF0)),
                  ),
                  child: const Text(
                    'Nenhum período de gozo programado',
                    style: TextStyle(color: ConcessaoFolgaColors.muted),
                  ),
                )
              else
                ...concessao.solicitacoes.map(
                  (solicitacao) => Container(
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
                          height: 56,
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
                                  color: ConcessaoFolgaColors.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${dateFormat.format(solicitacao.inicio)} a ${dateFormat.format(solicitacao.fim)}',
                                style: const TextStyle(
                                  color: ConcessaoFolgaColors.muted,
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
                                  ),
                                  Text(
                                    '${solicitacao.diasCalculados} dia(s)',
                                    style: const TextStyle(
                                      color: ConcessaoFolgaColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
              style: TextStyle(color: ConcessaoFolgaColors.muted, fontSize: 12),
            ),
          );
        }

        final operacoes = snapshot.data ?? const [];
        if (operacoes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Nenhuma ação disponível.',
              style: TextStyle(color: ConcessaoFolgaColors.muted, fontSize: 12),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: operacoes
                .map(
                  (operacao) => _OperationChip(
                    operacao: operacao,
                    enabled: !_isExecuting,
                    onTap: () => _handleOperation(operacao),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Future<void> _handleOperation(OperacaoSolicitacaoConcessao operacao) async {
    switch (operacao) {
      case OperacaoSolicitacaoConcessao.cancelar:
      case OperacaoSolicitacaoConcessao.suspenderIntegralmente:
        await _confirmAndRun(operacao);
      case OperacaoSolicitacaoConcessao.adiar:
      case OperacaoSolicitacaoConcessao.antecipar:
      case OperacaoSolicitacaoConcessao.interromper:
        final data = await _showDateOperationSheet(operacao);
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

  Future<DateTime?> _showDateOperationSheet(
    OperacaoSolicitacaoConcessao operacao,
  ) {
    return showModalBottomSheet<DateTime>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DateOperationSheet(operacao: operacao),
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
    final messenger = ScaffoldMessenger.of(context);
    try {
      await execute(widget.solicitacao, operacao, data: data, dataFim: dataFim);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(operacao.successMessage)));
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        _isExecuting = false;
        _future = _load();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExecuting = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Não foi possível executar a operação: $e')),
      );
    }
  }
}

class _OperationChip extends StatelessWidget {
  final OperacaoSolicitacaoConcessao operacao;
  final bool enabled;
  final VoidCallback onTap;

  const _OperationChip({
    required this.operacao,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final destructive =
        operacao == OperacaoSolicitacaoConcessao.cancelar ||
        operacao == OperacaoSolicitacaoConcessao.suspenderIntegralmente;
    final foreground = destructive
        ? const Color(0xFFE5252A)
        : ConcessaoFolgaColors.ink;
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
            operacao.label,
            style: TextStyle(
              color: enabled ? foreground : ConcessaoFolgaColors.muted,
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

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _DateOperationSheet extends StatefulWidget {
  final OperacaoSolicitacaoConcessao operacao;

  const _DateOperationSheet({required this.operacao});

  @override
  State<_DateOperationSheet> createState() => _DateOperationSheetState();
}

class _DateOperationSheetState extends State<_DateOperationSheet> {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    return _OperationSheetFrame(
      title: widget.operacao.label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DatePickerTile(
            label: _dateLabel(widget.operacao),
            value: _selected == null
                ? 'Selecionar data'
                : _dateFormat.format(_selected!),
            onTap: _selectDate,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: _selected == null
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
    final selected = await showDatePicker(
      context: context,
      initialDate: _selected ?? today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 5),
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
                      color: ConcessaoFolgaColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: ConcessaoFolgaColors.muted,
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
                        color: ConcessaoFolgaColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        color: ConcessaoFolgaColors.ink,
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
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: ConcessaoFolgaColors.muted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ConcessaoFolgaColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

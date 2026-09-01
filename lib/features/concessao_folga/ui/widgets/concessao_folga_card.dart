import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/concessao_folga.dart';
import '../../models/operacao_solicitacao_concessao.dart';
import '../../models/solicitacao_concessao.dart';
import '../../models/sugestao_data_final.dart';
import 'concessao_folga_details_sheet.dart';
import 'concessao_folga_theme.dart';

class ConcessaoFolgaCard extends StatelessWidget {
  final ConcessaoFolga concessao;
  final Future<void> Function(
    ConcessaoFolga concessao,
    DateTime dataInicial,
    int numeroDias,
  )?
  onSolicitar;
  final Future<List<SugestaoDataFinal>> Function(
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

  const ConcessaoFolgaCard({
    super.key,
    required this.concessao,
    this.onSolicitar,
    this.onBuscarSugestoes,
    this.onBuscarOperacoes,
    this.onExecutarOperacao,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final primeiraSolicitacao = concessao.solicitacoes.isEmpty
        ? null
        : concessao.solicitacoes.first;
    final typeColor = concessao.tipo.color;
    final titleDetail = _cardTitleDetail(concessao);
    final canSolicitar = concessao.saldoRestante > 0 && onSolicitar != null;

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ConcessaoFolgaDetailsSheet(
          concessao: concessao,
          onBuscarOperacoes: onBuscarOperacoes,
          onExecutarOperacao: onExecutarOperacao,
        ),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9EDF0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10101828),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TypeChip(label: concessao.tipo.label, color: typeColor),
                      if (titleDetail.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          titleDetail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ConcessaoFolgaColors.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _SaldoChip(saldo: concessao.saldoRestante),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Dias concedidos',
                    value: '${concessao.diasConcedidos}',
                    background: _softColor(typeColor),
                    border: typeColor.withValues(alpha: 0.24),
                    labelColor: ConcessaoFolgaColors.muted,
                    valueColor: ConcessaoFolgaColors.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    label: 'Saldo disponível',
                    value: '${concessao.saldoRestante} dias',
                    background: _softColor(typeColor),
                    border: typeColor.withValues(alpha: 0.24),
                    labelColor: ConcessaoFolgaColors.muted,
                    valueColor: ConcessaoFolgaColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (primeiraSolicitacao == null)
              const Text(
                'Nenhum período de gozo programado',
                style: TextStyle(
                  color: ConcessaoFolgaColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              )
            else ...[
              Text(
                'Período: ${dateFormat.format(primeiraSolicitacao.inicio)} a ${dateFormat.format(primeiraSolicitacao.fim)}',
                style: const TextStyle(
                  color: ConcessaoFolgaColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  _StatusChip(
                    label: primeiraSolicitacao.status.label,
                    color: primeiraSolicitacao.status.color,
                  ),
                  if (concessao.solicitacoes.length > 1) ...[
                    const SizedBox(width: 8),
                    Text(
                      '+${concessao.solicitacoes.length - 1}',
                      style: const TextStyle(
                        color: ConcessaoFolgaColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (canSolicitar) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: _MarcacaoButton(onTap: () => _abrirMarcacao(context)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _abrirMarcacao(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarcacaoGozoSheet(
        concessao: concessao,
        onSubmit: onSolicitar!,
        onBuscarSugestoes: onBuscarSugestoes,
      ),
    );
  }
}

class _MarcacaoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MarcacaoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F3F5),
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: const Color(0x26101828),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD7DEDA)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_available_rounded,
                color: ConcessaoFolgaColors.ink,
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'Marcar gozo',
                style: TextStyle(
                  color: ConcessaoFolgaColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _cardTitleDetail(ConcessaoFolga concessao) {
  final title = concessao.titulo.trim();
  final label = concessao.tipo.label;
  final prefixed = '$label - ';
  if (title.startsWith(prefixed)) {
    return title.substring(prefixed.length).trim();
  }
  if (title == label) return '';
  return title;
}

Color _softColor(Color color) => color.withValues(alpha: 0.08);

class _TypeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color.computeLuminance() > 0.45
        ? ConcessaoFolgaColors.ink
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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

class _MarcacaoGozoSheet extends StatefulWidget {
  final ConcessaoFolga concessao;
  final Future<void> Function(
    ConcessaoFolga concessao,
    DateTime dataInicial,
    int numeroDias,
  )
  onSubmit;
  final Future<List<SugestaoDataFinal>> Function(
    ConcessaoFolga concessao,
    DateTime dataInicial,
  )?
  onBuscarSugestoes;

  const _MarcacaoGozoSheet({
    required this.concessao,
    required this.onSubmit,
    this.onBuscarSugestoes,
  });

  @override
  State<_MarcacaoGozoSheet> createState() => _MarcacaoGozoSheetState();
}

class _MarcacaoGozoSheetState extends State<_MarcacaoGozoSheet> {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  DateTime? _dataInicial;
  SugestaoDataFinal? _sugestaoSelecionada;
  bool _isSubmitting = false;
  bool _isLoadingSugestoes = false;
  int _sugestoesRequestId = 0;
  List<SugestaoDataFinal> _sugestoes = const [];
  String? _sugestoesError;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final sugestao = _sugestaoSelecionada;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F8F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
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
                      const Expanded(
                        child: Text(
                          'Marcar gozo',
                          style: TextStyle(
                            color: Color(0xFF202322),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: const Color(0xFF697370),
                        tooltip: 'Fechar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.concessao.titulo,
                    style: const TextStyle(
                      color: Color(0xFF697370),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SheetTile(
                    label: 'Data inicial',
                    value: _dataInicial == null
                        ? 'Selecione uma data'
                        : _dateFormat.format(_dataInicial!),
                    icon: Icons.calendar_today_rounded,
                    onTap: _isSubmitting ? null : _selecionarData,
                  ),
                  if (_isLoadingSugestoes) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: Color(0xFFE5252A),
                      backgroundColor: Color(0xFFE9EDF0),
                    ),
                  ] else if (_sugestoes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SugestoesBox(
                      sugestoes: _sugestoes,
                      selected: _sugestaoSelecionada,
                      onSelect: _isSubmitting
                          ? null
                          : (sugestao) =>
                                setState(() => _sugestaoSelecionada = sugestao),
                    ),
                  ] else if (_sugestoesError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _sugestoesError!,
                      style: const TextStyle(
                        color: Color(0xFF697370),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (sugestao != null && _dataInicial != null) ...[
                    const SizedBox(height: 12),
                    _ResumoMarcacao(
                      tipo: widget.concessao.tipo.label,
                      dataInicial: _dateFormat.format(_dataInicial!),
                      dataFinal: sugestao.dataFinalFormatada,
                      numeroDias: sugestao.numeroDias,
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed:
                          _isSubmitting ||
                              _isLoadingSugestoes ||
                              _dataInicial == null ||
                              _sugestaoSelecionada == null
                          ? null
                          : _enviar,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE5252A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Solicitar marcação',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final today = DateTime.now();
    final initialDate = _dataInicial ?? today.add(const Duration(days: 1));
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 3),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: const Locale('pt', 'BR'),
      helpText: 'Data inicial',
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      builder: _concessaoDatePickerTheme,
    );
    if (selected != null) {
      setState(() {
        _dataInicial = selected;
        _sugestaoSelecionada = null;
        _sugestoes = const [];
        _sugestoesError = null;
      });
      await _buscarSugestoes(selected);
    }
  }

  Future<void> _buscarSugestoes(DateTime dataInicial) async {
    final fetch = widget.onBuscarSugestoes;
    if (fetch == null) return;

    final requestId = ++_sugestoesRequestId;
    setState(() {
      _isLoadingSugestoes = true;
      _sugestoes = const [];
      _sugestaoSelecionada = null;
      _sugestoesError = null;
    });

    try {
      final sugestoes = await fetch(widget.concessao, dataInicial);
      if (!mounted || requestId != _sugestoesRequestId) return;
      setState(() {
        _isLoadingSugestoes = false;
        _sugestoes = sugestoes;
        _sugestoesError = sugestoes.isEmpty
            ? 'Nenhum intervalo sugerido para a data selecionada.'
            : null;
      });
    } catch (_) {
      if (!mounted || requestId != _sugestoesRequestId) return;
      setState(() {
        _isLoadingSugestoes = false;
        _sugestoesError = 'Não foi possível carregar os intervalos sugeridos.';
      });
    }
  }

  Future<void> _enviar() async {
    final dataInicial = _dataInicial;
    final sugestao = _sugestaoSelecionada;
    if (dataInicial == null || sugestao == null) return;

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.onSubmit(widget.concessao, dataInicial, sugestao.numeroDias);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Solicitação de gozo enviada.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Não foi possível marcar o gozo: $e')),
      );
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

class _SugestoesBox extends StatelessWidget {
  final List<SugestaoDataFinal> sugestoes;
  final SugestaoDataFinal? selected;
  final ValueChanged<SugestaoDataFinal>? onSelect;

  const _SugestoesBox({
    required this.sugestoes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datas finais permitidas',
            style: TextStyle(
              color: Color(0xFF202322),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...sugestoes.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SugestaoOption(
                sugestao: item,
                selected: selected == item,
                onTap: onSelect == null ? null : () => onSelect!(item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SugestaoOption extends StatelessWidget {
  final SugestaoDataFinal sugestao;
  final bool selected;
  final VoidCallback? onTap;

  const _SugestaoOption({
    required this.sugestao,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0x1400A86B) : const Color(0xFFF7F8F6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF00A86B)
                  : const Color(0xFFE9EDF0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? const Color(0xFF00A86B)
                    : const Color(0xFF697370),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sugestao.dataFinalFormatada,
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sugestao.numeroDias} dia(s)',
                      style: const TextStyle(
                        color: Color(0xFF697370),
                        fontSize: 12,
                        height: 1.25,
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

class _ResumoMarcacao extends StatelessWidget {
  final String tipo;
  final String dataInicial;
  final String dataFinal;
  final int numeroDias;

  const _ResumoMarcacao({
    required this.tipo,
    required this.dataInicial,
    required this.dataFinal,
    required this.numeroDias,
  });

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
      child: Column(
        children: [
          _ResumoLine(label: 'Tipo', value: tipo),
          _ResumoLine(label: 'Data inicial', value: dataInicial),
          _ResumoLine(label: 'Data final', value: dataFinal),
          _ResumoLine(label: 'Quantidade', value: '$numeroDias dia(s)'),
        ],
      ),
    );
  }
}

class _ResumoLine extends StatelessWidget {
  final String label;
  final String value;

  const _ResumoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF697370), fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF202322),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _SheetTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9EDF0)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x12E5252A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFE5252A), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF697370),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF697370)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaldoChip extends StatelessWidget {
  final int saldo;

  const _SaldoChip({required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD7DEDA)),
      ),
      child: Text(
        '$saldo dias',
        style: const TextStyle(
          color: ConcessaoFolgaColors.ink,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color background;
  final Color border;
  final Color labelColor;
  final Color valueColor;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.background,
    required this.border,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.47)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

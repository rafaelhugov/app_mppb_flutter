import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../../core/ui/app_feedback.dart';
import '../../models/concessao_afastamento.dart';
import '../../models/operacao_solicitacao_concessao.dart';
import '../../models/solicitacao_concessao.dart';
import '../../models/sugestao_data_final.dart';
import '../../models/text_normalizer.dart';
import '../../models/tipo_concessao.dart';
import 'concessao_afastamento_details_sheet.dart';
import 'concessao_afastamento_theme.dart';

class ConcessaoAfastamentoCard extends StatelessWidget {
  final ConcessaoAfastamento concessao;
  final bool isMembro;
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

  const ConcessaoAfastamentoCard({
    super.key,
    required this.concessao,
    required this.isMembro,
    this.onSolicitar,
    this.onBuscarSugestoes,
    this.onBuscarOperacoes,
    this.onExecutarOperacao,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final gozos = concessao.solicitacoes.where((item) => item.isGozo).toList();
    final gozosComPeriodo = gozos
        .where((item) => item.possuiPeriodoCompleto)
        .toList();
    final movimentacoes = concessao.solicitacoes
        .where((item) => item.isMovimentacao)
        .toList();
    final primeiraSolicitacao = gozosComPeriodo.isEmpty
        ? null
        : gozosComPeriodo.first;
    final diasAguardandoRetorno = movimentacoes.fold<int>(
      0,
      (total, item) =>
          total + (item.possuiDiasParaRetorno ? item.diasInformados! : 0),
    );
    final typeColor = concessao.tipo.color;
    final titleDetail = _cardTitleDetail(concessao);
    final canSolicitar = concessao.saldoRestante > 0 && onSolicitar != null;

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ConcessaoAfastamentoDetailsSheet(
          concessao: concessao,
          isMembro: isMembro,
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
                          concessao.tipo == TipoConcessao.licencaPremio
                              ? 'Período: $titleDetail'
                              : titleDetail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ConcessaoAfastamentoColors.ink,
                            fontSize: 14,
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
                    labelColor: ConcessaoAfastamentoColors.muted,
                    valueColor: ConcessaoAfastamentoColors.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    label: 'Saldo disponível',
                    value: '${concessao.saldoRestante} dias',
                    background: _softColor(typeColor),
                    border: typeColor.withValues(alpha: 0.24),
                    labelColor: ConcessaoAfastamentoColors.muted,
                    valueColor: ConcessaoAfastamentoColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (primeiraSolicitacao == null)
              const Text(
                'Nenhum período de gozo programado',
                style: TextStyle(
                  color: ConcessaoAfastamentoColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              )
            else ...[
              Text(
                'Período: ${dateFormat.format(primeiraSolicitacao.inicio!)} a ${dateFormat.format(primeiraSolicitacao.fim!)}',
                style: const TextStyle(
                  color: ConcessaoAfastamentoColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _StatusChip(
                    label: primeiraSolicitacao.status.label,
                    color: primeiraSolicitacao.status.color,
                    foreground: primeiraSolicitacao.status.foreground,
                  ),
                  if (gozosComPeriodo.length > 1) ...[
                    Text(
                      '+${gozosComPeriodo.length - 1}',
                      style: const TextStyle(
                        color: ConcessaoAfastamentoColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (diasAguardandoRetorno > 0) ...[
              const SizedBox(height: 8),
              _PendingReturnNotice(dias: diasAguardandoRetorno),
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
                color: ConcessaoAfastamentoColors.ink,
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'Marcar gozo',
                style: TextStyle(
                  color: ConcessaoAfastamentoColors.ink,
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

String _cardTitleDetail(ConcessaoAfastamento concessao) {
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
        ? ConcessaoAfastamentoColors.ink
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
  final Color foreground;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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

class _PendingReturnNotice extends StatelessWidget {
  final int dias;

  const _PendingReturnNotice({required this.dias});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x33F97316)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.pending_actions_rounded,
            size: 15,
            color: ConcessaoAfastamentoColors.statusConfirmada,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$dias dia(s) solicitados para estorno do saldo disponível',
              style: const TextStyle(
                color: ConcessaoAfastamentoColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarcacaoGozoSheet extends StatefulWidget {
  final ConcessaoAfastamento concessao;
  final Future<void> Function(
    ConcessaoAfastamento concessao,
    DateTime dataInicial,
    int numeroDias,
  )
  onSubmit;
  final Future<List<SugestaoDataFinal>> Function(
    ConcessaoAfastamento concessao,
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
  final _numeroDiasController = TextEditingController();
  DateTime? _dataInicial;
  int? _numeroDias;
  SugestaoDataFinal? _sugestaoSelecionada;
  bool _isSubmitting = false;
  bool _isLoadingSugestoes = false;
  int _sugestoesRequestId = 0;
  List<SugestaoDataFinal> _sugestoes = const [];
  String? _sugestoesError;
  String? _submitError;

  bool get _isAfastamentoEleitoral =>
      widget.concessao.tipo == TipoConcessao.licencaEleitoral;

  bool get _usesManualDayEntry =>
      _isAfastamentoEleitoral || widget.concessao.tipo == TipoConcessao.plantao;

  bool get _numeroDiasValido {
    final numeroDias = _numeroDias;
    return numeroDias != null &&
        numeroDias > 0 &&
        numeroDias <= widget.concessao.saldoRestante;
  }

  String? get _eleitoralValidationMessage {
    if (!_isAfastamentoEleitoral) return null;

    final dataInicial = _dataInicial;
    if (dataInicial != null) {
      final blockedStart = _blockedElectionLeaveDay(dataInicial);
      if (blockedStart != null) {
        return 'A data inicial não pode cair em ${blockedStart.toLowerCase()}.';
      }
    }

    final numeroDias = _numeroDias;
    if (numeroDias == null || numeroDias <= 0) return null;
    if (numeroDias > widget.concessao.saldoRestante) {
      return 'Informe no máximo ${widget.concessao.saldoRestante} dia(s).';
    }
    if (dataInicial == null) return null;

    for (var offset = 0; offset < numeroDias; offset++) {
      final date = dataInicial.add(Duration(days: offset));
      final blockedDay = _blockedElectionLeaveDay(date);
      if (blockedDay != null) {
        return 'O período informado inclui ${blockedDay.toLowerCase()} em ${_dateFormat.format(date)}.';
      }
    }
    return null;
  }

  bool get _canSubmit {
    if (_isSubmitting || _isLoadingSugestoes || _dataInicial == null) {
      return false;
    }
    if (_usesManualDayEntry) {
      return _numeroDiasValido && _eleitoralValidationMessage == null;
    }
    return _sugestaoSelecionada != null;
  }

  @override
  void dispose() {
    _numeroDiasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final sugestao = _sugestaoSelecionada;
    final numeroDias = _numeroDias;
    final numeroDiasResumoManual = numeroDias != null && numeroDias > 0
        ? numeroDias
        : null;
    final showResumoManual =
        _usesManualDayEntry &&
        _dataInicial != null &&
        numeroDiasResumoManual != null &&
        _eleitoralValidationMessage == null;
    final formError = _submitError ?? _eleitoralValidationMessage;
    final showElectionLeaveNotice =
        _isAfastamentoEleitoral && formError == null && _dataInicial == null;

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
                  if (showElectionLeaveNotice) ...[
                    const _SheetNotice(
                      title: 'Atenção aos dias úteis',
                      message:
                          'Afastamento eleitoral não pode incluir fins de semana ou feriados.',
                      icon: Icons.info_outline_rounded,
                      tone: _SheetNoticeTone.info,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _SheetTile(
                    label: 'Data inicial',
                    value: _dataInicial == null
                        ? 'Selecione uma data'
                        : _dateFormat.format(_dataInicial!),
                    icon: Icons.calendar_today_rounded,
                    onTap: _isSubmitting ? null : _selecionarData,
                  ),
                  if (_usesManualDayEntry) ...[
                    const SizedBox(height: 12),
                    _NumeroDiasField(
                      controller: _numeroDiasController,
                      enabled: !_isSubmitting,
                      saldoRestante: widget.concessao.saldoRestante,
                      onChanged: _atualizarNumeroDias,
                    ),
                  ] else if (_isLoadingSugestoes) ...[
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
                  if (showResumoManual) ...[
                    const SizedBox(height: 12),
                    _ResumoMarcacao(
                      tipo: widget.concessao.tipo.label,
                      dataInicial: _dateFormat.format(_dataInicial!),
                      numeroDias: numeroDiasResumoManual,
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
                  if (formError != null) ...[
                    const SizedBox(height: 12),
                    _SheetNotice(
                      title: _submitError == null
                          ? 'Revise a marcação'
                          : 'Não foi possível solicitar',
                      message: formError,
                      icon: _submitError == null
                          ? Icons.warning_amber_rounded
                          : Icons.error_outline_rounded,
                      tone: _submitError == null
                          ? _SheetNoticeTone.warning
                          : _SheetNoticeTone.error,
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _canSubmit ? _enviar : null,
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
    final firstDate = DateTime(today.year, today.month, today.day);
    final lastDate = DateTime(today.year + 3);
    final selectableDayPredicate = _isAfastamentoEleitoral
        ? (DateTime date) => _blockedElectionLeaveDay(date) == null
        : null;
    final initialDate = _initialSelectableDate(
      preferredDate: _dataInicial ?? today.add(const Duration(days: 1)),
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
    );
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: const Locale('pt', 'BR'),
      helpText: 'Data inicial',
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      selectableDayPredicate: selectableDayPredicate,
      builder: _concessaoDatePickerTheme,
    );
    if (selected != null) {
      setState(() {
        _dataInicial = selected;
        _sugestaoSelecionada = null;
        _sugestoes = const [];
        _sugestoesError = null;
        _submitError = null;
      });
      if (!_usesManualDayEntry) {
        await _buscarSugestoes(selected);
      }
    }
  }

  void _atualizarNumeroDias(String value) {
    final parsed = int.tryParse(value.trim());
    setState(() {
      _numeroDias = parsed;
      _submitError = null;
    });
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
    final numeroDias = _usesManualDayEntry
        ? _numeroDias
        : _sugestaoSelecionada?.numeroDias;
    if (dataInicial == null || numeroDias == null || numeroDias <= 0) return;

    setState(() => _isSubmitting = true);
    final feedback = AppFeedback.showLoading(
      context,
      title: 'Enviando solicitação',
      message: 'Aguarde enquanto registramos o gozo.',
    );
    try {
      await widget.onSubmit(widget.concessao, dataInicial, numeroDias);
      feedback.dismiss();
      if (!mounted) return;
      AppFeedback.showSuccess(context, 'Solicitação de gozo enviada.');
      Navigator.of(context).pop();
    } catch (e) {
      feedback.dismiss();
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = _solicitacaoErrorMessage(e);
      });
    }
  }

  String _solicitacaoErrorMessage(Object error) {
    if (error is DioException) {
      final responseMessage = _extractResponseMessage(error.response?.data);
      if (responseMessage != null) {
        return _friendlyResponseMessage(responseMessage);
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return 'Sessão expirada ou usuário sem permissão.';
      }
      if (statusCode != null) {
        return 'O serviço recusou a solicitação. Código HTTP $statusCode.';
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

    return error.toString();
  }

  String _friendlyResponseMessage(String message) {
    final normalized = normalizarTexto(message).replaceAll('�', '');
    if (normalized.contains('eleitoral') &&
        normalized.contains('fins de semana') &&
        normalized.contains('feriados')) {
      return 'Afastamento eleitoral não pode incluir fins de semana ou feriados.';
    }
    return message;
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
    }
    return null;
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

class _NumeroDiasField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final int saldoRestante;
  final ValueChanged<String> onChanged;

  const _NumeroDiasField({
    required this.controller,
    required this.enabled,
    required this.saldoRestante,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = int.tryParse(controller.text.trim());
    final hasValue = controller.text.trim().isNotEmpty;
    final hasError =
        hasValue && (value == null || value <= 0 || value > saldoRestante);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasError ? const Color(0xFFE5252A) : const Color(0xFFE9EDF0),
        ),
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
            child: const Icon(
              Icons.format_list_numbered_rounded,
              color: Color(0xFFE5252A),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
              style: const TextStyle(
                color: Color(0xFF202322),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                labelText: 'Número de dias',
                labelStyle: const TextStyle(
                  color: Color(0xFF697370),
                  fontSize: 12,
                ),
                hintText: 'Informe a quantidade',
                hintStyle: const TextStyle(
                  color: Color(0xFF697370),
                  fontWeight: FontWeight.w500,
                ),
                errorText: hasError
                    ? 'Informe de 1 a $saldoRestante dia(s)'
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SheetNoticeTone { info, warning, error }

class _SheetNotice extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final _SheetNoticeTone tone;

  const _SheetNotice({
    required this.title,
    required this.message,
    required this.icon,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _SheetNoticeColors.fromTone(tone);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.icon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.title,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: colors.message,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetNoticeColors {
  final Color background;
  final Color border;
  final Color iconBackground;
  final Color icon;
  final Color title;
  final Color message;

  const _SheetNoticeColors({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.message,
  });

  factory _SheetNoticeColors.fromTone(_SheetNoticeTone tone) {
    switch (tone) {
      case _SheetNoticeTone.info:
        return const _SheetNoticeColors(
          background: Color(0xFFF0F7FA),
          border: Color(0xFFD7EAF0),
          iconBackground: Color(0xFFE0F2FE),
          icon: Color(0xFF0369A1),
          title: Color(0xFF164E63),
          message: Color(0xFF3F626D),
        );
      case _SheetNoticeTone.warning:
        return const _SheetNoticeColors(
          background: Color(0xFFFFF8E8),
          border: Color(0xFFF4E1B5),
          iconBackground: Color(0xFFFFE9B3),
          icon: Color(0xFFB45309),
          title: Color(0xFF7C3E08),
          message: Color(0xFF72551F),
        );
      case _SheetNoticeTone.error:
        return const _SheetNoticeColors(
          background: Color(0xFFFFF1F1),
          border: Color(0xFFFFD2D2),
          iconBackground: Color(0xFFFFE0E0),
          icon: Color(0xFFE5252A),
          title: Color(0xFF8F1D1D),
          message: Color(0xFF7A3030),
        );
    }
  }
}

class _ResumoMarcacao extends StatelessWidget {
  final String tipo;
  final String dataInicial;
  final String? dataFinal;
  final int numeroDias;

  const _ResumoMarcacao({
    required this.tipo,
    required this.dataInicial,
    this.dataFinal,
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
          if (dataFinal != null)
            _ResumoLine(label: 'Data final', value: dataFinal!),
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

DateTime _initialSelectableDate({
  required DateTime preferredDate,
  required DateTime firstDate,
  required DateTime lastDate,
  required bool Function(DateTime date)? selectableDayPredicate,
}) {
  var candidate = _dateOnly(preferredDate);
  final minDate = _dateOnly(firstDate);
  final maxDate = _dateOnly(lastDate);
  if (candidate.isBefore(minDate)) candidate = minDate;
  if (candidate.isAfter(maxDate)) candidate = maxDate;
  if (selectableDayPredicate == null || selectableDayPredicate(candidate)) {
    return candidate;
  }

  for (
    var next = candidate.add(const Duration(days: 1));
    !next.isAfter(maxDate);
    next = next.add(const Duration(days: 1))
  ) {
    if (selectableDayPredicate(next)) return next;
  }

  for (
    var previous = candidate.subtract(const Duration(days: 1));
    !previous.isBefore(minDate);
    previous = previous.subtract(const Duration(days: 1))
  ) {
    if (selectableDayPredicate(previous)) return previous;
  }

  return candidate;
}

String? _blockedElectionLeaveDay(DateTime date) {
  if (date.weekday == DateTime.saturday) return 'sábado';
  if (date.weekday == DateTime.sunday) return 'domingo';
  return _brazilianHolidayName(date);
}

String? _brazilianHolidayName(DateTime date) {
  final month = date.month;
  final day = date.day;
  final fixedHolidays = <String, String>{
    '1-1': 'feriado de Confraternização Universal',
    '4-21': 'feriado de Tiradentes',
    '5-1': 'feriado do Dia do Trabalho',
    '9-7': 'feriado da Independência do Brasil',
    '10-12': 'feriado de Nossa Senhora Aparecida',
    '11-2': 'feriado de Finados',
    '11-15': 'feriado da Proclamação da República',
    '11-20': 'feriado do Dia da Consciência Negra',
    '12-25': 'feriado de Natal',
  };
  final fixed = fixedHolidays['$month-$day'];
  if (fixed != null) return fixed;

  final easter = _easterSunday(date.year);
  final movableHolidays = <DateTime, String>{
    _dateOnly(easter.subtract(const Duration(days: 48))): 'feriado de Carnaval',
    _dateOnly(easter.subtract(const Duration(days: 47))): 'feriado de Carnaval',
    _dateOnly(easter.subtract(const Duration(days: 2))):
        'feriado da Sexta-feira Santa',
    _dateOnly(easter.add(const Duration(days: 60))):
        'feriado de Corpus Christi',
  };
  return movableHolidays[_dateOnly(date)];
}

DateTime _easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

class _SaldoChip extends StatelessWidget {
  final int saldo;

  const _SaldoChip({required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD7DEDA)),
      ),
      child: Text(
        '$saldo ${saldo == 1 ? "dia" : "dias"}',
        style: const TextStyle(
          color: ConcessaoAfastamentoColors.ink,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.47)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

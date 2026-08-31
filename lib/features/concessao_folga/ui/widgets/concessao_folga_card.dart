import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/concessao_folga.dart';
import '../../models/tipo_concessao.dart';
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

  const ConcessaoFolgaCard({
    super.key,
    required this.concessao,
    this.onSolicitar,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final primeiraSolicitacao = concessao.solicitacoes.isEmpty
        ? null
        : concessao.solicitacoes.first;
    final typeColor = concessao.tipo.color;
    final onColor = typeColor.computeLuminance() > 0.45
        ? const Color(0xFF202322)
        : Colors.white;
    final secondaryColor = typeColor.computeLuminance() > 0.45
        ? const Color(0xD9202322)
        : const Color(0xE6FFFFFF);
    final tileColor = Colors.white.withValues(alpha: 0.18);
    final tileBorder = Colors.white.withValues(alpha: 0.36);
    final canSolicitar =
        concessao.tipo == TipoConcessao.ferias &&
        concessao.saldoRestante > 0 &&
        onSolicitar != null;

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ConcessaoFolgaDetailsSheet(concessao: concessao),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: typeColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: onColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    concessao.titulo,
                    style: TextStyle(
                      color: onColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _SaldoChip(saldo: concessao.saldoRestante, color: onColor),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Dias concedidos',
                    value: '${concessao.diasConcedidos}',
                    background: tileColor,
                    border: tileBorder,
                    labelColor: secondaryColor,
                    valueColor: onColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    label: 'Saldo disponível',
                    value: '${concessao.saldoRestante} dias',
                    background: tileColor,
                    border: tileBorder,
                    labelColor: secondaryColor,
                    valueColor: onColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (primeiraSolicitacao == null)
              const Text(
                'Nenhum período de gozo programado',
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              )
            else ...[
              Text(
                'Período: ${dateFormat.format(primeiraSolicitacao.inicio)} a ${dateFormat.format(primeiraSolicitacao.fim)}',
                style: TextStyle(
                  color: onColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.36),
                      ),
                    ),
                    child: Text(
                      primeiraSolicitacao.status.label,
                      style: TextStyle(
                        color: onColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (concessao.solicitacoes.length > 1) ...[
                    const SizedBox(width: 8),
                    Text(
                      '+${concessao.solicitacoes.length - 1}',
                      style: TextStyle(
                        color: secondaryColor,
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
                child: _MarcacaoButton(
                  color: onColor,
                  onTap: () => _abrirMarcacao(context),
                ),
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
      builder: (_) =>
          _MarcacaoFeriasSheet(concessao: concessao, onSubmit: onSolicitar!),
    );
  }
}

class _MarcacaoButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _MarcacaoButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_available_rounded, color: color, size: 15),
              const SizedBox(width: 6),
              Text(
                'Marcar férias',
                style: TextStyle(
                  color: color,
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

class _MarcacaoFeriasSheet extends StatefulWidget {
  final ConcessaoFolga concessao;
  final Future<void> Function(
    ConcessaoFolga concessao,
    DateTime dataInicial,
    int numeroDias,
  )
  onSubmit;

  const _MarcacaoFeriasSheet({required this.concessao, required this.onSubmit});

  @override
  State<_MarcacaoFeriasSheet> createState() => _MarcacaoFeriasSheetState();
}

class _MarcacaoFeriasSheetState extends State<_MarcacaoFeriasSheet> {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  DateTime? _dataInicial;
  late int _numeroDias;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _numeroDias = widget.concessao.saldoRestante.clamp(1, 30).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final saldo = widget.concessao.saldoRestante;
    final fimPrevisto = _dataInicial?.add(Duration(days: _numeroDias - 1));

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
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
                  const Expanded(
                    child: Text(
                      'Marcar férias',
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9EDF0)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Dias de gozo',
                        style: TextStyle(
                          color: Color(0xFF202322),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _CounterButton(
                      icon: Icons.remove_rounded,
                      enabled: !_isSubmitting && _numeroDias > 1,
                      onTap: () => setState(() => _numeroDias--),
                    ),
                    SizedBox(
                      width: 54,
                      child: Text(
                        '$_numeroDias',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF202322),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _CounterButton(
                      icon: Icons.add_rounded,
                      enabled: !_isSubmitting && _numeroDias < saldo,
                      onTap: () => setState(() => _numeroDias++),
                    ),
                  ],
                ),
              ),
              if (fimPrevisto != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Fim previsto: ${_dateFormat.format(fimPrevisto)}',
                  style: const TextStyle(
                    color: Color(0xFF697370),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isSubmitting || _dataInicial == null
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
      helpText: 'Data inicial',
      cancelText: 'Cancelar',
      confirmText: 'Selecionar',
    );
    if (selected != null) {
      setState(() => _dataInicial = selected);
    }
  }

  Future<void> _enviar() async {
    final dataInicial = _dataInicial;
    if (dataInicial == null) return;

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.onSubmit(widget.concessao, dataInicial, _numeroDias);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Solicitação de férias enviada.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Não foi possível marcar férias: $e')),
      );
    }
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

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: enabled ? onTap : null,
      style: IconButton.styleFrom(
        backgroundColor: enabled
            ? const Color(0xFF202322)
            : const Color(0xFFE9EDF0),
        foregroundColor: enabled ? Colors.white : const Color(0xFF9CA6A1),
        minimumSize: const Size(34, 34),
        fixedSize: const Size(34, 34),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

class _SaldoChip extends StatelessWidget {
  final int saldo;
  final Color color;

  const _SaldoChip({required this.saldo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.36)),
      ),
      child: Text(
        '$saldo dias',
        style: TextStyle(
          color: color,
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

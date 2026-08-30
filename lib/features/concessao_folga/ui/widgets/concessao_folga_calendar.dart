import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/ausencia_calendario.dart';
import '../../models/solicitacao_concessao.dart';
import '../../services/concessao_folga_service.dart';
import 'concessao_folga_theme.dart';

class RangeInfo {
  final bool inRange;
  final bool isStart;
  final bool isEnd;
  final Color color;

  const RangeInfo({
    required this.inRange,
    this.isStart = false,
    this.isEnd = false,
    this.color = Colors.transparent,
  });
}

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class ConcessaoFolgaCalendar extends StatefulWidget {
  final DateTime mes;
  final List<AusenciaCalendario> ausencias;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSelectMonth;
  final void Function(DateTime)? onNavigateToMonth;

  const ConcessaoFolgaCalendar({
    super.key,
    required this.mes,
    required this.ausencias,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
    required this.onRefresh,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectMonth,
    this.onNavigateToMonth,
  });

  @override
  State<ConcessaoFolgaCalendar> createState() => _ConcessaoFolgaCalendarState();
}

class _ConcessaoFolgaCalendarState extends State<ConcessaoFolgaCalendar> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.ausencias.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // if (widget.errorMessage != null && widget.ausencias.isEmpty) {
    //   return _ErrorState(
    //     message: widget.errorMessage!,
    //     onRetry: widget.onRetry,
    //   );
    // }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          _CalendarGrid(
            mes: widget.mes,
            ausencias: widget.ausencias,
            onPreviousMonth: widget.onPreviousMonth,
            onNextMonth: widget.onNextMonth,
            onSelectMonth: widget.onSelectMonth,
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 14),
            _InlineError(
              message: widget.errorMessage!,
              onRetry: widget.onRetry,
            ),
          ] else ...[
            _SummaryPanel(mes: widget.mes, ausencias: widget.ausencias, onSelectMonth: widget.onNavigateToMonth),
          ],
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: const Color(0xFFEDE2CF), size: 27),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar grid
// ---------------------------------------------------------------------------

class _CalendarGrid extends StatelessWidget {
  final DateTime mes;
  final List<AusenciaCalendario> ausencias;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSelectMonth;

  const _CalendarGrid({
    required this.mes,
    required this.ausencias,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectMonth,
  });

  RangeInfo _rangeInfoFor(DateTime dia) {
    if (ausencias.isEmpty) return const RangeInfo(inRange: false);

    final atual = normalizarData(dia);
    for (final ausencia in ausencias) {
      final inicio = ausencia.inicioNormalizado;
      final fim = ausencia.fimNormalizado;

      if (!atual.isBefore(inicio) && !atual.isAfter(fim)) {
        return RangeInfo(
          inRange: true,
          isStart: atual.isAtSameMomentAs(inicio) || dia.weekday == 7,
          isEnd: atual.isAtSameMomentAs(fim) || dia.weekday == 6,
          color: ausencia.tipo.color,
        );
      }
    }
    return const RangeInfo(inRange: false);
  }

  @override
  Widget build(BuildContext context) {
    final primeiroDia = DateTime(mes.year, mes.month);
    final diasNoMes = DateTime(mes.year, mes.month + 1, 0).day;
    final offset = primeiroDia.weekday % 7;
    final totalCells = ((offset + diasNoMes + 6) ~/ 7) * 7;
    final primeiroVisivel = primeiroDia.subtract(Duration(days: offset));
    const weekDays = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB'];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF241D19),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33111111)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24432B1D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                onTap: onPreviousMonth,
                tooltip: 'Mês anterior',
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onSelectMonth,
                  child: Center(
                    child: Text(
                      ConcessaoFolgaService.nomeMesAno(
                        mes,
                      ).replaceFirst(' de ', ' '),
                      style: const TextStyle(
                        color: Color(0xFFF7EFE3),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                onTap: onNextMonth,
                tooltip: 'Próximo mês',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Color(0xFF9A8D80),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: totalCells,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 1.72,
            ),
            itemBuilder: (context, index) {
              final dia = primeiroVisivel.add(Duration(days: index));
              return _DayCell(
                dia: dia,
                currentMonth: dia.year == mes.year && dia.month == mes.month,
                rangeInfo: _rangeInfoFor(dia),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day cell
// ---------------------------------------------------------------------------

class _DayCell extends StatelessWidget {
  final DateTime dia;
  final bool currentMonth;
  final RangeInfo rangeInfo;

  const _DayCell({
    required this.dia,
    required this.currentMonth,
    required this.rangeInfo,
  });

  bool get _isToday {
    final now = DateTime.now();
    return dia.year == now.year && dia.month == now.month && dia.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final isInRange = rangeInfo.inRange;
    final lineRadius = BorderRadius.horizontal(
      left: rangeInfo.isStart ? const Radius.circular(999) : Radius.zero,
      right: rangeInfo.isEnd ? const Radius.circular(999) : Radius.zero,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isInRange)
          Positioned(
            left: rangeInfo.isStart ? 12 : 0,
            right: rangeInfo.isEnd ? 12 : 0,
            bottom: 5,
            child: Container(
              height: 2.5,
              decoration: BoxDecoration(
                color: rangeInfo.color,
                borderRadius: lineRadius,
              ),
            ),
          ),
        if (_isToday)
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF8F2A1D),
              shape: BoxShape.circle,
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${dia.day}',
              style: TextStyle(
                color: _isToday
                    ? const Color(0xFFFFF8EA)
                    : currentMonth
                    ? const Color(0xFFEDE2CF)
                    : const Color(0xFF756A60),
                fontSize: 11.5,
                fontWeight: _isToday || isInRange
                    ? FontWeight.w900
                    : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Always-visible summary panel
// ---------------------------------------------------------------------------

class _SummaryPanel extends StatelessWidget {
  final DateTime mes;
  final List<AusenciaCalendario> ausencias;
  final Function(DateTime)? onSelectMonth;

  const _SummaryPanel({required this.mes, required this.ausencias, this.onSelectMonth});

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final currentMonth = DateTime(hoje.year, hoje.month);
    final isFutureMode = !mes.isBefore(currentMonth);

    // List to be rendered
    List<AusenciaCalendario> relevantes = [];

    if (isFutureMode) {
      // Future mode: Show all events starting from current month to the future
      relevantes = ausencias.where((a) {
        // Only keep events that end on or after the first day of the current month
        return !a.fimNormalizado.isBefore(currentMonth);
      }).toList();
      relevantes.sort((a, b) => a.inicioNormalizado.compareTo(b.inicioNormalizado));
    } else {
      // Historical mode: Only show events that overlap with the selected month
      final primeiroDia = DateTime(mes.year, mes.month);
      final ultimoDia = DateTime(mes.year, mes.month + 1, 0);

      relevantes = ausencias.where((a) {
        return !a.fimNormalizado.isBefore(primeiroDia) &&
            !a.inicioNormalizado.isAfter(ultimoDia);
      }).toList();
      relevantes.sort((a, b) => a.inicioNormalizado.compareTo(b.inicioNormalizado));
    }

    final String title = isFutureMode ? 'Próximos eventos' : 'Eventos de ${ConcessaoFolgaService.nomeMesAno(mes)}';
    final String emptyMessage = isFutureMode ? 'Nenhum próximo evento agendado.' : 'Nenhum evento em ${ConcessaoFolgaService.nomeMesAno(mes)}.';

    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F0E5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33936F52)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18432B1D),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Panel header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9D8C2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x33936F52)),
                  ),
                  child: const Icon(
                    Icons.list_alt_rounded,
                    size: 16,
                    color: ConcessaoFolgaColors.brand,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: ConcessaoFolgaColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (relevantes.isNotEmpty && !isFutureMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9D8C2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x33936F52)),
                    ),
                    child: Text(
                      '${relevantes.length}',
                      style: const TextStyle(
                        color: ConcessaoFolgaColors.brand,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x2673543E)),
          if (relevantes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_busy_rounded,
                    size: 18,
                    color: ConcessaoFolgaColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(
                        color: ConcessaoFolgaColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            _buildList(relevantes, isFutureMode),
        ],
      ),
    );
  }

  Widget _buildList(List<AusenciaCalendario> relevantes, bool isFutureMode) {
    if (!isFutureMode) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        itemCount: relevantes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _SummaryItem(ausencia: relevantes[index], onTap: null);
        },
      );
    }

    // Future mode requires grouping
    final groups = <String, List<AusenciaCalendario>>{};
    for (final a in relevantes) {
      // Find the month the event falls into. If it started before current month, show it in the month it ends.
      // Better: group by the month of 'dataInicio', but if 'dataInicio' < currentMonth, group by currentMonth.
      final hoje = DateTime.now();
      final currentMonth = DateTime(hoje.year, hoje.month);
      DateTime groupDate = a.inicioNormalizado;
      if (groupDate.isBefore(currentMonth)) {
        groupDate = currentMonth;
      }
      final key = '${groupDate.year}-${groupDate.month}';
      groups.putIfAbsent(key, () => []).add(a);
    }

    final List<Widget> children = [];
    final sortedKeys = groups.keys.toList()..sort((a, b) {
      final aParts = a.split('-');
      final bParts = b.split('-');
      final aYear = int.parse(aParts[0]);
      final aMonth = int.parse(aParts[1]);
      final bYear = int.parse(bParts[0]);
      final bMonth = int.parse(bParts[1]);
      if (aYear != bYear) return aYear.compareTo(bYear);
      return aMonth.compareTo(bMonth);
    });

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final items = groups[key]!;
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthName = ConcessaoFolgaService.nomeMesAno(DateTime(year, month)).toUpperCase();

      children.add(
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: i == 0 ? 12 : 20, bottom: 8),
          child: Text(
            monthName,
            style: const TextStyle(
              color: ConcessaoFolgaColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );

      for (int j = 0; j < items.length; j++) {
        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 14, j == items.length - 1 ? 0 : 8),
            child: _SummaryItem(
              ausencia: items[j], 
              onTap: onSelectMonth != null ? () {
                onSelectMonth!(DateTime(items[j].inicioNormalizado.year, items[j].inicioNormalizado.month));
              } : null,
            ),
          ),
        );
      }
    }
    
    children.add(const SizedBox(height: 14));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final AusenciaCalendario ausencia;
  final VoidCallback? onTap;

  const _SummaryItem({required this.ausencia, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    final dataInicio = ausencia.dataInicio;
    final dataFim = ausencia.dataFim;

    final sameDay =
        dataInicio.year == dataFim.year &&
        dataInicio.month == dataFim.month &&
        dataInicio.day == dataFim.day;
    final duracao = dataFim.difference(dataInicio).inDays + 1;
    final eventColor = ausencia.tipo.color;
    final cardColor = Color.lerp(const Color(0xFFFFF8EA), eventColor, 0.18)!;
    final cardBorder = Color.lerp(cardColor, eventColor, 0.38)!;
    final chipColor = Color.lerp(const Color(0xFFFFF8EA), eventColor, 0.10)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: eventColor.withAlpha(24),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: eventColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ausencia.descricao,
                      style: const TextStyle(
                        color: ConcessaoFolgaColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sameDay
                          ? dateFormat.format(dataInicio)
                          : '${dateFormat.format(dataInicio)} a ${dateFormat.format(dataFim)}',
                      style: TextStyle(
                        color: eventColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (ausencia.status?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        ausencia.status!,
                        style: const TextStyle(
                          color: ConcessaoFolgaColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: eventColor,
                  ),
                )
              else
                const SizedBox(width: 8),
              if (onTap == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: eventColor.withAlpha(170)),
                  ),
                  child: Text(
                    duracao == 1 ? '1 dia' : '$duracao dias',
                    style: TextStyle(
                      color: eventColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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

// ---------------------------------------------------------------------------
// Error states
// ---------------------------------------------------------------------------

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
    return OutlinedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(message, textAlign: TextAlign.center),
    );
  }
}

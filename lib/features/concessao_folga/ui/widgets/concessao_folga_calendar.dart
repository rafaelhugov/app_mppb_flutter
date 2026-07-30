import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/ausencia_calendario.dart';
import '../../models/solicitacao_concessao.dart';
import '../../services/concessao_folga_service.dart';
import 'concessao_folga_legend.dart';
import 'concessao_folga_theme.dart';

// ---------------------------------------------------------------------------
// Range info for each day cell
// ---------------------------------------------------------------------------

class _RangeInfo {
  final bool inRange;
  final bool isStart;
  final bool isEnd;
  final Color color;

  const _RangeInfo({
    required this.inRange,
    required this.isStart,
    required this.isEnd,
    required this.color,
  });

  static const none = _RangeInfo(
    inRange: false,
    isStart: false,
    isEnd: false,
    color: Colors.transparent,
  );
}

// ---------------------------------------------------------------------------
// Public widget — StatelessWidget (no day selection needed)
// ---------------------------------------------------------------------------

class ConcessaoFolgaCalendar extends StatelessWidget {
  final DateTime mes;
  final List<AusenciaCalendario> ausencias;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSelectMonth;

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
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && ausencias.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && ausencias.isEmpty) {
      return _ErrorState(message: errorMessage!, onRetry: onRetry);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          _MonthHeader(
            mes: mes,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onSelectMonth: onSelectMonth,
          ),
          const SizedBox(height: 14),
          const ConcessaoFolgaLegend(),
          const SizedBox(height: 14),
          _CalendarGrid(mes: mes, ausencias: ausencias),
          const SizedBox(height: 14),
          // Always-visible monthly summary
          _MonthSummaryPanel(mes: mes, ausencias: ausencias),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _InlineError(message: errorMessage!, onRetry: onRetry),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month navigation header
// ---------------------------------------------------------------------------

class _MonthHeader extends StatelessWidget {
  final DateTime mes;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSelectMonth;

  const _MonthHeader({
    required this.mes,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x269C7A54)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPreviousMonth,
            tooltip: 'Mês anterior',
          ),
          Expanded(
            child: GestureDetector(
              onTap: onSelectMonth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ConcessaoFolgaService.nomeMesAno(mes)
                        .split(' ')
                        .first
                        .toUpperCase(),
                    style: const TextStyle(
                      color: ConcessaoFolgaColors.brand,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    ConcessaoFolgaService.nomeMesAno(mes).split(' ').last,
                    style: const TextStyle(
                      color: ConcessaoFolgaColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E8D9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ConcessaoFolgaColors.brand, size: 22),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar grid — computes range info per day for highlighter effect
// ---------------------------------------------------------------------------

class _CalendarGrid extends StatelessWidget {
  final DateTime mes;
  final List<AusenciaCalendario> ausencias;

  const _CalendarGrid({required this.mes, required this.ausencias});

  /// Compute highlighter range info for a specific day.
  /// [column] is 0=Sunday … 6=Saturday (column position in the grid row).
  _RangeInfo _rangeInfoFor(
    DateTime dia,
    int column,
    bool isLastDayOfMonth,
  ) {
    final normalized = normalizarData(dia);

    for (final ausencia in ausencias) {
      if (!normalized.isBefore(ausencia.inicioNormalizado) &&
          !normalized.isAfter(ausencia.fimNormalizado)) {
        // Day is within this ausencia's range
        final isStart =
            normalized == ausencia.inicioNormalizado || column == 0;
        final isEnd = normalized == ausencia.fimNormalizado ||
            column == 6 ||
            isLastDayOfMonth;
        return _RangeInfo(
          inRange: true,
          isStart: isStart,
          isEnd: isEnd,
          color: ausencia.tipo.color,
        );
      }
    }
    return _RangeInfo.none;
  }

  @override
  Widget build(BuildContext context) {
    final primeiroDia = DateTime(mes.year, mes.month);
    final diasNoMes = DateTime(mes.year, mes.month + 1, 0).day;
    final offset = primeiroDia.weekday % 7;
    final totalCells = ((offset + diasNoMes + 6) ~/ 7) * 7;
    const weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x269C7A54)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Week day labels row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1E8D9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: weekDays
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: ConcessaoFolgaColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            itemCount: totalCells,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0, // zero gap — highlight band must not be cut
              crossAxisSpacing: 0,
              childAspectRatio: 1.7, // slim rows
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - offset + 1;
              if (dayNumber < 1 || dayNumber > diasNoMes) {
                return const SizedBox.shrink();
              }
              final dia = DateTime(mes.year, mes.month, dayNumber);
              final column = index % 7;
              final isLastDayOfMonth = dayNumber == diasNoMes;
              final rangeInfo = _rangeInfoFor(dia, column, isLastDayOfMonth);

              return _DayCell(dia: dia, rangeInfo: rangeInfo);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day cell — highlighter style
// ---------------------------------------------------------------------------

class _DayCell extends StatelessWidget {
  final DateTime dia;
  final _RangeInfo rangeInfo;

  const _DayCell({required this.dia, required this.rangeInfo});

  bool get _isToday {
    final now = DateTime.now();
    return dia.year == now.year && dia.month == now.month && dia.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final isInRange = rangeInfo.inRange;

    // Highlight border radius — only on the ends of the range
    BorderRadius highlightRadius;
    if (isInRange) {
      if (rangeInfo.isStart && rangeInfo.isEnd) {
        highlightRadius = BorderRadius.circular(8);
      } else if (rangeInfo.isStart) {
        highlightRadius = const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        );
      } else if (rangeInfo.isEnd) {
        highlightRadius = const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
      } else {
        highlightRadius = BorderRadius.zero;
      }
    } else {
      highlightRadius = BorderRadius.zero;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Highlight band — fills left-right, 2px inset top/bottom for subtle row separation
        if (isInRange)
          Positioned(
            left: 0,
            right: 0,
            top: 2,
            bottom: 2,
            child: Container(
              decoration: BoxDecoration(
                color: rangeInfo.color.withAlpha(50),
                borderRadius: highlightRadius,
              ),
            ),
          ),
        // Today circle
        if (_isToday)
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: ConcessaoFolgaColors.brand,
              shape: BoxShape.circle,
            ),
          ),
        // Day number
        Text(
          '${dia.day}',
          style: TextStyle(
            color: _isToday
                ? Colors.white
                : isInRange
                    ? rangeInfo.color
                    : ConcessaoFolgaColors.ink,
            fontSize: 12,
            fontWeight:
                (isInRange || _isToday) ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Always-visible monthly summary panel
// ---------------------------------------------------------------------------

class _MonthSummaryPanel extends StatelessWidget {
  final DateTime mes;
  final List<AusenciaCalendario> ausencias;

  const _MonthSummaryPanel({required this.mes, required this.ausencias});

  @override
  Widget build(BuildContext context) {
    // Filter to ausencias that intersect this month, sorted by start date
    final relevantes = ausencias
        .where((a) => a.intersectaMes(mes))
        .toList()
      ..sort((a, b) => a.inicioNormalizado.compareTo(b.inicioNormalizado));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x269C7A54)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 3),
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
                    color: const Color(0xFFF1E8D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.list_alt_rounded,
                    size: 16,
                    color: ConcessaoFolgaColors.brand,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Eventos do mês',
                  style: TextStyle(
                    color: ConcessaoFolgaColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                if (relevantes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E8D9),
                      borderRadius: BorderRadius.circular(20),
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
          const Divider(height: 1, color: Color(0x1A9C7A54)),
          if (relevantes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 18,
                    color: ConcessaoFolgaColors.muted,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Nenhum evento neste mês',
                    style: TextStyle(
                      color: ConcessaoFolgaColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              itemCount: relevantes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _SummaryItem(ausencia: relevantes[index], mes: mes);
              },
            ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final AusenciaCalendario ausencia;
  final DateTime mes;

  const _SummaryItem({required this.ausencia, required this.mes});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM');
    final fmtFull = DateFormat('dd/MM/yyyy');

    // Clamp dates to the current month for display
    final primeiroDia = DateTime(mes.year, mes.month);
    final ultimoDia = DateTime(mes.year, mes.month + 1, 0);

    final inicioDisplay = ausencia.inicioNormalizado.isBefore(primeiroDia)
        ? primeiroDia
        : ausencia.inicioNormalizado;
    final fimDisplay = ausencia.fimNormalizado.isAfter(ultimoDia)
        ? ultimoDia
        : ausencia.fimNormalizado;

    final sameDay = inicioDisplay == fimDisplay;

    // Duration in days (within this month)
    final duracao = fimDisplay.difference(inicioDisplay).inDays + 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ausencia.tipo.color.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: ausencia.tipo.color, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color dot
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: ausencia.tipo.color,
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
                      ? fmtFull.format(inicioDisplay)
                      : '${fmt.format(inicioDisplay)} → ${fmt.format(fimDisplay)}',
                  style: TextStyle(
                    color: ausencia.tipo.color.withAlpha(200),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Duration badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: ausencia.tipo.color.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              duracao == 1 ? '1 dia' : '$duracao dias',
              style: TextStyle(
                color: ausencia.tipo.color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error / Empty states (unchanged)
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

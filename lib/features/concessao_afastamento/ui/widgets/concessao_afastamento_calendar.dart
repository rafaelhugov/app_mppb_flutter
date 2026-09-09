import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/ui/main_layout.dart';
import '../../../../../core/ui/responsive_layout.dart';
import '../../models/ausencia_calendario.dart';
import '../../models/solicitacao_concessao.dart';
import '../../services/concessao_afastamento_service.dart';
import 'concessao_afastamento_theme.dart';

class RangeInfo {
  final bool inRange;
  final bool isStart;
  final bool isEnd;
  final bool outlined;
  final Color color;

  const RangeInfo({
    required this.inRange,
    this.isStart = false,
    this.isEnd = false,
    this.outlined = false,
    this.color = Colors.transparent,
  });
}

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class ConcessaoAfastamentoCalendar extends StatefulWidget {
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

  const ConcessaoAfastamentoCalendar({
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
  State<ConcessaoAfastamentoCalendar> createState() =>
      _ConcessaoAfastamentoCalendarState();
}

class _ConcessaoAfastamentoCalendarState
    extends State<ConcessaoAfastamentoCalendar> {
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

    final responsive = MppbResponsive.of(context);
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final contentMaxWidth = responsive.usesWideLayout
        ? 980.0
        : MainLayout.contentMaxWidth(context);

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
          if (responsive.isTablet && responsive.isLandscape)
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _CalendarGrid(
                        mes: widget.mes,
                        ausencias: widget.ausencias,
                        onPreviousMonth: widget.onPreviousMonth,
                        onNextMonth: widget.onNextMonth,
                        onSelectMonth: widget.onSelectMonth,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    if (widget.errorMessage != null)
                      Expanded(
                        flex: 6,
                        child: _InlineError(
                          message: widget.errorMessage!,
                          onRetry: widget.onRetry,
                        ),
                      )
                    else
                      Expanded(
                        flex: 6,
                        child: _SummaryPanel(
                          mes: widget.mes,
                          ausencias: widget.ausencias,
                          onSelectMonth: widget.onNavigateToMonth,
                          inline: true,
                        ),
                      ),
                  ],
                ),
              ),
            )
          else ...[
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: _CalendarGrid(
                  mes: widget.mes,
                  ausencias: widget.ausencias,
                  onPreviousMonth: widget.onPreviousMonth,
                  onNextMonth: widget.onNextMonth,
                  onSelectMonth: widget.onSelectMonth,
                ),
              ),
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 14),
              _InlineError(
                message: widget.errorMessage!,
                onRetry: widget.onRetry,
              ),
            ] else ...[
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: _SummaryPanel(
                    mes: widget.mes,
                    ausencias: widget.ausencias,
                    onSelectMonth: widget.onNavigateToMonth,
                  ),
                ),
              ),
            ],
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
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, color: const Color(0xFF202322), size: 22),
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
  final bool compact;

  const _CalendarGrid({
    required this.mes,
    required this.ausencias,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectMonth,
    this.compact = false,
  });

  RangeInfo _rangeInfoFor(DateTime dia) {
    if (ausencias.isEmpty) return const RangeInfo(inRange: false);

    final atual = normalizarData(dia);
    final today = normalizarData(DateTime.now());
    for (final ausencia in ausencias) {
      final inicio = ausencia.inicioNormalizado;
      final fim = ausencia.fimNormalizado;

      if (!atual.isBefore(inicio) && !atual.isAfter(fim)) {
        final outlined = !atual.isAfter(today);
        final previousDay = atual.subtract(const Duration(days: 1));
        final nextDay = atual.add(const Duration(days: 1));
        final previousInSameStyle = _dayHasSameRangeStyle(
          previousDay,
          inicio: inicio,
          fim: fim,
          today: today,
          outlined: outlined,
        );
        final nextInSameStyle = _dayHasSameRangeStyle(
          nextDay,
          inicio: inicio,
          fim: fim,
          today: today,
          outlined: outlined,
        );

        return RangeInfo(
          inRange: true,
          isStart: !previousInSameStyle || dia.weekday == 7,
          isEnd: !nextInSameStyle || dia.weekday == 6,
          outlined: outlined,
          color: ausencia.tipo.color,
        );
      }
    }
    return const RangeInfo(inRange: false);
  }

  bool _dayHasSameRangeStyle(
    DateTime dia, {
    required DateTime inicio,
    required DateTime fim,
    required DateTime today,
    required bool outlined,
  }) {
    final isInRange = !dia.isBefore(inicio) && !dia.isAfter(fim);
    if (!isInRange) return false;
    return !dia.isAfter(today) == outlined;
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
      padding: EdgeInsets.fromLTRB(14, compact ? 10 : 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x26343A40)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14101828),
            blurRadius: 18,
            offset: Offset(0, 8),
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
                      ConcessaoAfastamentoService.nomeMesAno(
                        mes,
                      ).replaceFirst(' de ', ' '),
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
          SizedBox(height: compact ? 8 : 12),
          Row(
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Color(0xFF697370),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: compact ? 4 : 6),
          GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: totalCells,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: compact ? 1.46 : 1.72,
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
    final isOutlined = isInRange && rangeInfo.outlined;
    final highlightRadius = BorderRadius.horizontal(
      left: rangeInfo.isStart ? const Radius.circular(999) : Radius.zero,
      right: rangeInfo.isEnd ? const Radius.circular(999) : Radius.zero,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isInRange)
          Positioned(
            left: rangeInfo.isStart ? 4 : -1,
            right: rangeInfo.isEnd ? 4 : -1,
            top: 2,
            bottom: 4,
            child: isOutlined
                ? CustomPaint(
                    painter: _OutlinedRangePainter(
                      color: rangeInfo.color,
                      isStart: rangeInfo.isStart,
                      isEnd: rangeInfo.isEnd,
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: rangeInfo.color,
                      borderRadius: highlightRadius,
                    ),
                  ),
          ),
        if (_isToday && !isOutlined)
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFD62828),
              shape: BoxShape.circle,
            ),
          ),
        if (_isToday && isOutlined)
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD62828), width: 2),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${dia.day}',
              style: TextStyle(
                color: _isToday
                    ? isOutlined
                          ? const Color(0xFFD62828)
                          : Colors.white
                    : isInRange
                    ? isOutlined
                          ? rangeInfo.color
                          : rangeInfo.color.computeLuminance() > 0.45
                          ? const Color(0xFF202322)
                          : Colors.white
                    : currentMonth
                    ? const Color(0xFF202322)
                    : const Color(0xFFB2BAB8),
                fontSize: 11.5,
                fontWeight: _isToday || isInRange
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ],
    );
  }
}

class _OutlinedRangePainter extends CustomPainter {
  final Color color;
  final bool isStart;
  final bool isEnd;

  const _OutlinedRangePainter({
    required this.color,
    required this.isStart,
    required this.isEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final left = 1.1;
    final top = 1.1;
    final right = size.width - 1.1;
    final bottom = size.height - 1.1;
    final radius = (bottom - top) / 2;

    if (isStart && isEnd) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, top, right, bottom),
          Radius.circular(radius),
        ),
        paint,
      );
      return;
    }

    final topStart = isStart ? left + radius : left;
    final topEnd = isEnd ? right - radius : right;
    final bottomStart = isStart ? left + radius : left;
    final bottomEnd = isEnd ? right - radius : right;

    canvas.drawLine(Offset(topStart, top), Offset(topEnd, top), paint);
    canvas.drawLine(
      Offset(bottomStart, bottom),
      Offset(bottomEnd, bottom),
      paint,
    );

    if (isStart) {
      canvas.drawArc(
        Rect.fromLTWH(left, top, radius * 2, radius * 2),
        pi / 2,
        pi,
        false,
        paint,
      );
    }

    if (isEnd) {
      canvas.drawArc(
        Rect.fromLTWH(right - radius * 2, top, radius * 2, radius * 2),
        -pi / 2,
        pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OutlinedRangePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isStart != isStart ||
        oldDelegate.isEnd != isEnd;
  }
}

// ---------------------------------------------------------------------------
// Always-visible summary panel
// ---------------------------------------------------------------------------

class _SummaryPanel extends StatelessWidget {
  final DateTime mes;
  final List<AusenciaCalendario> ausencias;
  final Function(DateTime)? onSelectMonth;
  final bool inline;

  const _SummaryPanel({
    required this.mes,
    required this.ausencias,
    this.onSelectMonth,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final today = normalizarData(DateTime.now());
    final selectedStart = DateTime(mes.year, mes.month);
    final selectedEnd = DateTime(mes.year, mes.month + 1, 0);
    final currentMonth = DateTime(today.year, today.month);
    final isCurrentMonth = selectedStart == currentMonth;

    final eventsInMonth = ausencias.where((a) => a.intersectaMes(mes)).toList()
      ..sort((a, b) => a.inicioNormalizado.compareTo(b.inicioNormalizado));

    final previousInCurrentMonth = isCurrentMonth
        ? eventsInMonth.where((a) => a.fimNormalizado.isBefore(today)).toList()
        : <AusenciaCalendario>[];
    final activeMonthEvents = isCurrentMonth
        ? eventsInMonth.where((a) => !a.fimNormalizado.isBefore(today)).toList()
        : eventsInMonth;
    final upcomingEvents =
        ausencias
            .where((a) => a.inicioNormalizado.isAfter(selectedEnd))
            .toList()
          ..sort((a, b) => a.inicioNormalizado.compareTo(b.inicioNormalizado));

    final sections = <Widget>[
      if (previousInCurrentMonth.isNotEmpty)
        _EventSectionCard(
          title: 'Eventos anteriores',
          icon: Icons.history_rounded,
          events: previousInCurrentMonth,
          emptyMessage: '',
          onSelectMonth: null,
        ),
      _EventSectionCard(
        title: 'Eventos do mês',
        icon: Icons.event_available_rounded,
        events: activeMonthEvents,
        emptyMessage:
            'Nenhum evento em ${ConcessaoAfastamentoService.nomeMesAno(mes)}.',
        onSelectMonth: null,
      ),
      _EventSectionCard(
        title: 'Próximos eventos',
        icon: Icons.list_alt_rounded,
        events: upcomingEvents,
        emptyMessage: 'Nenhum próximo evento agendado.',
        onSelectMonth: onSelectMonth,
        groupedByMonth: true,
      ),
    ];

    final responsive = MppbResponsive.of(context);
    if (inline && responsive.isTablet && responsive.isLandscape) {
      final visibleSections = sections.length > 2
          ? sections.sublist(sections.length - 2)
          : sections;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < visibleSections.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: visibleSections[i]),
          ],
        ],
      );
    }

    if (responsive.usesWideLayout && sections.length > 1) {
      final firstSection = sections.first;
      final remainingSections = sections.skip(1).toList();

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          if (sections.length == 2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: firstSection),
                const SizedBox(width: 14),
                Expanded(child: remainingSections.first),
              ],
            )
          else ...[
            firstSection,
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < remainingSections.length; i++) ...[
                  if (i > 0) const SizedBox(width: 14),
                  Expanded(child: remainingSections[i]),
                ],
              ],
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < sections.length; i++) ...[
          if (i == 0)
            const SizedBox(height: 14)
          else
            const SizedBox(height: 12),
          sections[i],
        ],
      ],
    );
  }
}

class _EventSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<AusenciaCalendario> events;
  final String emptyMessage;
  final Function(DateTime)? onSelectMonth;
  final bool groupedByMonth;

  const _EventSectionCard({
    required this.title,
    required this.icon,
    required this.events,
    required this.emptyMessage,
    required this.onSelectMonth,
    this.groupedByMonth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x26343A40)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14101828),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x26343A40)),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: ConcessaoAfastamentoColors.brand,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: ConcessaoAfastamentoColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (events.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x26343A40)),
                    ),
                    child: Text(
                      '${events.length}',
                      style: const TextStyle(
                        color: ConcessaoAfastamentoColors.brand,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x20343A40)),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_busy_rounded,
                    size: 18,
                    color: ConcessaoAfastamentoColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(
                        color: ConcessaoAfastamentoColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (groupedByMonth)
            _buildGroupedList(events)
          else
            _buildPlainList(events),
        ],
      ),
    );
  }

  Widget _buildPlainList(List<AusenciaCalendario> relevantes) {
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

  Widget _buildGroupedList(List<AusenciaCalendario> relevantes) {
    final groups = <String, List<AusenciaCalendario>>{};
    for (final a in relevantes) {
      DateTime groupDate = a.inicioNormalizado;
      final key = '${groupDate.year}-${groupDate.month}';
      groups.putIfAbsent(key, () => []).add(a);
    }

    final List<Widget> children = [];
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) {
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
      final monthName = ConcessaoAfastamentoService.nomeMesAno(
        DateTime(year, month),
      ).toUpperCase();

      children.add(
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: i == 0 ? 12 : 20,
            bottom: 8,
          ),
          child: Text(
            monthName,
            style: const TextStyle(
              color: ConcessaoAfastamentoColors.muted,
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
            padding: EdgeInsets.fromLTRB(
              14,
              0,
              14,
              j == items.length - 1 ? 0 : 8,
            ),
            child: _SummaryItem(
              ausencia: items[j],
              onTap: onSelectMonth != null
                  ? () {
                      onSelectMonth!(
                        DateTime(
                          items[j].inicioNormalizado.year,
                          items[j].inicioNormalizado.month,
                        ),
                      );
                    }
                  : null,
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
    final onColor = eventColor.computeLuminance() > 0.45
        ? const Color(0xFF202322)
        : Colors.white;
    final secondaryColor = eventColor.computeLuminance() > 0.45
        ? const Color(0xD9202322)
        : const Color(0xE6FFFFFF);
    final chipColor = Colors.white.withValues(alpha: 0.18);
    final chipBorder = Colors.white.withValues(alpha: 0.36);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: eventColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: eventColor.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 8),
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
                    color: onColor,
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
                      style: TextStyle(
                        color: onColor,
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
                        color: onColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (ausencia.status?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        ausencia.status!,
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: Icon(Icons.chevron_right, size: 20, color: onColor),
                )
              else
                const SizedBox(width: 8),
              if (onTap == null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: chipBorder),
                  ),
                  child: Text(
                    duracao == 1 ? '1 dia' : '$duracao dias',
                    style: TextStyle(
                      color: onColor,
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

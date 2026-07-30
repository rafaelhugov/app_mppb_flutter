import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/concessao_folga_provider.dart';
import '../services/concessao_folga_service.dart';
import 'widgets/concessao_folga_calendar.dart';
import 'widgets/concessao_folga_theme.dart';
import 'widgets/concessoes_vigentes_list.dart';

class ConcessaoFolgaPage extends ConsumerWidget {
  const ConcessaoFolgaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(concessaoFolgaProvider);
    final notifier = ref.read(concessaoFolgaProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFDED4C5),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(child: _Header(state: state)),
            const SliverPersistentHeader(
              pinned: true,
              delegate: _TabsHeaderDelegate(),
            ),
          ],
          body: TabBarView(
            children: [
              ConcessaoFolgaCalendar(
                mes: state.mesSelecionado,
                ausencias: state.calendario.ausencias,
                isLoading: state.calendario.isLoading,
                errorMessage: state.calendario.errorMessage,
                onRetry: () => notifier.carregarAusencias(forceRefresh: true),
                onRefresh: () => notifier.carregarAusencias(forceRefresh: true),
                onPreviousMonth: () => notifier.mudarMes(-1),
                onNextMonth: () => notifier.mudarMes(1),
                onSelectMonth: () =>
                    _selecionarMesAno(context, notifier, state.mesSelecionado),
              ),
              ConcessoesVigentesList(
                concessoes: state.concessoes.concessoes,
                isLoading: state.concessoes.isLoading,
                errorMessage: state.concessoes.errorMessage,
                onRetry: () => notifier.carregarConcessoes(forceRefresh: true),
                onRefresh: () =>
                    notifier.carregarConcessoes(forceRefresh: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarMesAno(
    BuildContext context,
    ConcessaoFolgaNotifier notifier,
    DateTime selecionado,
  ) async {
    final result = await showDatePicker(
      context: context,
      initialDate: selecionado,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Selecionar mês',
    );
    if (result != null) {
      await notifier.selecionarMesAno(result.month, result.year);
    }
  }
}

class _Header extends StatelessWidget {
  final ConcessaoFolgaState state;

  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 34),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x3DD6A92F), width: 1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF241D19), Color(0xFF3A241D), Color(0xFF8F2A1D)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE5B84C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available,
              color: Color(0xFF211713),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MINISTÉRIO PÚBLICO DA PARAÍBA',
                  style: TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Concessão de Folga',
                  style: TextStyle(
                    color: Color(0xFFFFF8EA),
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ConcessaoFolgaService.nomeMesAno(state.mesSelecionado),
                  style: const TextStyle(
                    color: Color(0xFFD8C5AA),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabsHeaderDelegate();

  @override
  double get minExtent => 82;

  @override
  double get maxExtent => 82;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F0E5),
        border: Border(bottom: BorderSide(color: Color(0x1F73543E))),
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE1D1),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0x26936F52)),
        ),
        child: TabBar(
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFFFFF8EA),
          unselectedLabelColor: ConcessaoFolgaColors.muted,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          indicator: BoxDecoration(
            color: ConcessaoFolgaColors.brand,
            borderRadius: BorderRadius.circular(13),
            boxShadow: const [
              BoxShadow(
                color: Color(0x268F2A1D),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          tabs: const [
            Tab(
              height: 46,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month, size: 18),
                    SizedBox(width: 8),
                    Text('Calendário'),
                  ],
                ),
              ),
            ),
            Tab(
              height: 46,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Concessões'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) => false;
}

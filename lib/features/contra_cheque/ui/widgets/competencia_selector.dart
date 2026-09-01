import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/contra_cheque.dart';
import '../../providers/contra_cheque_provider.dart';

class CompetenciaSelector extends ConsumerWidget {
  const CompetenciaSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contraChequeProvider);
    final selected = state.competenciaSelecionada;

    if (selected == null) return const SizedBox.shrink();

    final dateRef = DateTime(selected.ano, selected.mes);
    final monthName = DateFormat.MMMM('pt_BR').format(dateRef);
    final mesCapitalized =
        '${monthName[0].toUpperCase()}${monthName.substring(1)}';

    final currentIndex = state.competencias.indexOf(selected);
    final hasOlder = currentIndex < state.competencias.length - 1;
    final hasNewer = currentIndex > 0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF202322),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A101828),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 3, 5, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNavButton(
                      icon: Icons.chevron_left_rounded,
                      enabled: hasOlder,
                      onTap: () {
                        ref
                            .read(contraChequeProvider.notifier)
                            .selecionarMesAnterior();
                      },
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 200,
                      child: InkWell(
                        onTap: () => _showCompetenciaModal(context, ref, state),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 10,
                                  color: Color(0xFFF4F7F4),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'MÊS DE REFERÊNCIA',
                                  style: TextStyle(
                                    color: Color(0xFFDDE4DF),
                                    fontSize: 7,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$mesCapitalized ${selected.ano}',
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildNavButton(
                      icon: Icons.chevron_right_rounded,
                      enabled: hasNewer,
                      onTap: () {
                        ref
                            .read(contraChequeProvider.notifier)
                            .selecionarProximoMes();
                      },
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

  Widget _buildNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFF1F3F5) : const Color(0x33F1F3F5),
            shape: BoxShape.circle,
            border: Border.all(
              color: enabled
                  ? const Color(0xFFD7DEDA)
                  : const Color(0x44D7DEDA),
            ),
          ),
          child: Icon(
            icon,
            color: enabled ? const Color(0xFF202322) : const Color(0x77FFFFFF),
            size: 16,
          ),
        ),
      ),
    );
  }

  void _showCompetenciaModal(
    BuildContext context,
    WidgetRef ref,
    ContraChequeState state,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CompetenciaModal(state: state, ref: ref);
      },
    );
  }
}

class _CompetenciaModal extends StatefulWidget {
  final ContraChequeState state;
  final WidgetRef ref;

  const _CompetenciaModal({required this.state, required this.ref});

  @override
  State<_CompetenciaModal> createState() => _CompetenciaModalState();
}

class _CompetenciaModalState extends State<_CompetenciaModal> {
  late int selectedYear;
  late Map<int, List<Competencia>> byYear;
  late List<int> sortedYears;

  @override
  void initState() {
    super.initState();
    byYear = {};
    for (var c in widget.state.competencias) {
      if (!byYear.containsKey(c.ano)) {
        byYear[c.ano] = [];
      }
      byYear[c.ano]!.add(c);
    }
    sortedYears = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

    selectedYear =
        widget.state.competenciaSelecionada?.ano ??
        (sortedYears.isNotEmpty ? sortedYears.first : DateTime.now().year);
  }

  @override
  Widget build(BuildContext context) {
    final mesesNomes = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Selecionar Competência',
                style: TextStyle(
                  color: Color(0xFF202322),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EDF0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF202322),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (sortedYears.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9EDF0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedYear,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF202322),
                  ),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedYear = newValue;
                      });
                    }
                  },
                  items: sortedYears.map<DropdownMenuItem<int>>((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.0,
            ),
            itemCount: 12,
            itemBuilder: (ctx, idx) {
              final mes = idx + 1;
              final String mesLabel = mesesNomes[idx];

              final isAvailable =
                  byYear[selectedYear]?.any((c) => c.mes == mes) ?? false;
              final isSelected =
                  widget.state.competenciaSelecionada?.ano == selectedYear &&
                  widget.state.competenciaSelecionada?.mes == mes;

              Color bgColor = Colors.white;
              Color textColor = const Color(0xFFB0B8B4);
              FontWeight fontWeight = FontWeight.w600;
              Border? border = Border.all(color: const Color(0xFFE9EDF0));

              if (isSelected) {
                bgColor = const Color(0xFFD62828);
                textColor = Colors.white;
                fontWeight = FontWeight.w800;
                border = null;
              } else if (isAvailable) {
                textColor = const Color(0xFF202322);
                fontWeight = FontWeight.w800;
              }

              return InkWell(
                onTap: isAvailable
                    ? () {
                        widget.ref
                            .read(contraChequeProvider.notifier)
                            .buscarContracheque(
                              Competencia(mes: mes, ano: selectedYear),
                            );
                        Navigator.pop(context);
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: border,
                  ),
                  child: Text(
                    mesLabel,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: fontWeight,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF4).withAlpha(242),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x66FFFFFF), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x263A241D),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color(0x99FFFFFF),
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Expanded(
                child: InkWell(
                  onTap: () => _showCompetenciaModal(context, ref, state),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.calendar_today,
                              size: 13,
                              color: Color(0xFF8F2A1D),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'MÊS DE REFERÊNCIA',
                              style: TextStyle(
                                color: Color(0xFF8F6A4A),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$mesCapitalized ${selected.ano}',
                          style: const TextStyle(
                            color: Color(0xFF2F2923),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: enabled ? const Color(0xFF73543E) : const Color(0x4773543E),
            size: 22,
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CompetenciaModal(state: state, ref: ref);
      },
    );
  }
}

class _CompetenciaModal extends StatelessWidget {
  final ContraChequeState state;
  final WidgetRef ref;

  const _CompetenciaModal({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    // Agrupar competências por ano
    final Map<int, List<Competencia>> byYear = {};
    for (var c in state.competencias) {
      if (!byYear.containsKey(c.ano)) {
        byYear[c.ano] = [];
      }
      byYear[c.ano]!.add(c);
    }
    final sortedYears = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

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
        color: Color(0xFFFFFBF4),
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
                  color: Color(0xFF2F2923),
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
                    color: const Color(0xFFF1EBE1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF5A4434),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...sortedYears.map((year) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F2A1D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    year.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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

                    final isAvailable = byYear[year]!.any((c) => c.mes == mes);
                    final isSelected =
                        state.competenciaSelecionada?.ano == year &&
                        state.competenciaSelecionada?.mes == mes;

                    Color bgColor = const Color(0xFFF6EFE6);
                    Color textColor = const Color(0xFFC4B8A9);
                    FontWeight fontWeight = FontWeight.w600;

                    if (isSelected) {
                      bgColor = const Color(0xFF8F2A1D);
                      textColor = Colors.white;
                      fontWeight = FontWeight.w800;
                    } else if (isAvailable) {
                      textColor = const Color(0xFF5A4434);
                      fontWeight = FontWeight.w800;
                    }

                    return InkWell(
                      onTap: isAvailable
                          ? () {
                              ref
                                  .read(contraChequeProvider.notifier)
                                  .buscarContracheque(
                                    Competencia(mes: mes, ano: year),
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
                const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }
}

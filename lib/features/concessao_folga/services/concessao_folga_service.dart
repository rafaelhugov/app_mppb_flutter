import '../models/ausencia_calendario.dart';
import '../models/solicitacao_concessao.dart';

class ConcessaoFolgaService {
  static Map<DateTime, List<AusenciaCalendario>> agruparAusenciasPorDia(
    List<AusenciaCalendario> ausencias,
    DateTime mes,
  ) {
    final primeiroDia = DateTime(mes.year, mes.month);
    final ultimoDia = DateTime(mes.year, mes.month + 1, 0);
    final eventos = <DateTime, List<AusenciaCalendario>>{};

    for (final ausencia in ausencias) {
      if (!ausencia.periodoValido || !ausencia.intersectaMes(mes)) continue;
      final inicio = ausencia.inicioNormalizado.isBefore(primeiroDia)
          ? primeiroDia
          : ausencia.inicioNormalizado;
      final fim = ausencia.fimNormalizado.isAfter(ultimoDia)
          ? ultimoDia
          : ausencia.fimNormalizado;
      for (
        var dia = inicio;
        !dia.isAfter(fim);
        dia = dia.add(const Duration(days: 1))
      ) {
        final key = normalizarData(dia);
        eventos.putIfAbsent(key, () => []).add(ausencia);
      }
    }

    return eventos;
  }

  static String nomeMesAno(DateTime mes) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${meses[mes.month - 1]} de ${mes.year}';
  }
}

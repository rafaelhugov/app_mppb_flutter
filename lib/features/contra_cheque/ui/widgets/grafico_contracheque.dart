import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/providers/privacy_provider.dart';

class GraficoContracheque extends ConsumerWidget {
  final double totalVantagens;
  final double totalDescontos;
  final double salarioLiquido;

  const GraficoContracheque({
    super.key,
    required this.totalVantagens,
    required this.totalDescontos,
    required this.salarioLiquido,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isPrivacyEnabled = ref.watch(privacyProvider);
    
    int percentDescontos = 0;
    if (totalVantagens > 0) {
      percentDescontos = ((totalDescontos / totalVantagens) * 100).round();
    }
    final int percentLiquido = totalVantagens <= 0 ? 100 : 100 - percentDescontos;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6A92F).withOpacity(0.24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1E16).withOpacity(0.20),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E2722),
            Color(0xFF201A16),
            Color(0xFF3A241D),
          ],
          stops: [0.0, 0.54, 1.0],
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildChartRow(currencyFormatter, percentDescontos, percentLiquido, isPrivacyEnabled),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VISÃO GERAL',
                style: TextStyle(
                  color: Color(0xFFE3C474),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Composição do mês',
                style: TextStyle(
                  color: Color(0xFFFFF8EA),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Valores consolidados do contracheque',
                style: TextStyle(
                  color: Color(0xFFD8C5AA),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE5B84C),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.account_balance_wallet, color: Color(0xFF241D19), size: 28),
        ),
      ],
    );
  }

  Widget _buildChartRow(NumberFormat formatter, int pDescontos, int pLiquido, bool isPrivacyEnabled) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            _buildDonutChart(formatter, isPrivacyEnabled),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildLegendCard('Líquido', salarioLiquido, pLiquido, const Color(0xFF3F7A4A), formatter, isPrivacyEnabled)),
                const SizedBox(width: 10),
                Expanded(child: _buildLegendCard('Descontos', totalDescontos, pDescontos, const Color(0xFF8F2A1D), formatter, isPrivacyEnabled)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDonutChart(NumberFormat formatter, bool isPrivacyEnabled) {
    // A porcentagem que a cor vermelha ocupa
    final double fractionDescontos = totalVantagens > 0 ? (totalDescontos / totalVantagens) : 0;

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 190,
            height: 190,
            child: CustomPaint(
              painter: DonutPainter(
                fractionRed: fractionDescontos,
                colorRed: const Color(0xFF8F2A1D),
                colorGreen: const Color(0xFF3F7A4A),
              ),
            ),
          ),
          Container(
            width: 142,
            height: 142,
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E1E16).withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'VANTAGENS',
                  style: TextStyle(
                    color: Color(0xFF806F5E),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isPrivacyEnabled ? '••••••' : formatter.format(totalVantagens),
                  style: const TextStyle(
                    color: Color(0xFF2F2923),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard(String label, double value, int percent, Color borderColor, NumberFormat formatter, bool isPrivacyEnabled) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3).withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5B84C).withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 45,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFD8C5AA),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPrivacyEnabled ? '••••••' : formatter.format(value),
                  style: const TextStyle(
                    color: Color(0xFFFFF8EA),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isPrivacyEnabled ? '•••' : '$percent% do total',
                  style: const TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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

class DonutPainter extends CustomPainter {
  final double fractionRed;
  final Color colorRed;
  final Color colorGreen;

  DonutPainter({
    required this.fractionRed,
    required this.colorRed,
    required this.colorGreen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Convertemos frações para radianos (2 * pi é a volta completa)
    // O Vue usa conic-gradient(red 0%, red x%, green x%, green 100%) começando de "cima".
    // No Flutter, o 0 radiano é às 3 horas. Para começar às 12 horas, giramos -pi/2.
    final startAngle = -pi / 2;
    final sweepRed = fractionRed * 2 * pi;
    final sweepGreen = (1 - fractionRed) * 2 * pi;

    final redPaint = Paint()
      ..color = colorRed
      ..style = PaintingStyle.fill;
      
    final greenPaint = Paint()
      ..color = colorGreen
      ..style = PaintingStyle.fill;

    // Red Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepRed,
      true,
      redPaint,
    );

    // Green Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepRed,
      sweepGreen,
      true,
      greenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    return oldDelegate.fractionRed != fractionRed;
  }
}

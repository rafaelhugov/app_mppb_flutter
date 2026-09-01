import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/providers/privacy_provider.dart';
import '../../../../shared/widgets/privacy_toggle_button.dart';

class GraficoContracheque extends ConsumerStatefulWidget {
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
  ConsumerState<GraficoContracheque> createState() =>
      _GraficoContrachequeState();
}

class _GraficoContrachequeState extends ConsumerState<GraficoContracheque>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart);
  }

  @override
  void didUpdateWidget(covariant GraficoContracheque oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalVantagens != widget.totalVantagens ||
        oldWidget.totalDescontos != widget.totalDescontos ||
        oldWidget.salarioLiquido != widget.salarioLiquido) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _playOpeningAnimation();
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final isPrivacyEnabled = ref.watch(privacyProvider);

    int percentDescontos = 0;
    if (widget.totalVantagens > 0) {
      percentDescontos = ((widget.totalDescontos / widget.totalVantagens) * 100)
          .round();
    }
    final int percentLiquido = widget.totalVantagens <= 0
        ? 100
        : 100 - percentDescontos;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x26343A40)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A101828),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildChartRow(
            currencyFormatter,
            percentDescontos,
            percentLiquido,
            isPrivacyEnabled,
          ),
        ],
      ),
    );
  }

  void _playOpeningAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controller.isAnimating) return;
      _controller.forward(from: 0);
    });
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
                  color: Color(0xFF6F7D80),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Composição do mês',
                style: TextStyle(
                  color: Color(0xFF202322),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.12,
                ),
              ),
            ],
          ),
        ),
        const PrivacyToggleButton(size: 34, compact: true, showEveryTime: true),
      ],
    );
  }

  Widget _buildChartRow(
    NumberFormat formatter,
    int pDescontos,
    int pLiquido,
    bool isPrivacyEnabled,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            _buildDonutChart(formatter, isPrivacyEnabled),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildLegendCard(
                    'Líquido',
                    widget.salarioLiquido,
                    pLiquido,
                    const Color(0xFF00A86B),
                    formatter,
                    isPrivacyEnabled,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildLegendCard(
                    'Descontos',
                    widget.totalDescontos,
                    pDescontos,
                    const Color(0xFFD62828),
                    formatter,
                    isPrivacyEnabled,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDonutChart(NumberFormat formatter, bool isPrivacyEnabled) {
    // A porcentagem que a cor vermelha ocupa
    final double fractionDescontos = widget.totalVantagens > 0
        ? (widget.totalDescontos / widget.totalVantagens)
        : 0;

    return SizedBox(
      width: 164,
      height: 164,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _curve,
            builder: (context, child) {
              final value = _curve.value;
              return Transform.rotate(
                angle: (1 - value) * -2 * pi,
                child: SizedBox(
                  width: 164,
                  height: 164,
                  child: CustomPaint(
                    painter: DonutPainter(
                      fractionRed: fractionDescontos,
                      progress: value,
                      colorRed: const Color(0xFFD62828),
                      colorGreen: const Color(0xFF00A86B),
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 106,
            height: 106,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F6),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'VANTAGENS',
                  style: TextStyle(
                    color: Color(0xFF7A8587),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPrivacyEnabled
                      ? '••••••'
                      : formatter.format(widget.totalVantagens),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard(
    String label,
    double value,
    int percent,
    Color borderColor,
    NumberFormat formatter,
    bool isPrivacyEnabled,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x20343A40)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 38,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(3),
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
                    color: Color(0xFF697370),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPrivacyEnabled ? '••••••' : formatter.format(value),
                  style: const TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isPrivacyEnabled ? '•••' : '$percent% do total',
                  style: const TextStyle(
                    color: Color(0xFF7A8587),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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
  final double progress;
  final Color colorRed;
  final Color colorGreen;

  DonutPainter({
    required this.fractionRed,
    required this.progress,
    required this.colorRed,
    required this.colorGreen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Convertemos frações para radianos (2 * pi é a volta completa)
    // O Vue usa conic-gradient(red 0%, red x%, green x%, green 100%) começando de "cima".
    // No Flutter, o 0 radiano é às 3 horas. Para começar às 12 horas, giramos -pi/2.
    final startAngle = -pi / 2;
    final sweepRed = fractionRed * 2 * pi * progress;
    final sweepGreen = (1 - fractionRed) * 2 * pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = const Color(0xFFE9EDF0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    final redPaint = Paint()
      ..color = colorRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final greenPaint = Paint()
      ..color = colorGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(rect, startAngle + sweepRed, sweepGreen, false, greenPaint);
    if (sweepRed > 0) {
      canvas.drawArc(rect, startAngle, sweepRed, false, redPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    return oldDelegate.fractionRed != fractionRed ||
        oldDelegate.progress != progress;
  }
}

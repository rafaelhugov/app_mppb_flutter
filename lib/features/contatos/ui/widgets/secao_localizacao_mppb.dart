import 'package:flutter/material.dart';
import '../../../../core/ui/app_feedback.dart';
import '../../dados/dados_institucionais.dart';
import '../../servicos/servico_links_externos.dart';

class SecaoLocalizacaoMppb extends StatelessWidget {
  const SecaoLocalizacaoMppb({super.key});

  static const _verdeProjeto = Color(0xFF00A86B);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: SecaoLocalizacaoMppb._verdeProjeto,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Onde estamos',
              style: TextStyle(
                color: Color(0xFF202322),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: InkWell(
              onTap: () => _handleLink(
                context,
                () => ServicoLinksExternos.abrirMapa(
                  DadosInstitucionais.queryMapa,
                ),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: SecaoLocalizacaoMppb._verdeProjeto.withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Faixa de mapa estilizada (placeholder visual)
                    Container(
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFE9FFF6),
                            const Color(0xFFD7F7EA),
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Grid de ruas decorativo
                          CustomPaint(
                            size: const Size(double.infinity, 76),
                            painter: _MapaGridPainter(),
                          ),
                          // Pin de localização
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _verdeProjeto,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _verdeProjeto.withValues(
                                        alpha: 0.34,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 21,
                                ),
                              ),
                              // Sombra do pin
                              Container(
                                width: 14,
                                height: 4,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: _verdeProjeto.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Corpo do card
                    Padding(
                      padding: const EdgeInsets.all(13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rua
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.home_work_outlined,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DadosInstitucionais.enderecoSedeLinha1,
                                      style: TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${DadosInstitucionais.enderecoSedeLinha2}  •  ${DadosInstitucionais.enderecoSedeLinha3}',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11.5,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 11),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 11),

                          // Botão "Como chegar" — largura total, visual primário
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _handleLink(
                                context,
                                () => ServicoLinksExternos.abrirMapa(
                                  DadosInstitucionais.queryMapa,
                                ),
                              ),
                              icon: const Icon(
                                Icons.directions_rounded,
                                size: 16,
                              ),
                              label: const Text('Como chegar'),
                              style: FilledButton.styleFrom(
                                backgroundColor: _verdeProjeto,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLink(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(
          context,
          'Não foi possível abrir o link no momento.',
        );
      }
    }
  }
}

/// Pintor do grid decorativo que imita ruas de mapa
class _MapaGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9DE8CB).withValues(alpha: 0.65)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Horizontais
    for (double y = 20; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Verticais
    for (double x = 30; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

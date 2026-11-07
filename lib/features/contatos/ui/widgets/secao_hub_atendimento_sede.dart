import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/ui/app_feedback.dart';
import '../../dados/dados_institucionais.dart';
import '../../servicos/servico_links_externos.dart';

/// Hub Unificado de Atendimento (Ouvidoria do MPPB) e Localização da Sede
class SecaoHubAtendimentoSede extends StatelessWidget {
  const SecaoHubAtendimentoSede({super.key});

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

  Widget _buildContactAction({
    required BuildContext context,
    required Widget icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: icon,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1F343A40)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12101828),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x08101828),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // PARTE 1: OUVIDORIA DO MPPB (CANAIS)
          // ==========================================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topo da Ouvidoria: Ícone, Título e Tag de Horário
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0x1A2563EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFF2563EB),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ouvidoria do MPPB',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Denúncias, manifestações e informações',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Badge de Horário Oficial
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0x1410B981),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0x3310B981)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5.5,
                            height: 5.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4.5),
                          const Text(
                            '7h às 14h',
                            style: TextStyle(
                              color: Color(0xFF047857),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Grade dos 3 Canais (WhatsApp, Ligar, E-mail)
                Row(
                  children: [
                    Expanded(
                      child: _buildContactAction(
                        context: context,
                        icon: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Color(0xFF25D366),
                          size: 16,
                        ),
                        iconBgColor: const Color(0x1A25D366),
                        title: 'WhatsApp',
                        subtitle: 'Mensagem',
                        onTap: () => _handleLink(
                          context,
                          () => ServicoLinksExternos.abrirWhatsApp(
                            DadosInstitucionais.whatsappOuvidoria,
                            mensagem:
                                DadosInstitucionais.mensagemPadraoWhatsApp,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildContactAction(
                        context: context,
                        icon: const Icon(
                          Icons.phone_in_talk_rounded,
                          color: Color(0xFF2563EB),
                          size: 16,
                        ),
                        iconBgColor: const Color(0x1A2563EB),
                        title: 'Ligar',
                        subtitle: '(83) 2107-6150',
                        onTap: () => _handleLink(
                          context,
                          () => ServicoLinksExternos.abrirTelefone(
                            DadosInstitucionais.telefoneOuvidoria,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildContactAction(
                        context: context,
                        icon: const Icon(
                          Icons.mail_outline_rounded,
                          color: Color(0xFFD62828),
                          size: 16,
                        ),
                        iconBgColor: const Color(0x1AD62828),
                        title: 'E-mail',
                        subtitle: 'ouvidoria@...',
                        onTap: () => _handleLink(
                          context,
                          () => ServicoLinksExternos.abrirEmail(
                            DadosInstitucionais.emailOuvidoria,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divisor interno
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // ==========================================
          // PARTE 2: SEDE / ONDE ESTAMOS (LOCALIZAÇÃO)
          // ==========================================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Faixa de Mapa Urbana Estilizada
                InkWell(
                  onTap: () => _handleLink(
                    context,
                    () => ServicoLinksExternos.abrirMapa(
                        DadosInstitucionais.queryMapa),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(double.infinity, 80),
                          painter: _ModernUrbanMapPainter(),
                        ),
                        // Pin oficial do MPPB
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD62828),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x4DD62828),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Container(
                              width: 14,
                              height: 3.5,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        // Etiqueta discreta "Sede PGJ"
                        Positioned(
                          top: 6,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pin_drop_rounded,
                                    size: 10, color: Color(0xFFD62828)),
                                SizedBox(width: 3),
                                Text(
                                  'Sede PGJ',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Endereço Institucional
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                      color: Color(0xFFD62828),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Procuradoria-Geral de Justiça (Sede Central)',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DadosInstitucionais.enderecoSedeLinha1} • ${DadosInstitucionais.enderecoSedeLinha2}, ${DadosInstitucionais.enderecoSedeLinha3} • CEP 58013-030',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Botão "Traçar rota no mapa"
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _handleLink(
                      context,
                      () => ServicoLinksExternos.abrirMapa(
                          DadosInstitucionais.queryMapa),
                    ),
                    icon: const Icon(Icons.directions_rounded, size: 16),
                    label: const Text('Traçar rota no mapa'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

/// Pintor que gera um mapa urbano moderno, minimalista e limpo
class _ModernUrbanMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Áreas de quarteirões e parques suaves
    final parkPaint = Paint()
      ..color = const Color(0xFFE9F5ED)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, 10, size.width * 0.22, size.height * 0.42),
        const Radius.circular(6),
      ),
      parkPaint,
    );

    final blockPaint = Paint()
      ..color = const Color(0xFFEEF2F6)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, 14, size.width * 0.24, size.height * 0.46),
        const Radius.circular(6),
      ),
      blockPaint,
    );

    // 2. Ruas secundárias
    final minorStreetPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        Offset(0, size.height * 0.28), Offset(size.width, size.height * 0.28), minorStreetPaint);
    canvas.drawLine(
        Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), minorStreetPaint);
    canvas.drawLine(
        Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), minorStreetPaint);
    canvas.drawLine(
        Offset(size.width * 0.65, 0), Offset(size.width * 0.65, size.height), minorStreetPaint);

    // 3. Avenida Principal (passando pelo centro)
    final mainAvenuePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        Offset(0, size.height * 0.52), Offset(size.width, size.height * 0.52), mainAvenuePaint);

    // Avenida transversal
    final transAvenuePaint = Paint()
      ..color = const Color(0xFFD6DEE7)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        Offset(size.width * 0.50, 0), Offset(size.width * 0.50, size.height), transAvenuePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

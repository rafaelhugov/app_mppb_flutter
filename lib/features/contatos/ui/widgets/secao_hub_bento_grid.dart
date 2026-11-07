import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/ui/app_feedback.dart';
import '../../dados/dados_institucionais.dart';
import '../../servicos/servico_links_externos.dart';

/// Opção B: Dois Cards Independentes no Estilo Bento Grid (Inspirado no Design iOS)
class SecaoHubBentoGrid extends StatelessWidget {
  const SecaoHubBentoGrid({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARD 1: Ouvidoria do MPPB (Bento List)
          _buildOuvidoriaBentoCard(context),

          const SizedBox(height: 16),

          // CARD 2: Sede Central da PGJ (Bento Map & Rota)
          _buildSedeBentoCard(context),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 1: OUVIDORIA DO MPPB (BENTO LIST)
  // ==========================================
  Widget _buildOuvidoriaBentoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ouvidoria Cidadã',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Denúncias, elogios e informações',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge de Horário
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1410B981),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x3310B981)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
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
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Lista de Canais (Estilo Linhas iOS)
          _buildBentoListItem(
            context: context,
            icon: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Color(0xFF25D366),
              size: 18,
            ),
            iconBg: const Color(0x1925D366),
            title: 'WhatsApp Oficial',
            subtitle: '${DadosInstitucionais.whatsappOuvidoriaFormatado} • Mensagem direta',
            onTap: () => _handleLink(
              context,
              () => ServicoLinksExternos.abrirWhatsApp(
                DadosInstitucionais.whatsappOuvidoria,
                mensagem: DadosInstitucionais.mensagemPadraoWhatsApp,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(left: 62, right: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          _buildBentoListItem(
            context: context,
            icon: const Icon(
              Icons.phone_in_talk_rounded,
              color: Color(0xFF2563EB),
              size: 18,
            ),
            iconBg: const Color(0x192563EB),
            title: 'Telefone Ouvidoria',
            subtitle: '${DadosInstitucionais.telefoneOuvidoriaFormatado} • Ligação direta',
            onTap: () => _handleLink(
              context,
              () => ServicoLinksExternos.abrirTelefone(
                DadosInstitucionais.telefoneOuvidoria,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(left: 62, right: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          _buildBentoListItem(
            context: context,
            icon: const Icon(
              Icons.mail_outline_rounded,
              color: Color(0xFFD62828),
              size: 18,
            ),
            iconBg: const Color(0x19D62828),
            title: 'E-mail Oficial',
            subtitle: '${DadosInstitucionais.emailOuvidoria} • Manifestações',
            isLast: true,
            onTap: () => _handleLink(
              context,
              () => ServicoLinksExternos.abrirEmail(
                DadosInstitucionais.emailOuvidoria,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoListItem({
    required BuildContext context,
    required Widget icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(20))
          : BorderRadius.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: icon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CARD 2: SEDE CENTRAL DA PGJ (BENTO MAP)
  // ==========================================
  Widget _buildSedeBentoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFEE2E2)),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFD62828),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edifício-Sede da PGJ',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Procuradoria-Geral de Justiça',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Centro',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mapa Urbano Estilizado (Sem grid verde amador)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 105,
                width: double.infinity,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(double.infinity, 105),
                      painter: _BentoUrbanMapPainter(),
                    ),
                    // Badge Sede PGJ
                    Positioned(
                      top: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.apartment_rounded,
                              size: 11,
                              color: Color(0xFFD62828),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'João Pessoa - PB',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Pin Central
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD62828),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x40D62828),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                          Container(
                            width: 7,
                            height: 3,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x33000000),
                              borderRadius: BorderRadius.circular(2),
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

          const SizedBox(height: 12),

          // Endereço
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.business_rounded,
                  size: 16,
                  color: Color(0xFFD62828),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${DadosInstitucionais.enderecoSedeLinha1} • ${DadosInstitucionais.enderecoSedeLinha2} • ${DadosInstitucionais.enderecoSedeLinha3}',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Botão Como Chegar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () => _handleLink(
                  context,
                  () => ServicoLinksExternos.abrirMapa(
                    DadosInstitucionais.queryMapa,
                  ),
                ),
                icon: const Icon(
                  Icons.directions_outlined,
                  size: 17,
                  color: Colors.white,
                ),
                label: const Text(
                  'Como chegar à Sede',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter minimalista para renderizar o traçado de ruas da Sede no estilo Bento
class _BentoUrbanMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fundo cinza suave cartográfico
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Bloco parque verde suave institucional
    final parkPaint = Paint()..color = const Color(0xFFE2F0D9);
    final parkRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.52, size.width * 0.24, size.height * 0.38),
      const Radius.circular(6),
    );
    canvas.drawRRect(parkRRect, parkPaint);

    // Bloco predial secundário
    final blockPaint = Paint()..color = const Color(0xFFE2E8F0);
    final blockRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.12, size.width * 0.30, size.height * 0.32),
      const Radius.circular(6),
    );
    canvas.drawRRect(blockRRect, blockPaint);

    // Ruas secundárias
    final secStreetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      secStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.60, 0),
      Offset(size.width * 0.60, size.height),
      secStreetPaint,
    );

    // Avenida Principal (horizontal) onde a Sede se localiza
    final mainStreetBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.58),
      Offset(size.width, size.height * 0.58),
      mainStreetBorder,
    );

    final mainStreetFill = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.58),
      Offset(size.width, size.height * 0.58),
      mainStreetFill,
    );

    // Linha pontilhada no centro da via
    final lanePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height * 0.58),
        Offset(startX + 8, size.height * 0.58),
        lanePaint,
      );
      startX += 14;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


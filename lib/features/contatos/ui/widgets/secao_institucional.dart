import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/ui/app_feedback.dart';
import '../../dados/dados_institucionais.dart';
import '../../servicos/servico_links_externos.dart';

/// Seção Institucional com Design Bento Cards e Cabeçalhos em Faixa Destacada
class SecaoInstitucional extends StatelessWidget {
  final bool compacta;

  const SecaoInstitucional({super.key, this.compacta = false});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CARD 1: Ouvidoria do MPPB (Atendimento ao Cidadão e Servidor)
        _buildOuvidoriaCard(context),

        const SizedBox(height: 16),

        // CARD 2: Sede Central da PGJ (Localização e Acesso)
        _buildSedeCard(context),

        const SizedBox(height: 16),

        // CARD 3: Redes Sociais Oficiais (Instagram, Facebook e X)
        _buildRedesSociaisCard(context),

        const SizedBox(height: 24),
      ],
    );
  }

  // ===========================================================================
  // CARD 1: OUVIDORIA DO MPPB
  // ===========================================================================
  Widget _buildOuvidoriaCard(BuildContext context) {
    return _buildBentoCard(
      header: _buildCardHeaderStrip(
        icon: Icons.support_agent_rounded,
        iconColor: const Color(0xFFC4171D),
        title: 'Ouvidoria do MPPB',
        subtitle: 'Canais oficiais de atendimento e manifestação',
        badgeText: 'Atendimento',
        badgeColor: const Color(0xFFC4171D),
        badgeBg: const Color(0xFFFEF2F2),
        badgeBorder: const Color(0xFFFEE2E2),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Canal 1: WhatsApp
            _buildCanalTile(
              context,
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Color(0xFF16A34A),
                size: 19,
              ),
              iconBg: const Color(0xFFDCFCE7),
              iconBorder: const Color(0xFFBBF7D0),
              title: 'WhatsApp da Ouvidoria',
              subtitle: DadosInstitucionais.whatsappOuvidoriaFormatado,
              onTap: () => _handleLink(
                context,
                () => ServicoLinksExternos.abrirWhatsApp(
                  DadosInstitucionais.whatsappOuvidoria,
                  mensagem: DadosInstitucionais.mensagemPadraoWhatsApp,
                ),
              ),
            ),
            const Divider(height: 14, color: Color(0xFFF1F5F9)),
            // Canal 2: Telefone
            _buildCanalTile(
              context,
              icon: const Icon(
                Icons.phone_in_talk_rounded,
                color: Color(0xFF2563EB),
                size: 19,
              ),
              iconBg: const Color(0xFFDBEAFE),
              iconBorder: const Color(0xFFBFDBFE),
              title: 'Telefone Direto',
              subtitle: DadosInstitucionais.telefoneOuvidoriaFormatado,
              onTap: () => _handleLink(
                context,
                () => ServicoLinksExternos.abrirTelefone(
                  DadosInstitucionais.telefoneOuvidoria,
                ),
              ),
            ),
            const Divider(height: 14, color: Color(0xFFF1F5F9)),
            // Canal 3: E-mail
            _buildCanalTile(
              context,
              icon: const Icon(
                Icons.mail_outline_rounded,
                color: Color(0xFFDC2626),
                size: 19,
              ),
              iconBg: const Color(0xFFFEE2E2),
              iconBorder: const Color(0xFFFECACA),
              title: 'E-mail Oficial',
              subtitle: DadosInstitucionais.emailOuvidoria,
              onTap: () => _handleLink(
                context,
                () => ServicoLinksExternos.abrirEmail(
                  DadosInstitucionais.emailOuvidoria,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CARD 2: SEDE DA PGJ (LOCALIZAÇÃO)
  // ===========================================================================
  Widget _buildSedeCard(BuildContext context) {
    return _buildBentoCard(
      header: _buildCardHeaderStrip(
        icon: Icons.location_on_rounded,
        iconColor: const Color(0xFF2563EB),
        title: 'Edifício-Sede da PGJ',
        subtitle: 'Procuradoria-Geral de Justiça da Paraíba',
        badgeText: 'João Pessoa/PB',
        badgeColor: const Color(0xFF2563EB),
        badgeBg: const Color(0xFFEFF6FF),
        badgeBorder: const Color(0xFFDBEAFE),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DadosInstitucionais.enderecoSedeLinha1} • ${DadosInstitucionais.enderecoSedeLinha2}',
                          style: const TextStyle(
                            fontFamily: 'Rawline',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DadosInstitucionais.enderecoSedeLinha3,
                          style: const TextStyle(
                            fontFamily: 'Rawline',
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _handleLink(
                  context,
                  () => ServicoLinksExternos.abrirMapa(
                    DadosInstitucionais.queryMapa,
                  ),
                ),
                icon: const Icon(
                  Icons.directions_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
                label: const Text(
                  'Como chegar / Abrir no mapa',
                  style: TextStyle(
                    fontFamily: 'Rawline',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CARD 3: REDES SOCIAIS OFICIAIS
  // ===========================================================================
  Widget _buildRedesSociaisCard(BuildContext context) {
    return _buildBentoCard(
      header: _buildCardHeaderStrip(
        icon: Icons.alternate_email_rounded,
        iconColor: const Color(0xFF475569),
        title: 'Redes Sociais Oficiais',
        subtitle: 'Acompanhe as ações e divulgações do MPPB',
        badgeText: '@mppboficial',
        badgeColor: const Color(0xFF475569),
        badgeBg: const Color(0xFFF1F5F9),
        badgeBorder: const Color(0xFFE2E8F0),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildSocialPill(
                context,
                icon: const FaIcon(
                  FontAwesomeIcons.instagram,
                  color: Color(0xFFE4405F),
                  size: 20,
                ),
                iconBg: const Color(0xFFFDF2F4),
                iconBorder: const Color(0xFFFCE7F3),
                label: 'Instagram',
                tag: '@mppboficial',
                onTap: () => _handleLink(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlInstagram,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSocialPill(
                context,
                icon: const FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Color(0xFF1877F2),
                  size: 20,
                ),
                iconBg: const Color(0xFFEFF6FF),
                iconBorder: const Color(0xFFDBEAFE),
                label: 'Facebook',
                tag: '/mppboficial',
                onTap: () => _handleLink(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlFacebook,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSocialPill(
                context,
                icon: const FaIcon(
                  FontAwesomeIcons.xTwitter,
                  color: Color(0xFF0F172A),
                  size: 20,
                ),
                iconBg: const Color(0xFFF8FAFC),
                iconBorder: const Color(0xFFE2E8F0),
                label: 'X',
                tag: '@mppboficial',
                onTap: () => _handleLink(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlX,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPERS VISUAIS BENTO COM HEADER STRIP
  // ===========================================================================
  Widget _buildBentoCard({
    required Widget header,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeaderStrip({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required Color badgeBorder,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Rawline',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontFamily: 'Rawline',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Rawline',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanalTile(
    BuildContext context, {
    required Widget icon,
    required Color iconBg,
    required Color iconBorder,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconBorder, width: 1),
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Rawline',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Rawline',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialPill(
    BuildContext context, {
    required Widget icon,
    required Color iconBg,
    required Color iconBorder,
    required String label,
    required String tag,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconBorder, width: 1),
              ),
              child: Center(child: icon),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Rawline',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tag,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Rawline',
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

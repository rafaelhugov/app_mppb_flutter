import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dados/dados_institucionais.dart';
import '../../servicos/servico_links_externos.dart';
import 'secao_fale_com_mppb.dart';
import 'secao_localizacao_mppb.dart';
import 'secao_siga_mppb.dart';

class SecaoInstitucional extends StatelessWidget {
  final bool compacta;

  const SecaoInstitucional({super.key, this.compacta = false});

  @override
  Widget build(BuildContext context) {
    if (compacta) {
      return _buildCompacto(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SecaoFaleComMppb(),
        SizedBox(height: 24),
        SecaoLocalizacaoMppb(),
        SizedBox(height: 24),
        SecaoSigaMppb(),
        SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCompacto(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFFE9EDF0)),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(
              Icons.support_agent_rounded,
              color: Color(0xFF2563EB),
              size: 19,
            ),
            SizedBox(width: 8),
            Text(
              'Atendimento e canais oficiais',
              style: TextStyle(
                color: Color(0xFF202322),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _buildCompactChip(
              context,
              icone: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Color(0xFF25D366),
                size: 14,
              ),
              label: 'WhatsApp',
              onTap: () => _handleLink(
                context,
                () => ServicoLinksExternos.abrirWhatsApp(
                  DadosInstitucionais.whatsappOuvidoria,
                  mensagem: DadosInstitucionais.mensagemPadraoWhatsApp,
                ),
              ),
            ),
            _buildCompactChip(
              context,
              icone: const Icon(
                Icons.email_outlined,
                color: Color(0xFFD92D20),
                size: 14,
              ),
              label: 'E-mail',
              onTap: () => _handleLink(
                context,
                () => ServicoLinksExternos.abrirEmail(
                  DadosInstitucionais.emailOuvidoria,
                ),
              ),
            ),
            _buildCompactChip(
              context,
              icone: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF2563EB),
                size: 14,
              ),
              label: 'Localização',
              onTap: () => _handleLink(
                context,
                () => ServicoLinksExternos.abrirMapa(
                  DadosInstitucionais.queryMapa,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildCompactSocial(
                context,
                icone: FontAwesomeIcons.facebook,
                cor: const Color(0xFF1877F2),
                label: 'Facebook',
                onTap: () => _handleLink(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlFacebook,
                  ),
                ),
              ),
              _buildCompactSocial(
                context,
                icone: FontAwesomeIcons.instagram,
                cor: const Color(0xFFE4405F),
                label: 'Instagram',
                onTap: () => _handleLink(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlInstagram,
                  ),
                ),
              ),
              _buildCompactSocial(
                context,
                icone: FontAwesomeIcons.xTwitter,
                cor: const Color(0xFF202322),
                label: 'X',
                mostrarRotulo: false,
                onTap: () => _handleLink(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlX,
                  ),
                ),
              ),
              _buildCompactSocial(
                context,
                icone: FontAwesomeIcons.youtube,
                cor: const Color(0xFFFF0000),
                label: 'YouTube',
                onTap: () => _handleLink(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlYoutube,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFE9EDF0)),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o link no momento.'),
          ),
        );
      }
    }
  }

  Widget _buildCompactChip(
    BuildContext context, {
    required Widget icone,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE9EDF0)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icone,
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF202322),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSocial(
    BuildContext context, {
    required FaIconData icone,
    required Color cor,
    required String label,
    bool mostrarRotulo = true,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(icone, color: cor, size: 15),
                if (mostrarRotulo) ...[
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF697370),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/ui/app_feedback.dart';
import '../../dados/dados_institucionais.dart';
import '../../servicos/servico_links_externos.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecaoSigaMppb extends StatelessWidget {
  const SecaoSigaMppb({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.thumb_up_alt_outlined,
              color: Color(0xFFD62828),
              size: 20,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Redes sociais',
                style: TextStyle(
                  color: Color(0xFF202322),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
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
              _iconeRede(
                context: context,
                cor: const Color(0xFF1877F2),
                icone: FontAwesomeIcons.facebook,
                label: 'Facebook',
                onTap: () => _link(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlFacebook,
                  ),
                ),
              ),
              _iconeRede(
                context: context,
                cor: const Color(0xFFE4405F),
                icone: FontAwesomeIcons.instagram,
                label: 'Instagram',
                onTap: () => _link(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlInstagram,
                  ),
                ),
              ),
              _iconeRede(
                context: context,
                cor: const Color(0xFF202322),
                icone: FontAwesomeIcons.xTwitter,
                label: 'X',
                mostrarRotulo: false,
                onTap: () => _link(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlX,
                  ),
                ),
              ),
              _iconeRede(
                context: context,
                cor: const Color(0xFFFF0000),
                icone: FontAwesomeIcons.youtube,
                label: 'YouTube',
                onTap: () => _link(
                  context,
                  () => ServicoLinksExternos.abrirUrlExterna(
                    DadosInstitucionais.urlYoutube,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _link(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(context, 'Não foi possível abrir o link.');
      }
    }
  }

  Widget _iconeRede({
    required BuildContext context,
    required FaIconData icone,
    required Color cor,
    required String label,
    bool mostrarRotulo = true,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label == 'X' ? 'X (Twitter) do MPPB' : '$label do MPPB',
      child: Semantics(
        label: label == 'X' ? 'X (Twitter) do MPPB' : '$label do MPPB',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(icone, size: 15, color: cor),
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

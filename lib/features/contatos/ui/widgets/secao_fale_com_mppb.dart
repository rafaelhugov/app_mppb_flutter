import 'package:flutter/material.dart';
import '../../../../core/ui/app_feedback.dart';
import '../../dados/dados_institucionais.dart';
import '../../servicos/servico_links_externos.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecaoFaleComMppb extends StatelessWidget {
  const SecaoFaleComMppb({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF2563EB),
              size: 21,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Ouvidoria',
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildActionChip(
              icone: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Color(0xFF25D366),
                size: 16,
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
            _buildActionChip(
              icone: Icon(Icons.phone, color: Colors.green.shade700, size: 16),
              label: 'Ligar',
              onTap: () => _handleLink(
                context,
                () => ServicoLinksExternos.abrirTelefone(
                  DadosInstitucionais.telefoneOuvidoria,
                ),
              ),
            ),
            _buildActionChip(
              icone: const Icon(
                Icons.email_outlined,
                color: Color(0xFFD92D20),
                size: 16,
              ),
              label: 'E-mail',
              onTap: () => _handleLink(
                context,
                () => ServicoLinksExternos.abrirEmail(
                  DadosInstitucionais.emailOuvidoria,
                ),
              ),
            ),
          ],
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

  Widget _buildActionChip({
    required Widget icone,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE9EDF0)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icone,
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF202322),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

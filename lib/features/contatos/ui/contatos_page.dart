import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/responsive_layout.dart';
import '../dados/dados_institucionais.dart';
import '../servicos/servico_links_externos.dart';

class ContatosPage extends ConsumerWidget {
  const ContatosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = MppbResponsive.of(context);
    final isWide = responsive.usesWideLayout;
    final horizontalPadding = MainLayout.publicHorizontalPadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        title: const Text(
          'Contatos e Atendimento',
          style: TextStyle(
            color: Color(0xFF202322),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF202322)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(connectivityProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MainLayout.contentBottomPadding(context),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MainLayout.contentMaxWidth(context),
              ),
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildContactSection(
                              context,
                              'Sede do MPPB',
                              _buildSedeCard(),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              children: [
                                _buildContactSection(
                                  context,
                                  'Atendimento nas Promotorias',
                                  _buildPromotoriasCard(),
                                ),
                                const SizedBox(height: 28),
                                _buildContactSection(
                                  context,
                                  'Ouvidoria',
                                  _buildOuvidoriaCard(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContactSection(
                            context,
                            'Sede do MPPB',
                            _buildSedeCard(),
                          ),
                          const SizedBox(height: 32),
                          _buildContactSection(
                            context,
                            'Atendimento nas Promotorias',
                            _buildPromotoriasCard(),
                          ),
                          const SizedBox(height: 32),
                          _buildContactSection(
                            context,
                            'Ouvidoria',
                            _buildOuvidoriaCard(),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, String title, Widget card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
        const SizedBox(height: 16),
        card,
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final responsive = MppbResponsive.of(context);

    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF202322),
        fontSize: responsive.isTablet ? 24 : 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EDF0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSedeCard() {
    return _buildCard(
      children: [
        _buildInfoTile(
          icon: Icons.phone,
          title: 'Telefone',
          subtitle: DadosInstitucionais.telefoneSedeFormatado,
          actionLabel: 'Ligar',
          onAction: () => ServicoLinksExternos.abrirTelefone(
            DadosInstitucionais.telefoneSede,
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE9EDF0)),
        _buildInfoTile(
          icon: Icons.location_on_outlined,
          title: 'Endereço',
          subtitle:
              '${DadosInstitucionais.enderecoSedeLinha1}\n${DadosInstitucionais.enderecoSedeLinha2}\n${DadosInstitucionais.enderecoSedeLinha3}',
          actionLabel: 'Como chegar',
          onAction: () =>
              ServicoLinksExternos.abrirMapa(DadosInstitucionais.queryMapa),
        ),
      ],
    );
  }

  Widget _buildPromotoriasCard() {
    return _buildCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFF697370), size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Horário de atendimento',
                  style: TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                DadosInstitucionais.atendimentoPromotorias,
                style: const TextStyle(color: Color(0xFF697370), fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOuvidoriaCard() {
    return _buildCard(
      children: [
        _buildInfoTile(
          icon: Icons.phone,
          title: 'Telefone',
          subtitle: DadosInstitucionais.telefoneOuvidoriaFormatado,
          actionLabel: 'Ligar',
          onAction: () => ServicoLinksExternos.abrirTelefone(
            DadosInstitucionais.telefoneOuvidoria,
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE9EDF0)),
        _buildInfoTile(
          icon: Icons.message,
          title: 'WhatsApp',
          subtitle: DadosInstitucionais.whatsappOuvidoriaFormatado,
          actionLabel: 'Conversar',
          onAction: () => ServicoLinksExternos.abrirWhatsApp(
            DadosInstitucionais.whatsappOuvidoria,
            mensagem: DadosInstitucionais.mensagemPadraoWhatsApp,
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE9EDF0)),
        _buildInfoTile(
          icon: Icons.email_outlined,
          title: 'E-mail',
          subtitle: DadosInstitucionais.emailOuvidoria,
          actionLabel: 'Enviar e-mail',
          onAction: () => ServicoLinksExternos.abrirEmail(
            DadosInstitucionais.emailOuvidoria,
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE9EDF0)),
        _buildInfoTile(
          icon: Icons.location_on_outlined,
          title: 'Atendimento presencial',
          subtitle:
              'Segunda a quinta-feira: ${DadosInstitucionais.atendimentoOuvidoriaSegQui}\nSexta-feira: ${DadosInstitucionais.atendimentoOuvidoriaSexta}\n\nLocal:\n${DadosInstitucionais.localOuvidoriaLinha1}\n${DadosInstitucionais.localOuvidoriaLinha2}\n${DadosInstitucionais.localOuvidoriaLinha3}',
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF697370), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF697370),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF202322),
                  side: const BorderSide(color: Color(0xFFE9EDF0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

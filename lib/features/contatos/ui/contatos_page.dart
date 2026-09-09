import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/responsive_layout.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../dados/dados_institucionais.dart';
import '../servicos/servico_links_externos.dart';

class ContatosPage extends ConsumerWidget {
  const ContatosPage({super.key});

  static const _ink = Color(0xFF202322);
  static const _muted = Color(0xFF697370);
  static const _border = Color(0xFFE1E6E4);
  static const _red = Color(0xFFD62828);
  static const _blue = Color(0xFF1769FF);
  static const _green = Color(0xFF00A86B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = MppbResponsive.of(context);
    final isWide = responsive.isTablet && responsive.isLandscape;
    final isCompact = responsive.windowClass == MppbWindowClass.compact;
    final horizontalPadding = MainLayout.publicHorizontalPadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: RefreshIndicator(
        onRefresh: () => ref.read(connectivityProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MainLayout.contentBottomPadding(context),
          ),
          children: [
            const HeroHeaderPublico(
              label: '',
              title: 'Contatos e Atendimento',
              subtitle: '',
              icon: Icons.contact_phone_rounded,
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MainLayout.contentMaxWidth(context),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isCompact ? 12 : 18,
                    horizontalPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PageLead(compact: isCompact),
                      const SizedBox(height: 22),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ContactSection(
                                icon: Icons.account_balance_rounded,
                                iconColor: _red,
                                title: 'Sede do MPPB',
                                child: _buildSedeCard(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  _ContactSection(
                                    icon: Icons.schedule_rounded,
                                    iconColor: _blue,
                                    title: 'Atendimento nas Promotorias',
                                    child: _buildPromotoriasCard(),
                                  ),
                                  const SizedBox(height: 18),
                                  _ContactSection(
                                    icon: Icons.support_agent_rounded,
                                    iconColor: _green,
                                    title: 'Ouvidoria',
                                    child: _buildOuvidoriaCard(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _ContactSection(
                          icon: Icons.account_balance_rounded,
                          iconColor: _red,
                          title: 'Sede do MPPB',
                          child: _buildSedeCard(),
                        ),
                        const SizedBox(height: 24),
                        _ContactSection(
                          icon: Icons.schedule_rounded,
                          iconColor: _blue,
                          title: 'Atendimento nas Promotorias',
                          child: _buildPromotoriasCard(),
                        ),
                        const SizedBox(height: 24),
                        _ContactSection(
                          icon: Icons.support_agent_rounded,
                          iconColor: _green,
                          title: 'Ouvidoria',
                          child: _buildOuvidoriaCard(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSedeCard() {
    return _ContactCard(
      children: [
        _ContactTile(
          icon: Icons.phone_rounded,
          title: 'Telefone geral',
          value: DadosInstitucionais.telefoneSedeFormatado,
          accent: _red,
          actionLabel: 'Ligar',
          onAction: () => ServicoLinksExternos.abrirTelefone(
            DadosInstitucionais.telefoneSede,
          ),
        ),
        const _ContactDivider(),
        _ContactTile(
          icon: Icons.location_on_rounded,
          title: 'Endereço',
          value:
              '${DadosInstitucionais.enderecoSedeLinha1}\n${DadosInstitucionais.enderecoSedeLinha2}\n${DadosInstitucionais.enderecoSedeLinha3}',
          accent: _red,
          actionLabel: 'Mapa',
          onAction: () =>
              ServicoLinksExternos.abrirMapa(DadosInstitucionais.queryMapa),
        ),
      ],
    );
  }

  Widget _buildPromotoriasCard() {
    return _ContactCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const _IconBadge(icon: Icons.access_time_rounded, color: _blue),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horário de atendimento',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Unidades ministeriais',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _TimeChip(label: DadosInstitucionais.atendimentoPromotorias),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOuvidoriaCard() {
    return _ContactCard(
      children: [
        _ContactTile(
          icon: Icons.phone_rounded,
          title: 'Telefone',
          value: DadosInstitucionais.telefoneOuvidoriaFormatado,
          accent: _green,
          actionLabel: 'Ligar',
          onAction: () => ServicoLinksExternos.abrirTelefone(
            DadosInstitucionais.telefoneOuvidoria,
          ),
        ),
        const _ContactDivider(),
        _ContactTile(
          icon: Icons.chat_rounded,
          title: 'WhatsApp',
          value: DadosInstitucionais.whatsappOuvidoriaFormatado,
          accent: _green,
          actionLabel: 'Abrir',
          onAction: () => ServicoLinksExternos.abrirWhatsApp(
            DadosInstitucionais.whatsappOuvidoria,
            mensagem: DadosInstitucionais.mensagemPadraoWhatsApp,
          ),
        ),
        const _ContactDivider(),
        _ContactTile(
          icon: Icons.mail_rounded,
          title: 'E-mail',
          value: DadosInstitucionais.emailOuvidoria,
          accent: _green,
          actionLabel: 'Enviar',
          onAction: () => ServicoLinksExternos.abrirEmail(
            DadosInstitucionais.emailOuvidoria,
          ),
        ),
        const _ContactDivider(),
        _ContactTile(
          icon: Icons.meeting_room_rounded,
          title: 'Atendimento presencial',
          value:
              'Segunda a quinta-feira: ${DadosInstitucionais.atendimentoOuvidoriaSegQui}\nSexta-feira: ${DadosInstitucionais.atendimentoOuvidoriaSexta}\n${DadosInstitucionais.localOuvidoriaLinha1}\n${DadosInstitucionais.localOuvidoriaLinha2}\n${DadosInstitucionais.localOuvidoriaLinha3}',
          accent: _green,
        ),
      ],
    );
  }
}

class _PageLead extends StatelessWidget {
  final bool compact;

  const _PageLead({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Canais oficiais',
          style: TextStyle(
            color: ContatosPage._ink,
            fontSize: compact ? 22 : 24,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sede, promotorias e Ouvidoria em um só lugar.',
          style: TextStyle(
            color: ContatosPage._muted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _ContactSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = MppbResponsive.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: ContatosPage._ink,
                  fontSize: responsive.isTablet ? 20 : 19,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final List<Widget> children;

  const _ContactCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: ContatosPage._border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accent;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(icon: icon, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ContatosPage._ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: const TextStyle(
                        color: ContatosPage._muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
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
              child: _ActionButton(label: actionLabel!, onPressed: onAction!),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Future<void> Function() onPressed;

  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: ContatosPage._red,
        foregroundColor: Colors.white,
        minimumSize: const Size(74, 34),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
      child: Text(label),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;

  const _TimeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x101769FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x301769FF)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ContatosPage._blue,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _ContactDivider extends StatelessWidget {
  const _ContactDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: ContatosPage._border);
  }
}

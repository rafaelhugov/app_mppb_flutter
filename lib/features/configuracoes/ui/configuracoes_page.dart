import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/connectivity_provider.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/responsive_layout.dart';
import '../../auth/providers/auth_provider.dart';

class ConfiguracoesPage extends ConsumerWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = MppbResponsive.of(context);
    final isTablet = responsive.isTablet;
    final horizontalPadding = responsive.horizontalPadding;
    final isOnline = ref.watch(connectivityProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.token != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF202322),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(isAuthenticated ? '/restrito' : '/');
            }
          },
        ),
        title: const Text(
          'Configurações',
          style: TextStyle(
            color: Color(0xFF202322),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE8EEE4), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isTablet ? 24 : 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MainLayout.contentMaxWidth(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SEÇÃO NOTIFICAÇÕES (DEDICADA)
                _buildSectionTitle('PREFERÊNCIAS'),
                _buildCardGroup([
                  _ConfigTile(
                    icon: Icons.notifications_active_outlined,
                    iconColor: const Color(0xFFD62828),
                    iconBgColor: const Color(0x14D62828),
                    title: 'Notificações',
                    subtitle:
                        'Notícias, transmissões ao vivo e alertas institucionais',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF98A29D),
                      size: 22,
                    ),
                    onTap: () => context.push('/configuracoes/notificacoes'),
                  ),
                ]),

                const SizedBox(height: 24),

                // SEÇÃO ARMAZENAMENTO E DADOS
                _buildSectionTitle('ARMAZENAMENTO E DADOS'),
                _buildCardGroup([
                  _ConfigTile(
                    icon: Icons.cleaning_services_outlined,
                    iconColor: const Color(0xFF2563EB),
                    iconBgColor: const Color(0x142563EB),
                    title: 'Limpar cache temporário',
                    subtitle:
                        'Libera espaço excluindo imagens e dados temporários',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF98A29D),
                      size: 22,
                    ),
                    onTap: () => _limparCache(context),
                  ),
                ]),

                const SizedBox(height: 24),

                // SEÇÃO DIAGNÓSTICO
                _buildSectionTitle('DIAGNÓSTICO E REDE'),
                _buildCardGroup([
                  _ConfigTile(
                    icon: isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    iconColor: isOnline
                        ? const Color(0xFF00A76F)
                        : const Color(0xFFD62828),
                    iconBgColor: isOnline
                        ? const Color(0x1400A76F)
                        : const Color(0x14D62828),
                    title: 'Status da conexão',
                    subtitle: isOnline
                        ? 'Conectado à internet (Online)'
                        : 'Sem conexão com a internet (Offline)',
                    trailing: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline
                            ? const Color(0xFF00A76F)
                            : const Color(0xFFD62828),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 28),

                // SEÇÃO SOBRE O APP
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Image.asset(
                          'assets/images/brasao_mppb_sem_fundo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) => const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFFD62828),
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ministério Público da Paraíba',
                        style: TextStyle(
                          color: Color(0xFF202322),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final info = snapshot.data;
                          final text = info == null
                              ? 'MPPB+'
                              : 'MPPB+ • versão ${info.version} (${info.buildNumber})';
                          return Text(
                            text,
                            style: const TextStyle(
                              color: Color(0xFF98A29D),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _limparCache(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Limpar cache?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Isso removerá cópias temporárias de imagens e dados salvos no aparelho para liberar espaço. Seus dados cadastrais não serão afetados.',
          style: TextStyle(fontSize: 14, color: Color(0xFF697370), height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF697370))),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD62828),
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cache temporário limpo com sucesso!'),
              backgroundColor: Color(0xFF00A76F),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF697370),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1F343A40)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A101828),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ConfigTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF202322),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF697370),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/app_feedback.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/responsive_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../perfil/models/preferencias_notificacao.dart';
import '../../perfil/providers/preferencias_notificacao_provider.dart';

class ConfiguracoesNotificacoesPage extends ConsumerStatefulWidget {
  const ConfiguracoesNotificacoesPage({super.key});

  @override
  ConsumerState<ConfiguracoesNotificacoesPage> createState() =>
      _ConfiguracoesNotificacoesPageState();
}

class _ConfiguracoesNotificacoesPageState
    extends ConsumerState<ConfiguracoesNotificacoesPage> {
  Future<void> _updatePreferences(PreferenciasNotificacao preferencias) async {
    final success = await ref
        .read(preferenciasNotificacaoProvider.notifier)
        .atualizar(preferencias);

    if (!mounted) return;

    if (!success) {
      final errorMessage =
          ref.read(preferenciasNotificacaoProvider).errorMessage ??
          'Não foi possível salvar suas preferências.';
      AppFeedback.showError(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = MppbResponsive.of(context);
    final isTablet = responsive.isTablet;
    final horizontalPadding = responsive.horizontalPadding;
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.token != null;
    final notificationState = ref.watch(preferenciasNotificacaoProvider);
    final prefs = notificationState.preferencias;
    final enabled =
        !notificationState.isLoading && !notificationState.isSaving;

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
              context.go('/configuracoes');
            }
          },
        ),
        title: const Text(
          'Notificações',
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                    // Intro
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Escolha quais avisos serão exibidos em seu aparelho e quais ficarão armazenados na central de avisos.',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 13.5,
                          color: const Color(0xFF5B6560),
                          height: 1.4,
                        ),
                      ),
                    ),

                    // SEÇÃO 1: CANAIS PÚBLICOS (PUSH)
                    _SectionHeader(
                      title: 'CANAIS PÚBLICOS',
                      subtitle:
                          'Alertas instantâneos emitidos no aparelho para todos os cidadãos.',
                      icon: Icons.public_rounded,
                    ),
                    _CardContainer(
                      children: [
                        _NotificationSwitchTile(
                          icon: Icons.newspaper_rounded,
                          title: 'Notícias do MPPB',
                          subtitle:
                              'Principais destaques, atuações ministeriais e informes',
                          value: prefs.pushNoticias,
                          enabled: enabled,
                          onChanged: (val) => _updatePreferences(
                            prefs.copyWith(pushNoticias: val),
                          ),
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16),
                        _NotificationSwitchTile(
                          icon: Icons.live_tv_rounded,
                          title: 'Transmissões e Lives',
                          subtitle:
                              'Sessões do Colégio de Procuradores e eventos ao vivo',
                          value: prefs.pushLives,
                          enabled: enabled,
                          onChanged: (val) => _updatePreferences(
                            prefs.copyWith(pushLives: val),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SEÇÃO 2: CANAIS FUNCIONAIS (PUSH)
                    _SectionHeader(
                      title: 'CANAIS FUNCIONAIS',
                      subtitle:
                          'Avisos individuais relativos à carreira e vida funcional.',
                      icon: Icons.badge_outlined,
                    ),
                    if (isAuthenticated) ...[
                      _CardContainer(
                        children: [
                          _NotificationSwitchTile(
                            icon: Icons.receipt_long_rounded,
                            title: 'Contracheques',
                            subtitle:
                                'Fechamento de folha e comprovantes mensais',
                            value: prefs.pushContracheques,
                            enabled: enabled,
                            onChanged: (val) => _updatePreferences(
                              prefs.copyWith(pushContracheques: val),
                            ),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16),
                          _NotificationSwitchTile(
                            icon: Icons.payments_rounded,
                            title: 'Pagamentos Diversos',
                            subtitle:
                                'Informes de diárias, verbas e créditos financeiros',
                            value: prefs.pushPagamentos,
                            enabled: enabled,
                            onChanged: (val) => _updatePreferences(
                              prefs.copyWith(pushPagamentos: val),
                            ),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16),
                          _NotificationSwitchTile(
                            icon: Icons.assignment_ind_rounded,
                            title: 'Designações',
                            subtitle:
                                'Portarias de substituição e designações de atuação',
                            value: prefs.pushDesignacoes,
                            enabled: enabled,
                            onChanged: (val) => _updatePreferences(
                              prefs.copyWith(pushDesignacoes: val),
                            ),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16),
                          _NotificationSwitchTile(
                            icon: Icons.event_busy_rounded,
                            title: 'Afastamentos',
                            subtitle:
                                'Concessões de férias, licenças e afastamentos',
                            value: prefs.pushAfastamentos,
                            enabled: enabled,
                            onChanged: (val) => _updatePreferences(
                              prefs.copyWith(pushAfastamentos: val),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Usuário público: Cartão informativo para Login
                      _LoginRequiredNotificationCard(),
                    ],

                    const SizedBox(height: 24),

                    // SEÇÃO 3: CENTRAL DE NOTIFICAÇÕES (SINO NO APP) - CANAIS PÚBLICOS
                    _SectionHeader(
                      title: 'CENTRAL DE AVISOS — CANAIS PÚBLICOS',
                      subtitle:
                          'Itens públicos guardados na caixa de entrada do aplicativo.',
                      icon: Icons.inbox_rounded,
                    ),
                    _CardContainer(
                      children: [
                        _NotificationSwitchTile(
                          icon: Icons.newspaper_rounded,
                          title: 'Salvar Notícias na Central',
                          subtitle: 'Guarda as notícias recebidas na lista do sino',
                          value: prefs.centralNoticias,
                          enabled: enabled,
                          onChanged: (val) => _updatePreferences(
                            prefs.copyWith(centralNoticias: val),
                          ),
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16),
                        _NotificationSwitchTile(
                          icon: Icons.live_tv_rounded,
                          title: 'Salvar Lives na Central',
                          subtitle: 'Histórico de transmissões e eventos passados',
                          value: prefs.centralLives,
                          enabled: enabled,
                          onChanged: (val) => _updatePreferences(
                            prefs.copyWith(centralLives: val),
                          ),
                        ),
                      ],
                    ),

                    if (isAuthenticated) ...[
                      const SizedBox(height: 24),
                      // SEÇÃO 4: CENTRAL DE NOTIFICAÇÕES (SINO NO APP) - CANAIS FUNCIONAIS
                      _SectionHeader(
                        title: 'CENTRAL DE AVISOS — CANAIS FUNCIONAIS',
                        subtitle:
                            'Avisos individuais guardados na caixa de entrada do aplicativo.',
                        icon: Icons.badge_outlined,
                      ),
                      _CardContainer(
                        children: [
                          _NotificationSwitchTile(
                            icon: Icons.receipt_long_rounded,
                            title: 'Salvar Contracheques',
                            subtitle: 'Histórico de avisos de folha no sino',
                            value: prefs.centralContracheques,
                            enabled: enabled,
                            onChanged: (val) => _updatePreferences(
                              prefs.copyWith(centralContracheques: val),
                            ),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16),
                          _NotificationSwitchTile(
                            icon: Icons.payments_rounded,
                            title: 'Salvar Pagamentos',
                            subtitle: 'Histórico de notificações financeiras',
                            value: prefs.centralPagamentos,
                            enabled: enabled,
                            onChanged: (val) => _updatePreferences(
                              prefs.copyWith(centralPagamentos: val),
                            ),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16),
                          _NotificationSwitchTile(
                            icon: Icons.assignment_ind_rounded,
                            title: 'Salvar Designações',
                            subtitle: 'Acesso rápido às últimas designações',
                            value: prefs.centralDesignacoes,
                            enabled: enabled,
                            onChanged: (val) => _updatePreferences(
                              prefs.copyWith(centralDesignacoes: val),
                            ),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16),
                          _NotificationSwitchTile(
                            icon: Icons.event_busy_rounded,
                            title: 'Salvar Afastamentos',
                            subtitle: 'Histórico de licenças e concessões',
                            value: prefs.centralAfastamentos,
                            enabled: enabled,
                            onChanged: (val) => _updatePreferences(
                              prefs.copyWith(centralAfastamentos: val),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (notificationState.isSaving || notificationState.isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Colors.transparent,
                color: Color(0xFFD62828),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFD62828)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF75817B),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8C9893),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final List<Widget> children;

  const _CardContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE4), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _NotificationSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF4C5852), size: 19),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF202322),
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF697370),
          fontSize: 12.5,
          height: 1.25,
        ),
      ),
      value: value,
      activeTrackColor: const Color(0xFF00A76F),
      onChanged: enabled ? onChanged : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    );
  }
}

class _LoginRequiredNotificationCard extends StatelessWidget {
  const _LoginRequiredNotificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE4), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x14D62828),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFD62828),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acesso restrito a membros e servidores',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202322),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Para ativar notificações de contracheque, pagamentos e designações, faça login com sua conta funcional.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF697370),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_rounded, size: 16),
                  label: const Text('Entrar no MPPB+'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD62828),
                    side: const BorderSide(color: Color(0xFFD62828)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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


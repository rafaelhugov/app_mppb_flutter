import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/connectivity_provider.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/responsive_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../perfil/providers/perfil_provider.dart';

enum _SecurityFeedbackType { success, warning, error }

class ConfiguracoesPage extends ConsumerStatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  ConsumerState<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends ConsumerState<ConfiguracoesPage> {
  bool _isBiometricActionLoading = false;
  String? _biometricAuthenticationError;

  bool get _supportsBiometrics =>
      ref.read(perfilProvider).canUseBiometrics ||
      ref.read(perfilProvider).biometricsEnabled;

  Future<void> _enableBiometricsNow() async {
    setState(() {
      _isBiometricActionLoading = true;
      _biometricAuthenticationError = null;
    });

    final authenticated = await _authenticateWithBiometrics(
      'Confirme sua identidade para habilitar o acesso seguro com biometria',
    );

    if (!mounted) return;
    if (!authenticated) {
      setState(() => _isBiometricActionLoading = false);
      await _showFeedbackDialog(
        type: _SecurityFeedbackType.warning,
        title: 'Identidade não confirmada',
        message:
            _biometricAuthenticationError ??
            'A confirmação pelo aparelho falhou ou foi cancelada. Tente novamente.',
      );
      return;
    }

    final enabled =
        await ref.read(authProvider.notifier).enableBiometricLogin();
    await ref.read(perfilProvider.notifier).refreshBiometrics();
    if (!mounted) return;
    setState(() => _isBiometricActionLoading = false);
    final activationError =
        ref.read(authProvider.notifier).biometricActivationError;
    await _showFeedbackDialog(
      type: enabled
          ? _SecurityFeedbackType.success
          : _SecurityFeedbackType.error,
      title: enabled
          ? 'Acesso seguro habilitado'
          : 'Não foi possível habilitar',
      message: enabled
          ? 'O aparelho recebeu uma credencial revogável, separada da sua senha.'
          : activationError ??
                'Não foi possível registrar a credencial segura no servidor.',
    );
  }

  Future<void> _disableBiometrics() async {
    setState(() => _isBiometricActionLoading = true);
    final authenticated = await _authenticateWithBiometrics(
      'Confirme sua identidade para desativar o acesso seguro',
    );

    if (!mounted) return;
    if (!authenticated) {
      setState(() => _isBiometricActionLoading = false);
      await _showFeedbackDialog(
        type: _SecurityFeedbackType.warning,
        title: 'Identidade não confirmada',
        message: 'Não foi possível confirmar sua identidade neste aparelho.',
      );
      return;
    }

    await ref.read(authProvider.notifier).disableBiometricLogin();
    await ref.read(perfilProvider.notifier).refreshBiometrics();
    if (!mounted) return;
    setState(() => _isBiometricActionLoading = false);
    await _showFeedbackDialog(
      type: _SecurityFeedbackType.success,
      title: 'Acesso seguro desativado',
      message: 'O acesso com senha volta a ser necessário no próximo login.',
    );
  }

  Future<bool> _authenticateWithBiometrics(String reason) async {
    final localAuth = LocalAuthentication();
    try {
      return await localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (error) {
      _biometricAuthenticationError = _localAuthErrorMessage(error);
      return false;
    } catch (error) {
      _biometricAuthenticationError =
          'Falha ao abrir a autenticação local do aparelho (${error.runtimeType}).';
      return false;
    }
  }

  String _localAuthErrorMessage(LocalAuthException error) {
    switch (error.code) {
      case LocalAuthExceptionCode.noBiometricsEnrolled:
        return 'O Android não encontrou biometria cadastrada. Use o PIN, padrão ou senha do aparelho, ou cadastre uma biometria nas configurações.';
      case LocalAuthExceptionCode.noBiometricHardware:
        return 'Este aparelho não possui biometria compatível. Configure PIN, padrão ou senha de bloqueio.';
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        return 'O sensor biométrico está temporariamente indisponível. Aguarde e tente novamente.';
      case LocalAuthExceptionCode.temporaryLockout:
        return 'A biometria foi bloqueada temporariamente após várias tentativas. Aguarde e tente novamente.';
      case LocalAuthExceptionCode.biometricLockout:
        return 'A biometria foi bloqueada pelo Android. Desbloqueie o aparelho com PIN ou senha e tente novamente.';
      case LocalAuthExceptionCode.authInProgress:
        return 'Já existe uma confirmação biométrica em andamento. Feche-a e tente novamente.';
      case LocalAuthExceptionCode.uiUnavailable:
        return 'O Android não conseguiu abrir a tela de autenticação local. Tente novamente.';
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
        return 'A confirmação biométrica foi cancelada ou expirou. Tente novamente.';
      case LocalAuthExceptionCode.noCredentialsSet:
        return 'Configure PIN, padrão, senha ou biometria nas configurações do aparelho.';
      default:
        final description = error.description?.trim();
        return description == null || description.isEmpty
            ? 'O Android recusou a autenticação biométrica (${error.code.name}).'
            : 'O Android recusou a autenticação biométrica (${error.code.name}): $description';
    }
  }

  Future<void> _showFeedbackDialog({
    required _SecurityFeedbackType type,
    required String title,
    required String message,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      barrierColor: const Color(0x99000000),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _SecurityFeedbackDialog(
          type: type,
          title: title,
          message: message,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _limparCache() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Limpar cache do aplicativo?',
          style: TextStyle(
            color: Color(0xFF202322),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Imagens temporárias e dados armazenados em cache local serão removidos. Nenhuma informação pessoal ou documento oficial será apagado.',
          style: TextStyle(color: Color(0xFF697370), fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Color(0xFF697370),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD62828),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache de imagens e dados temporários liberado.'),
        backgroundColor: Color(0xFF00A76F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = MppbResponsive.of(context);
    final isTablet = responsive.isTablet;
    final horizontalPadding = responsive.horizontalPadding;
    final isOnline = ref.watch(connectivityProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.token != null;
    final perfilState = ref.watch(perfilProvider);
    final biometricsEnabled =
        perfilState.biometricsEnabled && perfilState.canUseBiometrics;

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

                // SEÇÃO SEGURANÇA (NOVO BLOCO DEDICADO)
                _buildSectionTitle('SEGURANÇA E ACESSO'),
                if (isAuthenticated) ...[
                  _SecurityCard(
                    enabled: biometricsEnabled,
                    supportsBiometrics: _supportsBiometrics,
                    isLoading: _isBiometricActionLoading,
                    onEnable: _enableBiometricsNow,
                    onDisable: _disableBiometrics,
                  ),
                ] else ...[
                  _buildCardGroup([
                    _ConfigTile(
                      icon: Icons.lock_outline_rounded,
                      iconColor: const Color(0xFF697370),
                      iconBgColor: const Color(0x14697370),
                      title: 'Acesso Seguro e Biometria',
                      subtitle:
                          'Disponível após entrar com uma conta institucional',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF98A29D),
                        size: 22,
                      ),
                      onTap: () => context.push('/login'),
                    ),
                  ]),
                ],

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
                    onTap: _limparCache,
                  ),
                ]),

                const SizedBox(height: 24),

                // SEÇÃO DIAGNÓSTICO
                _buildSectionTitle('DIAGNÓSTICO E REDE'),
                _buildCardGroup([
                  _ConfigTile(
                    icon: isOnline
                        ? Icons.wifi_rounded
                        : Icons.wifi_off_rounded,
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
                      Image.asset(
                        'assets/images/brasao_mppb_sem_fundo.png',
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.account_balance_rounded,
                          size: 40,
                          color: Color(0xFF202322),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ministério Público da Paraíba',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202322),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final version = snapshot.data?.version ?? '4.0.0';
                          final build = snapshot.data?.buildNumber ?? '128';
                          return Text(
                            'MPPB+ • versão $version ($build)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8C9893),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF75817B),
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
        child: Column(children: children),
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final bool enabled;
  final bool supportsBiometrics;
  final bool isLoading;
  final VoidCallback onEnable;
  final VoidCallback onDisable;

  const _SecurityCard({
    required this.enabled,
    required this.supportsBiometrics,
    required this.isLoading,
    required this.onEnable,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0x1400A76F)
                      : const Color(0x14D62828),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fingerprint_rounded,
                  color: enabled
                      ? const Color(0xFF00A76F)
                      : const Color(0xFFD62828),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enabled
                          ? 'Acesso seguro habilitado'
                          : 'Acesso seguro desabilitado',
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supportsBiometrics
                          ? 'O acesso usa a biometria ou bloqueio do aparelho e uma credencial revogável, sem salvar sua senha.'
                          : 'Configure biometria, PIN, padrão ou senha de bloqueio no aparelho.',
                      style: const TextStyle(
                        color: Color(0xFF697370),
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
          const SizedBox(height: 16),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: isLoading ? 48 : 240,
              height: 44,
              child: OutlinedButton(
                onPressed:
                    !isLoading ? (enabled ? onDisable : onEnable) : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD62828),
                  side: const BorderSide(color: Color(0xFFD62828)),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isLoading ? 0 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isLoading ? 22 : 12),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFD62828),
                          ),
                        )
                      : Row(
                          key: const ValueKey('label'),
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              enabled
                                  ? Icons.lock_open_rounded
                                  : Icons.fingerprint_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              enabled
                                  ? 'Desabilitar acesso seguro'
                                  : 'Habilitar acesso seguro',
                            ),
                          ],
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

class _ConfigTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _ConfigTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202322),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF697370),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityFeedbackDialog extends StatelessWidget {
  final _SecurityFeedbackType type;
  final String title;
  final String message;

  const _SecurityFeedbackDialog({
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    switch (type) {
      case _SecurityFeedbackType.success:
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF00A76F);
        break;
      case _SecurityFeedbackType.warning:
        icon = Icons.warning_amber_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case _SecurityFeedbackType.error:
        icon = Icons.error_rounded;
        color = const Color(0xFFD62828);
        break;
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202322),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF697370),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF202322),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

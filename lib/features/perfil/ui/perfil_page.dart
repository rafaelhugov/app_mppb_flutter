import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/ui/main_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/perfil_usuario.dart';
import '../models/preferencias_notificacao.dart';
import '../providers/perfil_provider.dart';
import '../providers/preferencias_notificacao_provider.dart';

class PerfilPage extends ConsumerStatefulWidget {
  const PerfilPage({super.key});

  @override
  ConsumerState<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends ConsumerState<PerfilPage> {
  bool _supportsBiometrics = false;
  bool _isBiometricActionLoading = false;
  String? _biometricAuthenticationError;

  @override
  void initState() {
    super.initState();
    _loadBiometricSupport();
  }

  Future<void> _loadBiometricSupport() async {
    final auth = LocalAuthentication();
    try {
      final supported = await auth.isDeviceSupported();
      if (mounted) {
        setState(() => _supportsBiometrics = supported);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _supportsBiometrics = false);
      }
    }
  }

  Future<void> _enableBiometricsNow() async {
    setState(() => _isBiometricActionLoading = true);
    _biometricAuthenticationError = null;
    final authenticated = await _authenticateWithBiometrics(
      'Confirme sua identidade com a segurança do aparelho',
    );
    if (!mounted) return;
    if (!authenticated) {
      setState(() => _isBiometricActionLoading = false);
      await _showFeedbackDialog(
        type: _ProfileFeedbackType.warning,
        title: 'Identidade não confirmada',
        message:
            _biometricAuthenticationError ??
            'A confirmação pelo aparelho falhou ou foi cancelada. Tente novamente.',
      );
      return;
    }

    final enabled = await ref
        .read(authProvider.notifier)
        .enableBiometricLogin();
    await ref.read(perfilProvider.notifier).refreshBiometrics();
    if (!mounted) return;
    setState(() => _isBiometricActionLoading = false);
    final activationError = ref
        .read(authProvider.notifier)
        .biometricActivationError;
    await _showFeedbackDialog(
      type: enabled ? _ProfileFeedbackType.success : _ProfileFeedbackType.error,
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
        type: _ProfileFeedbackType.warning,
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
      type: _ProfileFeedbackType.success,
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
        return 'O Android não conseguiu abrir a tela de autenticação local. Volte ao perfil e tente novamente.';
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
    required _ProfileFeedbackType type,
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
        return _ProfileFeedbackDialog(
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

  Future<void> _updateNotificationPreference(
    PreferenciasNotificacao preferencias,
  ) async {
    final saved = await ref
        .read(preferenciasNotificacaoProvider.notifier)
        .atualizar(preferencias);
    if (!mounted) return;
    final errorMessage = ref.read(preferenciasNotificacaoProvider).errorMessage;
    await _showFeedbackDialog(
      type: saved ? _ProfileFeedbackType.success : _ProfileFeedbackType.error,
      title: saved ? 'Preferência atualizada' : 'Não foi possível salvar',
      message: saved
          ? 'Suas preferências de notificação foram salvas e serão aplicadas aos seus aparelhos.'
          : errorMessage ??
                'Não foi possível salvar a preferência de notificação.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(perfilProvider);
    final authState = ref.watch(authProvider);
    final notificationState = ref.watch(preferenciasNotificacaoProvider);
    final perfil = state.data;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(perfilProvider.notifier).carregar(forceRefresh: true),
            ref.read(preferenciasNotificacaoProvider.notifier).carregar(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  MainLayout.horizontalPadding(context),
                  MainLayout.authenticatedContentTopPadding(context) + 14,
                  MainLayout.horizontalPadding(context),
                  MainLayout.contentBottomPadding(context) + 96,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MainLayout.contentMaxWidth(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(
                          perfil: perfil,
                          isLoading: state.isLoading,
                          authToken: authState.token,
                        ),
                        const SizedBox(height: 18),
                        if (state.errorMessage != null)
                          _InlineMessage(message: state.errorMessage!),
                        if (state.isLoading && perfil == null)
                          const _ProfileLoading()
                        else ...[
                          _Section(
                            title: 'Conta',
                            children: [
                              _InfoRow(
                                icon: Icons.alternate_email_rounded,
                                label: 'Login',
                                value: perfil?.login,
                              ),
                              _InfoRow(
                                icon: Icons.badge_rounded,
                                label: 'Matrícula',
                                value: perfil?.matricula,
                              ),
                              _InfoRow(
                                icon: Icons.verified_user_rounded,
                                label: 'Vínculo',
                                value: perfil?.tipoCargo,
                              ),
                              _InfoRow(
                                icon: Icons.check_circle_rounded,
                                label: 'Situação',
                                value: perfil?.situacao,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _Section(
                            title: 'Vínculo Funcional',
                            children: [
                              _InfoRow(
                                icon: Icons.work_rounded,
                                label: 'Cargo',
                                value: _firstNonBlank([
                                  perfil?.tituloCargo,
                                  perfil?.cargo,
                                  perfil?.especialidade,
                                ]),
                              ),
                              _InfoRow(
                                icon: Icons.event_available_rounded,
                                label: 'Posse',
                                value: _formatDate(perfil?.dataPosse),
                              ),
                              _InfoRow(
                                icon: Icons.play_circle_fill_rounded,
                                label: 'Exercício',
                                value: _formatDate(perfil?.dataExercicio),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _Section(
                            title: 'Contato',
                            children: [
                              _InfoRow(
                                icon: Icons.email_rounded,
                                label: 'Email',
                                value: perfil?.email,
                              ),
                              _InfoRow(
                                icon: Icons.call_rounded,
                                label: 'Telefone',
                                value: perfil?.telefone,
                              ),
                              _InfoRow(
                                icon: Icons.phone_android_rounded,
                                label: 'Celular',
                                value: perfil?.celular,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _NotificationPreferencesSection(
                            state: notificationState,
                            onChanged: _updateNotificationPreference,
                          ),
                          const SizedBox(height: 12),
                          _SecuritySection(
                            supportsBiometrics: _supportsBiometrics,
                            biometricsEnabled: state.biometricsEnabled,
                            canUseBiometrics: state.canUseBiometrics,
                            isLoading: _isBiometricActionLoading,
                            onEnable: _enableBiometricsNow,
                            onDisable: _disableBiometrics,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPreferencesSection extends StatelessWidget {
  final PreferenciasNotificacaoState state;
  final ValueChanged<PreferenciasNotificacao> onChanged;

  const _NotificationPreferencesSection({
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final preferencias = state.preferencias;
    final enabled = !state.isLoading && !state.isSaving;
    return _Section(
      title: 'Notificações',
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            'Escolha quais avisos deseja receber neste e nos demais aparelhos.',
            style: TextStyle(
              color: Color(0xFF697370),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
        _NotificationSwitch(
          icon: Icons.newspaper_rounded,
          label: 'Notícias',
          value: preferencias.noticias,
          enabled: enabled,
          onChanged: (value) =>
              onChanged(preferencias.copyWith(noticias: value)),
        ),
        _NotificationSwitch(
          icon: Icons.assignment_ind_rounded,
          label: 'Designações',
          value: preferencias.designacoes,
          enabled: enabled,
          onChanged: (value) =>
              onChanged(preferencias.copyWith(designacoes: value)),
        ),
        _NotificationSwitch(
          icon: Icons.receipt_long_rounded,
          label: 'Contracheques',
          value: preferencias.contracheques,
          enabled: enabled,
          onChanged: (value) =>
              onChanged(preferencias.copyWith(contracheques: value)),
        ),
        _NotificationSwitch(
          icon: Icons.payments_rounded,
          label: 'Pagamentos',
          value: preferencias.pagamentos,
          enabled: enabled,
          onChanged: (value) =>
              onChanged(preferencias.copyWith(pagamentos: value)),
        ),
        _NotificationSwitch(
          icon: Icons.event_busy_rounded,
          label: 'Afastamentos',
          value: preferencias.afastamentos,
          enabled: enabled,
          isLast: true,
          onChanged: (value) =>
              onChanged(preferencias.copyWith(afastamentos: value)),
        ),
        if (state.isLoading || state.isSaving)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final bool enabled;
  final bool isLast;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile.adaptive(
          secondary: Icon(icon, color: const Color(0xFF697370), size: 21),
          title: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF202322),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          value: value,
          activeTrackColor: const Color(0xFF00A76F),
          onChanged: enabled ? onChanged : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        if (!isLast) const Divider(height: 1, indent: 52, endIndent: 16),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final PerfilUsuario? perfil;
  final bool isLoading;
  final String? authToken;

  const _Header({
    required this.perfil,
    required this.isLoading,
    required this.authToken,
  });

  @override
  Widget build(BuildContext context) {
    final name = _formatName(perfil?.nome);
    final initials = _initials(perfil?.nome);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF202322),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F101828),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _Avatar(
            url: perfil?.fotoUrl,
            initials: initials,
            authToken: authToken,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meu Perfil',
                  style: TextStyle(
                    color: Color(0xFFBFC7C2),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isLoading && perfil == null ? 'Carregando...' : name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF7F8F6),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _firstNonBlank([perfil?.tipoCargo, perfil?.matricula]) ??
                      'Conta funcional',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE8EEE4),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

class _Avatar extends StatelessWidget {
  final String? url;
  final String initials;
  final String? authToken;

  const _Avatar({
    required this.url,
    required this.initials,
    required this.authToken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3C96B),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: ColoredBox(
          color: const Color(0xFFF7F8F6),
          child: url == null || url!.trim().isEmpty
              ? Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF202322),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              : Image.network(
                  url!,
                  headers: authToken == null || authToken!.trim().isEmpty
                      ? null
                      : {'Authorization': 'Bearer ${authToken!.trim()}'},
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E5E3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF202322),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final display = _clean(value) ?? 'Não informado';
    final isEmpty = _clean(value) == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF697370)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF697370),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  display,
                  style: TextStyle(
                    color: isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF202322),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
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

class _SecuritySection extends StatelessWidget {
  final bool supportsBiometrics;
  final bool biometricsEnabled;
  final bool canUseBiometrics;
  final bool isLoading;
  final VoidCallback onEnable;
  final VoidCallback onDisable;

  const _SecuritySection({
    required this.supportsBiometrics,
    required this.biometricsEnabled,
    required this.canUseBiometrics,
    required this.isLoading,
    required this.onEnable,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = biometricsEnabled && canUseBiometrics;

    return _Section(
      title: 'Segurança',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supportsBiometrics
                          ? 'O acesso usa a segurança local do aparelho e uma credencial revogável, sem armazenar sua senha institucional.'
                          : 'Configure biometria, PIN, padrão ou senha de bloqueio no aparelho.',
                      style: const TextStyle(
                        color: Color(0xFF697370),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        width: isLoading ? 48 : null,
                        height: 40,
                        child: OutlinedButton(
                          // Permite uma tentativa manual mesmo quando a
                          // sondagem inicial do Android falhar. O prompt nativo
                          // continua sendo a autoridade final.
                          onPressed: !isLoading
                              ? (enabled ? onDisable : onEnable)
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD62828),
                            side: const BorderSide(color: Color(0xFFD62828)),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isLoading ? 0 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isLoading ? 20 : 12,
                              ),
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
                                            ? 'Desativar acesso seguro'
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _ProfileFeedbackType { success, warning, error }

class _ProfileFeedbackDialog extends StatefulWidget {
  final _ProfileFeedbackType type;
  final String title;
  final String message;

  const _ProfileFeedbackDialog({
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  State<_ProfileFeedbackDialog> createState() => _ProfileFeedbackDialogState();
}

class _ProfileFeedbackDialogState extends State<_ProfileFeedbackDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.type) {
      _ProfileFeedbackType.success => const Color(0xFF00A76F),
      _ProfileFeedbackType.warning => const Color(0xFFFF8A00),
      _ProfileFeedbackType.error => const Color(0xFFD62828),
    };
    final icon = switch (widget.type) {
      _ProfileFeedbackType.success => Icons.check_rounded,
      _ProfileFeedbackType.warning => Icons.priority_high_rounded,
      _ProfileFeedbackType.error => Icons.close_rounded,
    };

    return SafeArea(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            margin: const EdgeInsets.symmetric(horizontal: 26),
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAF7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE0E5E3)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33101828),
                  blurRadius: 34,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulse,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: color.withAlpha(24),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withAlpha(70), width: 1),
                    ),
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(80),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF697370),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF202322),
                      foregroundColor: const Color(0xFFF7F8F6),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;

  const _InlineMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD8A8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_rounded, color: Color(0xFFB25E09), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF7A4100),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator(color: Color(0xFFD62828))),
    );
  }
}

String? _firstNonBlank(List<String?> values) {
  for (final value in values) {
    final cleaned = _clean(value);
    if (cleaned != null) {
      return cleaned;
    }
  }
  return null;
}

String? _clean(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String _formatName(String? value) {
  final cleaned = _clean(value);
  if (cleaned == null) {
    return 'Usuário';
  }

  final particles = {'da', 'das', 'de', 'di', 'do', 'dos', 'e'};
  return cleaned
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map((word) {
        final lower = word.toLowerCase();
        if (particles.contains(lower)) return lower;
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(' ');
}

String _initials(String? value) {
  final cleaned = _clean(value);
  if (cleaned == null) {
    return 'MP';
  }

  final words = cleaned
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .toList();
  if (words.isEmpty) {
    return 'MP';
  }
  if (words.length == 1) {
    return words.first.substring(0, 1).toUpperCase();
  }
  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}

String? _formatDate(String? value) {
  final cleaned = _clean(value);
  if (cleaned == null) {
    return null;
  }

  final date = DateTime.tryParse(cleaned);
  if (date == null) {
    return cleaned;
  }

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

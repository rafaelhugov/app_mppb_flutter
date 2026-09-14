import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/ui/main_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/perfil_usuario.dart';
import '../providers/perfil_provider.dart';

class PerfilPage extends ConsumerStatefulWidget {
  const PerfilPage({super.key});

  @override
  ConsumerState<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends ConsumerState<PerfilPage> {
  bool _supportsBiometrics = false;
  bool _isBiometricActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSupport();
  }

  Future<void> _loadBiometricSupport() async {
    final auth = LocalAuthentication();
    try {
      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      if (mounted) {
        setState(() => _supportsBiometrics = supported && canCheck);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _supportsBiometrics = false);
      }
    }
  }

  Future<void> _enableBiometricsNow() async {
    final confirmed = await _showBiometricDecisionDialog();
    if (confirmed != true || !mounted) return;

    setState(() => _isBiometricActionLoading = true);

    final authNotifier = ref.read(authProvider.notifier);
    final hasCredentials = await authNotifier
        .hasAvailableBiometricCredentials();
    var enabled = false;

    if (!hasCredentials) {
      setState(() => _isBiometricActionLoading = false);
      final password = await _showPasswordFallbackDialog();
      if (password == null || password.isEmpty || !mounted) return;

      setState(() => _isBiometricActionLoading = true);
      enabled = await authNotifier.enableBiometricLoginForCurrentUser(password);
    } else {
      final authenticated = await _authenticateWithBiometrics(
        'Confirme sua identidade para habilitar a biometria',
      );

      if (!authenticated) {
        if (mounted) {
          setState(() => _isBiometricActionLoading = false);
          await _showFeedbackDialog(
            type: _ProfileFeedbackType.warning,
            title: 'Biometria não confirmada',
            message:
                'Não foi possível confirmar sua identidade neste aparelho.',
          );
        }
        return;
      }

      enabled = await authNotifier
          .enableBiometricLoginFromAvailableCredentials();
    }

    await ref.read(perfilProvider.notifier).refreshBiometrics();

    if (!mounted) return;

    setState(() => _isBiometricActionLoading = false);
    await _showFeedbackDialog(
      type: enabled ? _ProfileFeedbackType.success : _ProfileFeedbackType.error,
      title: enabled ? 'Biometria habilitada' : 'Não foi possível habilitar',
      message: enabled
          ? 'Seu próximo acesso poderá ser feito com biometria.'
          : 'Confira sua senha e tente habilitar novamente.',
    );
  }

  Future<void> _disableBiometrics() async {
    setState(() => _isBiometricActionLoading = true);
    final authenticated = await _authenticateWithBiometrics(
      'Confirme sua identidade para desativar a biometria',
    );

    if (!mounted) return;
    if (!authenticated) {
      setState(() => _isBiometricActionLoading = false);
      await _showFeedbackDialog(
        type: _ProfileFeedbackType.warning,
        title: 'Biometria não confirmada',
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
      title: 'Biometria desativada',
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
    } catch (_) {
      return false;
    }
  }

  Future<bool?> _showBiometricDecisionDialog() {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Habilitar biometria',
      barrierColor: const Color(0x99000000),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _BiometricDecisionDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );
  }

  Future<String?> _showPasswordFallbackDialog() {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Confirmar senha',
      barrierColor: const Color(0x99000000),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _PasswordFallbackDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(perfilProvider);
    final perfil = state.data;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(perfilProvider.notifier).carregar(forceRefresh: true),
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
                        _Header(perfil: perfil, isLoading: state.isLoading),
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

class _Header extends StatelessWidget {
  final PerfilUsuario? perfil;
  final bool isLoading;

  const _Header({required this.perfil, required this.isLoading});

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
          _Avatar(url: perfil?.fotoUrl, initials: initials),
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

  const _Avatar({required this.url, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F6),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      clipBehavior: Clip.antiAlias,
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
                          ? 'Biometria habilitada'
                          : 'Biometria desabilitada',
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supportsBiometrics
                          ? 'Controle o acesso biométrico desta conta.'
                          : 'Este aparelho não informou biometria disponível.',
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
                      child: OutlinedButton.icon(
                        onPressed: supportsBiometrics && !isLoading
                            ? (enabled ? onDisable : onEnable)
                            : null,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFD62828),
                                ),
                              )
                            : Icon(
                                enabled
                                    ? Icons.lock_open_rounded
                                    : Icons.fingerprint_rounded,
                                size: 18,
                              ),
                        label: Text(
                          enabled
                              ? 'Desativar biometria'
                              : 'Habilitar biometria',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD62828),
                          side: const BorderSide(color: Color(0xFFD62828)),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

class _BiometricDecisionDialog extends StatelessWidget {
  const _BiometricDecisionDialog();

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD62828).withAlpha(18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD62828).withAlpha(48),
                      ),
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: Color(0xFFD62828),
                      size: 31,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Habilitar biometria?',
                  style: TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Você poderá acessar o app usando a biometria cadastrada neste aparelho.',
                  style: TextStyle(
                    color: Color(0xFF697370),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF697370),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Agora não'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD62828),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Habilitar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordFallbackDialog extends StatefulWidget {
  const _PasswordFallbackDialog();

  @override
  State<_PasswordFallbackDialog> createState() =>
      _PasswordFallbackDialogState();
}

class _PasswordFallbackDialogState extends State<_PasswordFallbackDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD62828).withAlpha(18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD62828).withAlpha(48),
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFFD62828),
                      size: 29,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Confirme sua senha de login',
                  style: TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Informe a mesma senha usada para entrar no MPPB+.',
                  style: TextStyle(
                    color: Color(0xFF697370),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  cursorColor: const Color(0xFFD62828),
                  decoration: InputDecoration(
                    labelText: 'Senha de login do MPPB+',
                    labelStyle: const TextStyle(
                      color: Color(0xFF697370),
                      fontWeight: FontWeight.w700,
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD62828),
                        width: 2,
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE0E5E3)),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      color: const Color(0xFF202322),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF697370),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD62828),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    Navigator.pop(context, _controller.text);
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

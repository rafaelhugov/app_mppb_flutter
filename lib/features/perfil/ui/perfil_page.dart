import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Sair do aplicativo?',
          style: TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Sua sessão será encerrada neste aparelho. Você poderá entrar novamente quando quiser.',
          style: TextStyle(
            color: Color(0xFF475467),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF475467),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.logout();
    final hasBiometricCredential = await authNotifier
        .hasAvailableBiometricCredentials();
    if (mounted) context.go(hasBiometricCredential ? '/login' : '/');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(perfilProvider);
    final authState = ref.watch(authProvider);
    final perfil = state.data;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(perfilProvider.notifier).carregar(forceRefresh: true);
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
                          const SizedBox(height: 24),
                          _LogoutSection(onLogout: _confirmLogout),
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

class _LogoutSection extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutSection({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 240,
            height: 44,
            child: FilledButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sair do aplicativo'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD62828),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final info = snapshot.data;
            final text = info == null
                ? 'MPPB+'
                : 'MPPB+ • versão ${info.version} (${info.buildNumber})';
            return Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF98A29D),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ],
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

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/designacoes/providers/designacoes_provider.dart';
import '../../features/noticias/providers/noticia_provider.dart';
import '../../features/noticias/ui/noticias_page.dart';
import '../../features/noticias/utils/noticia_share.dart';
import '../../features/perfil/providers/preferencias_notificacao_provider.dart';
import '../notifications/device_registration_diagnostics_provider.dart';
import '../notifications/device_registration_provider.dart';
import '../notifications/notification_center_provider.dart';
import 'responsive_layout.dart';
import 'widgets/notification_center_sheet.dart';

class MppbAppBar extends ConsumerWidget implements PreferredSizeWidget {
  static const Color background = Color(0xFFFAFAF7);
  static const double altura = 36;
  static const double authenticatedAltura = 46;

  static double heightFor(bool isAuthenticated) {
    return isAuthenticated ? authenticatedAltura : altura;
  }

  static double heightForContext(BuildContext context, bool isAuthenticated) {
    final metrics = MppbResponsive.of(context);
    if (!metrics.isTablet) {
      return heightFor(isAuthenticated);
    }
    return isAuthenticated ? 54 : 46;
  }

  final bool showLeadingCrest;

  const MppbAppBar({super.key, this.showLeadingCrest = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final metrics = MppbResponsive.of(context);
    final toolbarHeight = heightForContext(context, isAuthenticated);

    if (isAuthenticated) {
      final noticiaState = ref.watch(noticiaProvider);
      final designacoesState = ref.watch(designacoesProvider);
      final notificationState = ref.watch(notificationCenterProvider);
      final notificationPreferences = ref
          .watch(preferenciasNotificacaoProvider)
          .preferencias;
      final deviceDiagnostics = ref.watch(
        deviceRegistrationDiagnosticsProvider,
      );
      final notificationItems = buildNotificationCenterItems(
        noticias: noticiaState.noticias,
        designacoes: designacoesState.designacoes,
        readKeys: notificationState.readKeys,
        inboxItems: notificationState.inboxItems,
        includeNoticias: notificationPreferences.noticias,
        includeDesignacoes: notificationPreferences.designacoes,
        includeContracheques: notificationPreferences.contracheques,
        includePagamentos: notificationPreferences.pagamentos,
        includeAfastamentos: notificationPreferences.afastamentos,
      );

      return AppBar(
        toolbarHeight: toolbarHeight,
        backgroundColor: MppbAppBar.background,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leadingWidth: metrics.isTablet ? 82 : 64,
        leading: Padding(
          padding: EdgeInsets.only(left: metrics.isTablet ? 24 : 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _HomeTapTarget(
              tooltip: 'Ir para início',
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: showLeadingCrest ? 1 : 0,
                child: Image.asset(
                  'assets/images/brasao_mppb_sem_fundo.png',
                  height: metrics.isTablet ? 34 : 30,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE8EEE4), height: 1.0),
        ),
        title: _HomeTapTarget(
          tooltip: 'Ir para início',
          child: SizedBox(
            height: toolbarHeight,
            child: Center(
              // O desenho das letras fica visualmente alguns pixels acima do
              // centro geometrico. Este ajuste alinha o titulo ao brasao e
              // aos icones de perfil e saida na mesma linha.
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'MPPB+',
                  style: TextStyle(
                    color: const Color(0xFF4C4741),
                    fontSize: metrics.isTablet ? 23 : 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Meu perfil',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.all(metrics.isTablet ? 10 : 8),
            icon: Icon(
              Icons.account_circle_rounded,
              color: const Color(0xFF202322),
              size: metrics.isTablet ? 24 : 22,
            ),
            onPressed: () => context.go('/perfil'),
          ),
          IconButton(
            tooltip: notificationItems.isEmpty
                ? 'Notificações'
                : 'Notificações (${notificationItems.length} novas)',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.all(metrics.isTablet ? 10 : 8),
            icon: _NotificationBell(count: notificationItems.length),
            onPressed: () {
              // Abrir o centro equivale a visualizar os avisos pendentes.
              // A lista atual permanece visivel neste painel, mas o badge
              // some imediatamente e nao volta quando ele for reaberto.
              unawaited(
                ref
                    .read(notificationCenterProvider.notifier)
                    .markAllAsRead(notificationItems.map((item) => item.key)),
              );
              NotificationCenterSheet.show(
                context,
                items: notificationItems,
                onOpenItem: (item) => _openNotificationItem(context, ref, item),
                deviceDiagnostics: deviceDiagnostics,
                onRetryDeviceRegistration: () =>
                    _retryDeviceRegistration(ref, authState.token),
              );
            },
          ),
          IconButton(
            tooltip: 'Sair da conta',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.all(metrics.isTablet ? 10 : 8),
            icon: Icon(
              Icons.logout,
              color: const Color(0xFF202322),
              size: metrics.isTablet ? 24 : 22,
            ),
            onPressed: () async {
              final authNotifier = ref.read(authProvider.notifier);
              await authNotifier.logout();
              final hasBiometricCredential = await authNotifier
                  .hasAvailableBiometricCredentials();
              if (context.mounted) {
                context.go(hasBiometricCredential ? '/login' : '/');
              }
            },
          ),
          SizedBox(width: metrics.isTablet ? 12 : 4),
        ],
      );
    }

    final noticiaState = ref.watch(noticiaProvider);
    final notificationState = ref.watch(notificationCenterProvider);
    final notificationItems = buildNotificationCenterItems(
      noticias: noticiaState.noticias,
      designacoes: const [],
      readKeys: notificationState.readKeys,
      includeDesignacoes: false,
      includeContracheques: false,
      includePagamentos: false,
      includeAfastamentos: false,
    );

    return AppBar(
      toolbarHeight: toolbarHeight,
      backgroundColor: MppbAppBar.background,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      titleSpacing: metrics.isTablet ? 24 : 16,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: const Color(0xFFE8EEE4), height: 1.0),
      ),
      title: _HomeTapTarget(
        tooltip: 'Ir para início',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: metrics.isTablet ? 32 : 28,
              height: metrics.isTablet ? 32 : 28,
              child: ExcludeSemantics(
                child: Image.asset(
                  'assets/images/brasao_mppb_sem_fundo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => const Text(
                    'M',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Color(0xFF202322),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: metrics.isTablet ? 10 : 8),
            Flexible(
              child: Text(
                'MPPB+',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: metrics.isTablet ? 24 : 22,
                  color: const Color(0xFF202322),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          tooltip: notificationItems.isEmpty
              ? 'Notificações'
              : 'Notificações (${notificationItems.length} novas)',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.all(metrics.isTablet ? 10 : 8),
          icon: _NotificationBell(count: notificationItems.length),
          onPressed: () {
            unawaited(
              ref
                  .read(notificationCenterProvider.notifier)
                  .markAllAsRead(notificationItems.map((item) => item.key)),
            );
            NotificationCenterSheet.show(
              context,
              items: notificationItems,
              onOpenItem: (item) => _openNotificationItem(context, ref, item),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(right: metrics.isTablet ? 18 : 10),
          child: TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: Icon(Icons.login_rounded, size: metrics.isTablet ? 20 : 18),
            label: const Text('Entrar'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF202322),
              textStyle: TextStyle(
                fontSize: metrics.isTablet ? 14 : 13,
                fontWeight: FontWeight.w900,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: metrics.isTablet ? 12 : 10,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(altura);

  void _openNotificationItem(
    BuildContext context,
    WidgetRef ref,
    NotificationCenterItem item,
  ) {
    unawaited(
      ref.read(notificationCenterProvider.notifier).markAsRead(item.key),
    );

    switch (item.type) {
      case NotificationCenterItemType.noticia:
        _showNewsModal(context, item);
        return;
      case NotificationCenterItemType.designacao:
        context.go('/designacoes');
        return;
      case NotificationCenterItemType.contracheque:
        context.go('/contracheque');
        return;
      case NotificationCenterItemType.pagamento:
        context.go('/pagamentos');
        return;
      case NotificationCenterItemType.afastamento:
        context.go('/concessao-afastamento');
        return;
    }
  }

  void _retryDeviceRegistration(WidgetRef ref, String? authToken) {
    unawaited(
      ref
          .read(deviceRegistrationManagerProvider)
          .registrarSeAutenticado(authToken),
    );
  }

  void _showNewsModal(BuildContext context, NotificationCenterItem item) {
    final noticia = item.noticia;
    if (noticia == null) {
      context.go('/noticias');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewsDetailSheet(
        noticia: noticia,
        fallbackImageUrl: NoticiasPage.fallbackImageUrl,
        date: _dateForNews(item),
        readingTime: _readingTime(item),
        onOpenLink: () => _openNewsTarget(context, item.targetUrl),
        onShare: () => compartilharNoticia(noticia),
      ),
    );
  }

  int _readingTime(NotificationCenterItem item) {
    final words = (item.noticia?.resumo ?? '')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .length;
    final minutes = (words / 180).ceil();
    return minutes > 0 ? minutes : 1;
  }

  String _dateForNews(NotificationCenterItem item) {
    final date = item.noticia?.dataPublicacao ?? '';
    return date.split(' ').isNotEmpty ? date.split(' ')[0] : '';
  }

  Future<void> _openNewsTarget(BuildContext context, String? targetUrl) async {
    final text = targetUrl?.trim();
    if (text == null || text.isEmpty) {
      return;
    }

    final url = Uri.tryParse(text);
    if (url == null || !await canLaunchUrl(url)) {
      return;
    }

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

class _HomeTapTarget extends StatelessWidget {
  final Widget child;
  final String tooltip;

  const _HomeTapTarget({required this.child, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go('/'),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatefulWidget {
  final int count;

  const _NotificationBell({required this.count});

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _attentionController;
  Timer? _attentionTimer;

  @override
  void initState() {
    super.initState();
    _attentionController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 860),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _attentionController.value = 0;
          }
        });
    _startAttentionIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _NotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _startAttentionIfNeeded();
    }
  }

  @override
  void dispose() {
    _attentionTimer?.cancel();
    _attentionController.dispose();
    super.dispose();
  }

  void _startAttentionIfNeeded() {
    if (widget.count <= 0) {
      _stopAttention();
      return;
    }

    if (_attentionTimer != null) {
      return;
    }

    _attentionTimer?.cancel();
    _playAttention();
    _attentionTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _playAttention(),
    );
  }

  void _playAttention() {
    if (!mounted || widget.count <= 0 || _attentionController.isAnimating) {
      return;
    }
    _attentionController.forward(from: 0);
  }

  void _stopAttention() {
    _attentionTimer?.cancel();
    _attentionTimer = null;
    if (_attentionController.isAnimating) {
      _attentionController.stop();
    }
    _attentionController.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _attentionController,
      builder: (context, child) {
        final attention = widget.count > 0 && _attentionController.value > 0;
        final progress = Curves.easeOutCubic.transform(
          _attentionController.value,
        );
        final settle = 1 - progress;
        final shake = attention
            ? math.sin(_attentionController.value * math.pi * 5) * settle
            : 0.0;
        final bellScale = attention
            ? 1.0 + (math.sin(_attentionController.value * math.pi) * 0.13)
            : 1.0;
        final badgeScale = attention
            ? 1.0 + (math.sin(_attentionController.value * math.pi) * 0.18)
            : 1.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.scale(
              scale: bellScale,
              child: Transform.rotate(
                angle: shake * 0.18,
                child: const Icon(
                  Icons.notifications,
                  color: Color(0xFF202322),
                  size: 22,
                ),
              ),
            ),
            if (widget.count > 0)
              Positioned(
                right: -2,
                top: -3,
                child: Transform.scale(
                  scale: badgeScale,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD62828),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: MppbAppBar.background,
                        width: 1.5,
                      ),
                      boxShadow: attention
                          ? const [
                              BoxShadow(
                                color: Color(0x55D62828),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.count > 9 ? '9+' : '${widget.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/designacoes/providers/designacoes_provider.dart';
import '../../features/noticias/providers/noticia_provider.dart';
import '../../features/noticias/ui/noticias_page.dart';
import '../../features/noticias/utils/noticia_share.dart';
import '../notifications/notification_center_provider.dart';
import 'widgets/notification_center_sheet.dart';

class MppbAppBar extends ConsumerWidget implements PreferredSizeWidget {
  static const Color background = Color(0xFFFAFAF7);
  static const double altura = 36;
  static const double authenticatedAltura = 46;

  static double heightFor(bool isAuthenticated) {
    return isAuthenticated ? authenticatedAltura : altura;
  }

  const MppbAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    if (isAuthenticated) {
      final noticiaState = ref.watch(noticiaProvider);
      final designacoesState = ref.watch(designacoesProvider);
      final notificationState = ref.watch(notificationCenterProvider);
      final notificationItems = buildNotificationCenterItems(
        noticias: noticiaState.noticias,
        designacoes: designacoesState.designacoes,
        readKeys: notificationState.readKeys,
        includeDesignacoes: true,
      );

      return AppBar(
        toolbarHeight: MppbAppBar.authenticatedAltura,
        backgroundColor: MppbAppBar.background,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/brasao_mppb_sem_fundo.png',
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE8EEE4), height: 1.0),
        ),
        title: const Text(
          'MPPB+',
          style: TextStyle(
            color: Color(0xFF4C4741),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
            height: 1.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            icon: _NotificationBell(count: notificationItems.length),
            onPressed: () {
              NotificationCenterSheet.show(
                context,
                items: notificationItems,
                onOpenItem: (item) => _openNotificationItem(context, ref, item),
                onClearAll: () => _clearNotifications(ref, notificationItems),
              );
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            icon: const Icon(Icons.logout, color: Color(0xFF202322), size: 22),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
          const SizedBox(width: 4),
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
    );

    return AppBar(
      toolbarHeight: MppbAppBar.altura,
      backgroundColor: MppbAppBar.background,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      titleSpacing: 16,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: const Color(0xFFE8EEE4), height: 1.0),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
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
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'MPPB+',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Color(0xFF202322),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(8),
          icon: _NotificationBell(count: notificationItems.length),
          onPressed: () {
            NotificationCenterSheet.show(
              context,
              items: notificationItems,
              onOpenItem: (item) => _openNotificationItem(context, ref, item),
              onClearAll: () => _clearNotifications(ref, notificationItems),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Entrar'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF202322),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
    }
  }

  void _clearNotifications(
    WidgetRef ref,
    List<NotificationCenterItem> notificationItems,
  ) {
    unawaited(
      ref
          .read(notificationCenterProvider.notifier)
          .markAllAsRead(notificationItems.map((item) => item.key)),
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

class _NotificationBell extends StatelessWidget {
  final int count;

  const _NotificationBell({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications, color: Color(0xFF202322), size: 22),
        if (count > 0)
          Positioned(
            right: -2,
            top: -3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD62828),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: MppbAppBar.background, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 9 ? '9+' : '$count',
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
      ],
    );
  }
}

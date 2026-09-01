import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

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
            icon: const Icon(
              Icons.notifications,
              color: Color(0xFF202322),
              size: 22,
            ),
            onPressed: () {},
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
}

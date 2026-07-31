import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

class MppbAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MppbAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    if (isAuthenticated) {
      return AppBar(
        backgroundColor: const Color(0xFFFFFBF4),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFF9C7A54).withAlpha(71),
            height: 1.0,
          ),
        ),
        title: Row(
          children: [
            Image.asset('assets/images/brasao_mppb_sem_fundo.png', height: 36),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MPPB+',
                    style: TextStyle(
                      color: Color(0xFF241D19),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'SERVIÇOS AO SERVIDOR',
                    style: TextStyle(
                      color: Color(0xFF8F2A1D),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF8A6A00)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8F2A1D)),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: const Color(0xFFFFFBF4),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFF9C7A54).withAlpha(71),
          height: 1.0,
        ),
      ),
      title: Row(
        children: [
          Image.asset('assets/images/brasao_mppb_sem_fundo.png', height: 40),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'MPPB+',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Color(0xFF241D19),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

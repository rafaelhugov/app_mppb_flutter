import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/providers/privacy_provider.dart';

class MppbAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MppbAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final currentPath = GoRouterState.of(context).uri.path;
    final showPrivacyIcon = currentPath == '/contracheque' || currentPath == '/pagamentos';

    if (isAuthenticated) {
      return AppBar(
        backgroundColor: const Color(0xFFFFFBF4),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF9C7A54).withAlpha(71), height: 1.0),
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
          if (showPrivacyIcon) const _PrivacyToggleButton(),
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
        child: Container(color: const Color(0xFF9C7A54).withAlpha(71), height: 1.0),
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

class _PrivacyToggleButton extends ConsumerStatefulWidget {
  const _PrivacyToggleButton();

  @override
  ConsumerState<_PrivacyToggleButton> createState() => _PrivacyToggleButtonState();
}

class _PrivacyToggleButtonState extends ConsumerState<_PrivacyToggleButton> {
  final _tooltipController = JustTheController();
  static bool _hasShownTooltip = false;

  @override
  void initState() {
    super.initState();
    if (!_hasShownTooltip) {
      _hasShownTooltip = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _tooltipController.showTooltip();
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted) _tooltipController.hideTooltip();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      controller: _tooltipController,
      isModal: false,
      tailLength: 10.0,
      tailBaseWidth: 16.0,
      backgroundColor: const Color(0xFF8F2A1D),
      margin: const EdgeInsets.all(16.0),
      content: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Text(
          'Toque aqui para exibir os valores',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
      child: IconButton(
        icon: Icon(
          ref.watch(privacyProvider) ? Icons.visibility_off : Icons.visibility,
          color: const Color(0xFF8A6A00),
        ),
        onPressed: () {
          ref.read(privacyProvider.notifier).toggle();
          _tooltipController.hideTooltip();
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../network/connectivity_provider.dart';
import 'mppb_app_bar.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context, bool isAuthenticated, bool isOnline) {
    final location = GoRouterState.of(context).matchedLocation;
    
    if (isAuthenticated) {
      if (location == '/restrito') return 0;
      if (location == '/carteira') return 1; // actually it's contracheque at 1, carteira at 2? Let's check below.
      if (!isOnline) return 0;
      if (location == '/contracheque') return 1;
      if (location == '/carteira') return 2;
      return 3; // Outras páginas restritas ficarão no slot 4
    } else {
      if (location == '/') return 0;
      if (location == '/noticias') return 1;
      if (location == '/diario_oficial') return 2;
      return 3;
    }
  }

  void _onItemTapped(int index, BuildContext context, bool isAuthenticated) {
    if (isAuthenticated) {
      switch (index) {
        case 0:
          context.go('/restrito');
          break;
        case 1:
          context.go('/contracheque');
          break;
        case 2:
          context.go('/carteira');
          break;
        case 3:
          _showMaisMenu(context, isAuthenticated);
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/noticias');
          break;
        case 2:
          context.go('/diario_oficial');
          break;
        case 3:
          _showMaisMenu(context, isAuthenticated);
          break;
      }
    }
  }

  void _showMaisMenu(BuildContext context, bool isAuthenticated) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFDF7EF),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Color(0x29432B1D), blurRadius: 40, offset: Offset(0, -8)),
            ],
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Serviços',
                        style: TextStyle(
                          color: Color(0xFF2F2923),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C7A54).withAlpha(36),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, color: Color(0xFF73543E), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.start,
                    children: isAuthenticated ? [
                      SizedBox(width: (MediaQuery.of(context).size.width - 70) / 4, child: _buildMenuShortcut(ctx, Icons.newspaper, 'Notícias', '/noticias')),
                      SizedBox(width: (MediaQuery.of(context).size.width - 70) / 4, child: _buildMenuShortcut(ctx, Icons.description, 'Diário', '/diario_oficial')),
                      SizedBox(width: (MediaQuery.of(context).size.width - 70) / 4, child: _buildMenuShortcut(ctx, Icons.assignment, 'Pagamentos', '/pagamentos')),
                      SizedBox(width: (MediaQuery.of(context).size.width - 70) / 4, child: _buildMenuShortcut(ctx, Icons.flight_takeoff, 'Férias', '/ferias')),
                      SizedBox(width: (MediaQuery.of(context).size.width - 70) / 4, child: _buildMenuShortcut(ctx, Icons.gavel, 'Processos', '/processos')),
                    ] : [
                      SizedBox(width: (MediaQuery.of(context).size.width - 70) / 4, child: _buildMenuShortcut(ctx, Icons.gavel, 'Processos', '/processos')),
                      SizedBox(width: (MediaQuery.of(context).size.width - 70) / 4, child: _buildMenuShortcut(ctx, Icons.lock, 'Área Restrita', '/login')),
                    ],
                  ),
                ],
          ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuShortcut(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(route);
        });
      },
      child: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 12, left: 8, right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF9C7A54).withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8F2A1D).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF8F2A1D), size: 22),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFF3A2416),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int selectedIndex, bool isAuthenticated, VoidCallback onTap) {
    final isSelected = index == selectedIndex;
    
    // As cores do layout restrito (amarelo)
    final selectedBgColor = const Color(0xFFF4DC96);
    final selectedIconColor = const Color(0xFF8A6A00);
    final selectedTextColor = const Color(0xFF8A6A00);
    final unselectedColor = const Color(0xFF8A8F99);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: const Color(0xFF9C7A54).withAlpha(25),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: selectedBgColor,
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? selectedIconColor : unselectedColor),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? selectedTextColor : unselectedColor,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isOnline = ref.watch(connectivityProvider);
    final location = GoRouterState.of(context).matchedLocation;

    final isHiddenPage = location == '/login' || location.contains('/detalhes');
    final selectedIndex = _calculateSelectedIndex(context, isAuthenticated, isOnline);

    String label4 = 'Mais';
    IconData icon4 = Icons.grid_view;
    if (isAuthenticated) {
      if (location == '/pagamentos') {
        label4 = 'Pagamentos';
        icon4 = Icons.assignment;
      } else if (location == '/ferias') {
        label4 = 'Férias';
        icon4 = Icons.flight_takeoff;
      } else if (location == '/processos') {
        label4 = 'Processos';
        icon4 = Icons.gavel;
      } else if (location == '/noticias') {
        label4 = 'Notícias';
        icon4 = Icons.newspaper;
      } else if (location == '/diario_oficial') {
        label4 = 'Diário';
        icon4 = Icons.description;
      }
    } else {
      if (location == '/processos') {
        label4 = 'Processos';
        icon4 = Icons.gavel;
      } else if (location == '/login') {
        label4 = 'Login';
        icon4 = Icons.lock;
      }
    }

    return Scaffold(
      appBar: isHiddenPage ? null : const MppbAppBar(),
      body: child,
      bottomNavigationBar: isHiddenPage 
        ? null 
        : Container(
            height: 82,
            padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(245),
              border: Border(top: BorderSide(color: const Color(0xFF9C7A54).withAlpha(56), width: 1.0)),
            ),
            child: Row(
              children: isAuthenticated 
                ? isOnline
                  ? [
                      _buildNavItem(0, Icons.home, 'Início', selectedIndex, isAuthenticated, () => _onItemTapped(0, context, isAuthenticated)),
                      const SizedBox(width: 4),
                      _buildNavItem(1, Icons.receipt_long, 'Contracheque', selectedIndex, isAuthenticated, () => _onItemTapped(1, context, isAuthenticated)),
                      const SizedBox(width: 4),
                      _buildNavItem(2, Icons.badge, 'Carteira', selectedIndex, isAuthenticated, () => _onItemTapped(2, context, isAuthenticated)),
                      const SizedBox(width: 4),
                      _buildNavItem(3, icon4, label4, selectedIndex, isAuthenticated, () => _onItemTapped(3, context, isAuthenticated)),
                    ]
                  : [
                      _buildNavItem(0, Icons.home, 'Início', selectedIndex, isAuthenticated, () => _onItemTapped(0, context, isAuthenticated)),
                      const SizedBox(width: 4),
                      _buildNavItem(1, Icons.badge, 'Carteira', selectedIndex, isAuthenticated, () => _onItemTapped(2, context, isAuthenticated)),
                      const Spacer(),
                      const Spacer(),
                    ]
                : [
                    _buildNavItem(0, Icons.home, 'Início', selectedIndex, isAuthenticated, () => _onItemTapped(0, context, isAuthenticated)),
                    const SizedBox(width: 4),
                    _buildNavItem(1, Icons.newspaper, 'Notícias', selectedIndex, isAuthenticated, () => _onItemTapped(1, context, isAuthenticated)),
                    const SizedBox(width: 4),
                    _buildNavItem(2, Icons.description, 'Diário', selectedIndex, isAuthenticated, () => _onItemTapped(2, context, isAuthenticated)),
                    const SizedBox(width: 4),
                    _buildNavItem(3, icon4, label4, selectedIndex, isAuthenticated, () => _onItemTapped(3, context, isAuthenticated)),
                  ],
            ),
          ),
    );
  }
}

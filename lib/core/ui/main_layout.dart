import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../network/connectivity_provider.dart';
import 'mppb_app_bar.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  int _calculateSelectedIndex(
    BuildContext context,
    bool isAuthenticated,
    bool isOnline,
  ) {
    final location = GoRouterState.of(context).matchedLocation;

    if (isAuthenticated) {
      if (location == '/restrito') return 0;
      if (!isOnline) {
        if (location == '/carteira') return 3;
        return 0;
      }
      if (location == '/contracheque') return 1;
      if (location == '/carteira') return 3;
      return 4; // Outras páginas restritas ficam no último atalho.
    } else {
      if (location == '/') return 0;
      if (location == '/processos') return 1;
      if (location == '/diario_oficial') return 3;
      if (location == '/noticias') return 4;
      return 0;
    }
  }

  void _onItemTapped(
    int index,
    BuildContext context,
    bool isAuthenticated, {
    String? extraRoute,
  }) {
    if (isAuthenticated) {
      switch (index) {
        case 0:
          context.go('/restrito');
          break;
        case 1:
          context.go('/contracheque');
          break;
        case 2:
          _showMaisMenu(context, isAuthenticated);
          break;
        case 3:
          context.go('/carteira');
          break;
        case 4:
          context.go(extraRoute ?? '/concessao-folga');
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/processos');
          break;
        case 2:
          _showMaisMenu(context, isAuthenticated);
          break;
        case 3:
          context.go('/diario_oficial');
          break;
        case 4:
          context.go('/noticias');
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x29432B1D),
                blurRadius: 40,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 32,
              ),
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
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF73543E),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.start,
                    children: isAuthenticated
                        ? [
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.newspaper,
                                'Notícias',
                                '/noticias',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.description,
                                'Diário',
                                '/diario_oficial',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.assignment,
                                'Pagamentos',
                                '/pagamentos',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.event_available,
                                'Concessões',
                                '/concessao-folga',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.assignment_ind,
                                'Designações',
                                '/designacoes',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.gavel,
                                'Processos',
                                '/processos',
                              ),
                            ),
                          ]
                        : [
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.newspaper,
                                'Notícias',
                                '/noticias',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.description,
                                'Diário',
                                '/diario_oficial',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.gavel,
                                'Processos',
                                '/processos',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.lock,
                                'Área Restrita',
                                '/login',
                              ),
                            ),
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

  Widget _buildMenuShortcut(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
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

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int selectedIndex,
    VoidCallback onTap,
  ) {
    final isSelected = index == selectedIndex;

    const selectedBgColor = Color(0xFFFFF0C2);
    const selectedIconColor = Color(0xFFA96A1D);
    const selectedTextColor = Color(0xFF5E421E);
    const unselectedColor = Color(0xFF8B8177);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: const Color(0xFF9C7A54).withAlpha(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: isSelected
              ? BoxDecoration(
                  color: selectedBgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x55E5B84C)),
                )
              : null,
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 21,
                color: isSelected ? selectedIconColor : unselectedColor,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? selectedTextColor : unselectedColor,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2F2923), Color(0xFF181310)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0x66E5B84C), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3D2F2923),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Color(0xFFFFF8EA),
            size: 34,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar({
    required BuildContext context,
    required bool isAuthenticated,
    required bool isOnline,
    required int selectedIndex,
    required IconData extraIcon,
    required String extraLabel,
    required String extraRoute,
  }) {
    final children = isAuthenticated
        ? isOnline
              ? [
                  _buildNavItem(
                    0,
                    Icons.home_rounded,
                    'Início',
                    selectedIndex,
                    () => _onItemTapped(0, context, isAuthenticated),
                  ),
                  _buildNavItem(
                    1,
                    Icons.receipt_long_rounded,
                    'Contracheque',
                    selectedIndex,
                    () => _onItemTapped(1, context, isAuthenticated),
                  ),
                  _buildMoreButton(
                    () => _onItemTapped(2, context, isAuthenticated),
                  ),
                  _buildNavItem(
                    3,
                    Icons.badge_rounded,
                    'Carteira',
                    selectedIndex,
                    () => _onItemTapped(3, context, isAuthenticated),
                  ),
                  _buildNavItem(
                    4,
                    extraIcon,
                    extraLabel,
                    selectedIndex,
                    () => _onItemTapped(
                      4,
                      context,
                      isAuthenticated,
                      extraRoute: extraRoute,
                    ),
                  ),
                ]
              : [
                  _buildNavItem(
                    0,
                    Icons.home_rounded,
                    'Início',
                    selectedIndex,
                    () => _onItemTapped(0, context, isAuthenticated),
                  ),
                  const Spacer(),
                  _buildMoreButton(
                    () => _onItemTapped(2, context, isAuthenticated),
                  ),
                  const Spacer(),
                  _buildNavItem(
                    3,
                    Icons.badge_rounded,
                    'Carteira',
                    selectedIndex,
                    () => _onItemTapped(3, context, isAuthenticated),
                  ),
                ]
        : [
            _buildNavItem(
              0,
              Icons.home_rounded,
              'Início',
              selectedIndex,
              () => _onItemTapped(0, context, isAuthenticated),
            ),
            _buildNavItem(
              1,
              Icons.gavel_rounded,
              'Processos',
              selectedIndex,
              () => _onItemTapped(1, context, isAuthenticated),
            ),
            _buildMoreButton(() => _onItemTapped(2, context, isAuthenticated)),
            _buildNavItem(
              3,
              Icons.description_rounded,
              'Diário',
              selectedIndex,
              () => _onItemTapped(3, context, isAuthenticated),
            ),
            _buildNavItem(
              4,
              Icons.newspaper_rounded,
              'Notícias',
              selectedIndex,
              () => _onItemTapped(4, context, isAuthenticated),
            ),
          ];

    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(color: Color(0x00FFFFFF)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            height: 78,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF4).withAlpha(238),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0x66FFFFFF), width: 1.3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x303A241D),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
                BoxShadow(
                  color: Color(0xCCFFFFFF),
                  blurRadius: 14,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(children: children),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final hasInternet = ref.watch(connectivityProvider);
    final isOnline = hasInternet;
    final location = GoRouterState.of(context).matchedLocation;

    final isHiddenPage = location == '/login' || location.contains('/detalhes');
    final selectedIndex = _calculateSelectedIndex(
      context,
      isAuthenticated,
      isOnline,
    );

    String label4 = 'Folga';
    IconData icon4 = Icons.event_available_rounded;
    String route4 = '/concessao-folga';
    if (isAuthenticated) {
      if (location == '/pagamentos') {
        label4 = 'Pagamentos';
        icon4 = Icons.assignment_rounded;
        route4 = '/pagamentos';
      } else if (location == '/concessao-folga') {
        label4 = 'Folga';
        icon4 = Icons.event_available_rounded;
        route4 = '/concessao-folga';
      } else if (location == '/designacoes') {
        label4 = 'Designações';
        icon4 = Icons.assignment_ind_rounded;
        route4 = '/designacoes';
      } else if (location == '/processos') {
        label4 = 'Processos';
        icon4 = Icons.gavel_rounded;
        route4 = '/processos';
      } else if (location == '/noticias') {
        label4 = 'Notícias';
        icon4 = Icons.newspaper_rounded;
        route4 = '/noticias';
      } else if (location == '/diario_oficial') {
        label4 = 'Diário';
        icon4 = Icons.description_rounded;
        route4 = '/diario_oficial';
      }
    }

    return Scaffold(
      extendBody: !isHiddenPage,
      appBar: isHiddenPage ? null : const MppbAppBar(),
      body: child,
      bottomNavigationBar: isHiddenPage
          ? null
          : _buildBottomNavBar(
              context: context,
              isAuthenticated: isAuthenticated,
              isOnline: isOnline,
              selectedIndex: selectedIndex,
              extraIcon: icon4,
              extraLabel: label4,
              extraRoute: route4,
            ),
    );
  }
}

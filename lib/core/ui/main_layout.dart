import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../network/connectivity_provider.dart';
import 'mppb_app_bar.dart';
import 'widgets/services_bottom_sheet.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  bool _isNavVisible = true;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse && _isNavVisible) {
        setState(() => _isNavVisible = false);
      } else if (notification.direction == ScrollDirection.forward &&
          !_isNavVisible) {
        setState(() => _isNavVisible = true);
      }
    }

    if (notification.metrics.pixels <= 12 && !_isNavVisible) {
      setState(() => _isNavVisible = true);
    }

    return false;
  }

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
      if (location == '/ouvidoria' || location == '/noticias') return 4;
      return -1;
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
          ServicesBottomSheet.show(context, isAuthenticated);
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
          ServicesBottomSheet.show(context, isAuthenticated);
          break;
        case 3:
          context.go('/diario_oficial');
          break;
        case 4:
          context.go(extraRoute ?? '/ouvidoria');
          break;
      }
    }
  }

  int _getFlexForLabel(String label) {
    switch (label) {
      case 'Contracheque':
        return 16;
      case 'Designações':
      case 'Pagamentos':
        return 14;
      case 'Processos':
      case 'Ouvidoria':
        return 13;
      case 'Carteira':
      case 'Notícias':
        return 12;
      case 'Diário':
        return 11;
      case 'Início':
      case 'Folga':
      default:
        return 10;
    }
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

    return Flexible(
      flex: _getFlexForLabel(label),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: const Color(0xFF9C7A54).withAlpha(25),
              highlightColor: const Color(0xFF9C7A54).withAlpha(15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 40),
                decoration: isSelected
                    ? BoxDecoration(
                        color: selectedBgColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x55E5B84C)),
                      )
                    : BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.transparent),
                      ),
                padding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: isSelected ? 10 : 4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected ? selectedIconColor : unselectedColor,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 9.5,
                          letterSpacing: 0,
                          color: isSelected
                              ? selectedTextColor
                              : unselectedColor,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(VoidCallback onTap, bool isHome) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: isHome ? 0.0 : 54.0,
      height: isHome ? 0.0 : 50.0,
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      child: OverflowBox(
        maxWidth: 54.0,
        maxHeight: 50.0,
        minWidth: 0.0,
        minHeight: 0.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          opacity: isHome ? 0.0 : 1.0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            scale: isHome ? 0.85 : 1.0,
            child: GestureDetector(
              onTap: isHome ? null : onTap,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF8F2A1D),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3D8F2A1D),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFFFFF8EA),
                  size: 30,
                ),
              ),
            ),
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
    required bool isHome,
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
                  const SizedBox(width: 54),
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
                  const SizedBox(width: 54),
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
            const SizedBox(width: 54),
            _buildNavItem(
              3,
              Icons.description_rounded,
              'Diário',
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
          ];

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dockWidth = math.min(screenWidth - 40, 350.0);
    final sideInset = math.max(20.0, (screenWidth - dockWidth) / 2);

    return SizedBox(
      height: 64 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: sideInset,
            right: sideInset,
            bottom: bottomInset + 6,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF4).withAlpha(245),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0x66FFFFFF), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x303A241D),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(children: children),
            ),
          ),
          Positioned(
            top: 0,
            child: _buildMoreButton(
              () => _onItemTapped(2, context, isAuthenticated),
              isHome,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final hasInternet = ref.watch(connectivityProvider);
    final isOnline = hasInternet;
    final location = GoRouterState.of(context).matchedLocation;

    final isHiddenPage = location == '/login' || location.contains('/detalhes');
    final isHome = location == '/' || location == '/restrito';
    final isDockHidden = isHiddenPage || isHome;
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
    } else {
      if (location == '/ouvidoria') {
        label4 = 'Ouvidoria';
        icon4 = Icons.record_voice_over;
        route4 = '/ouvidoria';
      } else {
        label4 = 'Notícias';
        icon4 = Icons.newspaper_rounded;
        route4 = '/noticias';
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: !isHiddenPage,
      extendBody: !isDockHidden,
      appBar: isHiddenPage ? null : const MppbAppBar(),
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: widget.child,
      ),
      bottomNavigationBar: isDockHidden
          ? null
          : IgnorePointer(
              ignoring: !_isNavVisible,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeInOutCubic,
                offset: _isNavVisible ? Offset.zero : const Offset(0, 1.18),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  opacity: _isNavVisible ? 1 : 0,
                  child: _buildBottomNavBar(
                    context: context,
                    isAuthenticated: isAuthenticated,
                    isOnline: isOnline,
                    selectedIndex: selectedIndex,
                    extraIcon: icon4,
                    extraLabel: label4,
                    extraRoute: route4,
                    isHome: isHome,
                  ),
                ),
              ),
            ),
    );
  }
}

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../network/connectivity_provider.dart';
import 'mppb_app_bar.dart';
import 'responsive_layout.dart';
import 'widgets/services_bottom_sheet.dart';

class _DockSlot {
  const _DockSlot.item({
    required this.index,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : width = null;

  const _DockSlot.space(this.width)
    : index = null,
      icon = null,
      label = null,
      onTap = null;

  final int? index;
  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;
  final double? width;
}

class _DockIndicatorMetrics {
  const _DockIndicatorMetrics({required this.left, required this.width});

  final double left;
  final double width;
}

class MainLayout extends ConsumerStatefulWidget {
  static const double dockStructuralHeight = 68;
  static const double dockContentGap = 16;
  static const double authenticatedHorizontalPadding = 16;
  static const double authenticatedSectionGap = 12;

  static double horizontalPadding(BuildContext context) {
    final metrics = MppbResponsive.of(context);
    return metrics.windowClass == MppbWindowClass.compact
        ? authenticatedHorizontalPadding
        : metrics.horizontalPadding;
  }

  static double publicHorizontalPadding(BuildContext context) {
    return MppbResponsive.of(context).horizontalPadding;
  }

  static double contentMaxWidth(BuildContext context) {
    return MppbResponsive.of(context).contentMaxWidth;
  }

  static double contentBottomPadding(BuildContext context) {
    final metrics = MppbResponsive.of(context);
    final gap = metrics.usesWideLayout ? 24.0 : dockContentGap;
    return MediaQuery.paddingOf(context).bottom + gap;
  }

  static double authenticatedContentTopPadding(BuildContext context) {
    final metrics = MppbResponsive.of(context);
    return metrics.usesWideLayout ? 20 : authenticatedSectionGap;
  }

  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _isNavVisible = true;
  late final AnimationController _crestIntroController;
  bool _showCrestIntro = false;
  bool _hasPlayedAuthenticatedIntro = false;

  @override
  void initState() {
    super.initState();
    _crestIntroController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1150),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _showCrestIntro = false);
          }
        });
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(connectivityProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _crestIntroController.dispose();
    super.dispose();
  }

  void _maybeStartCrestIntro({
    required bool isAuthenticated,
    required String location,
  }) {
    if (!isAuthenticated) {
      _hasPlayedAuthenticatedIntro = false;
      return;
    }

    if (_hasPlayedAuthenticatedIntro || location != '/restrito') {
      return;
    }

    _hasPlayedAuthenticatedIntro = true;
    _showCrestIntro = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _crestIntroController.forward(from: 0);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(connectivityProvider.notifier).refresh();
    }
  }

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
          context.go(extraRoute ?? '/concessao-afastamento');
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
      case 'Contr.':
      case 'Pagam.':
      case 'Desig.':
      case 'Proc.':
      case 'Ouvid.':
      case 'Cart.':
      case 'Notíc.':
      case 'Diár.':
      case 'Perfil':
        return 11;
      case 'Início':
      case 'Afast.':
      default:
        return 10;
    }
  }

  String _getAccessibleLabelFor(String label) {
    switch (label) {
      case 'Contr.':
        return 'Contracheque';
      case 'Cart.':
        return 'Carteira Funcional';
      case 'Proc.':
        return 'Processos';
      case 'Diár.':
        return 'Diário Oficial';
      case 'Afast.':
        return 'Concessão de Afastamento';
      case 'Pagam.':
        return 'Pagamentos';
      case 'Desig.':
        return 'Designações';
      case 'Notíc.':
        return 'Notícias';
      case 'Ouvid.':
        return 'Ouvidoria';
      case 'Início':
        return 'Início';
      case 'Perfil':
        return 'Meu Perfil';
      default:
        return label;
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
    final accessibleLabel = _getAccessibleLabelFor(label);
    final metrics = MppbResponsive.of(context);
    final itemHeight = metrics.isTablet ? 42.0 : 40.0;
    final iconSize = metrics.isTablet ? 18.0 : 17.0;
    final fontSize = metrics.isTablet ? 9.5 : 9.0;

    const selectedIconColor = Color(0xFFF7F8F6);
    const selectedTextColor = Color(0xFFF7F8F6);
    const unselectedColor = Color(0xDDF7F8F6);

    return Flexible(
      flex: _getFlexForLabel(label),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: accessibleLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: const Color(0xFFF7F8F6).withAlpha(18),
              highlightColor: const Color(0xFFF7F8F6).withAlpha(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: itemHeight,
                alignment: Alignment.center,
                constraints: const BoxConstraints(minWidth: 42, minHeight: 37),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: isSelected ? 8 : 3,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: iconSize,
                        color: isSelected ? selectedIconColor : unselectedColor,
                      ),
                      const SizedBox(height: 1),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: fontSize,
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
      ),
    ),
  );
}

  Widget _buildMoreButton(VoidCallback onTap, bool isHome) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: isHome ? 0.0 : 50.0,
      height: isHome ? 0.0 : 46.0,
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      child: OverflowBox(
        maxWidth: 50.0,
        maxHeight: 46.0,
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
            child: Semantics(
              button: true,
              label: 'Mais serviços',
              child: Tooltip(
                message: 'Mais serviços',
                child: GestureDetector(
                  onTap: isHome ? null : onTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF202322),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0x26FFFFFF)),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFFF7F8F6),
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _DockIndicatorMetrics? _calculateDockIndicator(
    List<_DockSlot> slots,
    int selectedIndex,
    double width,
  ) {
    final selectedSlot = slots.where((slot) => slot.index == selectedIndex);
    if (selectedSlot.isEmpty) return null;

    final fixedWidth = slots.fold<double>(
      0,
      (sum, slot) => sum + (slot.width ?? 0),
    );
    final totalFlex = slots.fold<int>(
      0,
      (sum, slot) =>
          sum + (slot.label == null ? 0 : _getFlexForLabel(slot.label!)),
    );
    if (totalFlex == 0) return null;

    final flexWidth = math.max(0.0, width - fixedWidth);
    var offset = 0.0;

    for (final slot in slots) {
      final slotWidth =
          slot.width ?? flexWidth * _getFlexForLabel(slot.label!) / totalFlex;
      if (slot.index == selectedIndex) {
        final indicatorWidth = math.min(math.max(slotWidth - 4, 48.0), 64.0);
        return _DockIndicatorMetrics(
          left: offset + (slotWidth - indicatorWidth) / 2,
          width: indicatorWidth,
        );
      }
      offset += slotWidth;
    }

    return null;
  }

  Widget _buildDockIndicator(List<_DockSlot> slots, int selectedIndex) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _calculateDockIndicator(
          slots,
          selectedIndex,
          constraints.maxWidth,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            if (metrics != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeInOutCubic,
                left: metrics.left,
                top: 4,
                width: metrics.width,
                height: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0x0FFFFFFF),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0x38FFFFFF),
                              width: 0.55,
                            ),
                            gradient: const RadialGradient(
                              center: Alignment.topCenter,
                              radius: 1.1,
                              colors: [
                                Color(0x30FFFFFF),
                                Color(0x12FFFFFF),
                                Color(0x08000000),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x44000000),
                                blurRadius: 12,
                                spreadRadius: -1,
                              ),
                              BoxShadow(
                                color: Color(0x24FFFFFF),
                                blurRadius: 10,
                                spreadRadius: -3,
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, -0.18),
                          child: Container(
                            width: metrics.width * 0.74,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const RadialGradient(
                                colors: [Color(0x24FFFFFF), Color(0x00FFFFFF)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Row(
              children: slots.map((slot) {
                if (slot.width != null) {
                  return SizedBox(width: slot.width);
                }

                return _buildNavItem(
                  slot.index!,
                  slot.icon!,
                  slot.label!,
                  selectedIndex,
                  slot.onTap!,
                );
              }).toList(),
            ),
          ],
        );
      },
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
    final slots = isAuthenticated
        ? isOnline
              ? [
                  _DockSlot.item(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: 'Início',
                    onTap: () => _onItemTapped(0, context, isAuthenticated),
                  ),
                  _DockSlot.item(
                    index: 1,
                    icon: Icons.receipt_long_rounded,
                    label: 'Contr.',
                    onTap: () => _onItemTapped(1, context, isAuthenticated),
                  ),
                  const _DockSlot.space(52),
                  _DockSlot.item(
                    index: 3,
                    icon: Icons.badge_rounded,
                    label: 'Cart.',
                    onTap: () => _onItemTapped(3, context, isAuthenticated),
                  ),
                  _DockSlot.item(
                    index: 4,
                    icon: extraIcon,
                    label: extraLabel,
                    onTap: () => _onItemTapped(
                      4,
                      context,
                      isAuthenticated,
                      extraRoute: extraRoute,
                    ),
                  ),
                ]
              : [
                  _DockSlot.item(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: 'Início',
                    onTap: () => _onItemTapped(0, context, isAuthenticated),
                  ),
                  const _DockSlot.space(52),
                  const _DockSlot.space(52),
                  _DockSlot.item(
                    index: 3,
                    icon: Icons.badge_rounded,
                    label: 'Cart.',
                    onTap: () => _onItemTapped(3, context, isAuthenticated),
                  ),
                ]
        : [
            _DockSlot.item(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Início',
              onTap: () => _onItemTapped(0, context, isAuthenticated),
            ),
            _DockSlot.item(
              index: 1,
              icon: Icons.gavel_rounded,
              label: 'Proc.',
              onTap: () => _onItemTapped(1, context, isAuthenticated),
            ),
            const _DockSlot.space(52),
            _DockSlot.item(
              index: 3,
              icon: Icons.description_rounded,
              label: 'Diár.',
              onTap: () => _onItemTapped(3, context, isAuthenticated),
            ),
            _DockSlot.item(
              index: 4,
              icon: extraIcon,
              label: extraLabel,
              onTap: () => _onItemTapped(
                4,
                context,
                isAuthenticated,
                extraRoute: extraRoute,
              ),
            ),
          ];

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final metrics = MppbResponsive.of(context);
    final dockMaxWidth = metrics.usesWideLayout ? 460.0 : 336.0;
    final horizontalInset = metrics.usesWideLayout
        ? metrics.horizontalPadding
        : 28.0;
    final dockWidth = math.min(
      screenWidth - (horizontalInset * 2),
      dockMaxWidth,
    );
    final sideInset = math.max(horizontalInset, (screenWidth - dockWidth) / 2);
    final dockHeight = metrics.isTablet ? 52.0 : 48.0;
    final dockRadius = dockHeight / 2;

    return SizedBox(
      height: MainLayout.dockStructuralHeight + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: sideInset,
            right: sideInset,
            bottom: bottomInset + 12,
            child: Container(
              height: dockHeight,
              padding: EdgeInsets.symmetric(
                horizontal: metrics.isTablet ? 8 : 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF202322).withAlpha(245),
                borderRadius: BorderRadius.circular(dockRadius),
                border: Border.all(color: const Color(0x26FFFFFF), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33202322),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: _buildDockIndicator(slots, selectedIndex),
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

    String label4 = 'Afast.';
    IconData icon4 = Icons.event_available_rounded;
    String route4 = '/concessao-afastamento';
    if (isAuthenticated) {
      if (location == '/pagamentos') {
        label4 = 'Pagam.';
        icon4 = Icons.assignment_rounded;
        route4 = '/pagamentos';
      } else if (location == '/concessao-afastamento') {
        label4 = 'Afast.';
        icon4 = Icons.event_available_rounded;
        route4 = '/concessao-afastamento';
      } else if (location == '/designacoes') {
        label4 = 'Desig.';
        icon4 = Icons.assignment_ind_rounded;
        route4 = '/designacoes';
      } else if (location == '/processos') {
        label4 = 'Proc.';
        icon4 = Icons.gavel_rounded;
        route4 = '/processos';
      } else if (location == '/noticias') {
        label4 = 'Notíc.';
        icon4 = Icons.newspaper_rounded;
        route4 = '/noticias';
      } else if (location == '/diario_oficial') {
        label4 = 'Diár.';
        icon4 = Icons.description_rounded;
        route4 = '/diario_oficial';
      } else if (location == '/perfil') {
        label4 = 'Perfil';
        icon4 = Icons.account_circle_rounded;
        route4 = '/perfil';
      }
    } else {
      if (location == '/ouvidoria') {
        label4 = 'Ouvid.';
        icon4 = Icons.record_voice_over;
        route4 = '/ouvidoria';
      } else {
        label4 = 'Notíc.';
        icon4 = Icons.newspaper_rounded;
        route4 = '/noticias';
      }
    }

    _maybeStartCrestIntro(isAuthenticated: isAuthenticated, location: location);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final homeRoute = isAuthenticated ? '/restrito' : '/';
        if (location != homeRoute) {
          context.go(homeRoute);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            extendBodyBehindAppBar: false,
            extendBody: !isDockHidden,
            appBar: isHiddenPage
                ? null
                : PreferredSize(
                    preferredSize: Size.fromHeight(
                      MppbAppBar.heightForContext(context, isAuthenticated),
                    ),
                    child: MppbAppBar(showLeadingCrest: !_showCrestIntro),
                  ),
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
                      offset: _isNavVisible
                          ? Offset.zero
                          : const Offset(0, 1.18),
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
          ),
          if (_showCrestIntro && !isHiddenPage)
            _CrestIntroOverlay(controller: _crestIntroController),
        ],
      ),
    );
  }
}

class _CrestIntroOverlay extends StatelessWidget {
  const _CrestIntroOverlay({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    final metrics = MppbResponsive.of(context);
    final targetSize = metrics.isTablet ? 34.0 : 30.0;
    final startSize = metrics.isTablet ? 116.0 : 104.0;
    final toolbarHeight = MppbAppBar.heightForContext(context, true);
    final safeTop = MediaQuery.paddingOf(context).top;
    final targetX = (metrics.isTablet ? 24.0 : 14.0) + (targetSize / 2);
    final targetY = safeTop + (toolbarHeight / 2);

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final startX = constraints.maxWidth / 2;
            final startY = constraints.maxHeight / 2;

            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final value = controller.value;
                final move = Curves.easeInOutCubic.transform(
                  ((value - 0.22) / 0.78).clamp(0.0, 1.0),
                );
                final intro = Curves.easeOutBack.transform(
                  (value / 0.24).clamp(0.0, 1.0),
                );
                final x = lerpDouble(startX, targetX, move)!;
                final y = lerpDouble(startY, targetY, move)!;
                final size = lerpDouble(startSize, targetSize, move)! * intro;
                final scrimOpacity = (1 - move) * 0.92;
                final crestOpacity = value < 0.94
                    ? 1.0
                    : 1 - ((value - 0.94) / 0.06).clamp(0.0, 1.0);

                return Stack(
                  children: [
                    Positioned.fill(
                      child: ColoredBox(
                        color: const Color(
                          0xFFF7F8F6,
                        ).withValues(alpha: scrimOpacity),
                      ),
                    ),
                    Positioned(
                      left: x - (size / 2),
                      top: y - (size / 2),
                      width: size,
                      height: size,
                      child: Opacity(
                        opacity: crestOpacity,
                        child: Image.asset(
                          'assets/images/brasao_mppb_sem_fundo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

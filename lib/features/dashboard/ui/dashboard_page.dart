import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../carteira/models/usuario_carteira.dart';
import '../../carteira/providers/carteira_provider.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/responsive_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../noticias/providers/noticia_provider.dart';
import '../../noticias/models/noticia.dart';
import '../../noticias/ui/noticias_page.dart';
import '../../noticias/utils/noticia_share.dart';
import '../../contatos/ui/widgets/secao_institucional.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with TickerProviderStateMixin {
  PageController? _pageController;
  double? _currentViewportFraction;
  Timer? _autoPlayTimer;
  int _currentNewsIndex = 0;
  int _carouselNewsCount = 0;
  bool _isNewsAutoPlayPaused = false;

  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnimation;
  late final AnimationController _newsAutoPlayProgressController;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _newsAutoPlayProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    Future.microtask(() {
      ref.read(noticiaProvider.notifier).fetchNoticias();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricSetup();
    });
  }

  Future<void> _checkBiometricSetup() async {
    final authState = ref.read(authProvider);
    if (!authState.justLoggedIn) return;

    final secureStorage = ref.read(secureStorageProvider);
    final asked = await secureStorage.read(key: 'biometrics_asked');
    if (asked == 'true') return;

    final localAuth = LocalAuthentication();
    final bool isSupported;
    try {
      isSupported = await localAuth.isDeviceSupported();
    } on MissingPluginException {
      await ref.read(authProvider.notifier).dismissBiometricPrompt();
      return;
    } catch (_) {
      await ref.read(authProvider.notifier).dismissBiometricPrompt();
      return;
    }

    if (!isSupported) {
      await ref.read(authProvider.notifier).dismissBiometricPrompt();
      return;
    }

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _BiometricPromptDialog(),
    );

    if (result == true) {
      final bool authenticated;
      try {
        authenticated = await localAuth.authenticate(
          localizedReason: 'Confirme sua identidade para habilitar a biometria',
          biometricOnly: false,
          persistAcrossBackgrounding: true,
        );
      } on MissingPluginException {
        await ref.read(authProvider.notifier).dismissBiometricPrompt();
        return;
      } catch (_) {
        await ref.read(authProvider.notifier).dismissBiometricPrompt();
        return;
      }

      if (authenticated) {
        await ref.read(authProvider.notifier).enableBiometricLogin();
      } else {
        await ref.read(authProvider.notifier).dismissBiometricPrompt();
      }
    } else {
      await ref.read(authProvider.notifier).dismissBiometricPrompt();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _blinkController.dispose();
    _newsAutoPlayProgressController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  double _newsViewportFractionFor(MppbResponsiveMetrics responsive) {
    if (responsive.windowClass == MppbWindowClass.large) return 0.25;
    if (responsive.isTablet && responsive.isLandscape) return 0.25;
    if (responsive.usesWideLayout) return 0.32;
    return 0.92;
  }

  PageController _newsControllerFor(double viewportFraction) {
    final currentController = _pageController;
    if (currentController != null &&
        _currentViewportFraction == viewportFraction) {
      return currentController;
    }

    final initialPage = _currentNewsIndex;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _currentViewportFraction = viewportFraction;
    _pageController?.dispose();
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: viewportFraction,
      keepPage: false,
    );
    return _pageController!;
  }

  void _restartNewsAutoPlayProgress() {
    _newsAutoPlayProgressController
      ..stop()
      ..forward(from: 0);
  }

  void _syncAutoPlay(int itemCount) {
    if (_carouselNewsCount == itemCount &&
        _autoPlayTimer != null &&
        !_isNewsAutoPlayPaused) {
      return;
    }

    _carouselNewsCount = itemCount;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _newsAutoPlayProgressController.stop();

    if (_isNewsAutoPlayPaused || itemCount < 2) {
      return;
    }

    _restartNewsAutoPlayProgress();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final controller = _pageController;
      if (!mounted || controller == null || !controller.hasClients) {
        return;
      }

      final nextPage = (_currentNewsIndex + 1) % itemCount;
      controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      _restartNewsAutoPlayProgress();
    });
  }

  void _toggleNewsAutoPlay() {
    setState(() {
      _isNewsAutoPlayPaused = !_isNewsAutoPlayPaused;
    });
    _syncAutoPlay(_carouselNewsCount);
  }

  Widget _buildNewsAutoPlayControl(int itemCount) {
    if (itemCount < 2) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Tooltip(
          message: _isNewsAutoPlayPaused
              ? 'Retomar notícias'
              : 'Pausar notícias',
          child: InkWell(
            onTap: _toggleNewsAutoPlay,
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _newsAutoPlayProgressController,
                    builder: (context, _) {
                      return CircularProgressIndicator(
                        value: 1 - _newsAutoPlayProgressController.value,
                        strokeWidth: 2.6,
                        backgroundColor: const Color(0xFFE9EDF0),
                        color: const Color(0xFFD62828),
                      );
                    },
                  ),
                  Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE2E4E8)),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10101828),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isNewsAutoPlayPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      color: const Color(0xFF697370),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            itemCount,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 7,
              width: _currentNewsIndex == index ? 20 : 7,
              decoration: BoxDecoration(
                color: _currentNewsIndex == index
                    ? const Color(0xFFD62828)
                    : const Color(0x33D62828),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openNews(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  String? _newsImageUrl(Noticia noticia) {
    final url = noticia.imagemUrl?.trim();
    if (url == null || url.isEmpty) return null;
    if (kIsWeb) return null;
    return url.replaceFirst(
      'http://www.mppb.mp.br/',
      'https://www.mppb.mp.br/',
    );
  }

  void _showNewsModal(Noticia noticia) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewsDetailSheet(
        noticia: noticia,
        fallbackImageUrl: NoticiasPage.fallbackImageUrl,
        date: _dateForNews(noticia),
        readingTime: _readingTime(noticia),
        onOpenLink: () => _openNews(noticia.link),
        onShare: () => compartilharNoticia(noticia),
      ),
    );
  }

  int _readingTime(Noticia noticia) {
    final words = (noticia.resumo ?? '')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .length;
    final minutes = (words / 180).ceil();
    return minutes > 0 ? minutes : 1;
  }

  String _dateForNews(Noticia noticia) {
    final date = noticia.dataPublicacao ?? '';
    return date.split(' ').isNotEmpty ? date.split(' ')[0] : '';
  }

  String _greetingForProfile({
    required String firstName,
    required String role,
    required String type,
  }) {
    final profile = '$firstName $role $type'.toLowerCase();
    final feminineTerms = ['servidora', 'promotora', 'procuradora'];
    final masculineTerms = ['servidor', 'promotor', 'procurador'];

    if (feminineTerms.any(profile.contains)) {
      return 'Bem-vinda';
    }

    if (masculineTerms.any(profile.contains)) {
      return 'Bem-vindo';
    }

    if (firstName.toLowerCase().endsWith('a')) {
      return 'Bem-vinda';
    }

    if (firstName.toLowerCase().endsWith('o')) {
      return 'Bem-vindo';
    }

    return 'Bem-vindo';
  }

  String _capitalizeName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Usuário';
    }

    final lower = trimmed.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final carteiraState = ref.watch(carteiraProvider);
    final hasInternet = ref.watch(connectivityProvider);
    final isOnline = hasInternet;
    final usuario = carteiraState.data;
    final responsive = MppbResponsive.of(context);
    final isTablet = responsive.isTablet;
    final isWide = responsive.usesWideLayout;
    final isTabletLandscape = isTablet && responsive.isLandscape;

    final firstName = _capitalizeName(
      usuario?.nome
              ?.split(' ')
              .firstWhere((e) => e.isNotEmpty, orElse: () => 'Usuário') ??
          'Usuário',
    );
    final userRole = usuario?.cargo ?? 'Membro ou Servidor';
    final greeting = _greetingForProfile(
      firstName: firstName,
      role: userRole,
      type: usuario?.tipoCargo ?? '',
    );

    final noticiaState = ref.watch(noticiaProvider);
    final todasNoticias = noticiaState.noticias;
    final carouselNews = todasNoticias.take(isTabletLandscape ? 8 : 4).toList();
    final newsPageController = _newsControllerFor(
      _newsViewportFractionFor(responsive),
    );
    _syncAutoPlay(carouselNews.length);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(connectivityProvider.notifier).refresh();
          await Future.wait([
            ref.read(carteiraProvider.notifier).fetchCarteira(),
            ref.read(noticiaProvider.notifier).fetchNoticias(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: _dashboardHorizontalPadding(responsive),
            right: _dashboardHorizontalPadding(responsive),
            top: MainLayout.authenticatedContentTopPadding(context),
            bottom: MainLayout.contentBottomPadding(context),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MainLayout.contentMaxWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDashboardIntro(
                    context: context,
                    responsive: responsive,
                    greeting: greeting,
                    firstName: firstName,
                    userRole: userRole,
                    usuario: usuario,
                  ),

                  SizedBox(height: isTablet ? 38 : 34),

                  if (isOnline) ...[
                    _buildServicesSection(
                      context,
                      title: 'Serviços ao cidadão',
                      icon: Icons.public_rounded,
                      iconColor: const Color(0xFFD62828),
                      services: const [
                        _DashboardService(
                          title: 'Certidão',
                          subtitle: 'Extrajudicial',
                          icon: Icons.verified_outlined,
                          route: '/certidao-extrajudicial',
                        ),
                        _DashboardService(
                          title: 'Diário Oficial',
                          subtitle: 'Publicações',
                          icon: Icons.article,
                          route: '/diario_oficial',
                        ),
                        _DashboardService(
                          title: 'Ouvidoria',
                          subtitle: 'Manifestações',
                          icon: Icons.record_voice_over,
                          route: '/ouvidoria',
                        ),
                        _DashboardService(
                          title: 'Processos',
                          subtitle: 'Consulta',
                          icon: Icons.gavel,
                          route: '/processos',
                        ),
                      ],
                    ),

                    SizedBox(height: isWide ? 30 : 26),

                    _buildServicesSection(
                      context,
                      title: 'Serviços internos',
                      icon: Icons.grid_view_rounded,
                      iconColor: const Color(0xFF2563EB),
                      services: const [
                        _DashboardService(
                          title: 'Contracheque',
                          subtitle: 'Demonstrativo',
                          icon: Icons.receipt_long_rounded,
                          route: '/contracheque',
                        ),
                        _DashboardService(
                          title: 'Designações',
                          subtitle: 'Ativas',
                          icon: Icons.assignment_ind,
                          route: '/designacoes',
                        ),
                        _DashboardService(
                          title: 'Afastamento',
                          subtitle: 'Concessões',
                          icon: Icons.event_available_rounded,
                          route: '/concessao-afastamento',
                        ),
                        _DashboardService(
                          title: 'Pagamentos',
                          subtitle: 'Área Financeira',
                          icon: Icons.assignment,
                          route: '/pagamentos',
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 38 : 34),

                    Row(
                      children: [
                        const Icon(
                          Icons.newspaper_rounded,
                          color: Color(0xFFD62828),
                          size: 20,
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'Notícias',
                          style: TextStyle(
                            color: Color(0xFF202322),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () => context.go('/noticias'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD62828),
                            foregroundColor: const Color(0xFFD62828),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            minimumSize: const Size(82, 34),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFD62828)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text(
                            'Todas as notícias',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 18 : 16),

                    if (noticiaState.isLoading && carouselNews.isEmpty)
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFD62828),
                          ),
                        ),
                      )
                    else if (carouselNews.isEmpty)
                      Container(
                        constraints: const BoxConstraints(minHeight: 108),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x26343A40)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.newspaper,
                              color: Color(0xFFD62828),
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Nenhuma notícia disponível no momento.',
                                style: TextStyle(color: Color(0xFF697370)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      SizedBox(
                        height: isTabletLandscape ? 292 : 380,
                        child: PageView.builder(
                          controller: newsPageController,
                          itemCount: carouselNews.length,
                          padEnds: false,
                          onPageChanged: (index) {
                            setState(() {
                              _currentNewsIndex = index;
                            });
                            if (!_isNewsAutoPlayPaused &&
                                carouselNews.length > 1) {
                              _autoPlayTimer?.cancel();
                              _autoPlayTimer = null;
                              _syncAutoPlay(carouselNews.length);
                            }
                          },
                          itemBuilder: (context, index) {
                            final noticia = carouselNews[index];
                            String dateFormatted = noticia.dataPublicacao ?? '';
                            final parts = dateFormatted.split(' ');
                            if (parts.length > 1) {
                              dateFormatted = '${parts[0]}, ${parts[1]}';
                            }
                            final imageUrl = _newsImageUrl(noticia);
                            final cardHorizontalPadding = isTabletLandscape
                                ? 12.0
                                : 18.0;
                            final cardTopPadding = isTabletLandscape
                                ? 10.0
                                : 16.0;
                            final cardBottomPadding = isTabletLandscape
                                ? 6.0
                                : 10.0;

                            return Padding(
                              padding: EdgeInsets.only(
                                right: isTabletLandscape ? 8.0 : 12.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0x26343A40),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x14101828),
                                      blurRadius: 18,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // IMAGE
                                    Expanded(
                                      flex: isTabletLandscape ? 8 : 9,
                                      child: GestureDetector(
                                        onTap: () => _showNewsModal(noticia),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF202322),
                                                Color(0xFF2563EB),
                                                Color(0xFFD62828),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            image: imageUrl != null
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                      imageUrl,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: imageUrl == null
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.newspaper,
                                                    color: Color(0xFFD62828),
                                                    size: 42,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    // CONTENT
                                    Expanded(
                                      flex: isTabletLandscape ? 10 : 11,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: cardHorizontalPadding,
                                          right: cardHorizontalPadding,
                                          top: cardTopPadding,
                                          bottom: cardBottomPadding,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isTabletLandscape
                                                    ? 7
                                                    : 9,
                                                vertical: isTabletLandscape
                                                    ? 5
                                                    : 7,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0x1FD62828),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                (noticia.categoria ??
                                                        'Destaque')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Color(0xFFD62828),
                                                  fontSize: isTabletLandscape
                                                      ? 8.5
                                                      : 10,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.2,
                                                  height: 1.0,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: isTabletLandscape ? 6 : 8,
                                            ),
                                            Text(
                                              dateFormatted,
                                              style: TextStyle(
                                                color: Color(0xFF697370),
                                                fontSize: isTabletLandscape
                                                    ? 10.5
                                                    : 12,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(
                                              height: isTabletLandscape ? 6 : 8,
                                            ),
                                            Text(
                                              noticia.titulo,
                                              maxLines: isTabletLandscape
                                                  ? 2
                                                  : 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Color(0xFF202322),
                                                fontSize: isTabletLandscape
                                                    ? 14
                                                    : 18,
                                                fontWeight: FontWeight.w900,
                                                height: isTabletLandscape
                                                    ? 1.08
                                                    : 1.12,
                                              ),
                                            ),
                                            if (!isTabletLandscape) ...[
                                              const SizedBox(height: 8),
                                              Expanded(
                                                child: Text(
                                                  noticia.resumo ?? '',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Color(0xFF697370),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    // ACTIONS
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: cardHorizontalPadding,
                                        right: cardHorizontalPadding,
                                        bottom: isTabletLandscape ? 10 : 16,
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: isTabletLandscape
                                                ? 104
                                                : 132,
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  _showNewsModal(noticia),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFD62828,
                                                ),
                                                foregroundColor: const Color(
                                                  0xFFFFFFFF,
                                                ),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                minimumSize: Size(
                                                  0,
                                                  isTabletLandscape ? 28 : 32,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: isTabletLandscape
                                                      ? 9
                                                      : 12,
                                                  vertical: isTabletLandscape
                                                      ? 6
                                                      : 8,
                                                ),
                                                textStyle: TextStyle(
                                                  fontSize: isTabletLandscape
                                                      ? 10
                                                      : 11.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              child: const FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text('Ler notícia'),
                                                    SizedBox(width: 5),
                                                    Icon(
                                                      Icons.open_in_new,
                                                      size: 14,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          SizedBox(
                                            width: isTabletLandscape ? 32 : 38,
                                            height: isTabletLandscape ? 30 : 34,
                                            child: _DashboardNewsShareButton(
                                              onPressed: () =>
                                                  compartilharNoticia(noticia),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildNewsAutoPlayControl(carouselNews.length),
                    ],
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.wifi_off,
                              color: Color(0xFF697370),
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Você está offline',
                              style: TextStyle(
                                color: Color(0xFF202322),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Serviços online indisponíveis.\nAcesse sua Carteira Funcional acima.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF697370),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (isOnline) ...[
                    const SizedBox(height: 48),
                    const SecaoInstitucional(compacta: true),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _dashboardHorizontalPadding(MppbResponsiveMetrics responsive) {
    if (responsive.isTablet && responsive.isLandscape) {
      return 20;
    }
    return MainLayout.authenticatedHorizontalPadding;
  }

  Widget _buildDashboardIntro({
    required BuildContext context,
    required MppbResponsiveMetrics responsive,
    required String greeting,
    required String firstName,
    required String userRole,
    required UsuarioCarteira? usuario,
  }) {
    final greetingWidget = _buildGreeting(
      responsive: responsive,
      greeting: greeting,
      firstName: firstName,
    );
    final walletCard = _buildWalletCard(
      context: context,
      responsive: responsive,
      userRole: userRole,
      usuario: usuario,
    );

    if (responsive.usesWideLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 260, child: greetingWidget),
          const SizedBox(width: 24),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: walletCard,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        greetingWidget,
        SizedBox(height: responsive.isTablet ? 16 : 12),
        walletCard,
      ],
    );
  }

  Widget _buildGreeting({
    required MppbResponsiveMetrics responsive,
    required String greeting,
    required String firstName,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, responsive.isTablet ? 8 : 4, 2, 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
            text: '$greeting,\n',
            style: const TextStyle(
              color: Color(0xFF697370),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.05,
            ),
            children: [
              TextSpan(
                text: firstName,
                style: TextStyle(
                  color: const Color(0xFF202322),
                  fontSize: responsive.usesWideLayout ? 34 : 36,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard({
    required BuildContext context,
    required MppbResponsiveMetrics responsive,
    required String userRole,
    required UsuarioCarteira? usuario,
  }) {
    final compactLandscape = responsive.isTablet && responsive.isLandscape;
    final isMobile = !responsive.isTablet;
    final horizontalInset = compactLandscape
        ? 18.0
        : responsive.isTablet
        ? 24.0
        : 16.0;
    final topInset = compactLandscape
        ? 18.0
        : responsive.isTablet
        ? 24.0
        : 22.0;
    final bottomInset = compactLandscape ? 16.0 : 20.0;
    final thumbnailRight = compactLandscape
        ? 18.0
        : responsive.isTablet
        ? 24.0
        : 18.0;
    final thumbnailTop = compactLandscape
        ? 16.0
        : responsive.isTablet
        ? 16.0
        : 12.0;
    final reservedThumbnailWidth = compactLandscape
        ? 82.0
        : responsive.isTablet
        ? 104.0
        : 96.0;
    final cardHeight = compactLandscape
        ? null
        : responsive.isTablet
        ? null
        : 136.0;

    final card = InkWell(
      onTap: () => context.go('/carteira'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF202322),
          border: Border.all(color: const Color(0x33FFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24101828),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned(
                right: thumbnailRight,
                top: thumbnailTop,
                child: _WalletMiniature(
                  usuario: usuario,
                  compact: compactLandscape,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalInset,
                  topInset,
                  horizontalInset,
                  bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: reservedThumbnailWidth),
                      child: Text(
                        'Carteira Funcional',
                        style: TextStyle(
                          color: const Color(0xFFFFFFFF),
                          fontSize: responsive.isTablet ? 18 : 17,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.only(right: reservedThumbnailWidth),
                      child: Text(
                        userRole,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFDDE4DF),
                          fontSize: responsive.isTablet ? 12 : 12,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _blinkAnimation,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00A86B),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Ativa e segura',
                          style: TextStyle(
                            color: const Color(0xFFDDE4DF),
                            fontSize: responsive.isTablet ? 12 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (!isMobile) ...[
                          Text(
                            'Acessar',
                            style: TextStyle(
                              color: const Color(0xFFDDE4DF),
                              fontSize: responsive.isTablet ? 12 : 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFFDDE4DF),
                            size: 15,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isMobile)
                Positioned(
                  right: thumbnailRight + 2,
                  bottom: 22,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Acessar',
                        style: TextStyle(
                          color: Color(0xFFDDE4DF),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFDDE4DF),
                        size: 15,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (responsive.usesWideLayout) {
      return AspectRatio(aspectRatio: 1.76, child: card);
    }

    return card;
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    final responsive = MppbResponsive.of(context);
    final isTablet = responsive.isTablet;

    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x26343A40)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10101828),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                right: isTablet ? -8 : -15,
                bottom: isTablet ? -18 : -22,
                child: Icon(
                  icon,
                  color: const Color(0x24343A40),
                  size: isTablet ? 96 : 86,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 15 : 12,
                  isTablet ? 14 : 11,
                  isTablet ? 14 : 12,
                  isTablet ? 12 : 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF202322),
                        fontSize: isTablet ? 14 : 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: const Color(0xFF697370),
                        fontSize: isTablet ? 10.5 : 9.5,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_DashboardService> services,
  }) {
    final responsive = MppbResponsive.of(context);
    final keepCardsInline =
        responsive.isTablet &&
        (responsive.isLandscape || responsive.size.width >= 1000);
    final columns = keepCardsInline ? services.length : responsive.gridColumns;
    final spacing = responsive.isTablet && responsive.isLandscape ? 8.0 : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title: title, icon: icon, iconColor: iconColor),
        SizedBox(height: responsive.isTablet ? 18 : 16),
        GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: responsive.isTablet && responsive.isLandscape
                ? 92
                : responsive.isTablet
                ? 104
                : 92,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceCard(
              context,
              service.title,
              service.subtitle,
              service.icon,
              service.route,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    final responsive = MppbResponsive.of(context);

    return Row(
      children: [
        Icon(icon, color: iconColor, size: responsive.isTablet ? 22 : 20),
        const SizedBox(width: 7),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF202322),
            fontSize: responsive.isTablet ? 19 : 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DashboardService {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const _DashboardService({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

class _DashboardNewsShareButton extends StatelessWidget {
  const _DashboardNewsShareButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x0FD62828),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x2ED62828)),
          ),
          child: const Icon(
            Icons.ios_share_rounded,
            color: Color(0xFFD62828),
            size: 17,
          ),
        ),
      ),
    );
  }
}

class _WalletMiniature extends StatefulWidget {
  const _WalletMiniature({required this.usuario, this.compact = false});

  final UsuarioCarteira? usuario;
  final bool compact;

  @override
  State<_WalletMiniature> createState() => _WalletMiniatureState();
}

class _WalletMiniatureState extends State<_WalletMiniature>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.compact ? 48.0 : 56.0;
    final height = widget.compact ? 62.0 : 72.0;

    return Transform.rotate(
      angle: -0.025,
      child: SizedBox(
        width: width,
        height: height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final angle = _flipAngle(_controller.value);
            final normalizedAngle = angle % (math.pi * 2);
            final showBack =
                normalizedAngle > math.pi / 2 &&
                normalizedAngle < math.pi * 1.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0018)
                ..rotateY(angle),
              child: showBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: _buildBack(),
                    )
                  : _buildFront(),
            );
          },
        ),
      ),
    );
  }

  double _flipAngle(double value) {
    const frontHoldEnd = 0.34;
    const toBackEnd = 0.48;
    const backHoldEnd = 0.82;
    const toFrontEnd = 0.96;

    if (value < frontHoldEnd) return 0;
    if (value < toBackEnd) {
      final t = (value - frontHoldEnd) / (toBackEnd - frontHoldEnd);
      return Curves.easeInOut.transform(t) * math.pi;
    }
    if (value < backHoldEnd) return math.pi;
    if (value < toFrontEnd) {
      final t = (value - backHoldEnd) / (toFrontEnd - backHoldEnd);
      return math.pi + Curves.easeInOut.transform(t) * math.pi;
    }
    return math.pi * 2;
  }

  Widget _buildFront() {
    return _MiniCardShell(
      compact: widget.compact,
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/brasao_mppb_sem_fundo.png',
              width: 12,
              height: 12,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 9,
            right: 9,
            top: 24,
            child: Center(child: _WalletMiniPhoto(url: widget.usuario?.foto)),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 8,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x1A8F2A1D),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _MiniCardShell(
      compact: widget.compact,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Icon(
              Icons.qr_code_2_rounded,
              color: const Color(0xFF8F2A1D).withValues(alpha: 0.72),
              size: 28,
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 19,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0x338F2A1D),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0x228F2A1D),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCardShell extends StatelessWidget {
  const _MiniCardShell({required this.child, this.compact = false});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 48.0 : 56.0;
    final height = compact ? 62.0 : 72.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EC),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E101828),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFBF5), Color(0xFFEED6C0)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/brasao_mppb_sem_fundo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _WalletMiniPhoto extends StatelessWidget {
  const _WalletMiniPhoto({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final photoUrl = url?.trim();
    final fallback = Container(
      color: const Color(0xFFE9EDF0),
      child: const Icon(
        Icons.person_rounded,
        color: Color(0xFF697370),
        size: 18,
      ),
    );

    return Container(
      width: 26,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24101828),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl == null || photoUrl.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => fallback,
              errorWidget: (context, url, error) => fallback,
            ),
    );
  }
}

class _BiometricPromptDialog extends StatelessWidget {
  const _BiometricPromptDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F6),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE9EDF0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24101828),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x14D62828),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x33D62828)),
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    color: Color(0xFFD62828),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Habilitar biometria',
                        style: TextStyle(
                          color: Color(0xFF202322),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Use biometria ou Face ID para acessar o app sem digitar sua senha nos próximos acessos.',
                        style: TextStyle(
                          color: Color(0xFF697370),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF202322),
                      side: const BorderSide(color: Color(0x33202322)),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Agora não'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD62828),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: const Text('Habilitar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

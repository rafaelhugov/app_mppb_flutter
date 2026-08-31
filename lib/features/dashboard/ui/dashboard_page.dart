import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import '../../carteira/providers/carteira_provider.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/ui/main_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../noticias/providers/noticia_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  Timer? _autoPlayTimer;
  int _currentNewsIndex = 0;
  int _carouselNewsCount = 0;

  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnimation;

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
      builder: (ctx) => AlertDialog(
        title: const Text('Habilitar Biometria'),
        content: const Text(
          'Deseja habilitar o login por biometria ou FaceID para não precisar digitar sua senha nos próximos acessos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Agora não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Habilitar'),
          ),
        ],
      ),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometria habilitada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
    _pageController.dispose();
    super.dispose();
  }

  void _syncAutoPlay(int itemCount) {
    if (_carouselNewsCount == itemCount && _autoPlayTimer != null) {
      return;
    }

    _carouselNewsCount = itemCount;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;

    if (itemCount < 2) {
      return;
    }

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final nextPage = (_currentNewsIndex + 1) % itemCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _openNews(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
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
    final carouselNews = todasNoticias.take(3).toList();
    _syncAutoPlay(carouselNews.length);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: MainLayout.authenticatedHorizontalPadding,
          right: MainLayout.authenticatedHorizontalPadding,
          top: MainLayout.authenticatedContentTopPadding(context),
          bottom: MainLayout.contentBottomPadding(context),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 4, 2, 2),
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
                            style: const TextStyle(
                              color: Color(0xFF202322),
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // WALLET CARD
                InkWell(
                  onTap: () => context.go('/carteira'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Carteira Funcional',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(right: 88),
                                  child: Text(
                                    userRole,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFDDE4DF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
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
                                    const Text(
                                      'Ativa e segura',
                                      style: TextStyle(
                                        color: Color(0xFFDDE4DF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Text(
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                if (isOnline) ...[
                  const Row(
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Serviços',
                        style: TextStyle(
                          color: Color(0xFF202322),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  GridView(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          mainAxisExtent: 92,
                        ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildServiceCard(
                        context,
                        'Certidão',
                        'Extrajudicial',
                        Icons.verified_outlined,
                        '/certidao-extrajudicial',
                      ),
                      _buildServiceCard(
                        context,
                        'Contracheque',
                        'Demonstrativo',
                        Icons.receipt_long_rounded,
                        '/contracheque',
                      ),
                      _buildServiceCard(
                        context,
                        'Designações',
                        'Ativas',
                        Icons.assignment_ind,
                        '/designacoes',
                      ),
                      _buildServiceCard(
                        context,
                        'Diário Oficial',
                        'Publicações',
                        Icons.article,
                        '/diario_oficial',
                      ),
                      _buildServiceCard(
                        context,
                        'Folga',
                        'Concessões',
                        Icons.event_available_rounded,
                        '/concessao-folga',
                      ),
                      _buildServiceCard(
                        context,
                        'Ouvidoria',
                        'Manifestações',
                        Icons.record_voice_over,
                        '/ouvidoria',
                      ),
                      _buildServiceCard(
                        context,
                        'Pagamentos',
                        'Área Financeira',
                        Icons.assignment,
                        '/pagamentos',
                      ),
                      _buildServiceCard(
                        context,
                        'Processos',
                        'Consulta',
                        Icons.gavel,
                        '/processos',
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

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
                  const SizedBox(height: 16),

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
                      height: 380,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: carouselNews.length,
                        padEnds: false,
                        onPageChanged: (index) {
                          setState(() {
                            _currentNewsIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final noticia = carouselNews[index];
                          String dateFormatted = noticia.dataPublicacao ?? '';
                          final parts = dateFormatted.split(' ');
                          if (parts.length > 1) {
                            dateFormatted = '${parts[0]}, ${parts[1]}';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // IMAGE
                                  Expanded(
                                    flex: 9,
                                    child: GestureDetector(
                                      onTap: () => _openNews(noticia.link),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
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
                                          image:
                                              noticia.imagemUrl != null &&
                                                  noticia.imagemUrl!.isNotEmpty
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    noticia.imagemUrl!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child:
                                            (noticia.imagemUrl == null ||
                                                noticia.imagemUrl!.isEmpty)
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
                                    flex: 11,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 18,
                                        right: 16,
                                        top: 16,
                                        bottom: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 7,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0x1FD62828),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              (noticia.categoria ?? 'Destaque')
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Color(0xFFD62828),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.2,
                                                height: 1.0,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            dateFormatted,
                                            style: const TextStyle(
                                              color: Color(0xFF697370),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            noticia.titulo,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF202322),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              height: 1.18,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: Text(
                                              noticia.resumo ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF697370),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // ACTIONS
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 18,
                                      right: 16,
                                      bottom: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 136,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _openNews(noticia.link),
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
                                              minimumSize: const Size(0, 32),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              textStyle: const TextStyle(
                                                fontSize: 11.5,
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
                    // DOTS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        carouselNews.length,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
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
                right: -15,
                bottom: -22,
                child: Icon(icon, color: const Color(0x24343A40), size: 86),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF697370),
                        fontSize: 9.5,
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
}

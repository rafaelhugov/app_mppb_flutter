import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import '../../carteira/providers/carteira_provider.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/storage/secure_storage.dart';
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
  int _currentNewsIndex = 0;

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
    _blinkController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _openNews(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final carteiraState = ref.watch(carteiraProvider);
    final hasInternet = ref.watch(connectivityProvider);
    final isOnline = hasInternet;
    final usuario = carteiraState.data;

    final firstName =
        usuario?.nome
            ?.split(' ')
            .firstWhere((e) => e.isNotEmpty, orElse: () => 'Usuário') ??
        'Usuário';
    final userRole = usuario?.cargo ?? 'Membro ou Servidor';

    final noticiaState = ref.watch(noticiaProvider);
    final todasNoticias = noticiaState.noticias;
    final carouselNews = todasNoticias.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x33523829), Color(0x00523829)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: 116,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x3DD6A92F)),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF241D19),
                          Color(0xFF3A241D),
                          Color(0xFF8F2A1D),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 0.48, 1.0],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x332E1E16),
                          blurRadius: 34,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SERVIÇOS AO SERVIDOR MPPB',
                              style: TextStyle(
                                color: Color(0xFFE3C474),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.9,
                              ),
                            ),
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                text: 'Bem-vindo,\n',
                                style: const TextStyle(
                                  color: Color(0xFFFFF8EA),
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 1.18,
                                ),
                                children: [
                                  TextSpan(
                                    text: firstName.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFE5B84C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Acesse seus serviços funcionais em um só lugar.',
                              style: TextStyle(
                                color: Color(0xFFD8C5AA),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // WALLET CARD
                  InkWell(
                    onTap: () => context.go('/carteira'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 172),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x3DD6A92F)),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2E2722),
                            Color(0xFF201A16),
                            Color(0xFF3A241D),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 0.54, 1.0],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x332E1E16),
                            blurRadius: 32,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'DOCUMENTO DIGITAL',
                                style: TextStyle(
                                  color: Color(0xFFCDBDA9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.9,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Carteira Funcional',
                                style: TextStyle(
                                  color: Color(0xFFFFF8EA),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                userRole.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFE5B84C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  FadeTransition(
                                    opacity: _blinkAnimation,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE5B84C),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Ativa e segura',
                                    style: TextStyle(
                                      color: Color(0xFFD8C5AA),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5B84C),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.badge,
                                color: Color(0xFF241D19),
                                size: 30,
                              ),
                            ),
                          ),
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: Row(
                              children: [
                                Text(
                                  'Acessar',
                                  style: TextStyle(
                                    color: Color(0xFFE5B84C),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFFE5B84C),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (isOnline) ...[
                    // NOTÍCIAS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Notícias',
                          style: TextStyle(
                            color: Color(0xFF2F2923),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/noticias'),
                          child: const Text(
                            'Ver todas',
                            style: TextStyle(
                              color: Color(0xFF8F2A1D),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (noticiaState.isLoading && carouselNews.isEmpty)
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8F2A1D),
                          ),
                        ),
                      )
                    else if (carouselNews.isEmpty)
                      Container(
                        constraints: const BoxConstraints(minHeight: 108),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7EFE3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x599C7A54)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.newspaper,
                              color: Color(0xFF8F2A1D),
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Nenhuma notícia disponível no momento.',
                                style: TextStyle(color: Color(0xFF73543E)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      SizedBox(
                        height: 420,
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
                                  color: const Color(0xFFF7EFE3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0x599C7A54),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x24432B1D),
                                      blurRadius: 30,
                                      offset: Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // IMAGE
                                    Expanded(
                                      flex: 9,
                                      child: GestureDetector(
                                        onTap: () => _openNews(noticia.link),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF2E2722),
                                                Color(0xFF3A241D),
                                                Color(0xFF8F2A1D),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            image:
                                                noticia.imagemUrl != null &&
                                                    noticia
                                                        .imagemUrl!
                                                        .isNotEmpty
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
                                                    color: Color(0xFFE5B84C),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 9,
                                                    vertical: 7,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2E2722),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                (noticia.categoria ??
                                                        'Destaque')
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Color(0xFFE5B84C),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.6,
                                                  height: 1.0,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              dateFormatted,
                                              style: const TextStyle(
                                                color: Color(0xFF806F5E),
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
                                                color: Color(0xFF2F2923),
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
                                                  color: Color(0xFF73543E),
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
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  _openNews(noticia.link),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF8F2A1D,
                                                ),
                                                foregroundColor: const Color(
                                                  0xFFFFF8EA,
                                                ),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                minimumSize: const Size(0, 40),
                                                textStyle: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              child: const FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text('Ler notícia'),
                                                    SizedBox(width: 6),
                                                    Icon(
                                                      Icons.open_in_new,
                                                      size: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () =>
                                                context.go('/noticias'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFEAD4A3,
                                              ),
                                              foregroundColor: const Color(
                                                0xFF5C3C22,
                                              ),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              minimumSize: const Size(0, 40),
                                              textStyle: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            child: const Text('Todas'),
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
                                  ? const Color(0xFF8F2A1D)
                                  : const Color(0x338F2A1D),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // SERVIÇOS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Serviços',
                          style: TextStyle(
                            color: Color(0xFF2F2923),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          '5 atalhos',
                          style: TextStyle(
                            color: Color(0xFF73543E),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.9,
                      children: [
                        _buildServiceCard(
                          context,
                          'Contracheque',
                          'Consulta mensal',
                          Icons.receipt_long,
                          '/contracheque',
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
                          'Concessões',
                          'Consulta',
                          Icons.event_available,
                          '/concessao-folga',
                        ),
                        _buildServiceCard(
                          context,
                          'Processos',
                          'Consulta',
                          Icons.gavel,
                          '/processos',
                        ),
                        _buildServiceCard(
                          context,
                          'Diário Oficial',
                          'Publicações',
                          Icons.article,
                          '/diario_oficial',
                        ),
                      ],
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.wifi_off,
                              color: Color(0xFF806F5E),
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Você está offline',
                              style: TextStyle(
                                color: Color(0xFF2F2923),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Serviços online indisponíveis.\nAcesse sua Carteira Funcional acima.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF806F5E),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EFE3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x599C7A54)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1E432B1D),
              blurRadius: 26,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEAD4A3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF8F2A1D), size: 20),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF2F2923),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF806F5E),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8F2A1D),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

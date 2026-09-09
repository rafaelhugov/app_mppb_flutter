import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/responsive_layout.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../noticias/providers/noticia_provider.dart';
import '../../noticias/ui/widgets/news_carousel.dart';
import '../../contatos/ui/widgets/secao_institucional.dart';

class PublicDashboardPage extends ConsumerWidget {
  const PublicDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = MppbResponsive.of(context);
    final isTablet = responsive.isTablet;
    final isWide = responsive.usesWideLayout;
    final horizontalPadding = _dashboardHorizontalPadding(responsive);
    final serviceColumns = isTablet && responsive.isLandscape
        ? 6
        : responsive.gridColumns;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(connectivityProvider.notifier).refresh();
          await ref.read(noticiaProvider.notifier).fetchNoticias();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top,
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
                  Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: isTablet ? 22 : 16,
                      bottom: isTablet ? 20 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo',
                          style: TextStyle(
                            color: const Color(0xFF202322),
                            fontSize: isWide ? 30 : 24,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: isTablet ? 6 : 4),
                        Text(
                          'Acesse os principais serviços do Ministério Público da Paraíba.',
                          style: TextStyle(
                            color: const Color(0xFF697370),
                            fontSize: isTablet ? 14 : 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              color: const Color(0xFF2563EB),
                              size: isTablet ? 23 : 21,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Serviços ao Cidadão',
                              style: TextStyle(
                                color: const Color(0xFF202322),
                                fontSize: isTablet ? 24 : 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 24 : 22),

                        GridView(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: serviceColumns,
                                crossAxisSpacing:
                                    isTablet && responsive.isLandscape ? 8 : 12,
                                mainAxisSpacing:
                                    isTablet && responsive.isLandscape ? 8 : 12,
                                mainAxisExtent:
                                    isTablet && responsive.isLandscape
                                    ? 96
                                    : isTablet
                                    ? 128
                                    : 140,
                              ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildSmallCard(
                              context,
                              'Certidão',
                              'Extrajudicial',
                              Icons.verified_outlined,
                              '/certidao-extrajudicial',
                              backgroundIcon: true,
                            ),
                            _buildSmallCard(
                              context,
                              'Diário Oficial',
                              'Atos e editais',
                              Icons.description,
                              '/diario_oficial',
                              backgroundIcon: true,
                            ),
                            _buildSmallCard(
                              context,
                              'Notícias',
                              'Fique por dentro',
                              Icons.newspaper,
                              '/noticias',
                              backgroundIcon: true,
                            ),
                            _buildSmallCard(
                              context,
                              'Ouvidoria',
                              'Manifestações',
                              Icons.record_voice_over,
                              '/ouvidoria',
                              backgroundIcon: true,
                            ),
                            _buildSmallCard(
                              context,
                              'Processos',
                              'Andamentos',
                              Icons.manage_search,
                              '/processos',
                              backgroundIcon: true,
                            ),
                            _buildSmallCard(
                              context,
                              'Contatos',
                              'Atendimento',
                              Icons.contact_support_outlined,
                              '/contatos',
                              backgroundIcon: true,
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 44 : 48),

                        Row(
                          children: [
                            Icon(
                              Icons.newspaper_rounded,
                              color: const Color(0xFFD62828),
                              size: isTablet ? 23 : 21,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Notícias',
                              style: TextStyle(
                                color: const Color(0xFF202322),
                                fontSize: isTablet ? 22 : 20,
                                fontWeight: FontWeight.w800,
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
                                side: const BorderSide(
                                  color: Color(0xFFD62828),
                                ),
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
                        SizedBox(height: isTablet ? 20 : 18),
                        const NewsCarousel(),
                        SizedBox(height: isTablet ? 42 : 48),
                        SecaoInstitucional(compacta: isWide),
                      ],
                    ),
                  ),
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
    return responsive.horizontalPadding;
  }

  Widget _buildSmallCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route, {
    bool backgroundIcon = false,
  }) {
    final responsive = MppbResponsive.of(context);
    final isTablet = responsive.isTablet;
    final isTabletLandscape = isTablet && responsive.isLandscape;

    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE9EDF0)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10101828),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              if (backgroundIcon)
                Positioned(
                  right: isTablet && responsive.isLandscape
                      ? -20
                      : isTablet
                      ? -12
                      : -22,
                  bottom: isTablet && responsive.isLandscape
                      ? -28
                      : isTablet
                      ? -24
                      : -30,
                  child: Icon(
                    icon,
                    color: const Color(0x18343A40),
                    size: isTablet && responsive.isLandscape
                        ? 92
                        : isTablet
                        ? 112
                        : 122,
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(
                  isTabletLandscape
                      ? 12
                      : isTablet
                      ? 18
                      : 16,
                ),
                child: backgroundIcon
                    ? Align(
                        alignment: Alignment.topLeft,
                        child: _buildSmallCardText(context, title, subtitle),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
                              ),
                              border: Border.all(
                                color: const Color(0x70FFDE8E),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x4C24120C),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              icon,
                              color: const Color(0xFF211713),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSmallCardText(context, title, subtitle),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCardText(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final responsive = MppbResponsive.of(context);
    final isTablet = responsive.isTablet;
    final isTabletLandscape = isTablet && responsive.isLandscape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF202322),
            fontSize: isTabletLandscape
                ? 14
                : isTablet
                ? 16
                : 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF697370),
            fontSize: isTabletLandscape
                ? 10.5
                : isTablet
                ? 12
                : 11,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

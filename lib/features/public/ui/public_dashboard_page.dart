import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../noticias/ui/widgets/news_carousel.dart';
import '../../contatos/ui/widgets/secao_institucional.dart';

class PublicDashboardPage extends StatelessWidget {
  const PublicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top,
          bottom: 112,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo',
                        style: TextStyle(
                          color: const Color(0xFF202322),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Acesse os principais serviços do Ministério Público da Paraíba.',
                        style: TextStyle(
                          color: Color(0xFF697370),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.grid_view_rounded,
                            color: Color(0xFF2563EB),
                            size: 21,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Serviços ao Cidadão',
                            style: TextStyle(
                              color: const Color(0xFF202322),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      GridView(
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 140,
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

                      const SizedBox(height: 48),

                      Row(
                        children: [
                          const Icon(
                            Icons.newspaper_rounded,
                            color: Color(0xFFD62828),
                            size: 21,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Notícias',
                            style: TextStyle(
                              color: Color(0xFF202322),
                              fontSize: 20,
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
                      const SizedBox(height: 18),
                      const NewsCarousel(),
                      const SizedBox(height: 48),
                      const SecaoInstitucional(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route, {
    bool backgroundIcon = false,
  }) {
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
                  right: -22,
                  bottom: -30,
                  child: Icon(icon, color: const Color(0x18343A40), size: 122),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: backgroundIcon
                    ? Align(
                        alignment: Alignment.topLeft,
                        child: _buildSmallCardText(title, subtitle),
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
                          _buildSmallCardText(title, subtitle),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCardText(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF202322),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF697370),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

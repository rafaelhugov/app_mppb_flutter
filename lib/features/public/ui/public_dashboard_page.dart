import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../noticias/ui/widgets/news_carousel.dart';

class PublicDashboardPage extends StatelessWidget {
  const PublicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 112),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 44),
                  margin: const EdgeInsets.only(bottom: 34),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF241D19),
                        Color(0xFF3A241D),
                        Color(0xFF8F2A1D),
                      ],
                      stops: [0.0, 0.46, 1.0],
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MPPB+',
                        style: TextStyle(
                          color: Color(0xFFE3C474),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bem-vindo ao MPPB',
                        style: TextStyle(
                          color: Color(0xFFFFF8EA),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Acesse de forma rápida e transparente os principais serviços do Ministério Público da Paraíba.',
                        style: TextStyle(
                          color: Color(0xFFD8C5AA),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Serviços ao Cidadão
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.public, color: Color(0xFF8F2A1D), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Serviços ao Cidadão',
                            style: TextStyle(
                              color: const Color(0xFF241D19),
                              fontFamily: GoogleFonts.ebGaramond().fontFamily,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Grid de Serviços (Cards Menores)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth > 720;
                          if (isDesktop) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _buildProcessosCard(context)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildDiarioCard(context)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(child: _buildOuvidoriaCard(context)),
                                    const SizedBox(width: 16),
                                    const Spacer(),
                                  ],
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              _buildOuvidoriaCard(context),
                              const SizedBox(height: 16),
                              _buildProcessosCard(context),
                              const SizedBox(height: 16),
                              _buildDiarioCard(context),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 36),

                      // Notícias (Ocupa a largura inteira)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            'Notícias',
                            style: TextStyle(
                              color: Color(0xFF241D19),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.push('/noticias'),
                            child: const Text(
                              'Ver todas',
                              style: TextStyle(
                                color: Color(0xFF8F2A1D),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const NewsCarousel(),

                      const SizedBox(height: 36),

                      // Membros e Servidores Section
                      Row(
                        children: [
                          const Icon(Icons.admin_panel_settings, color: Color(0xFF8F2A1D), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Membros e Servidores',
                            style: TextStyle(
                              color: const Color(0xFF241D19),
                              fontFamily: GoogleFonts.ebGaramond().fontFamily,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Card Área Restrita
                      _buildRestritoCard(context),
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

  Widget _buildOuvidoriaCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/ouvidoria'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF38312A), Color(0xFF241D19)],
          ),
          border: Border.all(color: Colors.white.withAlpha(13)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x1E2F2923), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
                ),
                border: Border.all(color: const Color(0x70FFDE8E)),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x4C24120C), blurRadius: 28, offset: Offset(0, 12)),
                ],
              ),
              child: const Icon(Icons.record_voice_over, color: Color(0xFF211713), size: 26),
            ),
            const SizedBox(height: 20),
            Text(
              'Ouvidoria',
              style: TextStyle(
                color: const Color(0xFFFFF8EA),
                fontFamily: GoogleFonts.ebGaramond().fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registre sua manifestação, denúncia ou solicitação ao MPPB.',
              style: TextStyle(
                color: Color(0xFFC4BBA9),
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessosCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/processos'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF38312A), Color(0xFF241D19)],
          ),
          border: Border.all(color: Colors.white.withAlpha(13)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x1E2F2923), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
                ),
                border: Border.all(color: const Color(0x70FFDE8E)),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x4C24120C), blurRadius: 28, offset: Offset(0, 12)),
                ],
              ),
              child: const Icon(Icons.manage_search, color: Color(0xFF211713), size: 26),
            ),
            const SizedBox(height: 20),
            Text(
              'Consulta de Processos',
              style: TextStyle(
                color: const Color(0xFFFFF8EA),
                fontFamily: GoogleFonts.ebGaramond().fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Acompanhe o andamento de procedimentos e processos.',
              style: TextStyle(
                color: Color(0xFFC4BBA9),
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiarioCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/diario_oficial'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF38312A), Color(0xFF241D19)],
          ),
          border: Border.all(color: Colors.white.withAlpha(13)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x1E2F2923), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
                ),
                border: Border.all(color: const Color(0x70FFDE8E)),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x4C24120C), blurRadius: 28, offset: Offset(0, 12)),
                ],
              ),
              child: const Icon(Icons.description, color: Color(0xFF211713), size: 26),
            ),
            const SizedBox(height: 20),
            Text(
              'Diário Oficial',
              style: TextStyle(
                color: const Color(0xFFFFF8EA),
                fontFamily: GoogleFonts.ebGaramond().fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Publicações oficiais, atos e editais do MPPB.',
              style: TextStyle(
                color: Color(0xFFC4BBA9),
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildRestritoCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/login'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF38312A), Color(0xFF241D19)],
          ),
          border: Border.all(color: Colors.white.withAlpha(13)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x1E2F2923), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
                ),
                border: Border.all(color: const Color(0x70FFDE8E)),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x4C24120C), blurRadius: 28, offset: Offset(0, 12)),
                ],
              ),
              child: const Icon(Icons.lock, color: Color(0xFF211713), size: 26),
            ),
            const SizedBox(height: 20),
            Text(
              'Serviços ao servidor',
              style: TextStyle(
                color: const Color(0xFFFFF8EA),
                fontFamily: GoogleFonts.ebGaramond().fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Acesse sua carteira funcional e outros serviços internos.',
              style: TextStyle(
                color: Color(0xFFC4BBA9),
                fontSize: 16,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8F2A1D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Fazer Login', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.login, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
